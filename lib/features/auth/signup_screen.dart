import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart'; // Add this
import '../../models/user.dart'; // Add this
import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;

  String? _validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter phone number';
    }
    final pattern = RegExp(r'^\d{10}$');
    if (!pattern.hasMatch(value.trim())) {
      return 'Enter valid 10-digit phone number';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final username = _phoneController.text.trim();
    final password = _passwordController.text;
    final ownerName = _ownerNameController.text.trim();
    final shopName = _shopNameController.text.trim();

    // For your sign up, you can adjust to your User model as needed
    // Here username = phone number, password is hashed inside AuthService.signUp()

    try {
      final authService = AuthService();
      final success = await authService.signUp(username, password);

      setState(() {
        _isLoading = false;
      });

      if (success) {
        // Optional: You may want to save owner/shop name somewhere; currently your User only stores username/password hash.
        // You can add these fields in your User model and update here accordingly.
        final userBox = Hive.box<User>('users');
        final user = userBox.values.firstWhere((u) => u.username == username);
        user.shopName = _shopNameController.text.trim();
        await user.save();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup successful! Please login.')),
        );

        // Navigate to login screen (adjust route name as per your app)
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        // User already exists
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User already exists with this phone number.'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Signup failed: $e')));
    }
  }

  @override
  void dispose() {
    _ownerNameController.dispose();
    _shopNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = 24.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _ownerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => _validateNotEmpty(v, 'name'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _shopNameController,
                  decoration: const InputDecoration(
                    labelText: 'Shop Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => _validateNotEmpty(v, 'shop name'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    prefixText: '+91 ',
                  ),
                  validator: _validatePhone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateConfirmPassword,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          )
                        : const Text('Sign Up'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
