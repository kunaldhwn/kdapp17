import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';  // For Material You support

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightColorScheme, darkColorScheme) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightColorScheme ?? ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 240, 242, 244)),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkColorScheme ?? ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 240, 242, 244)),
          ),
          home: const MyHomePage(title: 'CovidSafe Number of Masks Tracker'),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'We have distributed the following number of masks:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Positioned(
            bottom: 90,
            right: 20,
            child: FloatingActionButton(
              onPressed: _incrementCounter,
              tooltip: 'Add one',
              child: const Icon(Icons.add),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 20,
            child: FloatingActionButton(
              onPressed: _decrementCounter,
              tooltip: 'Subtract one',
              child: const Icon(Icons.remove),
            ),
          ),
        ],
      ),
    );
  }
}
