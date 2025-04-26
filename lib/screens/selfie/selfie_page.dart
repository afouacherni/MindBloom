import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mindbloom/widgets/back_button.dart';
import 'dart:io';
import '../../constants/colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SelfiePage extends StatefulWidget {
  const SelfiePage({super.key});

  @override
  _SelfiePageState createState() => _SelfiePageState();
}

class _SelfiePageState extends State<SelfiePage> {
  File? _image;
  String? userId;
  bool _isUploading = false;
  TextEditingController _thoughtController = TextEditingController();

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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      setState(() {
        _image = File(photo.path);
      });
    }
  }

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

  // Ajouter les pensées à Firestore
  Future<void> _addThoughtToFirestore(String userId, String thought) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'thoughts': FieldValue.arrayUnion([thought]),
      });
    } catch (e) {
      _showErrorDialog('Failed to update thought: $e');
    }
  }

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
                        icon: FaIcon(
                          FontAwesomeIcons.camera,
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
                const SizedBox(height: 20),
                Text(
                  _image == null ? 'Tap to take a selfie' : 'Selfie captured!',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                // Champ de texte pour saisir les pensées
                TextField(
                  controller: _thoughtController,
                  decoration: const InputDecoration(
                    labelText: 'Enter your thoughts',
                    labelStyle: TextStyle(color: Colors.white),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
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
                  onPressed: () async {
                    if (_thoughtController.text.isNotEmpty && userId != null) {
                      await _addThoughtToFirestore(
                        userId!,
                        _thoughtController.text,
                      );
                      _thoughtController
                          .clear(); // Vide le champ après soumission
                      _showConfirmationDialog();
                    } else {
                      _showErrorDialog('Please enter a thought.');
                    }
                  },
                  child: const Text(
                    'Submit Thought',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
