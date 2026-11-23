import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';

class RegisterStep1Screen extends StatefulWidget {
  const RegisterStep1Screen({super.key});

  @override
  State<RegisterStep1Screen> createState() => _RegisterStep1ScreenState();
}

class _RegisterStep1ScreenState extends State<RegisterStep1Screen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isEmailValid = false;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateEmail);
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final text = _emailController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _isEmailValid = false;
        _emailError = null;
      });
      return;
    }

    // Accepts @adssu.edu.ph, gmail, or any valid email format
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final isValid = emailRegex.hasMatch(text);
    setState(() {
      _isEmailValid = isValid;
      _emailError = isValid ? null : 'Please enter a valid email address';
    });
  }

  bool get _canProceed {
    return _nameController.text.trim().isNotEmpty && _isEmailValid;
  }

  void _handleNext() {
    if (!_canProceed) return;

    // Pass registration params to step 2 via extra
    context.push(
      '/register-2',
      extra: {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
      },
    );
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
              // Campus Logo banner
              Center(
                child: Image.asset(
                  AppAssets.logo,
                  height: 44,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Step 1 of 2: Basic Information',
                style: TextStyle(
                  fontSize: 14,
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
                'Tell us your details',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Enter your full name and email to connect with your campus peers.',
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
              const SizedBox(height: 20),

              // Email Field (institutional or Gmail)
              const Text(
                'Email Address (Institutional or Gmail)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'name@adssu.edu.ph or name@gmail.com',
                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primaryDarkGreen),
                  suffixIcon: _isEmailValid
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.statusSuccess)
                      : null,
                  errorText: _emailError,
                ),
              ),
              const SizedBox(height: 36),

              // Next Button
              PrimaryButton(
                label: 'Continue to Password Setup',
                icon: Icons.arrow_forward_rounded,
                onPressed: _canProceed ? _handleNext : null,
              ),
              const SizedBox(height: 24),

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
