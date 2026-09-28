import '../domain/receipt_ocr_draft.dart';

class ReceiptOcrParser {
  const ReceiptOcrParser._();

  static ReceiptOcrDraft parse(String rawText) {
    final lines = rawText
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final merchant = _findMerchant(lines);

    String? dateLine;
    DateTime? date;

    for (final line in lines) {
      final parsedDate = _parseDate(line);

      if (parsedDate != null) {
        dateLine = line;
        date = parsedDate;
        break;
      }
    }

    final totalIndex = _findBestTotalIndex(lines);
    final totalLine = totalIndex == -1 ? null : lines[totalIndex];

    final amount = totalIndex == -1
        ? null
        : _findAmountNearTotal(lines, totalIndex);

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

  static String _findMerchant(List<String> lines) {
    final candidates = lines.where(_isMerchantCandidate).take(20).toList();

    if (candidates.isEmpty) {
      return lines.isEmpty ? '' : lines.first;
    }

    final businessName = candidates.where((line) {
      final lowerCase = line.toLowerCase();

      return lowerCase.contains('store') ||
          lowerCase.contains('shop') ||
          lowerCase.contains('mart') ||
          lowerCase.contains('cafe') ||
          lowerCase.contains('restaurant') ||
          lowerCase.contains('hotel') ||
          lowerCase.contains('market');
    }).firstOrNull;

    return businessName ?? candidates.first;
  }

  static bool _isMerchantCandidate(String line) {
    final lowerCase = line.toLowerCase();

    if (line.length < 3 ||
        _parseDate(line) != null ||
        RegExp(r'^[\d\s:/.,-]+$').hasMatch(line) ||
        RegExp(
          r'^[a-z]{0,2}\d{1,2}:\d{2}$',
          caseSensitive: false,
        ).hasMatch(line)) {
      return false;
    }

    const ignoredFragments = [
      'transaction details',
      'edit transaction',
      'delete transaction',
      'subtotal',
      'total',
      'cashier',
      'order',
      'product',
      'phone',
      'email',
      'http',
      'www.',
      'thank you',
      'scan &',
      'membership',
      'receipt',
    ];

    return !ignoredFragments.any(lowerCase.contains);
  }

  static int _findBestTotalIndex(List<String> lines) {
    final preferredIndex = lines.indexWhere(_isPreferredTotalLine);

    return preferredIndex != -1
        ? preferredIndex
        : lines.indexWhere(_isTotalLine);
  }

  static bool _isPreferredTotalLine(String line) {
    final isNetTotal = RegExp(
      r'\b(?:NET|NETT)\s+TOTA(?:L)?\b',
      caseSensitive: false,
    ).hasMatch(line);

    if (isNetTotal) {
      return false;
    }

    return RegExp(
      r'\b(?:GRAND\s+)?TOTAL\b|\bAMOUNT\s+DUE\b|总计|合计|应付',
      caseSensitive: false,
    ).hasMatch(line);
  }

  static bool _isTotalLine(String line) {
    return RegExp(
      r'\b(?:GRAND\s+)?TOTAL\b|'
      r'\b(?:NET|NETT)\s+TOTA(?:L)?\b|'
      r'\bAMOUNT\s+DUE\b|'
      r'\bJUMLAH\b|'
      r'总计|合计|应付',
      caseSensitive: false,
    ).hasMatch(line);
  }

  static bool _isMoneySummaryLine(String line) {
    return _isTotalLine(line) ||
        RegExp(
          r'\bSUBTOTAL\b|\bCASH\b|\bCHANGE\b|\bROUNDING\b',
          caseSensitive: false,
        ).hasMatch(line);
  }

  static double? _findAmountNearTotal(List<String> lines, int totalIndex) {
    final amountOnTotalLine = _parseAmounts(lines[totalIndex]);

    if (amountOnTotalLine.isNotEmpty) {
      return amountOnTotalLine.last;
    }

    final allAmounts = <double>[];

    for (final line in lines) {
      allAmounts.addAll(_parseAmounts(line));
    }

    final frequencies = <String, int>{};

    for (final amount in allAmounts) {
      final key = amount.toStringAsFixed(2);
      frequencies[key] = (frequencies[key] ?? 0) + 1;
    }

    final candidates = <double>[];
    final endIndex = totalIndex + 12 < lines.length
        ? totalIndex + 12
        : lines.length - 1;

    for (var index = totalIndex + 1; index <= endIndex; index++) {
      for (final amount in _parseAmounts(lines[index])) {
        final key = amount.toStringAsFixed(2);
        final appearsMoreThanOnce = (frequencies[key] ?? 0) > 1;

        final hasNearbyCurrency =
            _containsCurrency(lines[index]) ||
            (index > totalIndex + 1 && _containsCurrency(lines[index - 1])) ||
            (index > totalIndex + 2 && _containsCurrency(lines[index - 2]));

        if (appearsMoreThanOnce || hasNearbyCurrency) {
          candidates.add(amount);
        }
      }
    }

    if (candidates.isEmpty) {
      return null;
    }

    candidates.sort((left, right) {
      final leftFrequency = frequencies[left.toStringAsFixed(2)] ?? 0;
      final rightFrequency = frequencies[right.toStringAsFixed(2)] ?? 0;

      final frequencyComparison = rightFrequency.compareTo(leftFrequency);

      return frequencyComparison != 0
          ? frequencyComparison
          : right.compareTo(left);
    });

    return candidates.first;
  }

  static bool _containsCurrency(String line) {
    return RegExp(
      r'\b(?:RM|MYR|CHF|EUR|USD|SGD)\b',
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

    final isoMatch = RegExp(r'(\d{4})[./-](\d{1,2})[./-](\d{1,2})')
        .firstMatch(line);

    if (isoMatch != null) {
      return _createValidDate(
        int.parse(isoMatch.group(1)!),
        int.parse(isoMatch.group(2)!),
        int.parse(isoMatch.group(3)!),
      );
    }

    final dayMonthYearMatch = RegExp(r'(\d{1,2})[./-](\d{1,2})[./-](\d{4})')
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

  static List<double> _parseAmounts(String line) {
    final matches = RegExp(r'(?<!\d)(\d+(?:[,.]\d{3})*[.,]\d{2})(?!\d)')
        .allMatches(line);

    return matches
        .map((match) => _normaliseAmount(match.group(1)!))
        .whereType<double>()
        .toList();
  }

  static double? _normaliseAmount(String value) {
    final lastComma = value.lastIndexOf(',');
    final lastDot = value.lastIndexOf('.');

    if (lastComma != -1 && lastDot != -1) {
      final decimalIndex = lastComma > lastDot ? lastComma : lastDot;
      final integerPart = value
          .substring(0, decimalIndex)
          .replaceAll(',', '')
          .replaceAll('.', '');

      final decimalPart = value.substring(decimalIndex + 1);

      return double.tryParse('$integerPart.$decimalPart');
    }

    return double.tryParse(value.replaceAll(',', '.'));
  }
}
