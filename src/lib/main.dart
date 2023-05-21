import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'firebase_options.dart';

import 'pages/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
  setUrlStrategy(PathUrlStrategy());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey.shade200,
        foregroundColor: Colors.grey.shade600,
        elevation: 0,
        toolbarHeight: 58,
        toolbarTextStyle: const TextStyle(
          fontSize: 20,
        )
      )
    ),
    title: "Piping Management System",
    home: const Index(),
  );
}