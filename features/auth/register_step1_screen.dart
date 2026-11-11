import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/campus_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/google_logo.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/mock/mock_database.dart';
import '../../data/services/firebase_service.dart';

class RegisterStep1Screen extends StatefulWidget {
  const RegisterStep1Screen({super.key});

  @override
  State<RegisterStep1Screen> createState() => _RegisterStep1ScreenState();
}

class _RegisterStep1ScreenState extends State<RegisterStep1Screen> {
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _studentIdFocusNode = FocusNode();

  bool _isEmailValid = false;
  String? _emailError;
  bool _isLoadingGoogle = false;
  String? _googlePhotoUrl;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (FirebaseService().isInitialized) {
        try {
          final u = FirebaseService().auth.currentUser;
          if (u != null && mounted && _nameController.text.isEmpty && _emailController.text.isEmpty) {
            final email = (u.email ?? '').trim().toLowerCase();
            if (email.endsWith('@adssu.edu.ph')) {
              final name = u.displayName?.trim().isNotEmpty == true
                  ? u.displayName!
                  : email.split('@').first.toUpperCase();
              setState(() {
                _nameController.text = name;
                _emailController.text = email;
                _googlePhotoUrl = u.photoURL;
                _validateEmail();
              });
              _studentIdFocusNode.requestFocus();
            }
          }
        } catch (_) {}
      }
    });
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateEmail);
    _nameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _studentIdFocusNode.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final text = _emailController.text.trim().toLowerCase();
    if (text.isEmpty) {
      setState(() {
        _isEmailValid = false;
        _emailError = null;
      });
      return;
    }

    final isValid = CampusConstants.emailRegex.hasMatch(text);
    setState(() {
      _isEmailValid = isValid;
      _emailError = isValid ? null : 'Must be an official @adssu.edu.ph institutional address';
    });
  }

  bool get _canProceed {
    return _nameController.text.trim().isNotEmpty &&
        _studentIdController.text.trim().isNotEmpty &&
        _isEmailValid;
  }

  void _handleNext() {
    if (!_canProceed) return;

    // 8 Register Step 1 → 9
    // Pass registration params to step 2 via query params or extra
    context.push(
      '/register-2',
      extra: {
        'name': _nameController.text.trim(),
        'studentId': _studentIdController.text.trim(),
        'email': _emailController.text.trim(),
        if (_googlePhotoUrl != null && _googlePhotoUrl!.isNotEmpty)
          'profilePhoto': _googlePhotoUrl,
      },
    );
  }

  Future<void> _handleGoogleSignUp() async {
    setState(() {
      _isLoadingGoogle = true;
    });

    try {
      final db = context.read<MockDatabase>();
      final account = await db.authRepo.getGoogleAccountForRegistration();
      if (!mounted) return;

      final name = account['name'] ?? '';
      final email = account['email'] ?? '';
      final photoUrl = account['photoUrl'];

      setState(() {
        _nameController.text = name;
        _emailController.text = email;
        _googlePhotoUrl = photoUrl;
        _validateEmail();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connected with Google ($email)! Please enter your Student or Employee ID to proceed.'),
          backgroundColor: AppColors.primaryDarkGreen,
          duration: const Duration(seconds: 4),
        ),
      );

      _studentIdFocusNode.requestFocus();
    } catch (e) {
      if (!mounted) return;
      final err = e.toString().toLowerCase();
      if (err.contains('cancel') || err.contains('cancelled') || err.contains('canceled')) {
        return;
      }
      if (err.contains('popup-blocked')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Browser blocked the Google popup! Please click the "Pop-up blocked" icon in your URL bar to allow it, or test directly at http://localhost:8080.'),
            backgroundColor: AppColors.statusError,
            duration: Duration(seconds: 5),
          ),
        );
        return;
      }
      if (err.contains('email-already-in-use') || err.contains('already registered')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '').replaceAll('FirebaseAuthException: ', '')),
            backgroundColor: AppColors.statusError,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Sign In',
              textColor: Colors.white,
              onPressed: () => context.go('/login'),
            ),
          ),
        );
        return;
      }
      if (err.contains('invalid-email-domain') || err.contains('@adssu.edu.ph')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Access restricted: Only official Agusan del Sur State University accounts (@adssu.edu.ph) are permitted to register.'),
            backgroundColor: AppColors.statusError,
            duration: Duration(seconds: 5),
          ),
        );
        return;
      }
      final msg = e.toString().contains('ApiException: 10')
          ? 'Google Sign-In (ApiException 10): SHA-1 fingerprint needs to be added in Firebase Console.'
          : 'Google Sign-Up: $e';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.statusError,
          duration: const Duration(seconds: 5),
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Create Account'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Student Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDarkGreen,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: 0.5,
                backgroundColor: AppColors.paleGreen,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryDarkGreen),
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 24),

              Text(
                'Tell us about yourself',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Your institutional information ensures verified, safe transactions across the ADSSU campus.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.mutedGray,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // Full Name Field
              const Text(
                'Full Name',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'e.g. Maria Santos',
                  prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.primaryDarkGreen),
                ),
              ),
              const SizedBox(height: 16),

              // Student / Employee ID Field
              const Text(
                'Student or Employee ID',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _studentIdController,
                focusNode: _studentIdFocusNode,
                textCapitalization: TextCapitalization.characters,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'e.g. 2024-CCIS-0142',
                  prefixIcon: Icon(Icons.badge_outlined, color: AppColors.primaryDarkGreen),
                ),
              ),
              const SizedBox(height: 16),

              // Institutional Email Field with inline validation
              const Text(
                'Institutional Email (@adssu.edu.ph)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'name@adssu.edu.ph',
                  prefixIcon: const Icon(Icons.school_outlined, color: AppColors.primaryDarkGreen),
                  suffixIcon: _isEmailValid
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.statusSuccess)
                      : null,
                  errorText: _emailError,
                ),
              ),
              const SizedBox(height: 32),

              // 8 Register Step 1 â†’ 9: Disabled until email valid and fields filled
              PrimaryButton(
                label: 'Continue to Step 2',
                icon: Icons.arrow_forward_rounded,
                onPressed: _canProceed ? _handleNext : null,
              ),
              const SizedBox(height: 16),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.borderLight, thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'or create account with',
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

              // Google Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _isLoadingGoogle ? null : _handleGoogleSignUp,
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
                              'Sign up with Google',
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
              const SizedBox(height: 20),

              Center(
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text(
                    'Already have an account? Sign In',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDarkGreen,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


