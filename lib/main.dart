import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scanner Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 128, 233, 102)),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'Flutter Demo Home Page'),
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
  int _counter = 0;
  
  // ignore: prefer_typing_uninitialized_variables
  var _ScanBarcodeResult;

Future<void> scanCode() async {
  String barcodeScanRes;
  try {barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
    '#ff6666',
    'Cancel',
    true,
    ScanMode.BARCODE,
    );
    debugPrint(barcodeScanRes);
  } on PlatformException {
    barcodeScanRes = 'Failed to get platform version.';
  }
  if (!mounted) return;
  setState(() {
  _ScanBarcodeResult = barcodeScanRes;
  });
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
      Builder(builder: (context) => Container(
        alignment: Alignment.center,
        child: Flex(direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(onPressed: scanCode, child: const Text('Scan code')),
          Text('Scan result : $_ScanBarcodeResult\n')
        ],
        ),
      ),
      )
      // Center(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: <Widget>[
      //       const Text(
      //         'You have pushed the button this many times:',
      //       ),
      //       Text(
      //         '$_counter',
      //         style: Theme.of(context).textTheme.headlineMedium,
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}
