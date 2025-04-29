import 'package:flutter/material.dart';
import 'package:mindbloom/screens/home/home_page.dart';
import '../screens/home/home_page.dart';

Future<void> showSubmissionDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // Ne se ferme pas si on clique en dehors
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Soumission réussie'),
        content: const Text(
          'Souhaitez-vous faire une autre entrée ou voir votre score mis à jour ?',
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Faire une autre entrée'),
            onPressed: () {
              Navigator.of(context).pop(); // Ferme la boîte de dialogue
            },
          ),
          ElevatedButton(
            child: const Text('Voir le score'),
            onPressed: () {
              Navigator.of(context).pop(); // Ferme la boîte de dialogue
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
          ),
        ],
      );
    },
  );
}
