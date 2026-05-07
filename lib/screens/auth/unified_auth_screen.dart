import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/auth_models.dart';
import '../../providers/auth_provider.dart';
import '../../localization/app_localization.dart';
import '../../localization/language_provider.dart';
import '../../theme/app_theme.dart';

enum AuthMode { login, register, forgotPassword, verifyCode, verifyPasswordReset, resetPassword }

class UnifiedAuthScreen extends StatefulWidget {
  final Function(UserType) onLoginSuccess;
  final LanguageProvider languageProvider;

  const UnifiedAuthScreen({
    super.key,
    required this.onLoginSuccess,
    required this.languageProvider,
  });

  @override
  State<UnifiedAuthScreen> createState() => _UnifiedAuthScreenState();
}

class _UnifiedAuthScreenState extends State<UnifiedAuthScreen> {
  AuthMode _currentMode = AuthMode.login;
  
  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  // State
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _rememberMe = false;
  bool _acceptTerms = false;
  String _selectedUserType = 'familyMember';
  String? _emailForVerification;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _verificationCodeController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  void _switchMode(AuthMode mode) {
    setState(() {
      _currentMode = mode;
      // Clear sensitive fields when switching modes
      _passwordController.clear();
      _confirmPasswordController.clear();
      _verificationCodeController.clear();
      _newPasswordController.clear();
      _confirmNewPasswordController.clear();
    });
  }

