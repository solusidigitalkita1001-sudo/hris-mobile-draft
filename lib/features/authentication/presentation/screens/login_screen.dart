import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hrm_app/core/errors/failure.dart';
import 'package:hrm_app/features/authentication/authentication_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const _blue = Color(0xFF2563EB);
  static const _pageBackground = Color(0xFFF8FAFC);

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isIndonesian = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
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
      backgroundColor: _pageBackground,
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
                        form: _buildForm(isLoading, error),
                      ),
                    ),
                  ],
                )
              : _FormPanel(
                  maxWidth: 440,
                  languageToggle: _buildLanguageToggle(),
                  form: _buildForm(isLoading, error),
                );
        },
      ),
    );
  }

  Widget _buildLanguageToggle() => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFFE2E8F0)),
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

  Widget _buildForm(bool isLoading, String? error) => Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _text('Masuk', 'Sign in'),
          style: const TextStyle(
            color: Color(0xFF0F172A),
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
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
        ),
        const SizedBox(height: 34),
        if (error != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFECACA)),
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
                    style: const TextStyle(
                      color: Color(0xFF991B1B),
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
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          enabled: !isLoading,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          decoration: _inputDecoration('name@company.com'),
          validator: (value) => value == null || value.trim().isEmpty
              ? _text('Email wajib diisi', 'Email is required')
              : null,
        ),
        const SizedBox(height: 22),
        Text(
          _text('Kata sandi', 'Password'),
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
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
                  tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 19,
                    color: const Color(0xFF64748B),
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
          height: 42,
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

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
    filled: true,
    fillColor: Colors.transparent,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(color: Color(0xFFDCE3ED)),
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

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ref
        .read(authControllerProvider.notifier)
        .login(
          email: _emailController.text,
          password: _passwordController.text,
        );
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
    color: _LoginScreenState._pageBackground,
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
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(5),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? _LoginScreenState._blue : Colors.transparent,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : const Color(0xFF475569),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}
