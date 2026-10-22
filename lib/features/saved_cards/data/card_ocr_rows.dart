import 'dart:math' as math;

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'card_text_parser.dart';
import 'saved_card.dart';

List<String> cardOcrReadingRows(RecognizedText result) {
  final detected = <TextLine>[];

  for (final block in result.blocks) {
    for (final line in block.lines) {
      if (line.text.trim().isNotEmpty) {
        detected.add(line);
      }
    }
  }

  detected.sort(
    (a, b) => a.boundingBox.center.dy.compareTo(
      b.boundingBox.center.dy,
    ),
  );

  final groups = <List<TextLine>>[];

  for (final line in detected) {
    if (groups.isEmpty) {
      groups.add([line]);
      continue;
    }

    final last = groups.last;

    final centerY =
        last.map((item) => item.boundingBox.center.dy).reduce((a, b) => a + b) /
            last.length;

    final tolerance = math.max(
      7.0,
      math.max(
            last.first.boundingBox.height,
            line.boundingBox.height,
          ) *
          0.65,
    );

    if ((line.boundingBox.center.dy - centerY).abs() <= tolerance) {
      last.add(line);
    } else {
      groups.add([line]);
    }
  }

  final rows = <String>[];

  for (final group in groups) {
    group.sort(
      (a, b) => a.boundingBox.left.compareTo(
        b.boundingBox.left,
      ),
    );

    final combined = group
        .map((line) => line.text.trim())
        .where((text) => text.isNotEmpty)
        .join(' ');

    if (combined.isNotEmpty) {
      rows.add(combined);
    }
  }

  for (final line in detected) {
    rows.add(line.text.trim());
  }

  return rows;
}

String? verifiedOcrCardNumber(
  ScannedCard parsed,
  List<String> lines,
) {
  final parsedNumber = parsed.number;

  if (parsedNumber != null && CardRules.luhnValid(parsedNumber)) {
    return parsedNumber;
  }

  const replacements = <String, String>{
    'O': '0',
    'o': '0',
    'D': '0',
    'Q': '0',
    'I': '1',
    'i': '1',
    'l': '1',
    '|': '1',
    'Z': '2',
    'z': '2',
    'S': '5',
    's': '5',
    'B': '8',
    'G': '6',
  };

  final pattern = RegExp(
    r'[0-9OoDQIil|ZzSsBG]+'
    r'(?:[ \t-]+[0-9OoDQIil|ZzSsBG]+)*',
  );

  final candidates = <String>{};

  for (final line in lines) {
    for (final match in pattern.allMatches(line)) {
      final raw = match.group(0)!;

      final compact = raw.replaceAll(
        RegExp(r'[\s-]'),
        '',
      );

      if (compact.length < 13 || compact.length > 19) {
        continue;
      }

      final realDigitCount = RegExp(
        r'[0-9]',
      ).allMatches(compact).length;

      if (realDigitCount < 10) {
        continue;
      }

      final digits =
          compact.split('').map((char) => replacements[char] ?? char).join();

      if (CardRules.luhnValid(digits)) {
        candidates.add(digits);
      }
    }
  }

  if (candidates.isEmpty) {
    return null;
  }

  final ranked = candidates.toList()
    ..sort((a, b) {
      final aScore = (a.length - 16).abs();
      final bScore = (b.length - 16).abs();

      return aScore.compareTo(bScore);
    });

  return ranked.first;
}
