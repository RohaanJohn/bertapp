import 'package:flutter/material.dart';
import 'package:huggingface_dart/huggingface_dart.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:core';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Next Word Prediction using Bert-Base-Uncased',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        title: 'Masked Language Model',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> completedSentences = [];
  TextEditingController inputController = TextEditingController();
  final hf = HfInference('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');
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    inputController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  Future<void> _fillMask(String inputText) async {
    final List completions = await hf.fillMask(
      model: 'bert-base-uncased',
      inputs: ['$inputText [MASK] .'],
    );

    if (completions.isEmpty) {
      // Handle the case when no completion is returned
      print('No completion found.');
    } else {
      setState(() {
        completedSentences = completions
            .map((completion) => capitalize(completion['sequence'].toString()))
            .toList();
      });
    }
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  String capitalize(String s) {
    if (s.isEmpty) return s;

    // Capitalize 'i' if it appears in the sentence
    s = s.replaceAllMapped(RegExp(r'\bi\b'), (match) => 'I');

    // Capitalize the first letter of the sentence
    return s[0].toUpperCase() + s.substring(1);
  }

  void _onTextChanged() {
    String inputText = inputController.text;
    if (inputText.isNotEmpty) {
      _fillMask(inputText);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: inputController,
              decoration: InputDecoration(
                labelText: 'Enter text',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: completedSentences.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      _speak(completedSentences[index]);
                    },
                    child: Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          completedSentences[index],
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
