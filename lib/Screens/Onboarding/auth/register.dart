import 'package:flutter/material.dart';
import 'package:inkspire/Screens/Onboarding/auth/login.dart';
import 'package:inkspire/components/my_button.dart';
import 'package:inkspire/components/my_textfield.dart';
import 'package:inkspire/services/auth_services.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _othernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String _passwordError = '';
  bool _obscurePassword = true; // State for password visibility

  @override
  void dispose() {
    _firstnameController.dispose();
    _othernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Regular expression for password validation
  bool _isValidPassword(String password) {
    final regex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
    return regex.hasMatch(password);
  }

  void _validatePassword(String password) {
    if (password.isEmpty) {
      setState(() {
        _passwordError = '';
      });
      return;
    }

    if (password.length < 8) {
      setState(() {
        _passwordError = 'Password must be at least 8 characters';
      });
    } else if (!RegExp(r'[A-Za-z]').hasMatch(password)) {
      setState(() {
        _passwordError = 'Password must contain at least one letter';
      });
    } else if (!RegExp(r'\d').hasMatch(password)) {
      setState(() {
        _passwordError = 'Password must contain at least one number';
      });
    } else {
      setState(() {
        _passwordError = '';
      });
    }
  }

  Future<void> _handleRegister() async {
    if (_firstnameController.text.isEmpty ||
        _othernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showSnackBar('Please fill in all fields');
      return;
    }

    if (!_isValidPassword(_passwordController.text)) {
      _showSnackBar(
        'Password must be at least 8 characters and contain both letters and numbers',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.registerWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstname: _firstnameController.text.trim(),
        othername: _othernameController.text.trim(),
      );

      _showSnackBar('Registration successful!');
      Navigator.pushReplacementNamed(context, '/home');
      _clearFields();
    } catch (e) {
      _showSnackBar('Registration failed: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearFields() {
    _firstnameController.clear();
    _othernameController.clear();
    _emailController.clear();
    _passwordController.clear();
    setState(() {
      _passwordError = '';
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo.png', width: 150, height: 150),
                const SizedBox(height: 16),
                MyTextfield(
                  icon: Icons.person,
                  hint: 'Enter your first name',
                  controller: _firstnameController,
                ),
                const SizedBox(height: 16),
                MyTextfield(
                  icon: Icons.person,
                  hint: 'Enter your other name',
                  controller: _othernameController,
                ),
                const SizedBox(height: 16),
                MyTextfield(
                  icon: Icons.email,
                  hint: 'Enter your email',
                  controller: _emailController,
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyTextfield(
                      icon: Icons.lock,
                      hint: 'Enter your password',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      onChanged: _validatePassword,
                      trailing: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onTrailingPressed: _togglePasswordVisibility,
                    ),
                    if (_passwordError.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                        child: Text(
                          _passwordError,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    if (_passwordError.isEmpty &&
                        _passwordController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                        child: Text(
                          'Password meets requirements',
                          style: TextStyle(
                            color: Colors.green[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                MyButton(
                  title: _isLoading ? "Registering..." : "Register",
                  onTap: _isLoading ? null : _handleRegister,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an Account?',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Login(),
                          ),
                        );
                      },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 18,
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
    );
  }
}
