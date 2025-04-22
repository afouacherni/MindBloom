// lib/screens/text_input/text_input_page.dart

import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../widgets/custom_text_field.dart'; // Import du widget
import '../../widgets/custom_button.dart';

class TextInputPage extends StatelessWidget {
  TextInputPage({super.key}); // Retirer 'const' ici

  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Text Input'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(
              // Utilisation du CustomTextField
              controller: _textController,
              hintText: 'Write your thoughts...',
              obscureText: false,
            ),
            const SizedBox(height: 32),
            CustomButton(
              label: 'Submit',
              onPressed: () {
                // TODO: Envoyer le texte à l'API ou à Firebase
              },
            ),
          ],
        ),
      ),
    );
  }
}
