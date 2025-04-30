import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindbloom/widgets/back_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../constants/colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class TextInputPage extends StatelessWidget {
  TextInputPage({super.key});

  final TextEditingController _textController = TextEditingController();
  final CollectionReference usersCollection = FirebaseFirestore.instance
      .collection('users');
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> _submitText(BuildContext context) async {
    final text = _textController.text.trim();

    if (text.isEmpty) {
      _showErrorDialog(context, 'Please write something before submitting.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorDialog(context, 'User not authenticated');
      return;
    }

    String userId = user.uid;

    try {
      await usersCollection.doc(userId).collection('thoughts').add({
        'content': text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _showNextStepDialog(context); // ← Affiche les options après soumission
    } catch (e) {
      _showErrorDialog(context, 'Failed to submit: $e');
    }
  }

  Future<void> _uploadSelfie(
    BuildContext context,
    String userId,
    String filePath,
  ) async {
    try {
      final file = File(filePath);
      final fileName =
          '$userId/selfie-${DateTime.now().millisecondsSinceEpoch}.jpg';

      await supabase.storage
          .from('selfies')
          .upload(
            fileName,
            file,
            fileOptions: FileOptions(cacheControl: '3600'),
          );

      final selfieUrl = supabase.storage.from('selfies').getPublicUrl(fileName);

      await _addSelfieToFirestore(context, userId, selfieUrl);
    } catch (e) {
      _showErrorDialog(context, 'Failed to upload selfie: $e');
    }
  }

  Future<void> _addSelfieToFirestore(
    BuildContext context,
    String userId,
    String selfieUrl,
  ) async {
    try {
      await usersCollection.doc(userId).update({
        'selfies': FieldValue.arrayUnion([selfieUrl]),
      });
    } catch (e) {
      _showErrorDialog(context, 'Failed to update selfie: $e');
    }
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

  void _showNextStepDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('What would you like to do next?'),
            content: const Text(
              'Your thoughts have been submitted successfully.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/home'); // ← Correction ici
                },
                child: const Text('View Score'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/selfie');
                },
                child: const Text('Take a Selfie'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/voice_input');
                },
                child: const Text('Record Voice'),
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
        title: const Text('Write Your Feelings'),
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: const BackButtonWidget(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Image.asset('assets/images/thou.jpg', height: 180),
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
