import 'exchange_rate_service.dart';

/// In-memory conversion table for one presentation/base currency. Values remain
/// in their source currency in storage; only callers' displayed totals change.
class CurrencyConverter {
  CurrencyConverter(this.baseCurrency, {ExchangeRateService? rates})
    : _rates = rates ?? ExchangeRateService();

  final String baseCurrency;
  final ExchangeRateService _rates;
  final Map<String, double> _toBase = {};

  Future<void> warm(Iterable<String> sourceCurrencies) async {
    final sources = sourceCurrencies.map((code) => code.toUpperCase()).toSet();
    await Future.wait(
      sources.map((source) async {
        if (source == baseCurrency || _toBase.containsKey(source)) return;
        try {
          _toBase[source] = (await _rates.rate(
            from: source,
            to: baseCurrency,
          )).rate;
        } catch (_) {
          // Keep native value visible until a live or cached rate is available.
          _toBase[source] = 1;
        }
      }),
    );
  }

  double convert(double amount, String sourceCurrency) =>
      amount *
      (_toBase[sourceCurrency.toUpperCase()] ??
          (sourceCurrency.toUpperCase() == baseCurrency ? 1 : 1));
}
