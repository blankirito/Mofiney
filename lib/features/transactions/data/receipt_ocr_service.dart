import 'package:flutter/services.dart';

import '../domain/receipt_ocr_draft.dart';
import 'receipt_ocr_parser.dart';

class ReceiptOcrException implements Exception {
  const ReceiptOcrException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ReceiptOcrService {
  ReceiptOcrService({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('mofiney/receipt_ocr');

  final MethodChannel _channel;

  Future<ReceiptOcrDraft> recognize(String imagePath) async {
    try {
      final response = await _channel.invokeMethod<dynamic>(
        'recognizeReceipt',
        {'imagePath': imagePath},
      );

      if (response is! Map) {
        throw const ReceiptOcrException(
          'Receipt OCR returned an invalid response.',
        );
      }

      final latinText = response['latinText'];
      final chineseText = response['chineseText'];

      if (latinText is! String || chineseText is! String) {
        throw const ReceiptOcrException(
          'Receipt OCR returned incomplete text.',
        );
      }

      final textParts = <String>[];

      if (latinText.trim().isNotEmpty) {
        textParts.add(latinText.trim());
      }

      if (chineseText.trim().isNotEmpty &&
          !textParts.contains(chineseText.trim())) {
        textParts.add(chineseText.trim());
      }

      final rawText = textParts.join('\n');

      if (rawText.isEmpty) {
        throw const ReceiptOcrException('No text was found on this receipt.');
      }

      return ReceiptOcrParser.parse(rawText);
    } on PlatformException catch (error) {
      throw ReceiptOcrException(
        error.message ?? 'Could not read this receipt.',
      );
    }
  }
}
