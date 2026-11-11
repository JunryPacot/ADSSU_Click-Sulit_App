import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/wave_header.dart';
import '../../data/mock/mock_database.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final List<TextEditingController> _codeControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // 0 = enter email, 1 = enter OTP, 2 = enter new password, 3 = success
  int _step = 0;
  String? _errorMessage;
  bool _isLoading = false;
  bool _obscurePassword = true;

  int _resendCountdown = 0;
  Timer? _countdownTimer;

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _countdownTimer?.cancel();
    for (final c in _codeControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _resendCountdown = 30);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCountdown > 1) {
        setState(() => _resendCountdown--);
      } else {
        setState(() => _resendCountdown = 0);
        timer.cancel();
      }
    });
  }

  String get _enteredCode =>
      _codeControllers.map((c) => c.text.trim()).join();

  Future<void> _handleSendOtp() async {
    final email = _emailController.text.trim().toLowerCase();
    if (!email.endsWith('@adssu.edu.ph')) {
      setState(() => _errorMessage = 'Only @adssu.edu.ph emails are accepted.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final db = context.read<MockDatabase>();
      await db.sendForgotPasswordOtp(email);
      if (!mounted) return;
      _startCountdown();
      setState(() {
        _step = 1;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _handleVerifyOtp() async {
    final code = _enteredCode;
    if (code.length != 6) {
      setState(() => _errorMessage = 'Please enter all 6 digits.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final db = context.read<MockDatabase>();
      final email = _emailController.text.trim().toLowerCase();
      final isValid = await db.verifyEmailOtp(email: email, enteredCode: code);

      if (!mounted) return;
      if (isValid) {
        setState(() {
          _step = 2;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Incorrect verification code. Please check your inbox.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _handleResetPassword() async {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters.');
      return;
    }
    if (newPassword != confirmPassword) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final db = context.read<MockDatabase>();
      final email = _emailController.text.trim().toLowerCase();
      await db.resetPassword(email: email, newPassword: newPassword);

      if (!mounted) return;
      setState(() {
        _step = 3;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _handleResendOtp() async {
    if (_resendCountdown > 0) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final db = context.read<MockDatabase>();
      await db.sendForgotPasswordOtp(_emailController.text.trim().toLowerCase());
      if (!mounted) return;
      _startCountdown();
      for (final c in _codeControllers) {
        c.clear();
      }
      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const WaveHeader(height: 100),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  // Icon badge
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.paleGreen,
                      shape: BoxShape.circle,
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Icon(
                      _step == 3 ? Icons.check_circle_outline : Icons.lock_reset_rounded,
                      size: 38,
                      color: AppColors.primaryDarkGreen,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    _step == 0 ? 'Password Management'
                      : _step == 1 ? 'Enter Verification Code'
                      : _step == 2 ? 'Create New Password'
                      : 'Password Updated!',
                    style: GoogleFonts.merriweather(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_step == 0) ...[
                    const SizedBox(height: 4),
                    const Text(
                      'Managed by ADSSU DTC',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDarkGreen,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),

                  Text(
                    _step == 0 ? 'Enter your @adssu.edu.ph email to receive a 6-digit verification code.'
                      : _step == 1 ? 'Check your inbox at ${_emailController.text.trim()} for the 6-digit OTP.'
                      : _step == 2 ? 'Choose a strong new password for your account.'
                      : 'You can now log in with your new password.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.mutedGray,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.statusError.withAlpha(15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.statusError.withAlpha(40)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.statusError, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: AppColors.statusError, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Step 0: Email input
                  if (_step == 0) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Institutional Email',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'yourname@adssu.edu.ph',
                              prefixIcon: const Icon(Icons.email_outlined, size: 20),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primaryDarkGreen))
                      : PrimaryButton(
                          label: 'Send Verification Code',
                          icon: Icons.send_rounded,
                          onPressed: _handleSendOtp,
                        ),
                  ],

                  // Step 1: OTP input
                  if (_step == 1) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (i) {
                        return Container(
                          width: 46,
                          height: 56,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: TextField(
                            controller: _codeControllers[i],
                            focusNode: _focusNodes[i],
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.merriweather(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDarkGreen,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppColors.borderLight),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppColors.primaryDarkGreen, width: 2),
                              ),
                            ),
                            onChanged: (val) {
                              if (val.isNotEmpty && i < 5) {
                                _focusNodes[i + 1].requestFocus();
                              } else if (val.isEmpty && i > 0) {
                                _focusNodes[i - 1].requestFocus();
                              }
                            },
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primaryDarkGreen))
                      : PrimaryButton(
                          label: 'Verify Code',
                          icon: Icons.verified_outlined,
                          onPressed: _handleVerifyOtp,
                        ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _resendCountdown > 0 ? null : _handleResendOtp,
                      child: Text(
                        _resendCountdown > 0
                          ? 'Resend code in ${_resendCountdown}s'
                          : 'Resend Verification Code',
                        style: TextStyle(
                          color: _resendCountdown > 0 ? AppColors.mutedGray : AppColors.primaryDarkGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],

                  // Step 2: New password
                  if (_step == 2) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'New Password',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _newPasswordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'Enter new password (min. 6 characters)',
                              prefixIcon: const Icon(Icons.lock_outline, size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 20),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Confirm Password',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: 'Re-enter new password',
                              prefixIcon: const Icon(Icons.lock_outline, size: 20),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primaryDarkGreen))
                      : PrimaryButton(
                          label: 'Reset Password',
                          icon: Icons.lock_reset_rounded,
                          onPressed: _handleResetPassword,
                        ),
                  ],

                  // Step 3: Success
                  if (_step == 3) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.statusSuccess.withAlpha(15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.statusSuccess.withAlpha(40)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.statusSuccess, size: 24),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your password has been updated successfully. You can now sign in with your new password.',
                              style: TextStyle(fontSize: 13, color: AppColors.textDark, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Back to Login',
                      icon: Icons.login_rounded,
                      onPressed: () => context.go('/login'),
                    ),
                  ],

                  const SizedBox(height: 16),
                  if (_step != 3)
                    TextButton.icon(
                      onPressed: () {
                        if (_step > 0) {
                          setState(() {
                            _step--;
                            _errorMessage = null;
                          });
                        } else {
                          context.pop();
                        }
                      },
                      icon: const Icon(Icons.arrow_back_rounded, size: 16),
                      label: Text(
                        _step > 0 ? 'Go Back' : 'Back to Login',
                        style: const TextStyle(
                          color: AppColors.mutedGray,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
