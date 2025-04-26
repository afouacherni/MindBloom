import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Initialise Firebase (pour Firestore, Auth, etc.)
  await Firebase.initializeApp();

  // 🧊 Initialise Supabase avec ton URL et ta clé
  await Supabase.initialize(
    url: 'https://xcieeonpxsirifymoohv.supabase.co', // Ton URL Supabase
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhjaWVlb25weHNpcmlmeW1vb2h2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU2MTAwMTYsImV4cCI6MjA2MTE4NjAxNn0.rOd2dita7BEmVnU9NhaOd2T76IO4j4H_NRbffI8dwk4', // Ta clé anonyme
  );

  runApp(const MindBloomApp());
}
