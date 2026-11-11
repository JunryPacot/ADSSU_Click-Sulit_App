import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/campus_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/mock/mock_database.dart';

class VerifyCodeScreen extends StatefulWidget {
  final Map<String, dynamic>? registrationData;

  const VerifyCodeScreen({super.key, this.registrationData});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final List<TextEditingController> _codeControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  String? _errorMessage;
  bool _isLoading = false;
  bool _isSending = false;

  int _resendCountdown = 30;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendCode();
    });
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _resendCountdown = 30;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCountdown > 1) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        setState(() {
          _resendCountdown = 0;
        });
        timer.cancel();
      }
    });
  }

  Future<void> _sendCode() async {
    final email = widget.registrationData?['email'] ??
        context.read<MockDatabase>().currentUser.email;

    setState(() {
      _isSending = true;
      _errorMessage = null;
    });

    try {
      await context.read<MockDatabase>().sendVerificationOtp(email);
      if (mounted) {
        _startCountdown();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not send verification code: ${e.toString().replaceAll("Exception: ", "")}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (final c in _codeControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _enteredCode =>
      _codeControllers.map((c) => c.text.trim()).join();

  void _handleVerify() async {
    final code = _enteredCode;
    if (code.length != 6) {
      setState(() {
        _errorMessage = 'Please enter all 6 digits of the verification code.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final db = context.read<MockDatabase>();
    final email = widget.registrationData?['email'] ?? db.currentUser.email;

    try {
      final isValid = await db.verifyEmailOtp(
        email: email,
        enteredCode: code,
      );

      if (!mounted) return;

      if (isValid) {
        if (widget.registrationData != null) {
          await db.registerUser(
            name: widget.registrationData!['name'] ?? 'New Student',
            email: widget.registrationData!['email'] ?? 'student@adssu.edu.ph',
            college: widget.registrationData!['college'] ?? CampusConstants.colleges.first,
            studentId: widget.registrationData!['studentId'] ?? '2024-ADSSU-0001',
            password: widget.registrationData!['password'] ?? 'AdssuSecure123!',
            profilePhoto: widget.registrationData!['profilePhoto'],
          );
        }
        if (!mounted) return;
        context.go('/account-submitted');
      } else {
        setState(() {
          _errorMessage = 'Incorrect 6-digit verification code. Please check your email inbox and try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.registrationData?['email'] ??
        context.read<MockDatabase>().currentUser.email;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Verify Email'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: AppColors.paleGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_read_rounded,
                  size: 40,
                  color: AppColors.primaryDarkGreen,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Enter 6-Digit Code',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),

              Text(
                'We sent a confidential 6-digit one-time passcode to:',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.mutedGray,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 4),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.paleGreen.withAlpha(120),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDarkGreen,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Privacy & Security Notice Card (NO OTP SHOWN - Strict privacy adherence)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2.0),
                      child: Icon(
                        Icons.shield_outlined,
                        size: 22,
                        color: AppColors.primaryDarkGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Confidential Email Verification',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'For your privacy and account security, the one-time code is sent exclusively to your inbox. Check your Gmail inbox, Spam, or Promotions tab to retrieve it.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.mutedGray,
                              height: 1.4,
                            ),
                          ),
                          if (_isSending) ...[
                            const SizedBox(height: 8),
                            const Row(
                              children: [
                                SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primaryDarkGreen,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Dispatching code to your inbox...',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primaryDarkGreen,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 6 PIN Input Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  return Container(
                    width: 44,
                    height: 52,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextField(
                      controller: _codeControllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        filled: true,
                        fillColor: AppColors.cardWhite,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.primaryDarkGreen,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (val) {
                        if (val.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (val.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        setState(() => _errorMessage = null);
                      },
                    ),
                  );
                }),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.statusError, fontSize: 12),
                  ),
                ),
              ],
              const SizedBox(height: 28),

              // Verify Button
              PrimaryButton(
                label: _isLoading ? 'Verifying...' : 'Verify & Activate Account',
                icon: Icons.check_circle_rounded,
                onPressed: (_enteredCode.length == 6 && !_isLoading) ? _handleVerify : null,
              ),
              const SizedBox(height: 20),

              // Resend Action with Cooldown
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Didn't receive the code? ",
                    style: TextStyle(fontSize: 13, color: AppColors.mutedGray),
                  ),
                  if (_resendCountdown > 0)
                    Text(
                      'Resend in ${_resendCountdown}s',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mutedGray,
                      ),
                    )
                  else
                    TextButton(
                      onPressed: _isSending
                          ? null
                          : () async {
                              await _sendCode();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('A new 6-digit code has been sent to $email.'),
                                    backgroundColor: AppColors.primaryDarkGreen,
                                    duration: const Duration(seconds: 4),
                                  ),
                                );
                              }
                            },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryDarkGreen,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text(
                        'Resend Code',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
