import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FormScreen extends StatefulWidget {
  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final TextEditingController _urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('URL Shortener'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'Enter URL',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _shortenUrl,
              child: Text('Shorten URL'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shortenUrl() async {
    final url = _urlController.text;
    if (url.isEmpty) return;

    try {
      final shortenedUrl = await shortenUrl(url);
      Clipboard.setData(ClipboardData(text: shortenedUrl));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Shortened URL copied to clipboard')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error shortening URL')),
      );
    }
  }

  Future<String> shortenUrl(String url) async {
    // Call your URL shortening API here
    return 'https://short.url/${url.hashCode}';
  }
}