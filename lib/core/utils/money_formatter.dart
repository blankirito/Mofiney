class MoneyFormatter {
  const MoneyFormatter._();

  static String format({
    required double amount,
    required String symbol,
    bool showSign = false,
  }) {
    final absoluteAmount = amount.abs();

    final parts = absoluteAmount.toStringAsFixed(2).split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];

    final formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );

    String sign = '';

    if (showSign) {
      if (amount > 0) {
        sign = '+';
      } else if (amount < 0) {
        sign = '−';
      }
    }

    final prefix = sign.isEmpty ? '' : '$sign ';

    return '$prefix$symbol $formattedInteger.$decimalPart';
  }

  static String amountOnly(double amount) {
    final parts = amount.abs().toStringAsFixed(2).split('.');

    final formattedInteger = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );

    return '$formattedInteger.${parts[1]}';
  }
}