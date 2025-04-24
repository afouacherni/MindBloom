import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mindbloom/widgets/emotion_graph.dart'; // Assure-toi que ce fichier existe bien
import '../../constants/colors.dart';
import '../text_input/text_input_page.dart';
import '../voice/voice_input_page.dart';
import '../selfie/selfie_page.dart';
import '../../widgets/back_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final String userName = 'Susan'; // À remplacer plus tard par Firebase

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Home'),
        elevation: 0,
        leading: const BackButtonWidget(),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------- Greeting --------
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(244, 131, 134, 96).withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Texte
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, $userName',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'You are not alone. Every emotion you feel matters.',
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Image
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: Image.asset(
                      'assets/images/back.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // -------- Input Buttons --------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  _buildAnimatedButton(
                    context,
                    icon: LucideIcons.edit,
                    label: 'Enter Text',
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TextInputPage(),
                          ),
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
                          MaterialPageRoute(
                            builder: (context) => const VoiceInputPage(),
                          ),
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
                          MaterialPageRoute(
                            builder: (context) => const SelfiePage(),
                          ),
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // -------- Emotion Graph Section --------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'View Emotion Graph',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  AspectRatio(aspectRatio: 1.5, child: EmotionGraphWidget()),
                ],
              ),
            ),
            const SizedBox(height: 32),
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
          shadowColor: AppColors.accent.withOpacity(0.3),
        ),
        onPressed: onTap,
      ),
    );
  }
}
