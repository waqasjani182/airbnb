import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/common/app_button.dart';
import '../../components/common/app_text_field.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Clear any previous error messages
      setState(() {
        _errorMessage = null;
        _isLoading = true;
      });

      try {
        // Call the signup method on the auth provider
        await ref.read(authProvider.notifier).signup(
              _usernameController.text.trim(),
              _emailController.text.trim(),
              _passwordController.text,
              _addressController.text.trim(),
              _phoneController.text.trim(),
            );

        // Check if authentication was successful
        final authState = ref.read(authProvider);
        if (authState.isAuthenticated) {
          // Navigate to dashboard on successful signup
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.dashboard,
              (route) => false, // Remove all previous routes
            );
          }
        }
      } catch (e) {
        // Handle any errors
        if (mounted) {
          setState(() {
            _errorMessage = e.toString();
          });
        }
      } finally {
        // Reset loading state
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Listen for auth state changes
    Future.microtask(() {
      ref.listenManual(authProvider, (previous, current) {
        if (!mounted) return;

        // Update loading state
        setState(() {
          _isLoading = current.isLoading;
        });

        // Handle error state changes
        if (current.status == AuthStatus.error &&
            current.errorMessage != null) {
          // Update error message in the UI
          setState(() {
            _errorMessage = current.errorMessage;
          });

          // Show error notification
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(current.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
            opacity: 0.7,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Create an Account",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Username field
                  AppTextField(
                    controller: _usernameController,
                    label: "Username",
                    hint: "Enter your username",
                    prefixIcon: Icons.person,
                    validator: Validators.validateUsername,
                  ),

                  const SizedBox(height: 16),

                  // Email field
                  AppTextField(
                    controller: _emailController,
                    label: "Email",
                    hint: "Enter your email",
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email,
                    validator: Validators.validateEmail,
                  ),

                  const SizedBox(height: 16),
                  // Address field
                  AppTextField(
                    controller: _addressController,
                    label: "Address",
                    hint: "Enter your address",
                    prefixIcon: Icons.home,
                  ),

                  const SizedBox(height: 16),

                  // Phone field
                  AppTextField(
                    controller: _phoneController,
                    label: "Phone",
                    hint: "Enter your phone number",
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone,
                    validator: Validators.validatePhoneNumber,
                  ),

                  const SizedBox(height: 16),

                  // Password field
                  AppTextField(
                    controller: _passwordController,
                    label: "Password",
                    hint: "Enter your password",
                    obscureText: true,
                    prefixIcon: Icons.lock,
                    validator: Validators.validatePassword,
                  ),

                  const SizedBox(height: 16),

                  // Confirm password field
                  AppTextField(
                    controller: _confirmPasswordController,
                    label: "Confirm Password",
                    hint: "Confirm your password",
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                    validator: (value) => Validators.validateConfirmPassword(
                      value,
                      _passwordController.text,
                    ),
                  ),

                  // Error message
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 14,
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Sign up button
                  AppButton(
                    text: "Sign Up",
                    onPressed: _signup,
                    isLoading: _isLoading,
                    isFullWidth: true,
                  ),

                  const SizedBox(height: 16),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?"),
                      TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(
                            context, AppRoutes.login),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
