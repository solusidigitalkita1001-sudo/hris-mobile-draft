import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hrm_app/core/errors/failure.dart';
import 'package:hrm_app/core/theme/app_theme.dart';
import 'package:hrm_app/features/authentication/authentication_providers.dart';
import 'package:hrm_app/features/authentication/presentation/controllers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const _blue = Color(0xFF2563EB);

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mfaController = TextEditingController();
  bool _obscurePassword = true;
  bool _isIndonesian = true;
  bool _requiresMfa = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _mfaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBackground = isDark ? AppColors.darkBg : AppColors.lightBg;
    final auth = ref.watch(authControllerProvider);
    final notice = ref.watch(authNoticeProvider);
    final isLoading = auth.isLoading;
    final error = auth.hasError
        ? auth.error is Failure
              ? (auth.error! as Failure).message
              : _text(
                  'Login gagal. Silakan coba lagi.',
                  'Login failed. Please try again.',
                )
        : null;

    return Scaffold(
      backgroundColor: pageBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final desktop = constraints.maxWidth >= 900;
          return desktop
              ? Row(
                  children: [
                    const Expanded(child: _BrandPanel(compact: false)),
                    Expanded(
                      child: _FormPanel(
                        maxWidth: 384,
                        languageToggle: _buildLanguageToggle(),
                        form: _buildForm(isLoading, error, notice),
                      ),
                    ),
                  ],
                )
              : _FormPanel(
                  maxWidth: 440,
                  languageToggle: _buildLanguageToggle(),
                  form: _buildForm(isLoading, error, notice),
                );
        },
      ),
    );
  }

  Widget _buildLanguageToggle() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LanguageButton(
            label: 'ID',
            selected: _isIndonesian,
            onTap: () => setState(() => _isIndonesian = true),
          ),
          _LanguageButton(
            label: 'EN',
            selected: !_isIndonesian,
            onTap: () => setState(() => _isIndonesian = false),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(bool isLoading, String? error, String? notice) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkText : AppColors.lightText;
    final textSecondary = isDark
        ? AppColors.darkTextSub
        : AppColors.lightTextSub;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _text('Masuk', 'Sign in'),
            style: TextStyle(
              color: textPrimary,
              fontSize: 25,
              height: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _text(
              'Masukkan kredensial Anda untuk mengakses akun',
              'Enter your credentials to access your account',
            ),
            style: TextStyle(color: textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 34),
          if (notice != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF052E2B)
                    : const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF0F766E)
                      : const Color(0xFFA7F3D0),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: Color(0xFF059669),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      notice,
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF6EE7B7)
                            : const Color(0xFF065F46),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],
          if (error != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF451A1A)
                    : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF7F1D1D)
                      : const Color(0xFFFECACA),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 18,
                    color: Color(0xFFDC2626),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error,
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFFCA5A5)
                            : const Color(0xFF991B1B),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],
          Text(
            _text('Alamat email', 'Email address'),
            style: TextStyle(
              color: textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            style: TextStyle(color: textPrimary, fontSize: 14),
            cursorColor: isDark ? AppColors.primaryLight : AppColors.primary,
            enabled: !isLoading,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            decoration: _inputDecoration('name@company.com'),
            validator: (value) => value == null || value.trim().isEmpty
                ? _text('Email wajib diisi', 'Email is required')
                : null,
          ),
          if (_requiresMfa) ...[
            const SizedBox(height: 22),
            Text(
              _text('Kode autentikator', 'Authenticator code'),
              style: TextStyle(
                color: textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _mfaController,
              style: TextStyle(color: textPrimary, fontSize: 14),
              cursorColor: isDark ? AppColors.primaryLight : AppColors.primary,
              enabled: !isLoading,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.oneTimeCode],
              onFieldSubmitted: (_) => _submit(),
              decoration: _inputDecoration(
                _text(
                  'Masukkan kode 6 digit atau recovery code',
                  'Enter the 6-digit or recovery code',
                ),
              ),
              validator: (value) {
                final length = value?.trim().length ?? 0;
                if (length < 6 || length > 20) {
                  return _text(
                    'Kode harus berisi 6 sampai 20 karakter',
                    'Code must contain 6 to 20 characters',
                  );
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: 22),
          Text(
            _text('Kata sandi', 'Password'),
            style: TextStyle(
              color: textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            style: TextStyle(color: textPrimary, fontSize: 14),
            cursorColor: isDark ? AppColors.primaryLight : AppColors.primary,
            enabled: !isLoading,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onFieldSubmitted: (_) => _submit(),
            decoration:
                _inputDecoration(
                  _text('Masukkan kata sandi Anda', 'Enter your password'),
                ).copyWith(
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword
                        ? 'Show password'
                        : 'Hide password',
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 19,
                      color: textSecondary,
                    ),
                  ),
                ),
            validator: (value) => value == null || value.isEmpty
                ? _text('Kata sandi wajib diisi', 'Password is required')
                : null,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                elevation: 1,
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _blue.withValues(alpha: 0.65),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(_text('Masuk', 'Sign in')),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hintColor = isDark ? AppColors.darkTextSub : AppColors.lightTextSub;
    final fillColor = isDark ? AppColors.darkCard : Colors.transparent;
    final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFDCE3ED);
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: hintColor, fontSize: 14),
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: _blue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
      ),
    );
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref
        .read(authControllerProvider.notifier)
        .login(
          email: _emailController.text,
          password: _passwordController.text,
          totp: _requiresMfa ? _mfaController.text : null,
        );
    if (!mounted) return;
    final error = ref.read(authControllerProvider).error;
    if (error is AuthenticationFailure && error.code == 'MFA_REQUIRED') {
      setState(() => _requiresMfa = true);
    }
  }

  String _text(String id, String en) => _isIndonesian ? id : en;
}

class _FormPanel extends StatelessWidget {
  const _FormPanel({
    required this.maxWidth,
    required this.languageToggle,
    required this.form,
  });

  final double maxWidth;
  final Widget languageToggle;
  final Widget form;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkBg
        : AppColors.lightBg,
    child: SafeArea(
      minimum: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          languageToggle,
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: form,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    ),
  );
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel({required this.compact});
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
    constraints: BoxConstraints(minHeight: compact ? 270 : double.infinity),
    color: _LoginScreenState._blue,
    padding: EdgeInsets.symmetric(
      horizontal: compact ? 28 : 72,
      vertical: compact ? 30 : 48,
    ),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'H',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'HRMS Enterprise',
              style: TextStyle(
                color: Colors.white,
                fontSize: compact ? 27 : 32,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Platform manajemen SDM lengkap untuk organisasi enterprise. Kelola tenaga kerja Anda secara efisien dengan tools kelas enterprise.',
              maxLines: compact ? 3 : null,
              overflow: compact ? TextOverflow.ellipsis : null,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.82),
                fontSize: compact ? 14 : 18,
                height: 1.55,
              ),
            ),
            if (!compact) ...[
              const SizedBox(height: 28),
              const _Benefit(label: 'Struktur multi-company & group'),
              const _Benefit(label: 'Siklus hidup karyawan end-to-end'),
              const _Benefit(label: 'Analitik & reporting lanjutan'),
              const _Benefit(label: 'Keamanan kelas enterprise'),
            ],
          ],
        ),
      ),
    ),
  );
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, size: 13, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5),
      child: Align(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? _LoginScreenState._blue : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? Colors.white
                  : Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkTextSub
                  : const Color(0xFF475569),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    ),
  );
}