  void _handleLogin(AuthProvider authProvider) async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      authProvider.clearError();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).strings['error'] ?? 'Error')),
      );
      return;
    }

    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      final user = authProvider.user;
      if (user != null) {
        widget.onLoginSuccess(user.userType);
      }
    }
  }

  void _handleRegister(AuthProvider authProvider) async {
    final loc = AppLocalizations.of(context);
    
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.strings['error'] ?? 'Error')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.strings['confirm_password'] ?? 'Passwords do not match')),
      );
      return;
    }

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.strings['terms_conditions'] ?? 'Accept terms')),
      );
      return;
    }

    final request = RegistrationRequest(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _nameController.text.trim(),
      userType: _selectedUserType,
      phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
    );

    final success = await authProvider.register(request);

    if (success && mounted) {
      _emailForVerification = _emailController.text.trim();
      _switchMode(AuthMode.verifyCode);
    }
  }

  void _handleVerifyEmail(AuthProvider authProvider) async {
    if (_verificationCodeController.text.isEmpty) {
      return;
    }

    final success = await authProvider.verifyEmail(
      _emailForVerification ?? _emailController.text.trim(),
      _verificationCodeController.text,
    );

    if (success && mounted) {
      final user = authProvider.user;
      if (user != null) {
        widget.onLoginSuccess(user.userType);
      }
    }
  }

  void _handleResendCode(AuthProvider authProvider) async {
    await authProvider.resendVerificationCode(
      _emailForVerification ?? _emailController.text.trim(),
    );
  }

  void _handleForgotPassword(AuthProvider authProvider) async {
    if (_emailController.text.isEmpty) {
      return;
    }

    final success = await authProvider.requestPasswordReset(_emailController.text.trim());

    if (success && mounted) {
      _emailForVerification = _emailController.text.trim();
      _switchMode(AuthMode.verifyPasswordReset);
    }
  }

  void _handleVerifyPasswordReset(AuthProvider authProvider) async {
    if (_verificationCodeController.text.isEmpty) {
      return;
    }

    final success = await authProvider.verifyPasswordResetCode(
      _emailForVerification ?? _emailController.text.trim(),
      _verificationCodeController.text,
    );

    if (success && mounted) {
      _switchMode(AuthMode.resetPassword);
    }
  }

  void _handleResetPassword(AuthProvider authProvider) async {
    final loc = AppLocalizations.of(context);

    if (_newPasswordController.text.isEmpty || _confirmNewPasswordController.text.isEmpty) {
      return;
    }

    if (_newPasswordController.text != _confirmNewPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.strings['confirm_password'] ?? 'Passwords do not match')),
      );
      return;
    }

    final success = await authProvider.resetPassword(
      _emailForVerification ?? _emailController.text.trim(),
      _verificationCodeController.text,
      _newPasswordController.text,
    );

    if (success && mounted) {
      _switchMode(AuthMode.login);
      _emailController.clear();
      _passwordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final loc = AppLocalizations.of(context);
        
        return Scaffold(
          backgroundColor: AppTheme.surface,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  if (_currentMode == AuthMode.login) ...[
                    _buildLoginHeader(loc),
                  ] else if (_currentMode == AuthMode.register) ...[
                    _buildRegisterHeader(loc),
                  ] else if (_currentMode == AuthMode.forgotPassword) ...[
                    _buildForgotPasswordHeader(loc),
                  ] else if (_currentMode == AuthMode.verifyCode) ...[
                    _buildVerifyEmailHeader(loc),
                  ] else if (_currentMode == AuthMode.verifyPasswordReset || _currentMode == AuthMode.resetPassword) ...[
                    _buildResetPasswordHeader(loc),
                  ],

                  const SizedBox(height: 32),

                  // Content based on mode
                  if (_currentMode == AuthMode.login) ...[
                    _buildLoginContent(authProvider, loc),
                  ] else if (_currentMode == AuthMode.register) ...[
                    _buildRegisterContent(authProvider, loc),
                  ] else if (_currentMode == AuthMode.forgotPassword) ...[
                    _buildForgotPasswordContent(authProvider, loc),
                  ] else if (_currentMode == AuthMode.verifyCode) ...[
                    _buildVerifyEmailContent(authProvider, loc),
                  ] else if (_currentMode == AuthMode.verifyPasswordReset) ...[
                    _buildVerifyPasswordResetContent(authProvider, loc),
                  ] else if (_currentMode == AuthMode.resetPassword) ...[
                    _buildResetPasswordContent(authProvider, loc),
                  ],

                  // Error message
                  if (authProvider.error != null) ...[
                    const SizedBox(height: 16),
                    _buildErrorWidget(authProvider.error!),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── Login Content ──────────────────────────────
  Widget _buildLoginHeader(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.strings['sign_in'] ?? 'Sign In',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          loc.strings['login_description'] ?? 'Sign in to continue',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginContent(AuthProvider authProvider, AppLocalizations loc) {
    return Column(
      children: [
        // Email field
        _buildTextField(
          controller: _emailController,
          label: loc.strings['email_address'] ?? 'Email',
          keyboardType: TextInputType.emailAddress,
          autofocus: true,
        ),
        const SizedBox(height: 16),

        // Password field
        _buildPasswordField(
          controller: _passwordController,
          label: loc.strings['password_label'] ?? 'Password',
          showPassword: _showPassword,
          onToggle: () => setState(() => _showPassword = !_showPassword),
        ),
        const SizedBox(height: 12),

        // Remember me
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) => setState(() => _rememberMe = value ?? false),
              fillColor: MaterialStateProperty.all(AppTheme.primary),
            ),
            Text(loc.strings['remember_me'] ?? 'Remember Me'),
          ],
        ),
        const SizedBox(height: 24),

        // Sign in button
        ElevatedButton(
          onPressed: authProvider.isLoading ? null : () => _handleLogin(authProvider),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: AppTheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: authProvider.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Text(
                  loc.strings['sign_in'] ?? 'Sign In',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
        const SizedBox(height: 16),

        // Forgot password link
        TextButton(
          onPressed: () => _switchMode(AuthMode.forgotPassword),
          child: Text(
            loc.strings['forgot_password'] ?? 'Forgot Password?',
            style: TextStyle(
              color: AppTheme.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Sign up link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(loc.strings['dont_have_account'] ?? "Don't have an account? "),
            TextButton(
              onPressed: () => _switchMode(AuthMode.register),
              child: Text(
                loc.strings['sign_up'] ?? 'Sign Up',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Register Content ──────────────────────────
  Widget _buildRegisterHeader(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => _switchMode(AuthMode.login),
              icon: const Icon(Icons.arrow_back),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.strings['sign_up'] ?? 'Sign Up',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRegisterContent(AuthProvider authProvider, AppLocalizations loc) {
    return Column(
      children: [
        // User type selection
        Text(
          loc.strings['select_role'] ?? 'Select Your Role',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildUserTypeSelector(loc),
        const SizedBox(height: 24),

        // Name field
        _buildTextField(
          controller: _nameController,
          label: loc.strings['full_name'] ?? 'Full Name',
          autofocus: true,
        ),
        const SizedBox(height: 16),

        // Email field
        _buildTextField(
          controller: _emailController,
          label: loc.strings['email_address'] ?? 'Email',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),

        // Phone field
        _buildTextField(
          controller: _phoneController,
          label: loc.strings['phone_number'] ?? 'Phone (Optional)',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),

        // Password field
        _buildPasswordField(
          controller: _passwordController,
          label: loc.strings['password_label'] ?? 'Password',
          showPassword: _showPassword,
          onToggle: () => setState(() => _showPassword = !_showPassword),
        ),
        const SizedBox(height: 16),

        // Confirm password field
        _buildPasswordField(
          controller: _confirmPasswordController,
          label: loc.strings['confirm_password'] ?? 'Confirm Password',
          showPassword: _showConfirmPassword,
          onToggle: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
        ),
        const SizedBox(height: 12),

        // Terms checkbox
        Row(
          children: [
            Checkbox(
              value: _acceptTerms,
              onChanged: (value) => setState(() => _acceptTerms = value ?? false),
              fillColor: MaterialStateProperty.all(AppTheme.primary),
            ),
            Expanded(
              child: Text(loc.strings['terms_conditions'] ?? 'I agree to Terms & Conditions'),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Create account button
        ElevatedButton(
          onPressed: authProvider.isLoading ? null : () => _handleRegister(authProvider),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: AppTheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: authProvider.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Text(
                  loc.strings['sign_up'] ?? 'Create Account',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
        const SizedBox(height: 16),

        // Sign in link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(loc.strings['already_have_account'] ?? 'Already have an account? '),
            TextButton(
              onPressed: () => _switchMode(AuthMode.login),
              child: Text(
                loc.strings['sign_in'] ?? 'Sign In',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Forgot Password Content ───────────────────
  Widget _buildForgotPasswordHeader(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => _switchMode(AuthMode.login),
              icon: const Icon(Icons.arrow_back),
            ),
            Expanded(
              child: Text(
                loc.strings['forgot_password'] ?? 'Forgot Password?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildForgotPasswordContent(AuthProvider authProvider, AppLocalizations loc) {
    return Column(
      children: [
        Text(
          loc.strings['enter_email'] ?? 'Enter your email to receive reset code',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 24),

        _buildTextField(
          controller: _emailController,
          label: loc.strings['email_address'] ?? 'Email',
          keyboardType: TextInputType.emailAddress,
          autofocus: true,
        ),
        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: authProvider.isLoading ? null : () => _handleForgotPassword(authProvider),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: AppTheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: authProvider.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Text(
                  loc.strings['send_code'] ?? 'Send Code',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ],
    );
  }

  // ─── Verify Email Content ──────────────────────
  Widget _buildVerifyEmailHeader(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.strings['verify_email'] ?? 'Verify Email',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyEmailContent(AuthProvider authProvider, AppLocalizations loc) {
    return Column(
      children: [
        Text(
          loc.strings['code_sent'] ?? 'Code sent to your email',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 24),

        _buildTextField(
          controller: _verificationCodeController,
          label: loc.strings['verification_code'] ?? 'Verification Code',
          hint: loc.strings['enter_code'] ?? 'Enter 6-digit code',
          keyboardType: TextInputType.number,
          maxLength: 6,
          autofocus: true,
        ),
        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: authProvider.isLoading ? null : () => _handleVerifyEmail(authProvider),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: AppTheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: authProvider.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Text(
                  loc.strings['verify'] ?? 'Verify',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
        const SizedBox(height: 16),

        TextButton(
          onPressed: () => _handleResendCode(authProvider),
          child: Text(
            loc.strings['resend_code'] ?? 'Resend Code',
            style: TextStyle(
              color: AppTheme.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Verify Password Reset Content ──────────────
  Widget _buildResetPasswordHeader(AppLocalizations loc) {
    if (_currentMode == AuthMode.verifyPasswordReset) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.strings['verify_password_reset'] ?? 'Verify Password Reset',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => _switchMode(AuthMode.forgotPassword),
                icon: const Icon(Icons.arrow_back),
              ),
              Expanded(
                child: Text(
                  loc.strings['reset_password'] ?? 'Reset Password',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildVerifyPasswordResetContent(AuthProvider authProvider, AppLocalizations loc) {
    return Column(
      children: [
        Text(
          loc.strings['code_sent'] ?? 'Code sent to your email',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 24),

        _buildTextField(
          controller: _verificationCodeController,
          label: loc.strings['verification_code'] ?? 'Verification Code',
          hint: loc.strings['enter_code'] ?? 'Enter 6-digit code',
          keyboardType: TextInputType.number,
          maxLength: 6,
          autofocus: true,
        ),
        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: authProvider.isLoading ? null : () => _handleVerifyPasswordReset(authProvider),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: AppTheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: authProvider.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Text(
                  loc.strings['verify'] ?? 'Verify',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
        const SizedBox(height: 16),

        TextButton(
          onPressed: () => _handleResendCode(authProvider),
          child: Text(
            loc.strings['resend_code'] ?? 'Resend Code',
            style: TextStyle(
              color: AppTheme.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Reset Password Content ────────────────────
  Widget _buildResetPasswordContent(AuthProvider authProvider, AppLocalizations loc) {
    return Column(
      children: [
        _buildPasswordField(
          controller: _newPasswordController,
          label: loc.strings['new_password'] ?? 'New Password',
          showPassword: _showPassword,
          onToggle: () => setState(() => _showPassword = !_showPassword),
        ),
        const SizedBox(height: 16),

        _buildPasswordField(
          controller: _confirmNewPasswordController,
          label: loc.strings['confirm_new_password'] ?? 'Confirm New Password',
          showPassword: _showConfirmPassword,
          onToggle: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
        ),
        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: authProvider.isLoading ? null : () => _handleResetPassword(authProvider),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: AppTheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: authProvider.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Text(
                  loc.strings['reset_password'] ?? 'Reset Password',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ],
    );
  }

  // ─── Helper Widgets ────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    bool autofocus = false,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      autofocus: autofocus,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppTheme.primary,
            width: 2,
          ),
        ),
        counterText: '',
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool showPassword,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: !showPassword,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppTheme.primary,
            width: 2,
          ),
        ),
        suffixIcon: IconButton(
          icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
      ),
    );
  }

  Widget _buildUserTypeSelector(AppLocalizations loc) {
    final userTypes = [
      ('familyMember', loc.strings['user_type_family_member'] ?? 'Family Member'),
      ('admin', loc.strings['user_type_admin'] ?? 'Administrator'),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: userTypes.map((type) {
        return ChoiceChip(
          label: Text(type.$2),
          selected: _selectedUserType == type.$1,
          onSelected: (selected) {
            if (selected) {
              setState(() => _selectedUserType = type.$1);
            }
          },
          selectedColor: AppTheme.primary,
          labelStyle: TextStyle(
            color: _selectedUserType == type.$1 ? Colors.white : Colors.black,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
