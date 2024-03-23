import 'package:flutter/material.dart';
import 'package:huggingface_dart/huggingface_dart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Masked Language Model',
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

  Future<void> _fillMask() async {
    final hf = HfInference('Put your hugging face token here');
    // Get the input text from the TextField
    String inputText = inputController.text;
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
            .map((completion) => completion['sequence'].toString())
            .toList();
      });
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
            ElevatedButton(
              onPressed: _fillMask,
              child: Text('Predict'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: completedSentences.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        completedSentences[index],
                        style: TextStyle(fontSize: 16),
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
