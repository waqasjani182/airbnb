import 'package:flutter/material.dart';

class MySignUp extends StatefulWidget {
  const MySignUp({super.key}); // Added constructor with key

  @override
  _MySignUpState createState() => _MySignUpState();
}

class _MySignUpState extends State<MySignUp> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController(); // Added Address controller
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _addressController.dispose(); // Dispose Address controller
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signUp() {
    if (_formKey.currentState?.validate() ?? false) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign-up successful!')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE6E6),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'SIGN UP',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF0004), // Changed title color to #FF0004
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildTextField(_usernameController, 'Username'),
                  const SizedBox(height: 20),
                  _buildTextField(_emailController, 'Email',
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 20),
                  _buildTextField(_addressController, 'Address'), // Added Address field
                  const SizedBox(height: 20),
                  _buildTextField(_phoneController, 'Phone',
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 20),
                  _buildTextField(_passwordController, 'Password',
                      obscureText: true),
                  const SizedBox(height: 20),
                  _buildTextField(_confirmPasswordController, 'Confirm Password',
                      obscureText: true),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF0004), // Changed button color to #FF0004
                    ),
                    child: const Text('SIGN UP'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(color: Colors.black), // Changed text color to black
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: Color(0xFFFF0004), // Changed Login button color to #FF0004
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

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label is required';
        }
        return null;
      },
    );
  }
}