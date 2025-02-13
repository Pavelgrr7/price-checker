import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scanner Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 128, 233, 102)),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'Price Scanner Home Page'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {  
  String? _scanBarcodeResult;
  String answer = "No data";
  bool isLoading = false;

  Future<void> scanCode() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );
      debugPrint("Scanned code: $barcodeScanRes");
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _scanBarcodeResult = barcodeScanRes;
      isLoading = true; // loading circle
    });

    await fetchMarket(barcodeScanRes); // api response
  }

  Future<void> fetchMarket(String barcode) async {
    final url = 'https://api.upcitemdb.com/prod/trial/lookup?upc=$barcode';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['items'] != null && data['items'].isNotEmpty) {
          final item = data['items'][0];
          setState(() {
            print(data);
            answer = "Title: ${item['title']}\nBrand: ${item['brand']}\nCategory: ${item['category']}";
          });
        } else {
          setState(() {
            print(data);
            answer = "Product not found";
          });
        }
      } else {
        setState(() {
          answer = "Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        answer = "Request failed: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: isLoading ? null : scanCode,
              child: const Text('Scan code'),
            ),
            const SizedBox(height: 20),
            Text('Scan result: ${_scanBarcodeResult ?? 'No scan yet'}'),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator() // loading circle
                : Text(
                    'Searching result:\n$answer',
                    textAlign: TextAlign.center,
                  ),
          ],
        ),
      ),
    );
  }
}