import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../localization/app_localization.dart';
import '../../models/auth_models.dart';
import '../../providers/auth_provider.dart';
import '../../utils/auth_error_mapper.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _showLogin = true;
  bool _showPassword = false;
  bool _isLoading = false;

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  UserType _selectedRole = UserType.familyMember;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final authProvider = context.read<AuthProvider>();
      final ok = await authProvider.login(
        _emailCtrl.text.trim(),
        _passCtrl.text,
      );

      if (mounted) {
        if (ok && authProvider.isAuthenticated) {
          // AuthGate chuyển sang app chính
        } else if (ok && authProvider.pendingVerificationEmail != null) {
          final loc = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.translate('login_verify_email')),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          final loc = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(mapAuthError(loc, authProvider.error)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc.translate('error_prefix')}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final authProvider = context.read<AuthProvider>();
      final userTypeString = _selectedRole == UserType.admin ? 'admin' : 'familyMember';
      
      final request = RegistrationRequest(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        fullName: _nameCtrl.text.trim(),
        userType: userTypeString,
        phone: _phoneCtrl.text.isNotEmpty ? _phoneCtrl.text : null,
      );
      
      final ok = await authProvider.register(request);

      if (mounted) {
        if (ok) {
          final loc = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.translate('register_success_email')),
              backgroundColor: Colors.green,
            ),
          );
          // AuthGate có thể chuyển sang màn xác thực — chỉ reset form khi vẫn ở welcome
          if (authProvider.pendingVerificationEmail == null) {
            setState(() {
              _showLogin = true;
              _emailCtrl.clear();
              _passCtrl.clear();
              _nameCtrl.clear();
              _phoneCtrl.clear();
            });
          }
        } else {
          final loc = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                authProvider.error ?? loc.translate('register_failed'),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc.translate('error_prefix')}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Hero section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryDark,
                ),
                child: Column(
                  children: [
                    // Logo
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryLight.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      loc.translate('app_title'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppLocalizations.of(context).translate('login_description'),
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Features row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _FeaturePill(
                          icon: Icons.videocam_rounded,
                          label: loc.translate('feature_live_view'),
                        ),
                        const SizedBox(width: 8),
                        _FeaturePill(
                          icon: Icons.notifications_active_rounded,
                          label: loc.translate('feature_instant_alerts'),
                        ),
                        const SizedBox(width: 8),
                        _FeaturePill(
                          icon: Icons.smart_toy_rounded,
                          label: loc.translate('feature_ai_detect'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Auth toggle
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _showLogin = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _showLogin
                                ? AppTheme.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              loc.signInTab,
                              style: TextStyle(
                                color: _showLogin
                                    ? Colors.white
                                    : AppTheme.textTertiary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _showLogin = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !_showLogin
                                ? AppTheme.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              loc.translate('register_tab'),
                              style: TextStyle(
                                color: !_showLogin
                                    ? Colors.white
                                    : AppTheme.textTertiary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: _showLogin
                    ? _LoginForm(
                        formKey: _formKey,
                        emailCtrl: _emailCtrl,
                        passCtrl: _passCtrl,
                        showPassword: _showPassword,
                        isLoading: _isLoading,
                        onTogglePassword: () =>
                            setState(() => _showPassword = !_showPassword),
                        onLogin: _handleLogin,
                        onForgotPassword: () => _showForgotPassword(context),
                      )
                    : _RegisterForm(
                        formKey: _formKey,
                        nameCtrl: _nameCtrl,
                        emailCtrl: _emailCtrl,
                        phoneCtrl: _phoneCtrl,
                        passCtrl: _passCtrl,
                        isLoading: _isLoading,
                        selectedRole: _selectedRole,
                        onRoleChanged: (role) {
                          setState(() => _selectedRole = role);
                        },
                        onRegister: _handleRegister,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showForgotPassword(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _ForgotPasswordSheet(
          initialEmail: _emailCtrl.text.trim(),
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white70),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final bool showPassword;
  final bool isLoading;
  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;
  final VoidCallback onForgotPassword;

  const _LoginForm({
    required this.formKey,
    required this.emailCtrl,
    required this.passCtrl,
    required this.showPassword,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onLogin,
    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.translate('welcome_back'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            loc.translate('sign_in_subtitle'),
            style: const TextStyle(fontSize: 13, color: AppTheme.textTertiary),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: loc.translate('email_address'),
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            validator: (v) =>
                v == null || v.isEmpty ? loc.translate('email_required') : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: passCtrl,
            obscureText: !showPassword,
            decoration: InputDecoration(
              labelText: loc.translate('password_label'),
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(
                  showPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                ),
                onPressed: onTogglePassword,
              ),
            ),
            validator: (v) =>
                v == null || v.length < 4 ? loc.translate('password_valid') : null,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onForgotPassword,
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primary,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
              ),
              child: Text(
                loc.translate('forgot_password'),
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: isLoading ? null : onLogin,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(loc.translate('sign_in_arrow')),
          ),
        ],
      ),
    );
  }
}

class _RegisterForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController passCtrl;
  final bool isLoading;
  final UserType selectedRole;
  final Function(UserType) onRoleChanged;
  final VoidCallback onRegister;

  const _RegisterForm({
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.passCtrl,
    required this.isLoading,
    required this.selectedRole,
    required this.onRoleChanged,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.translate('create_account'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            loc.translate('join_vital_horizon'),
            style: const TextStyle(fontSize: 13, color: AppTheme.textTertiary),
          ),
          const SizedBox(height: 20),
          
          // Role selector
          Text(
            loc.translate('account_type'),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<UserType>(
            segments: [
              ButtonSegment(
                value: UserType.familyMember,
                label: Text(loc.translate('role_family')),
                icon: const Icon(Icons.people_outline),
              ),
              ButtonSegment(
                value: UserType.admin,
                label: Text(loc.translate('role_admin')),
                icon: const Icon(Icons.admin_panel_settings_outlined),
              ),
            ],
            selected: {selectedRole},
            onSelectionChanged: (selection) {
              if (selection.isNotEmpty) {
                onRoleChanged(selection.first);
              }
            },
          ),
          const SizedBox(height: 20),

          TextFormField(
            controller: nameCtrl,
            decoration: InputDecoration(
              labelText: loc.translate('full_name'),
              prefixIcon: const Icon(Icons.person_outline_rounded),
            ),
            validator: (v) =>
                v == null || v.isEmpty ? loc.translate('name_required') : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: loc.translate('email_address'),
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            validator: (v) =>
                v == null || v.isEmpty ? loc.translate('email_required_short') : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: loc.translate('phone_number'),
              prefixIcon: const Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: passCtrl,
            obscureText: true,
            decoration: InputDecoration(
              labelText: loc.translate('password_label'),
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              helperText: loc.translate('password_hint'),
            ),
            validator: (v) =>
                v == null || v.length < 6 ? loc.translate('password_min_6') : null,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isLoading ? null : onRegister,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(loc.translate('create_account_arrow')),
          ),
        ],
      ),
    );
  }
}

class _ForgotPasswordSheet extends StatefulWidget {
  final String initialEmail;

  const _ForgotPasswordSheet({this.initialEmail = ''});

  @override
  State<_ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<_ForgotPasswordSheet> {
  late final TextEditingController _emailCtrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final loc = AppLocalizations.of(context);
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('enter_email_snack'))),
      );
      return;
    }
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    auth.clearError();
    final ok = await auth.requestPasswordReset(email);
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate('reset_email_sent')),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? loc.translate('reset_email_failed')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                loc.translate('reset_password_title'),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                loc.translate('forgot_password_body'),
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: loc.translate('email_address'),
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loading ? null : _send,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(loc.translate('send_reset_email')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
