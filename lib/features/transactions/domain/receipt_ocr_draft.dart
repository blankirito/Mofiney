class ReceiptOcrDraft {
  const ReceiptOcrDraft({
    required this.merchant,
    required this.date,
    required this.amount,
    required this.note,
    required this.rawText,
  });

  final String merchant;
  final DateTime? date;
  final double? amount;
  final String note;
  final String rawText;
}
