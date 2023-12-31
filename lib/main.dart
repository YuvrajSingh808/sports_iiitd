import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sports_iiitd/screens/Home.dart';
import 'package:sports_iiitd/screens/create_profile.dart';
import 'package:sports_iiitd/screens/fines/fines.dart';
import 'package:sports_iiitd/screens/landing_page.dart';
import 'package:sports_iiitd/screens/wrong_email.dart';
import 'package:sports_iiitd/screens/history.dart';
import 'firebase_options.dart';
import 'screens/create_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: LandingPage(),
      // add named routes
      routes: {
        '/home': (context) => HomeScreen(),
        // '/view_events': (context) => ViewEvents(),
        '/sign_in': (context) => LandingPage(),
        '/create_profile': (context) => CreateProfile(),
        '/wrong_email': (context) => const WrongEmail(),
        '/create_event': (context) => CreateEvent(),
        '/history': (context) => History(),
        '/fines': (context) => Fines(),
      },
    );
  }
}
