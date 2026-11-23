import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/campus_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/mock/mock_database.dart';

class RegisterStep2Screen extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const RegisterStep2Screen({super.key, this.initialData});

  @override
  State<RegisterStep2Screen> createState() => _RegisterStep2ScreenState();
}

class _RegisterStep2ScreenState extends State<RegisterStep2Screen> {
  String _selectedCollege = CampusConstants.colleges.first;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _agreedToRules = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    return _passwordController.text.length >= 6 &&
        _passwordController.text == _confirmPasswordController.text &&
        _agreedToRules &&
        !_isLoading;
  }

  Future<void> _handleRegister() async {
    if (!_canSubmit) return;

    setState(() => _isLoading = true);

    try {
      final db = context.read<MockDatabase>();
      final name = widget.initialData?['name']?.toString() ?? 'Student User';
      final email = widget.initialData?['email']?.toString() ?? 'user@adssu.edu.ph';

      await db.registerUser(
        name: name,
        email: email,
        college: _selectedCollege,
        studentId: '',
        password: _passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully! Welcome to ADSSU Click & Sulit.'),
          backgroundColor: AppColors.primaryDarkGreen,
        ),
      );

      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration error: ${e.toString()}'),
          backgroundColor: AppColors.statusError,
        ),
      );
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
        title: const Text('Password Setup'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Center(
                child: Image.asset(
                  AppAssets.logo,
                  height: 44,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Step 2 of 2: Security & College',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDarkGreen,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: 1.0,
                backgroundColor: AppColors.paleGreen,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryDarkGreen),
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 24),

              Text(
                'Create your password',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose your college and set a secure password for your account.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.mutedGray,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // College Dropdown
              const Text(
                'College / Department',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCollege,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryDarkGreen),
                    items: CampusConstants.colleges.map((college) {
                      return DropdownMenuItem<String>(
                        value: college,
                        child: Text(
                          college,
                          style: const TextStyle(fontSize: 13, color: AppColors.textDark),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedCollege = val);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Password
              const Text(
                'Create Password',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'At least 6 characters',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primaryDarkGreen),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.mutedGray,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Confirm Password
              const Text(
                'Confirm Password',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscurePassword,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Re-enter your password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primaryDarkGreen),
                  errorText: _confirmPasswordController.text.isNotEmpty &&
                          _confirmPasswordController.text != _passwordController.text
                      ? 'Passwords do not match'
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              // Agreement Checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _agreedToRules,
                      activeColor: AppColors.primaryDarkGreen,
                      onChanged: (val) {
                        setState(() => _agreedToRules = val ?? false);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'I agree to adhere to the official ADSSU Community Rules and Circular Economy policy for safe peer-to-peer exchanges.',
                      style: TextStyle(fontSize: 12, color: AppColors.textDark, height: 1.3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryDarkGreen))
                  : PrimaryButton(
                      label: 'Create Account',
                      icon: Icons.check_circle_outline_rounded,
                      onPressed: _canSubmit ? _handleRegister : null,
                    ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
