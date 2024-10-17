// ignore_for_file: library_private_types_in_public_api, unused_import, prefer_const_constructors, unused_local_variable, prefer_const_literals_to_create_immutables, avoid_print, use_build_context_synchronously

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stocks_1/DEV/DevLogin.dart';
import 'package:stocks_1/DEV/DeveloperPage.dart';
import 'package:stocks_1/GEST/gesti%C3%B3nstock.dart';
import 'package:stocks_1/register.dart';
import 'package:stocks_1/login.dart';

class DevLogin extends StatefulWidget {
  const DevLogin({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<DevLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.yellow, const Color.fromARGB(255, 206, 178, 18)],
            begin: Alignment.center,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Login Developer',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      fontSize: 36.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 30.0),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      filled: true,
                      fillColor: const Color.fromARGB(255, 255, 255, 255),
                      prefixIcon: Icon(Icons.email, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.lock, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_emailController.text.isNotEmpty ||
                          _passwordController.text.isNotEmpty) {
                        _loginDev();
                      } else {
                        errorDatos(context);
                      }
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Color.fromARGB(255, 17, 14, 22),
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  SizedBox(
                      height:
                          20), // Espacio entre el botón de inicio de sesión y el botón de registro
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    child: Text(
                      'Registrarse',
                      style: TextStyle(
                        color: Color.fromARGB(255, 17, 14, 22),
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text(
                      'login de toda la vida',
                      style: TextStyle(
                        color: Color.fromARGB(225, 17, 14, 22),
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _loginDev() async {
    try {
      // Autenticar al usuario
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Obtener el UID del usuario
      User? usuario = FirebaseAuth.instance.currentUser;
      String uidUsuario = usuario!.uid;

      // Consultar Firestore para obtener el rol
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Developer')
          .doc(uidUsuario)
          .get();

      if (userDoc.exists) {
        // Obtener el campo rol
        String rol = userDoc['rol'];

        // Navegar basado en el rol
        if (rol == "dev") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Developers()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }
      } else {
        // Manejar el caso cuando el documento no exista
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Usuario no encontrado en la colección Developer',
                    style: TextStyle(fontSize: 19.0)),
              );
            });
      }
    } on FirebaseAuthException catch (e) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Failed with error code: ${e.code}',
                  style: TextStyle(fontSize: 19.0)),
            );
          });
    }
  }
}

void errorDatos(BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Debes llenar todos los campos',
              style: TextStyle(fontSize: 19.0)),
        );
      });
}
/*
void faltaDato(BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Failed with error code: ${e.code}',
              style: TextStyle(fontSize: 19.0)),
        );
      });
}

*/
