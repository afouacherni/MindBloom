import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import de Firebase Auth
import 'package:mindbloom/widgets/back_button.dart';
import '../../constants/colors.dart';
import '../../widgets/custom_text_field.dart'; // Import du widget
import '../../widgets/custom_button.dart';
import '../../utils/validators.dart';

class ForgetPasswordPage extends StatelessWidget {
  ForgetPasswordPage({super.key});

  final TextEditingController _emailController = TextEditingController();

  // Fonction pour réinitialiser le mot de passe via Firebase Auth
  Future<void> _resetPassword(BuildContext context) async {
    final email = _emailController.text;

    // Vérifier si l'email est valide
    if (email.isEmpty || !email.contains('@')) {
      _showErrorDialog(context, 'Please enter a valid email.');
      return;
    }

    try {
      // Appel Firebase Auth pour envoyer un lien de réinitialisation de mot de passe
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // Afficher un message de confirmation
      _showConfirmationDialog(context);
    } catch (e) {
      // Si une erreur se produit, afficher un message d'erreur
      _showErrorDialog(context, 'Error: $e');
    }
  }

  // Fonction pour afficher un message d'erreur
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  // Fonction pour afficher un message de confirmation
  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Email Sent'),
            content: const Text(
              'A password reset link has been sent to your email.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Fermer la boîte de dialogue
                  Navigator.pop(context); // Retourner à la page de connexion
                },
                child: const Text('Back to Login'),
              ),
            ],
          ),
    );
  }

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
        title: const Text('Forgot Password'),
        elevation: 0,
        automaticallyImplyLeading:
            false, // Désactive le bouton retour par défaut
        leading: const BackButtonWidget(),
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
            const SizedBox(height: 32),
            CustomButton(
              label: 'Reset Password',
              onPressed: () {
                _resetPassword(
                  context,
                ); // Appeler la fonction de réinitialisation
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Naviguer vers la page "Login"
              },
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
