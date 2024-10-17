// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unused_import, duplicate_ignore, unnecessary_import
// ignore: unused_import
import 'package:flutter/widgets.dart';

import 'dart:js_interop';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// ignore: unnecessary_import
import 'package:flutter/rendering.dart';
import 'package:stocks_1/firebase_options.dart';
//libreria para que el firestore funcione, pero para que no de error
//hay que agregarla a dependencis con la lamparita
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: unused_import
import 'dart:io';
// ignore: unused_import
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:stocks_1/login.dart';

/// rest of `flutter create` code...void main() async {
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
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 53, 16, 100)),
        useMaterial3: true,
      ),
      home: LoginPage(),
    );
  }
}
