import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Chat extends StatefulWidget {
  const Chat({Key? key}) : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class Message {
  final String sender;
  final String content;

  Message({required this.sender, required this.content});
}

class _ChatState extends State<Chat> {
  final TextEditingController _textFieldController = TextEditingController();
  List<Message> _messages = [];

  Future<void> _sendMessage(String message) async {
    const apiKey = 'API Key'; // <------- *** PUT YOUR OpenAI KEY HERE *** 
    const modelName = 'gpt-3.5-turbo';
    const apiUrl = 'https://api.openai.com/v1/chat/completions';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({'messages': [{'role': 'user', 'content': message}], 'max_tokens': 50, 'model': modelName}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // print('Response Data: $responseData'); // Debug print statement
        final assistantMessage = responseData['choices'][0]['message']['content']; // Changed here
        if (assistantMessage != null) {
          // print('Assistant Message: $assistantMessage'); // Debug print statement
          _addMessage('User', message);
          _addMessage('Assistant', assistantMessage);
        } else {
          print('Assistant message is null.');
          // Handle null message
        }
      } else {
        // Handle error if response status code is not 200
        print('Error: ${response.statusCode}');
        // print('Response: ${response.body}');
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (error) {
      // Handle any other errors that might occur
      print('Error: $error');
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred while sending the message.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _addMessage(String sender, String content) {
    setState(() {
      _messages.add(Message(sender: sender, content: content));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            "HelloGPT",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return MessageBubble(
                      sender: message.sender,
                      content: message.content,
                    );
                  },
                ),
              ),
              const SizedBox(height: 5),
              Container(
                height: 50,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: Colors.white),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 0, 2),
                            child: TextField(
                              cursorColor: Colors.white,
                              cursorWidth: 3,
                              style: const TextStyle(color: Colors.white),
                              controller: _textFieldController,
                              autocorrect: true,
                              onSubmitted: (message) {
                                _sendMessage(message);
                                _textFieldController.clear();
                              },
                              decoration: const InputDecoration(
                                hintText: "Enter Text",
                                hintStyle: TextStyle(color: Colors.white),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          final message = _textFieldController.text;
                          _sendMessage(message);
                          _textFieldController.clear();
                        },
                        child: const Icon(
                          Icons.double_arrow_rounded,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String content;

  const MessageBubble({required this.sender, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Align(
        alignment: sender == 'User' ? Alignment.topRight : Alignment.topLeft,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: sender == 'User' ? Colors.blue : Colors.grey,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$sender: $content',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
