import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trabalho_final/src/provider/planta_provider.dart';
import 'package:trabalho_final/src/view/login/auth_view.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'firebase_options.dart';

Color primaryColor = Colors.green[400]!;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Gemini.init(
    apiKey: "AIzaSyCPW_u-VXRfkjS3immMhVCQvPvwWW2pVeA",
    enableDebugging: true,
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => PlantaProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
      ),
      home: AuthView(),
    );
  }
}
