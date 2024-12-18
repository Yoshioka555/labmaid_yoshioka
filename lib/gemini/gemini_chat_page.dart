import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:labmaidfastapi/gemini/call_gemini.dart';

class GeminiChatPage extends StatefulWidget {
  const GeminiChatPage({Key? key}) : super(key: key);

  @override
  GeminiChatPageState createState() => GeminiChatPageState();
}

class GeminiChatPageState extends State<GeminiChatPage> {
  final List<types.Message> _messages = [];

  final _gemini = const types.User(
    id: 'gemini',
    firstName: "Gemini",
  );

  final _user = const types.User(
    id: 'user',
    firstName: "User",
  );

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  Future<void> _handleSendPressed(types.PartialText message) async {
    final textMessage = types.TextMessage(
      author: _user,
      //createdAt: DateTime.now().millisecondsSinceEpoch,
      id: DateTime.now().toString(),
      text: message.text,
    );
    _addMessage(textMessage);
    final response = await callGemini(message.text);
    final geminiResponse = types.TextMessage(
      author: _gemini,
      //createdAt: DateTime.now().millisecondsSinceEpoch,
      id: DateTime.now().toString(),
      text: response,
    );
    _addMessage(geminiResponse);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemini Chat Page'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // フォーカスを解除
        },
        child: Chat(
          theme: const DefaultChatTheme(
            primaryColor: Colors.lightGreen,
          ),
          user: _user,
          messages: _messages,
          onSendPressed: _handleSendPressed,
          showUserNames: true,
          //showUserAvatars: true,
        ),
      ),
    );
  }
}