import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/campus_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/google_logo.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/wave_header.dart';
import '../../data/mock/mock_database.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;
  bool _isLoadingGoogle = false;
  bool _isLoggingIn = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final clean = email.toLowerCase();
    if (!clean.endsWith('@adssu.edu.ph')) {
      context.push('/login-error');
      return;
    }

    if (password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your password.');
      return;
    }

    setState(() {
      _isLoggingIn = true;
      _errorMessage = null;
    });

    try {
      final db = context.read<MockDatabase>();
      final success = await db.login(clean, password);
      if (!mounted) return;

      if (success) {
        SharedPreferences.getInstance().then((p) => p.setBool('has_seen_onboarding', true)).catchError((_) => false);
        if (clean == CampusConstants.demoAdminEmail.toLowerCase()) {
          context.go('/admin/dashboard');
        } else {
          context.go('/home');
        }
      } else {
        setState(() {
          _errorMessage = 'Incorrect password. Please verify your password or tap Forgot Password.';
          _isLoggingIn = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceAll('Exception: ', '').replaceAll('FirebaseAuthException: ', '');
      setState(() {
        _errorMessage = msg;
        _isLoggingIn = false;
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoadingGoogle = true;
      _errorMessage = null;
    });

    try {
      final db = context.read<MockDatabase>();
      final success = await db.loginWithGoogle();
      if (!mounted) return;

      if (success) {
        SharedPreferences.getInstance().then((p) => p.setBool('has_seen_onboarding', true)).catchError((_) => false);
        if (db.currentUser.email.toLowerCase() == CampusConstants.demoAdminEmail.toLowerCase()) {
          context.go('/admin/dashboard');
        } else {
          context.go('/home');
        }
      }
    } catch (e) {
      if (!mounted) return;
      final rawMsg = e.toString();
      final err = rawMsg.toLowerCase();
      if (err.contains('cancel') || err.contains('cancelled') || err.contains('canceled')) {
        setState(() => _errorMessage = null);
        return;
      }
      // Check for user not registered first (even if error message mentions @adssu.edu.ph)
      if (err.contains('user-not-found') ||
          err.contains('not registered') ||
          err.contains('no registered account') ||
          err.contains("haven't registered") ||
          err.contains('does not exist')) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.statusError),
                SizedBox(width: 8),
                Text('Account Not Found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            content: const Text(
              'This @adssu.edu.ph account is not registered yet. Please register first to activate your student account.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDarkGreen,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  context.push('/register-1');
                },
                child: const Text('Register Now'),
              ),
            ],
          ),
        );
        return;
      }
      // Access restricted only for non-adssu domains (e.g. personal @gmail.com, @yahoo.com)
      if (err.contains('invalid-email-domain') || (err.contains('access restricted') && !err.contains('registered'))) {
        context.push('/login-error');
        return;
      }
      final msg = e.toString().contains('ApiException: 10')
          ? 'Google Sign-In (ApiException 10): SHA-1 fingerprint needs to be added in Firebase Console.'
          : 'Google Sign-In: $e';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.statusError,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingGoogle = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Signature Wave Header
            Stack(
              children: [
                const WaveHeader(height: 120),
                Positioned(
                  top: 40,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite.withAlpha(40),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'SSO PORTAL',
                      style: TextStyle(
                        color: AppColors.cardWhite,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo Card
                  Container(
                    width: 180,
                    height: 80,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Image.asset(
                      AppAssets.logo,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tagline Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withAlpha(40),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      CampusConstants.appTagline,
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title & Subtitle
                  Text(
                    'Welcome Back, Adssunian!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Sign in with your official ADSSU credentials',
                    style: TextStyle(
                      color: AppColors.mutedGray,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Institutional Email Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Student / Institutional Email',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'yourname@adssu.edu.ph',
                          prefixIcon: Icon(Icons.school_outlined, color: AppColors.primaryDarkGreen),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primaryDarkGreen),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: AppColors.mutedGray,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Forgot Password Link -> Screen 6
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push('/forgot-password'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.midGreen,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppColors.statusError, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Sign In Button
                  _isLoggingIn
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primaryDarkGreen))
                    : PrimaryButton(
                        label: 'Sign In',
                        icon: Icons.login_rounded,
                        onPressed: _handleLogin,
                      ),
                  const SizedBox(height: 16),

                  // Divider with "or"
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.borderLight, thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          'or continue with',
                          style: TextStyle(
                            color: AppColors.mutedGray,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: AppColors.borderLight, thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Google Sign-In Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _isLoadingGoogle ? null : _handleGoogleSignIn,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.cardWhite,
                        side: const BorderSide(color: AppColors.borderLight, width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoadingGoogle
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryDarkGreen),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GoogleLogo(size: 20),
                                SizedBox(width: 12),
                                Text(
                                  'Sign in with Google',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Register Link -> Screen 8
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(fontSize: 13, color: AppColors.mutedGray),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/register-1'),
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDarkGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

