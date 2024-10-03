import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final List<Map<String, dynamic>> _message = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    int length = _message.length - 1;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height - 70,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _message.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      final message = _message[length - index];
                      return Align(
                        alignment: message['isMe']
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: message['isMe']
                                ? Colors.grey[200]
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            message['text'],
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      );
                    })),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.message),
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            label: const Text('Enter Text'),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 0.0, left: 10),
                      child: IconButton(
                        onPressed: () {
                          if (_controller.text.trim().isNotEmpty) {
                            _sendMessage(_controller.text.trim(), true);
                          }
                        },
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                        style: const ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll(Colors.black),
                            fixedSize: WidgetStatePropertyAll(Size(50, 50))),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _sendMessage(String text, bool isMe) async {
    setState(() {
      _message.add({'text': text, 'isMe': isMe});
    });
    _controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
    await detectText(text);
  }

  Future<void> detectText(String text) async {
    final uri = Uri.parse("https://ai-content-detector-ai-gpt.p.rapidapi.com/api/detectText/");
    final headers = {
      "x-rapidapi-key": "03161a5c0fmsha53eec84ca50befp1be75fjsn7610c616be52",
      "x-rapidapi-host": "ai-content-detector-ai-gpt.p.rapidapi.com",
      "Content-Type": "application/json",
    };
    final body = jsonEncode({
      'text': text,
    });

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: body,
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final detectedText = jsonResponse['fakePercentage'].toString();
        print(detectedText);

        setState(() {
          _message.add({
            'text': detectedText,
            'isMe': false
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          });
        });
      } else {
        print('Request failed with status: ${response.statusCode}.');
        print('Error response: ${response.body}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
