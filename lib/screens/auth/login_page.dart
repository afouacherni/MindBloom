import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../widgets/custom_text_field.dart'; // Import du widget
import '../../widgets/custom_button.dart';
import '../../utils/validators.dart';
import '../home/home_page.dart'; // Import de la HomePage
import 'signup_page.dart'; // Import de la SignUpPage
import 'forget_password_page.dart'; // Import de la ForgetPasswordPage

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
        title: const Text('Login'),
        elevation: 0,
        automaticallyImplyLeading:
            false, // Désactive le bouton retour par défaut
        // Ajout d'un bouton retour personnalisé si ce n'est pas la première page
        // Note: Pour la page de connexion, vous pouvez décider de ne pas ajouter de bouton retour
        // si c'est la première page de votre application. J'ai ajouté le code ci-dessous au cas où
        // cette page est accessible depuis une autre page.
        leading:
            Navigator.canPop(context)
                ? GestureDetector(
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
                )
                : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            const SizedBox(height: 32),
            CustomButton(
              label: 'Login',
              onPressed: () {
                // Simuler une connexion réussie et naviguer vers la HomePage
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Naviguer vers la page "Forgot Password"
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ForgetPasswordPage()),
                );
              },
              child: const Text('Forgot Password?'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Naviguer vers la page "Sign Up"
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
              child: const Text('Don\'t have an account? Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
