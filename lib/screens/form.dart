import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FormScreen extends StatefulWidget {
  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final TextEditingController _urlController = TextEditingController();
  String? _shortenedUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: Text(
                  'URL Shortener',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            TextField(
              controller: _urlController,
              enableInteractiveSelection: true, // ✅ Enables copy/paste menu
              toolbarOptions: const ToolbarOptions(
                copy: true,
                paste: true,
                selectAll: true,
                cut: true,
              ),
              decoration: InputDecoration(
                labelText: 'Enter URL',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.paste),
                  onPressed: () async {
                    ClipboardData? data =
                        await Clipboard.getData(Clipboard.kTextPlain);
                    if (data != null) {
                      _urlController.text = data.text ?? '';
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 16.0),
            if (_shortenedUrl != null) ...[
              Text(
                'Short URL: $_shortenedUrl',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8.0),
              SizedBox(
                height: 35,
                child: ElevatedButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _shortenedUrl!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Copied to clipboard')),
                    );
                  },
                  child: Text('Copy'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
            ],
            SizedBox(height: 20.0),

            // Show "Shorten URL" button ONLY if no short URL exists yet
            if (_shortenedUrl == null)
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
      setState(() {
        _shortenedUrl = shortenedUrl;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error shortening URL')),
      );
    }
  }

  Future<String> shortenUrl(String url) async {
    // Replace with your API logic
    return 'https://short.url/${url.hashCode}';
  }
}
