import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:image/image.dart' as img;

class CardPhotoCropper {
  const CardPhotoCropper._();

  static Rect cardFrame(Size viewport) {
    final width = viewport.width * 0.88;
    final height = width / 1.586;

    return Rect.fromCenter(
      center: Offset(
        viewport.width / 2,
        viewport.height * 0.44,
      ),
      width: width,
      height: height,
    );
  }

  static Rect imageRegion({
    required Size viewport,
    required Size imageSize,
  }) {
    if (viewport.isEmpty || imageSize.isEmpty) {
      throw ArgumentError('Invalid camera geometry');
    }

    final scale = math.max(
      viewport.width / imageSize.width,
      viewport.height / imageSize.height,
    );

    final scaledWidth = imageSize.width * scale;
    final scaledHeight = imageSize.height * scale;

    final hiddenLeft = (scaledWidth - viewport.width) / 2;
    final hiddenTop = (scaledHeight - viewport.height) / 2;

    final frame = cardFrame(viewport);

    return Rect.fromLTWH(
      (hiddenLeft + frame.left) / scale,
      (hiddenTop + frame.top) / scale,
      frame.width / scale,
      frame.height / scale,
    ).intersect(
      Rect.fromLTWH(
        0,
        0,
        imageSize.width,
        imageSize.height,
      ),
    );
  }

  static Future<String> crop({
    required String originalPath,
    required Size viewport,
  }) async {
    final bytes = await File(originalPath).readAsBytes();
    final decoded = img.decodeImage(bytes);

    if (decoded == null) {
      throw StateError('Could not decode camera image');
    }

    final photo = img.bakeOrientation(decoded);

    final region = imageRegion(
      viewport: viewport,
      imageSize: Size(
        photo.width.toDouble(),
        photo.height.toDouble(),
      ),
    );

    final x = region.left.floor().clamp(0, photo.width - 1);
    final y = region.top.floor().clamp(0, photo.height - 1);

    final width = region.width.ceil().clamp(
          1,
          photo.width - x,
        );

    final height = region.height.ceil().clamp(
          1,
          photo.height - y,
        );

    final cropped = img.copyCrop(
      photo,
      x: x,
      y: y,
      width: width,
      height: height,
    );

    final outputPath = '$originalPath.card-region.jpg';

    await File(outputPath).writeAsBytes(
      img.encodeJpg(cropped, quality: 92),
      flush: true,
    );

    return outputPath;
  }
}
