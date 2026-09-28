import 'package:flutter_test/flutter_test.dart';
import 'package:mofiney/features/transactions/data/receipt_ocr_parser.dart';

void main() {
  test('prefers TOTAL over subtotal, cash, and change', () {
    final result = ReceiptOcrParser.parse('''
JAYA GROCER
05/09/2026
SUBTOTAL RM 20.00
TOTAL RM 25.50
CASH RM 30.00
CHANGE RM 4.50
Milk
Bread
''');

    expect(result.merchant, 'JAYA GROCER');
    expect(result.date, DateTime(2026, 9, 5));
    expect(result.amount, 25.50);
    expect(result.note, contains('Milk'));
  });
  test('parses Chinese merchant, ISO date, and Chinese total label', () {
    final result = ReceiptOcrParser.parse('''
全家便利店
2026-09-05
总计 RM 18.80
矿泉水
面包
''');

    expect(result.merchant, '全家便利店');
    expect(result.date, DateTime(2026, 9, 5));
    expect(result.amount, 18.80);
    expect(result.note, contains('矿泉水'));
  });
  test('parses Chinese written date format', () {
    final result = ReceiptOcrParser.parse('''
茶室
2026年9月5日
应付总额 RM 12.50
海南鸡饭
''');

    expect(result.date, DateTime(2026, 9, 5));
    expect(result.amount, 12.50);
    expect(result.note, contains('海南鸡饭'));
  });
  test('parses a comma-formatted total amount', () {
    final result = ReceiptOcrParser.parse('''
MYDIN
05/09/2026
GRAND TOTAL RM 1,000.50
Rice
''');

    expect(result.amount, 1000.50);
  });

  test('leaves amount null when a receipt has no total', () {
    final result = ReceiptOcrParser.parse('''
Small Cafe
05/09/2026
Coffee
Cake
''');

    expect(result.amount, isNull);
    expect(result.merchant, 'Small Cafe');
  });
}
