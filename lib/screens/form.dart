import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
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
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            TextField(
              controller: _urlController,
              enableInteractiveSelection: true, 
              // ignore: deprecated_member_use
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
                    ClipboardData? data = await Clipboard.getData(
                      Clipboard.kTextPlain,
                    );
                    if (data != null) {
                      _urlController.text = data.text ?? '';
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 16.0),
            // Display the shortened URL
            if (_shortenedUrl != null) ...[
              Text(
                'This is your short URL: $_shortenedUrl. Cheers!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _shortenedUrl!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard')),
                  );
                },
                child: Text('Copy'),
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
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    try {
      final shortenedUrl = await shortenUrl(url);

      if (shortenedUrl != null && shortenedUrl.isNotEmpty) {
        setState(() {
          _shortenedUrl = shortenedUrl; // <-- now UI will update
        });
      } else {
        // Optional: show error if backend didn't return shortUrl
        if (kDebugMode) print('shortUrl was null or empty');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(const SnackBar(content: Text('Error shortening URL')));
    }
  }

  Future<String?> shortenUrl(String originalUrl) async {
    final String baseUrl = "https://url-shortner-jj7v.onrender.com";

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/shorten'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'originalUrl': originalUrl}),
      );

      if (kDebugMode) {
        print('Status code: ${response.statusCode}');
      }
      if (kDebugMode) {
        print('Raw response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (kDebugMode) print('Decoded JSON: $data');

        // Try multiple ways to fetch shortUrl
        String? url;
        if (data.containsKey('shortUrl')) {
          url = data['shortUrl'].toString();
        } else if (data.containsKey('data') &&
            data['data']['shortUrl'] != null) {
          url = data['data']['shortUrl'].toString();
        }

        if (url != null && url.isNotEmpty) {
          return url;
        } else {
          if (kDebugMode) print('shortUrl key missing or empty in response');
          return null;
        }
      } else {
        if (kDebugMode) {
          print('Non-200 response: ${response.body}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Network or parsing error: $e');
      }
      return null;
    }
  }
}
