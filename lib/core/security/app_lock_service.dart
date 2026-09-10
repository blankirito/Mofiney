import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/foundation.dart';

class AppLockService {
  AppLockService({
    FlutterSecureStorage? secureStorage,
    LocalAuthentication? localAuthentication,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
       _localAuthentication = localAuthentication ?? LocalAuthentication();

  static const _lockEnabledKey = 'app_lock_enabled';
  static const _pinHashKey = 'app_lock_pin_hash';
  static const _pinSaltKey = 'app_lock_pin_salt';
  static const _deviceAuthEnabledKey = 'app_lock_device_auth_enabled';

  final FlutterSecureStorage _secureStorage;
  final LocalAuthentication _localAuthentication;
  final ValueNotifier<bool> lockEnabledNotifier = ValueNotifier(false);

  bool isValidPin(String pin) {
    return RegExp(r'^\d{6}$').hasMatch(pin);
  }

  Future<bool> isLockEnabled() async {
    final isEnabled = await _secureStorage.read(key: _lockEnabledKey) == 'true';

    lockEnabledNotifier.value = isEnabled;

    return isEnabled;
  }

  Future<bool> isDeviceAuthenticationEnabled() async {
    return await _secureStorage.read(key: _deviceAuthEnabledKey) == 'true';
  }

  Future<bool> canUseDeviceAuthentication() async {
    return _localAuthentication.isDeviceSupported();
  }

  Future<void> enableWithPin(String pin) async {
    if (!isValidPin(pin)) {
      throw ArgumentError('PIN must contain exactly 6 digits.');
    }

    final salt = _createSalt();
    final pinHash = _hashPin(pin, salt);

    await _secureStorage.write(key: _pinSaltKey, value: salt);
    await _secureStorage.write(key: _pinHashKey, value: pinHash);
    await _secureStorage.write(key: _lockEnabledKey, value: 'true');
    await _secureStorage.write(key: _deviceAuthEnabledKey, value: 'false');

    lockEnabledNotifier.value = true;
  }

  Future<bool> verifyPin(String pin) async {
    final salt = await _secureStorage.read(key: _pinSaltKey);
    final savedHash = await _secureStorage.read(key: _pinHashKey);

    if (salt == null || savedHash == null) {
      return false;
    }

    return _hashPin(pin, salt) == savedHash;
  }

  Future<void> setDeviceAuthenticationEnabled(bool enabled) async {
    await _secureStorage.write(
      key: _deviceAuthEnabledKey,
      value: enabled.toString(),
    );
  }

  Future<bool> authenticateWithDevice() async {
    return _localAuthentication.authenticate(
      localizedReason: 'Unlock Mofiney to view your financial data.',
      biometricOnly: false,
      persistAcrossBackgrounding: true,
      sensitiveTransaction: true,
    );
  }

  Future<void> disableAndClear() async {
    await _secureStorage.delete(key: _lockEnabledKey);
    await _secureStorage.delete(key: _pinHashKey);
    await _secureStorage.delete(key: _pinSaltKey);
    await _secureStorage.delete(key: _deviceAuthEnabledKey);

    lockEnabledNotifier.value = false;
  }

  String _createSalt() {
    final random = Random.secure();

    return base64UrlEncode(List<int>.generate(32, (_) => random.nextInt(256)));
  }

  String _hashPin(String pin, String salt) {
    return sha256.convert(utf8.encode('$salt:$pin')).toString();
  }
}
