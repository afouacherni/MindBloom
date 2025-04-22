import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../constants/colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SelfiePage extends StatefulWidget {
  const SelfiePage({super.key});

  @override
  _SelfiePageState createState() => _SelfiePageState();
}

class _SelfiePageState extends State<SelfiePage> {
  File? _image;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      setState(() {
        _image = File(photo.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Créer un style de texte pour le bouton de retour texte
    final TextStyle backButtonStyle = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Take a Selfie'),
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading:
            false, // Désactive le bouton retour automatique
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
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
                    : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _image!,
                        width: 250,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
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
                if (_image != null)
                  Text(
                    'Image saved at:\n${_image!.path}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
