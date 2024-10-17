// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stocks_1/ADM/AdmPage.dart';
import 'package:stocks_1/DEV/DevLogin.dart';
import 'package:stocks_1/GEST/gestiónstock.dart';
import 'package:stocks_1/register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Color.fromARGB(255, 76, 130, 175)],
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Login',
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
                      prefixIcon: Icon(Icons.lock,
                          color: const Color.fromARGB(255, 46, 32, 31)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_emailController.text.isNotEmpty &&
                          _passwordController.text.isNotEmpty) {
                        await _login();
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
                  SizedBox(height: 20),
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
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => DevLogin()),
                      );
                    },
                    child: Text(
                      'LoginDev',
                      style: TextStyle(
                        color: Color.fromARGB(255, 17, 14, 22),
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

  Future<void> _login() async {
    try {
      // Autenticar al usuario con email y contraseña
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Obtener el usuario autenticado
      User? usuario = userCredential.user;

      if (usuario == null) {
        showError(context, 'No se pudo obtener el usuario autenticado');
        return;
      }

      String uidUsuario = usuario.uid;

      // Consultar Firestore para obtener el rol y la institución del usuario
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('DatosUsuarios')
          .doc(uidUsuario)
          .get();

      if (userDoc.exists) {
        String rol = userDoc['rol'];
        //String institucionid = userDoc['institucionid'];

        if (rol == "admin") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Admins()),
          );
        } else if (rol == "gestor") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MyHomePage(),
            ),
          );
        } else {
          showError(context, 'Rol no válido');
        }
      } else {
        showError(context, 'Usuario no encontrado en la base de datos');
      }
    } on FirebaseAuthException catch (e) {
      showError(context, 'Error al iniciar sesión: ${e.code}');
    }
  }

  void showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message, style: TextStyle(fontSize: 19.0)),
        );
      },
    );
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
    },
  );
}
