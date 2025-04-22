import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../widgets/custom_text_field.dart'; // Import du widget
import '../../widgets/custom_button.dart';
import '../../utils/validators.dart';
import '../home/home_page.dart'; // Import de la HomePage

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Style du texte pour le bouton retour
    final TextStyle backButtonStyle = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Sign Up'),
        elevation: 0,
        automaticallyImplyLeading:
            false, // Désactive le bouton retour par défaut
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Text('<', style: backButtonStyle),
          ),
        ),
      ),
      body: SingleChildScrollView(
        // Ajout d'un SingleChildScrollView pour permettre le défilement
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextField(
                controller: _firstNameController,
                hintText: 'First Name',
                obscureText: false,
                validator: Validators.validateName,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _lastNameController,
                hintText: 'Last Name',
                obscureText: false,
                validator: Validators.validateName,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                hintText: 'Email',
                obscureText: false,
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                hintText: 'Password',
                obscureText: true,
                validator: Validators.validatePassword,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _confirmPasswordController,
                hintText: 'Confirm Password',
                obscureText: true,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _ageController,
                hintText: 'Age',
                obscureText: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid age';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              CustomButton(
                label: 'Sign Up',
                onPressed: () {
                  // Simuler une inscription réussie et naviguer vers la HomePage
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Retour à la page de connexion
                  Navigator.pop(context);
                },
                child: const Text('Already have an account? Sign in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
