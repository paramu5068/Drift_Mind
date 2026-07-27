import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class GeminiService {
  static const String _apiKey = 'AIzaSyBpVEH9T3-6Yp7SZAjniEUJzhBx7JVrvgA';
  final GenerativeModel _model;

  GeminiService() : _model = GenerativeModel(
    model: 'gemini-3-flash-preview',
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
    
    Format the output as a JSON-like structure (but just text) with:
    Insights:
    1. [Insight 1]
    2. [Insight 2]
    3. [Insight 3]
    
    Recommendations:
    1. [Rec 1]
    2. [Rec 2]
    
    Keep it professional, encouraging, and data-driven.
    """;

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? "I couldn't analyze your data right now. Keep up the good work!";
    } catch (e) {
      debugPrint("Gemini Error: $e");
      return "Analysis unavailable. Focus on your goals today!";
    }
  }
}
