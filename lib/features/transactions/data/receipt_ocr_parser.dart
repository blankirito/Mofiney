import '../domain/receipt_ocr_draft.dart';

class ReceiptOcrParser {
  const ReceiptOcrParser._();

  static ReceiptOcrDraft parse(String rawText) {
    final lines = rawText
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final merchant = lines.isEmpty ? '' : lines.first;

    final dateLine = lines.cast<String?>().firstWhere(
      (line) => line != null && _parseDate(line) != null,
      orElse: () => null,
    );

    final totalLine = lines.cast<String?>().firstWhere(
      (line) => line != null && _isTotalLine(line),
      orElse: () => null,
    );

    final date = dateLine == null ? null : _parseDate(dateLine);
    final amount = totalLine == null ? null : _parseAmount(totalLine);

    final noteLines = lines.where((line) {
      return line != merchant &&
          line != dateLine &&
          line != totalLine &&
          !_isMoneySummaryLine(line);
    }).toList();

    return ReceiptOcrDraft(
      merchant: merchant,
      date: date,
      amount: amount,
      note: noteLines.join('\n'),
      rawText: rawText,
    );
  }

  static bool _isTotalLine(String line) {
    return RegExp(
      r'\b(?:GRAND\s+)?TOTAL\b|\bAMOUNT\s+DUE\b|总计|合计|应付',
      caseSensitive: false,
    ).hasMatch(line);
  }

  static bool _isMoneySummaryLine(String line) {
    return RegExp(
      r'\bSUBTOTAL\b|\bTOTAL\b|\bCASH\b|\bCHANGE\b',
      caseSensitive: false,
    ).hasMatch(line);
  }

  static DateTime? _parseDate(String line) {
    final chineseDateMatch = RegExp(
      r'(\d{4})\s*年\s*(\d{1,2})\s*月\s*(\d{1,2})\s*日?',
    ).firstMatch(line);

    if (chineseDateMatch != null) {
      return _createValidDate(
        int.parse(chineseDateMatch.group(1)!),
        int.parse(chineseDateMatch.group(2)!),
        int.parse(chineseDateMatch.group(3)!),
      );
    }

    final isoMatch = RegExp(r'(\d{4})[/-](\d{1,2})[/-](\d{1,2})')
        .firstMatch(line);

    if (isoMatch != null) {
      return _createValidDate(
        int.parse(isoMatch.group(1)!),
        int.parse(isoMatch.group(2)!),
        int.parse(isoMatch.group(3)!),
      );
    }

    final dayMonthYearMatch = RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{4})')
        .firstMatch(line);

    if (dayMonthYearMatch == null) {
      return null;
    }

    return _createValidDate(
      int.parse(dayMonthYearMatch.group(3)!),
      int.parse(dayMonthYearMatch.group(2)!),
      int.parse(dayMonthYearMatch.group(1)!),
    );
  }

  static DateTime? _createValidDate(int year, int month, int day) {
    final date = DateTime(year, month, day);

    return date.year == year && date.month == month && date.day == day
        ? date
        : null;
  }

  static double? _parseAmount(String line) {
    final match = RegExp(r'(\d[\d,]*\.\d{2})').firstMatch(line);

    if (match == null) {
      return null;
    }

    return double.tryParse(match.group(1)!.replaceAll(',', ''));
  }
}
