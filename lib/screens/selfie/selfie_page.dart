import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../constants/colors.dart';
import '../../widgets/back_button.dart';

class SelfiePage extends StatefulWidget {
  // Vous pouvez marquer le constructeur comme const
  const SelfiePage({Key? key}) : super(key: key);

  @override
  _SelfiePageState createState() => _SelfiePageState();
}

class _SelfiePageState extends State<SelfiePage> {
  File? _image;
  String? userId;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _getUserId();
  }

  // Récupérer l'ID de l'utilisateur authentifié
  Future<void> _getUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
    }
  }

  // Fonction pour choisir une image depuis la caméra
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      setState(() {
        _image = File(photo.path);
      });
    }
  }

  // Fonction pour télécharger la selfie
  Future<void> _uploadSelfie() async {
    if (_image == null || userId == null) {
      _showErrorDialog('No image selected or user not authenticated');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final fileName =
          '$userId/selfie-${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Upload le fichier à Supabase
      await Supabase.instance.client.storage
          .from('selfies')
          .upload(
            fileName,
            _image!,
            fileOptions: FileOptions(cacheControl: '3600'),
          );

      // Obtenir l'URL publique
      final selfieUrl = Supabase.instance.client.storage
          .from('selfies')
          .getPublicUrl(fileName);

      // Ajouter à Firestore
      await _addSelfieToFirestore(userId!, selfieUrl);

      _showConfirmationDialog();
    } catch (e) {
      _showErrorDialog('Failed to upload selfie: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // Ajouter la selfie à Firestore
  Future<void> _addSelfieToFirestore(String userId, String selfieUrl) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'selfies': FieldValue.arrayUnion([selfieUrl]),
      });
    } catch (e) {
      _showErrorDialog('Failed to update selfie: $e');
    }
  }

  // Fonction pour afficher un message d'erreur
  void _showErrorDialog(String message) {
    if (!mounted) return;

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

  // Fonction pour afficher un message de confirmation
  void _showConfirmationDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Selfie Submitted'),
            content: const Text('Your selfie has been successfully uploaded.'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take a Selfie'),
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
        leading: const BackButtonWidget(),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _image == null
                    ? AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent,
                            blurRadius: 10,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          size: 60,
                          color: Colors.white,
                        ),
                        onPressed: _pickImage,
                      ),
                    )
                    : Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            _image!,
                            width: 250,
                            height: 250,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _isUploading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: _uploadSelfie,
                              child: const Text(
                                'Upload Selfie',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                      ],
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
