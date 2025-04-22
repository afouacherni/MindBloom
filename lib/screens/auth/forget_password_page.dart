import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../widgets/custom_text_field.dart'; // Import du widget
import '../../widgets/custom_button.dart';
import '../../utils/validators.dart';

class ForgetPasswordPage extends StatelessWidget {
  ForgetPasswordPage({super.key}); // Retirer 'const' ici

  final TextEditingController _emailController = TextEditingController();

  // Fonction simulée pour réinitialiser le mot de passe
  Future<void> _resetPassword(BuildContext context) async {
    final email = _emailController.text;

    // Vérifier si l'email est valide
    if (email.isEmpty || !email.contains('@')) {
      _showErrorDialog(context, 'Please enter a valid email.');
      return;
    }

    // Simuler l'envoi d'un email de réinitialisation
    await Future.delayed(
      const Duration(seconds: 2),
    ); // Simuler un délai de 2 secondes

    // Afficher un message de confirmation
    _showConfirmationDialog(context);
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Forgot Password'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(
              // Utilisation du CustomTextField
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
