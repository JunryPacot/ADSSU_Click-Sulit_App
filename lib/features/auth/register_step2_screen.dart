import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/campus_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';

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
  bool _agreedToRules = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    return _passwordController.text.isNotEmpty &&
        _passwordController.text == _confirmPasswordController.text &&
        _agreedToRules;
  }

  void _handleRegister() {
    if (!_canSubmit) return;

    // 9 Register Step 2 → 10
    final data = {
      ...?widget.initialData,
      'college': _selectedCollege,
      'password': _passwordController.text,
    };

    context.push('/verify-code', extra: data);
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
        title: const Text('Campus & Security'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Campus & Security Credentials',
                style: TextStyle(
                  fontSize: 16,
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
                'Select your college',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              const Text(
                'This links your profile to your home department for relevant academic swaps.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.mutedGray,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // College Dropdown
              const Text(
                'ADSSU College / Department',
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
                  hintText: 'At least 8 characters',
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

              // Community Rules Checkbox & Link (9 Register Step 2 → Community Rules link → 83)
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
                  Expanded(
                    child: Wrap(
                      children: [
                        const Text(
                          'I agree to adhere to the official ',
                          style: TextStyle(fontSize: 13, color: AppColors.textDark),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/community-rules'),
                          child: const Text(
                            'ADSSU Community Rules & Circular Policy',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDarkGreen,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const Text(
                          ' for respectful exchanges.',
                          style: TextStyle(fontSize: 13, color: AppColors.textDark),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 9 Register Step 2 → 10
              PrimaryButton(
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
