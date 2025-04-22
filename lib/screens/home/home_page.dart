import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Assure-toi d'avoir lucide_icons dans pubspec.yaml
import '../../constants/colors.dart';
import '../text_input/text_input_page.dart';
import '../voice/voice_input_page.dart';
import '../selfie/selfie_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Home'),
        elevation: 0,
        // Personnalisation du bouton retour
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Text(
              '<',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                'Choose an option to proceed',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 40),

            _buildAnimatedButton(
              context,
              icon: LucideIcons.edit,
              label: 'Enter Text',
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TextInputPage()),
                  ),
            ),

            const SizedBox(height: 20),

            _buildAnimatedButton(
              context,
              icon: LucideIcons.mic,
              label: 'Record Audio',
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VoiceInputPage()),
                  ),
            ),

            const SizedBox(height: 20),

            _buildAnimatedButton(
              context,
              icon: LucideIcons.camera,
              label: 'Take a Selfie',
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SelfiePage()),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white, size: 24),
        label: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 6,
          shadowColor: AppColors.primary.withOpacity(0.3),
        ),
        onPressed: onTap,
      ),
    );
  }
}
