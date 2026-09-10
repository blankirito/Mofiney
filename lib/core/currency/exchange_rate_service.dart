import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ExchangeRateResult {
  const ExchangeRateResult({
    required this.rate,
    required this.asOf,
    required this.fromCache,
  });
  final double rate;
  final DateTime asOf;
  final bool fromCache;
}

/// Retrieves a daily reference rate and preserves the last successful result
/// locally, so conversion remains available without a connection.
class ExchangeRateService {
  ExchangeRateService({http.Client? client})
    : _client = client ?? http.Client();
  final http.Client _client;

  Future<ExchangeRateResult> rate({
    required String from,
    required String to,
  }) async {
    if (from == to)
      return ExchangeRateResult(
        rate: 1,
        asOf: DateTime.now(),
        fromCache: false,
      );
    final key = 'exchange_rate_${from}_$to';
    try {
      // This open endpoint publishes a daily ISO-4217 rate table without an
      // app-specific key, including currencies beyond the ECB set.
      final uri = Uri.https('open.er-api.com', '/v6/latest/$from');
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200)
        throw StateError('Rate service returned ${response.statusCode}');
      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final rate = (payload['rates'] as Map<String, dynamic>)[to] as num?;
      if (rate == null) throw const FormatException('Rate was not supplied');
      final asOf = DateTime.fromMillisecondsSinceEpoch(
        ((payload['time_last_update_unix'] as num?)?.toInt() ??
                DateTime.now().millisecondsSinceEpoch ~/ 1000) *
            1000,
      );
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(
        key,
        jsonEncode({'rate': rate, 'asOf': asOf.toIso8601String()}),
      );
      return ExchangeRateResult(
        rate: rate.toDouble(),
        asOf: asOf,
        fromCache: false,
      );
    } catch (_) {
      final cached = (await SharedPreferences.getInstance()).getString(key);
      if (cached == null) rethrow;
      final payload = jsonDecode(cached) as Map<String, dynamic>;
      return ExchangeRateResult(
        rate: (payload['rate'] as num).toDouble(),
        asOf: DateTime.parse(payload['asOf'] as String),
        fromCache: true,
      );
    }
  }
}
