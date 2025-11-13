import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart'; // For User class
import '../../services/auth_service.dart'; // For AuthService
import '../../providers/session_provider.dart'; // For SessionProvider
import '../../providers/stock_provider.dart'; // For StockProvider

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }
    final pattern = RegExp(r'^\d{10}$');
    if (!pattern.hasMatch(value.trim())) {
      return 'Enter valid 10-digit phone number';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      String phone = _phoneController.text.trim();
      String password = _passwordController.text;

      // Call AuthService login with phone and password
      User? loggedInUser = await AuthService().login(phone, password);

      if (loggedInUser != null) {
        final sessionProvider = Provider.of<SessionProvider>(
          context,
          listen: false,
        );
        final stockProvider = Provider.of<StockProvider>(
          context,
          listen: false,
        );

        // No need to set shopName here since it's saved
        await sessionProvider.login(loggedInUser);
        await stockProvider.init(currentUser: loggedInUser.username);

        Navigator.pushReplacementNamed(context, '/dashboard');
      }
      if (loggedInUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed! Please check credentials'),
          ),
        );
        return;
      }

      // Shop name prompt removed as requested
      // final sessionProvider and stockProvider for session & data init
      final sessionProvider = Provider.of<SessionProvider>(
        context,
        listen: false,
      );
      final stockProvider = Provider.of<StockProvider>(context, listen: false);

      if (loggedInUser != null) {
        // If you want to persist shop name, can set here, omitted as per your request
        await sessionProvider.login(loggedInUser);
        await stockProvider.init(currentUser: loggedInUser.username);

        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = 24.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
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
                const Text(
                  'Enter your phone number and password to login',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Phone Number',
                    prefixText: '+91 ',
                  ),
                  validator: _validatePhone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Login'),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('OR'),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement Google Sign In functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Google Sign-In pressed')),
                      );
                    },
                    icon: Image.asset(
                      'assets/google_logo.png',
                      width: 24,
                      height: 24,
                    ),
                    label: const Text('Sign in with Google'),
                  ),
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: const Text.rich(
                    TextSpan(
                      text: "Don't have an account? ",
                      children: [
                        TextSpan(
                          text: "Sign up",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
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
