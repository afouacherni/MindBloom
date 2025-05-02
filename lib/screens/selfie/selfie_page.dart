import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../constants/colors.dart';
import 'package:mindbloom/widgets/back_button.dart';

class SelfieUploadPage extends StatefulWidget {
  const SelfieUploadPage({super.key});

  @override
  State<SelfieUploadPage> createState() => _SelfieUploadPageState();
}

class _SelfieUploadPageState extends State<SelfieUploadPage> {
  File? _image;
  bool _loading = false;
  final ImagePicker _picker = ImagePicker();
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> _uploadSelfie() async {
    if (_image == null) return;

    final user = _supabase.auth.currentUser;
    if (user == null) {
      _showErrorDialog('User not authenticated');
      return;
    }

    setState(() => _loading = true);

    try {
      // 1. Upload vers Supabase Storage
      final fileName =
          'selfies/${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _supabase.storage.from('user-selfies').upload(fileName, _image!);

      // 2. Récupérer l'URL publique
      final publicUrl = _supabase.storage
          .from('user-selfies')
          .getPublicUrl(fileName);

      // 3. Enregistrer dans la table selfie_records
      await _supabase.from('selfie_records').insert({
        'user_id': user.id,
        'file_path': fileName,
        'url': publicUrl,
        'created_at': DateTime.now().toIso8601String(),
      });

      _showSuccessDialog();
    } catch (e) {
      _showErrorDialog('Upload failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Your selfie has been uploaded successfully!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Selfie'),
        backgroundColor: AppColors.primary,
        leading: const BackButtonWidget(),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image != null
                ? Image.file(_image!, height: 200)
                : const Icon(Icons.camera_alt, size: 100, color: Colors.grey),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Take Selfie'),
            ),
            const SizedBox(height: 20),
            if (_image != null)
              ElevatedButton(
                onPressed: _loading ? null : _uploadSelfie,
                child:
                    _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Upload to Supabase'),
              ),
          ],
        ),
      ),
    );
  }
}
