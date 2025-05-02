import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class EmotionalScoreGauge extends StatelessWidget {
  final double score; // entre 0.0 et 1.0

  const EmotionalScoreGauge({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: 100.0,
      lineWidth: 15.0,
      animation: true,
      percent: score,
      center: Text(
        "${(score * 100).toInt()}%",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0),
      ),
      footer: const Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Text("État émotionnel", style: TextStyle(fontSize: 16.0)),
      ),
      circularStrokeCap: CircularStrokeCap.round,
      progressColor:
          score > 0.7
              ? Colors.green
              : score > 0.4
              ? Colors.orange
              : Colors.red,
      backgroundColor: Colors.grey.shade200,
    );
  }
}
