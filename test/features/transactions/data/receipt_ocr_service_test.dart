import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mofiney/features/transactions/data/receipt_ocr_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('mofiney/receipt_ocr');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('sends image path to Android OCR and parses returned text', () async {
    String? receivedImagePath;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'recognizeReceipt');

          final arguments = Map<String, dynamic>.from(call.arguments as Map);
          receivedImagePath = arguments['imagePath'] as String?;

          return {
            'latinText': '''
JAYA GROCER
05/09/2026
TOTAL RM 25.50
Milk
''',
            'chineseText': '全家便利店',
          };
        });

    final result = await ReceiptOcrService().recognize(
      '/temporary/receipt.jpg',
    );

    expect(receivedImagePath, '/temporary/receipt.jpg');
    expect(result.merchant, 'JAYA GROCER');
    expect(result.date, DateTime(2026, 9, 5));
    expect(result.amount, 25.50);
    expect(result.note, contains('全家便利店'));
  });
}
