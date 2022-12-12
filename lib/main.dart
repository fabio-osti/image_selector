import 'package:flutter/material.dart';
import 'package:image_selector/views/main_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Selector',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 34, 137, 47),
            brightness: Brightness.dark,
          ),
          useMaterial3: true),
      home: const MainView(),
    );
  }
}
