import "package:flutter/material.dart";
import "package:crud_lab/services/auth_service.dart";
import 'package:crud_lab/users/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController txtLastName = TextEditingController();
  final TextEditingController txtFirstName = TextEditingController();
  final TextEditingController txtAge = TextEditingController();
  final TextEditingController txtEmail = TextEditingController();
  final TextEditingController txtPassword = TextEditingController();
  final TextEditingController txtConfirmPassword = TextEditingController();

  void register() async {
    String last_name = txtLastName.text.trim();
    String first_name = txtFirstName.text.trim();
    String age = txtAge.text.trim();
    String email = txtEmail.text.trim();
    String password = txtPassword.text.trim();
    String confirmPassword = txtConfirmPassword.text.trim();

    if (last_name.isEmpty ||
        first_name.isEmpty ||
        age.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill out all fields")),
      );
      return;
    }

    if (password != confirmPassword) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    // Call updated AuthService.register
    final result = await AuthService.register(
      lastName: last_name,
      firstName: first_name,
      age: age,
      email: email,
      password: password,
      passwordConfirmation: confirmPassword,
    );

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful! Please log in.")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      // Show detailed validation errors
      final errors = result['errors'] as Map<String, dynamic>;
      errors.forEach((field, messages) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "${field[0].toUpperCase()}${field.substring(1)}: ${messages.join(', ')}")),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF8F0), Color(0xFFD8A47F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1E6),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.shade200.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Icon(
                    Icons.coffee_outlined,
                    size: 80,
                    color: const Color(0xFFB58C6E),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Kofeetih?",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B6D5C),
                      fontFamily: 'Cursive',
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(txtLastName, "Last Name"),
                  const SizedBox(height: 16),
                  _buildTextField(txtFirstName, "First Name"),
                  const SizedBox(height: 16),
                  _buildTextField(txtAge, "Age", keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  _buildTextField(txtEmail, "Email", keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  _buildTextField(txtPassword, "Password", obscureText: true),
                  const SizedBox(height: 16),
                  _buildTextField(txtConfirmPassword, "Confirm Password", obscureText: true),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB58C6E),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        shadowColor: Colors.brown.shade200,
                        elevation: 6,
                      ),
                      child: const Text(
                        "Register",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      "Already have an account? Login",
                      style: TextStyle(color: Color(0xFF8B6D5C)),
                    ),
                  ),
                  const SizedBox(height: 10),
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
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF8B6D5C)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
