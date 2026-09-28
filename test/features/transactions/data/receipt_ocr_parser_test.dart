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
    test('finds a split MIX Store merchant and total from real OCR text', () {
    final result = ReceiptOcrParser.parse('''
Ff9:31
Transaction Details
MIX EMbIRE SDN BHO, (1416523 H)
MiX Store@Sunway Carnivat
(Mall
MIX.STORE
Nett Tota
Subtotal
:2026-09-13 14:43:49
Total
RM
9.80
28.20
Thank You For Shopping With Us!
28.20
Edit Transaction
''');

    expect(result.merchant, 'MiX Store@Sunway Carnivat');
    expect(result.date, DateTime(2026, 9, 13));
    expect(result.amount, 28.20);
  });

  test('parses a split German total and dotted date from real OCR text', () {
    final result = ReceiptOcrParser.parse('''
Ber ghotel
Grosse Scheidegg
Rech. Nr. 4572
Total :
30.07.2007/13:29:17
Tisch 7/01
5.00
à 18.50
CHF
54.50 CHF:
Entspricht in Euro
36.33 EUR
''');

    expect(result.merchant, 'Ber ghotel');
    expect(result.date, DateTime(2007, 7, 30));
    expect(result.amount, 54.50);
  });
    test('prefers a later exact total over an earlier partial net total', () {
    final result = ReceiptOcrParser.parse('''
MiX Store@Sunway Carnivat
2026-09-13
Nett Tota
Subtotal
Product Name
Coupon Applied
Order Discount
Rounding Adjustment
Cashier Name
Membership Points
Thank You For Shopping With Us!
Visit Us Again!
Store Address
Customer Service
Opening Hours
Facebook Mix Store Malaysia
Instagram mixcom.my
Email info@mix.com.my
Total
RM
28.20
28.20
''');

    expect(result.merchant, 'MiX Store@Sunway Carnivat');
    expect(result.date, DateTime(2026, 9, 13));
    expect(result.amount, 28.20);
  });
}
