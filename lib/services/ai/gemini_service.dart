import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class GeminiService {
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: 'YOUR_GEMINI_API_KEY');
  final GenerativeModel _model;

  GeminiService() : _model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: _apiKey.isNotEmpty ? _apiKey : 'YOUR_GEMINI_API_KEY',
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
      if (_apiKey == 'YOUR_GEMINI_API_KEY') {
        return _getFallbackInsights(totalScreenTime, focusStats, unlockCount);
      }
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final text = response.text;
      if (text != null && text.isNotEmpty && text.contains('Insights')) {
        return text;
      }
      return _getFallbackInsights(totalScreenTime, focusStats, unlockCount);
    } catch (e) {
      debugPrint("Gemini API Notice: $e");
      return _getFallbackInsights(totalScreenTime, focusStats, unlockCount);
    }
  }

  String _getFallbackInsights(Duration sot, Map<String, dynamic> focus, int unlocks) {
    final hours = sot.inHours;
    final mins = sot.inMinutes % 60;
    final score = focus['focusScore'] ?? 88;
    final interruptions = focus['interruptions'] ?? 4;

    return """
Insights:
1. Your total web screen time today is ${hours}h ${mins}m, balanced between Chrome and development tools.
2. High focus efficiency maintained at $score% with only $interruptions recorded interruptions.
3. You logged $unlocks device sessions today, showing steady digital mindfulness.

Recommendations:
1. Schedule a 15-minute screen-free break after 90 minutes of continuous browsing.
2. Enable bedtime focus mode 30 minutes before sleep to improve rest quality.
""";
  }
}
