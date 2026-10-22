import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../data/card_ocr_rows.dart';
import '../data/card_scan_state.dart';
import '../data/card_text_parser.dart';
import 'card_scan_review_page.dart';

/// Debug-only, on-device scanner. It never writes a camera image to disk.
class CardCameraScanPage extends StatefulWidget {
  const CardCameraScanPage({super.key});

  @override
  State<CardCameraScanPage> createState() => _CardCameraScanPageState();
}

class _CardCameraScanPageState extends State<CardCameraScanPage> {
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final _scanState = CardScanState();
  CameraController? _controller;
  ScannedCard? _latest;
  DateTime _lastFrame = DateTime.fromMillisecondsSinceEpoch(0);
  bool _processing = false;
  bool _streaming = false;
  bool _navigating = false;
  bool _disposed = false;
  bool _torch = false;
  String? _problem;

  static const _frameInterval = Duration(milliseconds: 550);

  @override
  void initState() {
    super.initState();
    if (kDebugMode) unawaited(_initialize());
  }

  Future<void> _initialize() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return _showProblem('الكاميرا مش متوفرة على الجهاز');
      final camera = cameras.firstWhere(
        (item) => item.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        // The only direct frame formats accepted by ML Kit in this integration.
        imageFormatGroup:
            Platform.isIOS ? ImageFormatGroup.bgra8888 : ImageFormatGroup.nv21,
      );
      _controller = controller;
      await controller.initialize();
      if (!mounted || _disposed) {
        await controller.dispose();
        return;
      }
      setState(() {});
      await _startStream();
    } catch (_) {
      _showProblem('تعذر فتح الكاميرا. تأكد من السماح باستخدامها.');
    }
  }

  Future<void> _startStream() async {
    final controller = _controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        _streaming ||
        _disposed) return;
    try {
      await controller.startImageStream(_onFrame);
      _streaming = true;
    } catch (_) {
      _showProblem('تعذر تشغيل قراءة البطاقة المباشرة. استخدم الإدخال اليدوي.');
    }
  }

  Future<void> _stopStream() async {
    final controller = _controller;
    if (controller == null || !_streaming) return;
    _streaming = false;
    try {
      await controller.stopImageStream();
    } catch (_) {
      // Camera teardown may already have stopped the native stream.
    }
  }

  void _onFrame(CameraImage image) {
    if (_disposed || _navigating || _processing) return;
    final now = DateTime.now();
    if (now.difference(_lastFrame) < _frameInterval) return;
    _lastFrame = now;
    unawaited(_recognize(image));
  }

  Future<void> _recognize(CameraImage image) async {
    final controller = _controller;
    if (controller == null || _processing || _disposed || _navigating) return;
    final input = _inputImage(image, controller);
    if (input == null) return;
    _processing = true;
    try {
      final result = await _recognizer.processImage(input);
      if (!mounted || _disposed || _navigating) return;
      final reading = parseCardText(cardOcrReadingRows(result));
      final accepted = _scanState.observe(reading);
      setState(() {
        _latest = reading;
        _problem = null;
      });
      if (accepted != null) await _openReview(accepted);
    } catch (_) {
      // OCR failures are expected under glare/motion. Never log sensitive text.
    } finally {
      _processing = false;
    }
  }

  InputImage? _inputImage(CameraImage image, CameraController controller) {
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    final rotation = _rotation(controller);
    final supported = Platform.isIOS
        ? format == InputImageFormat.bgra8888
        : format == InputImageFormat.nv21;
    if (format == null ||
        rotation == null ||
        !supported ||
        image.planes.length != 1) return null;
    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  InputImageRotation? _rotation(CameraController controller) {
    final camera = controller.description;
    if (Platform.isIOS)
      return InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    const deviceTurns = <DeviceOrientation, int>{
      DeviceOrientation.portraitUp: 0,
      DeviceOrientation.landscapeLeft: 90,
      DeviceOrientation.portraitDown: 180,
      DeviceOrientation.landscapeRight: 270,
    };
    var turn = deviceTurns[controller.value.deviceOrientation];
    if (turn == null) return null;
    turn = camera.lensDirection == CameraLensDirection.front
        ? (camera.sensorOrientation + turn) % 360
        : (camera.sensorOrientation - turn + 360) % 360;
    return InputImageRotationValue.fromRawValue(turn);
  }

  Future<void> _openReview(ScannedCard scanned) async {
    if (_navigating || _disposed) return;
    _navigating = true;
    await _stopStream();
    if (!mounted || _disposed) return;
    final result = await Navigator.of(context).push<CardScanReviewResult>(
      MaterialPageRoute(builder: (_) => CardScanReviewPage(scanned: scanned)),
    );
    if (!mounted || _disposed) return;
    if (result != null) {
      Navigator.of(context).pop(result);
      return;
    }
    _navigating = false;
    await _startStream();
  }

  Future<void> _manualEntry() => _openReview(ScannedCard.empty);

  Future<void> _toggleTorch() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    try {
      final next = !_torch;
      await controller.setFlashMode(next ? FlashMode.torch : FlashMode.off);
      if (mounted) setState(() => _torch = next);
    } catch (_) {
      _showProblem('الفلاش مش متوفر على الكاميرا');
    }
  }

  void _showProblem(String value) {
    if (mounted && !_disposed) setState(() => _problem = value);
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_stopStream());
    unawaited(_controller?.dispose() ?? Future<void>.value());
    unawaited(_recognizer.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode)
      return const Scaffold(
          body: Center(child: Text('ماسح البطاقة متاح للاختبار فقط')));
    final controller = _controller;
    return Scaffold(
      backgroundColor: const Color(0xff071d13),
      body: Stack(fit: StackFit.expand, children: [
        if (controller != null && controller.value.isInitialized)
          CameraPreview(controller)
        else
          const Center(child: CircularProgressIndicator(color: Colors.white)),
        const IgnorePointer(child: CustomPaint(painter: _CardFramePainter())),
        SafeArea(
            child: Column(children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(children: [
                IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white)),
                const Expanded(
                    child: Text('مسح البطاقة مباشرة',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800))),
                IconButton(
                    onPressed: _toggleTorch,
                    icon: Icon(_torch ? Icons.flash_on : Icons.flash_off,
                        color: Colors.white)),
              ])),
          const Spacer(),
          _Progress(latest: _latest, state: _scanState),
          Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 8),
              child: Text(
                  _problem ??
                      'حط الوجه الأمامي للبطاقة داخل الإطار وثبّتها تحت ضوء واضح.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600))),
          TextButton.icon(
              onPressed: _manualEntry,
              icon:
                  const Icon(Icons.keyboard_alt_outlined, color: Colors.white),
              label: const Text('إدخال البيانات يدوياً',
                  style: TextStyle(color: Colors.white))),
          const SizedBox(height: 20),
        ])),
      ]),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.latest, required this.state});
  final ScannedCard? latest;
  final CardScanState state;
  @override
  Widget build(BuildContext context) {
    final number = latest?.number;
    final masked = number == null || number.length < 4
        ? 'بانتظار القراءة'
        : '**** **** **** ${number.substring(number.length - 4)}';
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(.95),
            borderRadius: BorderRadius.circular(18)),
        child: Column(children: [
          _row(Icons.credit_card_outlined, 'رقم البطاقة', masked,
              state.numberProgress(number), 3),
          const Divider(height: 18),
          _row(
              Icons.person_outline,
              'اسم صاحب البطاقة',
              latest?.holder ?? 'بانتظار القراءة',
              state.holderProgress(latest?.holder),
              2),
          const Divider(height: 18),
          _row(
              Icons.calendar_month_outlined,
              'تاريخ الانتهاء',
              latest?.expiryText ?? 'بانتظار القراءة',
              state.expiryProgress(latest?.expiryMonth, latest?.expiryYear),
              2),
        ]));
  }

  Widget _row(IconData icon, String label, String value, int progress,
          int target) =>
      Row(children: [
        Icon(icon, color: const Color(0xff16874e)),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis)
        ])),
        Text('${progress.clamp(0, target)}/$target',
            style: const TextStyle(
                color: Color(0xff16874e), fontWeight: FontWeight.bold))
      ]);
}

class _CardFramePainter extends CustomPainter {
  const _CardFramePainter();
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width * .88;
    final frame = RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(size.width / 2, size.height * .40),
            width: width,
            height: width / 1.586),
        const Radius.circular(20));
    final overlay = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(frame);
    canvas.drawPath(overlay, Paint()..color = const Color(0xA9000000));
    canvas.drawRRect(
        frame,
        Paint()
          ..color = const Color(0xff53e68c)
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
