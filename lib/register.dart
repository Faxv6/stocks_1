// ignore_for_file: library_private_types_in_public_api, unused_import, prefer_const_constructors, unused_local_variable, prefer_const_literals_to_create_immutables, avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stocks_1/GEST/gesti%C3%B3nstock.dart';
import 'package:stocks_1/login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  static String loggedInstitucionID = "";

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _DNIController = TextEditingController();
  final TextEditingController _TelefonoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordController2 = TextEditingController();

  var userInstitutionid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Registro',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36.0,
              fontWeight: FontWeight.bold,
              backgroundColor: Colors.blue,
            )),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, const Color.fromARGB(255, 76, 130, 175)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: _surnameController,
                decoration: InputDecoration(labelText: 'Apellido'),
              ),
              TextField(
                controller: _DNIController,
                decoration: InputDecoration(labelText: 'DNI'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _TelefonoController,
                decoration: InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
              ),
              TextField(
                controller: _passwordController2,
                decoration: InputDecoration(labelText: 'Confirmar Contraseña'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_passwordController.text == _passwordController2.text) {
                    if (_emailController.text.isNotEmpty &&
                        _passwordController.text.isNotEmpty &&
                        _nameController.text.isNotEmpty &&
                        _surnameController.text.isNotEmpty &&
                        _emailController.text.isNotEmpty) {
                      try {
                        // Convertir DNI y Teléfono a enteros
                        int dni = int.parse(_DNIController.text);
                        int telefono = int.parse(_TelefonoController.text);
                        // Crear el usuario en Firebase Auth
                        UserCredential userCredential = await FirebaseAuth
                            .instance
                            .createUserWithEmailAndPassword(
                                email: _emailController.text,
                                password: _passwordController.text);

                        // Obtener el UID del usuario creado
                        String uid = userCredential.user!.uid;

                        // Guardar los datos del usuario en Firestore
                        try {
                          await FirebaseFirestore.instance
                              .collection('DatosUsuarios')
                              .doc(uid)
                              .set({
                            'nombre': _nameController.text,
                            'apellido': _surnameController.text,
                            'DNI': _DNIController.text,
                            'telefono': _TelefonoController.text,
                            'email': _emailController.text,
                            'rol': ""
                          });

                          // Mostrar cuadro de diálogo y navegar a la página principal
                          mostrarCuadro(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MyHomePage()),
                          );
                        } catch (e) {
                          print(
                              'Error al guardar los datos del usuario en Firestore: $e');
                          // Puedes mostrar un mensaje de error al usuario si es necesario
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
                    } else {
                      errorDatos(context);
                    }
                  } else {
                    errorContrasenia(context);
                  }
                },
                child: Text('Registrarse'),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

void mostrarCuadro(BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Usuario ingresado correctamente',
              style: TextStyle(fontSize: 19.0)),
        );
      });
}

void errorContrasenia(BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Las contraseñas no coinciden',
              style: TextStyle(fontSize: 19.0)),
        );
      });
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
