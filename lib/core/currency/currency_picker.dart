import 'package:flutter/material.dart';

import 'currency.dart';
import 'currency_catalog.dart';

Future<Currency?> showCurrencyPicker(
  BuildContext context, {
  required String selectedCode,
  String title = 'Select currency',
}) => showModalBottomSheet<Currency>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => _CurrencyPicker(selectedCode: selectedCode, title: title),
);

class _CurrencyPicker extends StatefulWidget {
  const _CurrencyPicker({required this.selectedCode, required this.title});
  final String selectedCode, title;
  @override
  State<_CurrencyPicker> createState() => _CurrencyPickerState();
}

class _CurrencyPickerState extends State<_CurrencyPicker> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final values = CurrencyCatalog.all
        .where(
          (c) =>
              c.code.toLowerCase().contains(query) ||
              c.name.toLowerCase().contains(query),
        )
        .toList();
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .78,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                autofocus: true,
                onChanged: (v) => setState(() => query = v.toLowerCase()),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search currency or ISO code',
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: values.length,
                itemBuilder: (_, i) {
                  final c = values[i];
                  return ListTile(
                    leading: CircleAvatar(child: Text(c.symbol, maxLines: 1)),
                    title: Text('${c.code} — ${c.name}'),
                    trailing: c.code == widget.selectedCode
                        ? const Icon(Icons.check)
                        : null,
                    onTap: () => Navigator.pop(context, c),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
