import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class TextInputPage extends StatelessWidget {
  TextInputPage({super.key});

  final TextEditingController _textController = TextEditingController();

  void _submitText(BuildContext context) {
    final text = _textController.text.trim();

    if (text.isEmpty) {
      _showErrorDialog(context, 'Please write something before submitting.');
      return;
    }

    // TODO: Envoyer le texte à l'API ou à Firebase
    _showConfirmationDialog(context);
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Submitted'),
            content: const Text(
              'Your thoughts have been successfully submitted.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Fermer le dialog
                  Navigator.pop(context); // Revenir en arrière
                },
                child: const Text('Back'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle backButtonStyle = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Write Your Feelings'),
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Text('<', style: backButtonStyle),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Image.asset(
              'assets/images/thou.jpg', // mets une belle image illustrant l'écriture
              height: 180,
            ),
            const SizedBox(height: 24),
            Text(
              "How are you feeling today?",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CustomTextField(
                  controller: _textController,
                  hintText: 'Write your thoughts...',
                  obscureText: false,
                  maxLines: 8,
                ),
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              label: 'Submit',
              onPressed: () => _submitText(context),
            ),
          ],
        ),
      ),
    );
  }
}
