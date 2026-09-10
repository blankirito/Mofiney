import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_dependencies.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class AppLockGate extends StatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  bool _isChecking = true;
  bool _isLocked = false;
  bool _isAppLockEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    appLockService.lockEnabledNotifier.addListener(_onAppLockEnabledChanged);
    _loadLockState();
  }

  Future<void> _loadLockState() async {
    final isLockEnabled = await appLockService.isLockEnabled();

    if (!mounted) return;

    setState(() {
      _isAppLockEnabled = isLockEnabled;
      _isLocked = isLockEnabled;
      _isChecking = false;
    });
  }

  void _unlock() {
    setState(() {
      _isLocked = false;
    });
  }

  void _onAppLockEnabledChanged() {
    if (!mounted) return;

    setState(() {
      _isAppLockEnabled = appLockService.lockEnabledNotifier.value;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if ((state == AppLifecycleState.paused ||
            state == AppLifecycleState.hidden ||
            state == AppLifecycleState.detached) &&
        _isAppLockEnabled) {
      setState(() {
        _isLocked = true;
      });
    }
  }

  @override
  void dispose() {
    appLockService.lockEnabledNotifier.removeListener(_onAppLockEnabledChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isLocked) {
      return _UnlockAppPage(onUnlocked: _unlock);
    }

    return widget.child;
  }
}

class _UnlockAppPage extends StatefulWidget {
  const _UnlockAppPage({required this.onUnlocked});

  final VoidCallback onUnlocked;

  @override
  State<_UnlockAppPage> createState() => _UnlockAppPageState();
}

class _UnlockAppPageState extends State<_UnlockAppPage> {
  final _pinController = TextEditingController();

  bool _isUnlocking = false;
  String? _errorText;
  bool _isDeviceAuthenticationAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadDeviceAuthenticationAvailability();
  }

  Future<void> _loadDeviceAuthenticationAvailability() async {
    final isEnabled = await appLockService.isDeviceAuthenticationEnabled();

    final isAvailable = await appLockService.canUseDeviceAuthentication();

    if (!mounted) return;

    setState(() {
      _isDeviceAuthenticationAvailable = isEnabled && isAvailable;
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _unlockWithPin() async {
    final pin = _pinController.text;

    if (!appLockService.isValidPin(pin)) {
      setState(() {
        _errorText = 'Enter your 6-digit PIN.';
      });
      return;
    }

    setState(() {
      _isUnlocking = true;
      _errorText = null;
    });

    try {
      final isCorrect = await appLockService.verifyPin(pin);

      if (!mounted) return;

      if (isCorrect) {
        widget.onUnlocked();
        return;
      }

      setState(() {
        _errorText = 'Incorrect PIN. Please try again.';
        _pinController.clear();
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorText = 'Could not unlock Mofiney. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isUnlocking = false;
        });
      }
    }
  }

  Future<void> _unlockWithDeviceAuthentication() async {
    setState(() {
      _isUnlocking = true;
      _errorText = null;
    });

    try {
      final didAuthenticate = await appLockService.authenticateWithDevice();

      if (!mounted) return;

      if (didAuthenticate) {
        widget.onUnlocked();
        return;
      }

      setState(() {
        _errorText = 'Device authentication was not completed.';
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorText =
            'Could not use device authentication. Try your PIN instead.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isUnlocking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 32,
                  color: colors.onPrimaryContainer,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              Text(
                'Unlock Mofiney',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: AppSpacing.xs),

              Text(
                'Enter your 6-digit PIN to continue.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              TextField(
                controller: _pinController,
                onChanged: (_) {
                  if (_errorText != null) {
                    setState(() {
                      _errorText = null;
                    });
                  }
                },
                onSubmitted: (_) => _unlockWithPin(),
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineMedium.copyWith(
                  color: colors.onSurface,
                  letterSpacing: 12,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••••',
                  filled: true,
                  fillColor: colors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              if (_errorText != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _errorText!,
                  style: AppTextStyles.bodySmall.copyWith(color: colors.error),
                ),
              ],

              const SizedBox(height: AppSpacing.lg),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isUnlocking ? null : _unlockWithPin,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isUnlocking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Unlock'),
                ),
              ),

              if (_isDeviceAuthenticationAvailable) ...[
                const SizedBox(height: AppSpacing.sm),

                OutlinedButton.icon(
                  onPressed: _isUnlocking
                      ? null
                      : _unlockWithDeviceAuthentication,
                  icon: const Icon(Icons.fingerprint_rounded),
                  label: const Text('Use Device Authentication'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
