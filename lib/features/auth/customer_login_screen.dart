import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/config/app_environment.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/server_config_dialog.dart';
import '../../data/models/user_profile.dart';
import 'auth_state_provider.dart';

class CustomerLoginScreen extends ConsumerStatefulWidget {
  const CustomerLoginScreen({super.key});

  @override
  ConsumerState<CustomerLoginScreen> createState() => _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends ConsumerState<CustomerLoginScreen> {
  final _identifierController = TextEditingController(text: 'customer@afrobarber.com');
  final _passwordController = TextEditingController(text: 'password123');
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final l10n = context.l10n;
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = l10n.errRequiredFields);
      return;
    }

    setState(() => _errorMessage = null);

    try {
      final user = await ref.read(authStateProvider.notifier).loginCustomer(identifier, password);
      if (!mounted) return;
      if (user.role == UserRole.customer) {
        context.go(AppConstants.customerHomePath);
      }
    } catch (e) {
      if (!mounted) return;
      final rawError = e.toString().replaceAll('Exception: ', '');
      String displayError = rawError;
      bool isNetworkError = false;

      if (rawError.contains('Invalid email or password')) {
        displayError = l10n.errInvalidCredentials;
      } else if (rawError.contains('staff portal')) {
        displayError = l10n.errStaffOnly;
      } else if (rawError.contains('Unable to connect')) {
        displayError = l10n.errNetwork;
        isNetworkError = true;
      }

      setState(() {
        _errorMessage = displayError;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage ?? l10n.errInvalidCredentials),
          backgroundColor: AppColors.error,
          action: isNetworkError
              ? SnackBarAction(
                  label: 'Change Server IP',
                  textColor: AppColors.goldLight,
                  onPressed: () => showServerConfigDialog(context),
                )
              : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.canPop() ? context.pop() : context.go(AppConstants.loginSelectionPath),
        ),
        title: Text(l10n.customerLogin),
        actions: [
          IconButton(
            tooltip: 'Server Settings',
            icon: const Icon(Icons.dns_rounded, color: AppColors.gold, size: 22),
            onPressed: () => showServerConfigDialog(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.welcomeBack,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.customerLoginSubtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Email / Phone Field
              Text(l10n.emailOrPhone, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _identifierController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: l10n.emailOrPhoneHint,
                  prefixIcon: const Icon(Icons.person_outline_rounded, size: 20, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 20),

              // Password Field
              Text(l10n.password, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: l10n.passwordHint,
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.textMuted),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Login Button
              PrimaryButton(
                title: l10n.loginBtn,
                isLoading: isLoading,
                onPressed: _handleLogin,
              ),
              const SizedBox(height: 24),

              // Development Quick Account (kDebugMode && dev only)
              if (AppEnvironment.showDevTools) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.developer_mode_rounded, size: 18, color: AppColors.gold),
                      const SizedBox(width: 8),
                      const Text(
                        'Dev Demo: ',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.gold),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          _identifierController.text = 'customer@afrobarber.com';
                          _passwordController.text = 'password123';
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceHighlight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Fill Customer', style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Create Account Link
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.dontHaveAccount,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push(AppConstants.customerRegisterPath),
                      child: Text(
                        l10n.createAccount,
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
