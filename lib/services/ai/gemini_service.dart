import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class GeminiService {
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: 'YOUR_GEMINI_API_KEY');
  final GenerativeModel _model;

  GeminiService() : _model = GenerativeModel(
    model: 'gemini-3.5-flash',
    apiKey: _apiKey,
  );

  Future<String> generateWellnessInsights({
    required Duration totalScreenTime,
    required List<Map<String, dynamic>> topApps,
    required int unlockCount,
    required Map<String, dynamic> focusStats,
    required Map<String, dynamic> sleepStats,
  }) async {
    final prompt = """
You are an AI Digital Wellness Coach for an app called 'Drift Mind'. 
Analyze the following user data for today and provide exactly 3 short, high-impact insights and 2 actionable recommendations.

Data:
- Total Screen Time: ${totalScreenTime.inHours}h ${totalScreenTime.inMinutes % 60}m
- Top Apps: ${topApps.map((e) => "${e['name']} (${e['duration']})").join(', ')}
- Device Unlocks: $unlockCount times
- Focus Score: ${focusStats['focusScore']}% (Interruptions: ${focusStats['interruptions']})
- Last Night Sleep: ${sleepStats['duration']} (Bedtime: ${sleepStats['start']}, Wake: ${sleepStats['end']})

Format your response strictly as plain numbered lists (do not output JSON or codeblock wrappers):

Insights:
1. [Insight 1]
2. [Insight 2]
3. [Insight 3]

Recommendations:
1. [Recommendation 1]
2. [Recommendation 2]

Keep it professional, encouraging, and data-driven.
""";

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? "Insights unavailable right now. Stay focused on your goals!";
    } catch (e) {
      debugPrint("Gemini Error: $e");
      return """
Insights:
1. Your screen time is currently ${totalScreenTime.inHours}h ${totalScreenTime.inMinutes % 60}m today.
2. Focus score is ${focusStats['focusScore']}% with ${focusStats['interruptions']} interruptions.
3. $unlockCount phone unlocks logged today.

Recommendations:
1. Take a 10-minute screen break every hour.
2. Enable bedtime focus mode before sleep.
""";
    }
  }
}
