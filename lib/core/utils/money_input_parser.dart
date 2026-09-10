class MoneyInputParser {
  const MoneyInputParser._();

  static final RegExp _validFormat = RegExp(
    r'^(?:\d{1,3}(?:,\d{3})+|\d+)(?:\.\d{1,2})?$',
  );

  static double? parse(String input) {
    final value = input
    .trim()
    .replaceAll('，', ',')
    .replaceAll('．', '.');

    if (value.isEmpty || !_validFormat.hasMatch(value)) {
      return null;
    }

    return double.tryParse(value.replaceAll(',', ''));
  }
}
