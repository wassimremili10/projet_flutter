import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'views/loginpage_view.dart';
import 'views/register_user_page_view.dart';
import 'views/register_organizer_page_view.dart';
import 'views/user_home_page_view.dart';
import 'views/organizer_home_page_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Event Manager",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4A90E2),
          elevation: 4,
        ),
      ),
      initialRoute: "/",
      routes: <String, WidgetBuilder>{
        "/": (BuildContext context) => LoginPageView(),
        "/register_user": (BuildContext context) => RegisterUserPageView(),
        "/register_organizer":(BuildContext context) => const RegisterOrganizerPageView(),
        "/user_home": (BuildContext context) => UserHomePageView(),
        "/organizer_home": (BuildContext context) => AddEventPage(),
        
      },
    );
  }
}  