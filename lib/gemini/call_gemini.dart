import 'package:google_generative_ai/google_generative_ai.dart';
import 'gemini_apikey.dart';

//geminiを呼び出す関数
Future<String> callGemini(String text) async {
  final model = GenerativeModel(
    model: 'gemini-pro',
    apiKey: geminiApiKey,
  );
  final content = [
    Content.text(text),
  ];
  final response = await model.generateContent(content);
  return response.text!;
}