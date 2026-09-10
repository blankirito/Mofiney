import 'package:flutter/material.dart';

import '../../../core/app_dependencies.dart';
import '../../../core/currency/currency_catalog.dart';
import '../../../core/currency/exchange_rate_service.dart';
import '../domain/category_budget.dart';

class BaseCurrencyPage extends StatefulWidget {
  const BaseCurrencyPage({super.key});
  @override
  State<BaseCurrencyPage> createState() => _BaseCurrencyPageState();
}

class _BaseCurrencyPageState extends State<BaseCurrencyPage> {
  String _current = 'MYR', _selected = 'MYR', _query = '';
  bool _loading = true;
  ExchangeRateResult? _usdRate;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await appSettingsRepository.ensureSettingsExist();
    final settings = await appSettingsRepository.getSettings();
    if (!mounted) return;
    setState(() {
      _current = settings?.baseCurrency ?? 'MYR';
      _selected = _current;
      _loading = false;
    });
    _loadRate();
  }

  Future<void> _loadRate() async {
    try {
      final rate = await ExchangeRateService().rate(from: _current, to: 'USD');
      if (mounted) setState(() => _usdRate = rate);
    } catch (_) {}
  }

  Future<void> _save() async {
    final oldCurrency = _current;
    // Budgets are denominated in the app base currency. Revalue their stored
    // numbers before changing the setting so the budget keeps its purchasing
    // value rather than merely receiving a new currency label.
    double factor = 1;
    if (oldCurrency != _selected) {
      try {
        factor = await ExchangeRateService()
            .rate(from: oldCurrency, to: _selected)
            .then((value) => value.rate);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Connect once to refresh the exchange rate before changing base currency.',
              ),
            ),
          );
        }
        return;
      }
    }
    final settings = await appSettingsRepository.getSettings();
    if (settings?.monthlyBudget != null) {
      await appSettingsRepository.updateMonthlyBudget(
        settings!.monthlyBudget! * factor,
      );
    }
    final categoryBudgets = await categoryBudgetRepository
        .getAllCategoryBudgets();
    for (final budget in categoryBudgets) {
      await categoryBudgetRepository.saveCategoryBudget(
        CategoryBudget(
          categoryId: budget.categoryId,
          monthlyBudget: budget.monthlyBudget * factor,
        ),
      );
    }
    await appSettingsRepository.updateBaseCurrency(_selected);
    if (!mounted) return;
    setState(() {
      _current = _selected;
      _usdRate = null;
    });
    _loadRate();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Base currency changed to $_current.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final active = CurrencyCatalog.find(_current);
    final values = CurrencyCatalog.all
        .where(
          (c) =>
              _query.isEmpty ||
              c.code.toLowerCase().contains(_query) ||
              c.name.toLowerCase().contains(_query),
        )
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Base Currency')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: ListTile(
                          leading: CircleAvatar(child: Text(active.symbol)),
                          title: Text('${active.code} — ${active.name}'),
                          subtitle: Text(
                            _usdRate == null
                                ? 'Daily exchange rates refresh when online.'
                                : '1 ${active.code} = ${_usdRate!.rate.toStringAsFixed(4)} USD · ${_usdRate!.fromCache ? 'offline cache' : 'live'}',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        onChanged: (v) =>
                            setState(() => _query = v.trim().toLowerCase()),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Search currency or ISO code',
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: values.length,
                    itemBuilder: (_, i) {
                      final c = values[i];
                      return RadioListTile<String>(
                        value: c.code,
                        groupValue: _selected,
                        onChanged: (v) => setState(() => _selected = v!),
                        title: Text('${c.code} — ${c.name}'),
                        secondary: CircleAvatar(
                          child: Text(c.symbol, maxLines: 1),
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _selected == _current ? null : _save,
                        child: Text(
                          'Use ${CurrencyCatalog.find(_selected).code} as base currency',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
