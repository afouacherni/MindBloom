import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/emotion_graph.dart';

import 'package:mindbloom/widgets/emotional_score_gauge.dart'; // 👈 AJOUT ICI

import '../../constants/colors.dart';
import '../text_input/text_input_page.dart';
import '../voice/voice_input_page.dart';
import '../selfie/selfie_page.dart';
import '../chatbot/chatbot_screen.dart';
import '../../widgets/back_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Données de profil
  String? firstName;
  String? lastName;
  int? age;
  String? createdAt;

  // État de chargement
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  double emotionalScore = 0.76; // 👈 Valeur exemple (à remplacer dynamiquement)

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    // Initialisez les données dès le démarrage
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      debugPrint("Récupération du profil utilisateur");
      final user = supabase.auth.currentUser;

      if (user == null) {
        // Définir un état par défaut si aucun utilisateur n'est connecté
        if (!mounted) return;
        setState(() {
          firstName = 'Invité';
          lastName = '';
          age = null;
          createdAt = null;
          isLoading = false;
        });
        return;
      }

      // Récupération des données du profil
      final response =
          await supabase
              .from('profiles')
              .select('first_name, last_name, age, created_at')
              .eq('id', user.id)
              .maybeSingle(); // Utilisation de maybeSingle au lieu de single pour éviter les exceptions

      if (!mounted) return;

      if (response == null) {
        // Profil non trouvé
        setState(() {
          firstName = 'new user';
          lastName = '';
          age = null;
          createdAt = null;
          isLoading = false;
        });
        return;
      }

      // Définir les valeurs du profil
      setState(() {
        firstName = response['first_name'];
        lastName = response['last_name'];
        age = response['age'];

        // Formatage simple de la date sans le package intl
        if (response['created_at'] != null) {
          try {
            final dateTime = DateTime.parse(response['created_at']);
            createdAt = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
          } catch (e) {
            createdAt = 'Date invalide';
          }
        } else {
          createdAt = 'Non définie';
        }

        isLoading = false;
      });
    } catch (e) {
      debugPrint("Erreur lors de la récupération du profil: $e");
      if (!mounted) return;

      setState(() {
        firstName = 'Utilisateur';
        lastName = '';
        age = null;
        createdAt = null;
        isLoading = false;
        hasError = true;
        errorMessage = 'Impossible de charger le profil. Veuillez réessayer.';
      });
    }
  }

  String formatDateSimple(String? dateStr) {
    if (dateStr == null) return 'Date inconnue';
    return dateStr;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final String name = '${firstName ?? 'User'} ${lastName ?? ''}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('My Profile'),
        elevation: 0,
        leading: const BackButtonWidget(),
      ),
      // Corps de la page
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildPageContent(),
    );
  }

  // Méthode séparée pour le contenu principal
  Widget _buildPageContent() {
    // Afficher un message d'erreur si nécessaire
    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: fetchUserProfile,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    // Contenu normal si les données sont chargées sans erreur
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section d'accueil
            Container(
              width: double.infinity, // Force la largeur complète
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HI! ${firstName ?? 'Utilisateur'}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Feel free to express yourself here. This is your safe space.",
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),
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

            const SizedBox(height: 20),

            // 👇 AJOUT DU SCORE GAUGE
            Center(child: EmotionalScoreGauge(score: emotionalScore)),

            const SizedBox(height: 32),

            // Actions disponibles
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Actions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _actionButton(
                    context,
                    icon: LucideIcons.edit,
                    label: 'Edit My Profile',
                    onTap: () => _showEditProfileDialog(context),
                  ),
                  const SizedBox(height: 12),
                  _actionButton(
                    context,
                    icon: LucideIcons.mic,
                    label: 'Record an Audio',
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VoiceInputPage(),
                          ),
                        ),
                  ),
                  const SizedBox(height: 12),
                  _actionButton(
                    context,
                    icon: LucideIcons.activity,
                    label: 'Let Your Thoughts Flow',
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TextInputPage(),
                          ),
                        ),
                  ),
                  const SizedBox(height: 12),
                  _actionButton(
                    context,
                    icon: LucideIcons.camera,
                    label: 'Take a Selfie',
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SelfieUploadPage(),
                          ),
                        ),
                  ),
                  const SizedBox(height: 12),
                  _actionButton(
                    context,
                    icon: LucideIcons.messageCircle,
                    label: 'Engage with the Chatbot',
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChatbotScreen(),
                          ),
                        ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Graphique émotionnel (si disponible)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Your Emotional State",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: _buildEmotionGraphWithErrorHandling(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Ligne d'information de profil
  Widget _infoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Bouton d'action
  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 16),
              Expanded(child: Text(label)),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  // Dialogue de modification du profil
  void _showEditProfileDialog(BuildContext context) {
    final firstNameController = TextEditingController(text: firstName);
    final lastNameController = TextEditingController(text: lastName);
    final ageController = TextEditingController(text: age?.toString() ?? '');

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit my profile'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: firstNameController,
                    decoration: const InputDecoration(labelText: 'first_name'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: lastNameController,
                    decoration: const InputDecoration(labelText: 'last_name'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: ageController,
                    decoration: const InputDecoration(labelText: 'Age'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    // Conversion de l'âge
                    int? newAge;
                    if (ageController.text.isNotEmpty) {
                      newAge = int.tryParse(ageController.text);
                    }

                    // Mise à jour du profil
                    final user = supabase.auth.currentUser;
                    if (user != null) {
                      await supabase
                          .from('profiles')
                          .update({
                            'first_name': firstNameController.text,
                            'last_name': lastNameController.text,
                            'age': newAge,
                          })
                          .eq('id', user.id);

                      if (mounted) {
                        setState(() {
                          firstName = firstNameController.text;
                          lastName = lastNameController.text;
                          age = newAge;

                          // Ne pas mettre à jour created_at car ce n'est pas modifié
                        });
                      }
                    }

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile updated')),
                      );
                    }
                  } catch (e) {
                    debugPrint("Update failed: $e");
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error during update')),
                      );
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  // Gestion du graphique d'émotions
  Widget _buildEmotionGraphWithErrorHandling() {
    return Builder(
      builder: (context) {
        try {
          return EmotionGraphWidget();
        } catch (e) {
          debugPrint("Graph error: $e");
          return const Center(child: Text('Graph is currently unavailable'));
        }
      },
    );
  }
}
