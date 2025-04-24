import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../constants/colors.dart';
import '../text_input/text_input_page.dart';
import '../voice/voice_input_page.dart';
import '../selfie/selfie_page.dart';
import '../../widgets/back_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 239, 167, 129),
        title: const Text('Home'),
        elevation: 0,
        leading: const BackButtonWidget(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
              child: Text(
                'Choose an option to proceed',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 243, 167, 126),
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
                    MaterialPageRoute(builder: (context) => const SelfiePage()),
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
          backgroundColor: const Color.fromARGB(255, 240, 164, 123),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 6,
          shadowColor: const Color.fromARGB(
            255,
            237,
            159,
            118,
          ).withOpacity(0.3),
        ),
        onPressed: onTap,
      ),
    );
  }
}
