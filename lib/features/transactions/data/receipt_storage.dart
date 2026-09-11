import 'dart:io';

import 'package:path_provider/path_provider.dart';

class ReceiptStorage {
  const ReceiptStorage._();

  static Future<String> save(String sourcePath) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();

    final receiptsDirectory = Directory(
      '${documentsDirectory.path}${Platform.pathSeparator}receipts',
    );

    if (!await receiptsDirectory.exists()) {
      await receiptsDirectory.create(recursive: true);
    }

    final lastDot = sourcePath.lastIndexOf('.');
    final extension = lastDot == -1 ? '.jpg' : sourcePath.substring(lastDot);

    final fileName =
        'receipt_${DateTime.now().microsecondsSinceEpoch}$extension';

    final savedFile = await File(sourcePath)
        .copy('${receiptsDirectory.path}${Platform.pathSeparator}$fileName');

    return savedFile.path;
  }

  static Future<void> delete(String? receiptPath) async {
    if (receiptPath == null || receiptPath.trim().isEmpty) {
      return;
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();

    final receiptsDirectory = Directory(
      '${documentsDirectory.path}${Platform.pathSeparator}receipts',
    );

    final receiptFile = File(receiptPath);

    final allowedPrefix =
        '${receiptsDirectory.absolute.path}${Platform.pathSeparator}';

    if (!receiptFile.absolute.path.startsWith(allowedPrefix)) {
      return;
    }

    if (await receiptFile.exists()) {
      await receiptFile.delete();
    }
  }
}
