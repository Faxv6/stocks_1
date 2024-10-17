// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, unnecessary_cast, unnecessary_string_interpolations, avoid_unnecessary_containers, avoid_print, prefer_const_literals_to_create_immutables, use_build_context_synchronously, unused_import

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stocks_1/DEV/DevLogin.dart';
import 'package:stocks_1/login.dart';
import 'package:stocks_1/register.dart';

class CustomLoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 50.0,
        height: 50.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          border: Border.all(
            color: Colors.blue,
            width: 4.0,
          ),
        ),
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      ),
    );
  }
}

class Developers extends StatefulWidget {
  @override
  State<Developers> createState() => _DevelopersState();
}

class _DevelopersState extends State<Developers> {
  String nombre = '';
  String cuit = '';
  String direccion = '';
  String telefono = '';

  TextEditingController search = TextEditingController();
  TextEditingController adminEmailController = TextEditingController();
  TextEditingController confirmAdminPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    });
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DevLogin()),
        );
      }
    } catch (e) {
      print('Error al cerrar sesión: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión. Inténtalo de nuevo.'),
          ),
        );
      }
    }
  }

  void mostrarSnackbar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        duration: Duration(seconds: 2),
        backgroundColor: const Color.fromARGB(255, 105, 105, 105),
      ),
    );
  }

  Future<void> agregarAdministrador(DocumentReference institucionRef) async {
    // Limpiar controlador de texto
    adminEmailController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Agregar administrador'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: adminEmailController,
                    decoration:
                        InputDecoration(labelText: 'Email del administrador'),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                String adminEmail = adminEmailController.text;

                if (adminEmail.isEmpty) {
                  mostrarSnackbar('El email no puede estar vacío.');
                  return;
                }

                try {
                  QuerySnapshot userSnapshot = await FirebaseFirestore.instance
                      .collection('DatosUsuarios')
                      .where('email', isEqualTo: adminEmail)
                      .get();

                  if (userSnapshot.docs.isNotEmpty) {
                    DocumentReference userRef =
                        userSnapshot.docs.first.reference;

                    await userRef.update({
                      'rol': 'admin',
                      'institucionid': institucionRef.id,
                    });

                    Navigator.of(context).pop();
                    mostrarSnackbar('Administrador agregado correctamente');
                  } else {
                    mostrarSnackbar('No se encontró un usuario con ese email');
                  }
                } catch (e) {
                  print('Error al agregar administrador: $e');
                  mostrarSnackbar('Error al agregar administrador');
                }
              },
              child: Text("Confirmar"),
            ),
          ],
        );
      },
    );
  }

  Future<void> eliminarAdministrador(
      DocumentReference institucionRef, String userId) async {
    // Limpiar controlador de texto
    confirmAdminPasswordController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar administrador'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: confirmAdminPasswordController,
                    decoration: InputDecoration(labelText: 'Contraseña'),
                    obscureText: true,
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                String password = confirmAdminPasswordController.text;

                if (password.isEmpty) {
                  mostrarSnackbar('La contraseña no puede estar vacía.');
                  return;
                }

                try {
                  // Reautenticar al desarrollador para confirmar la acción
                  User? currentUser = FirebaseAuth.instance.currentUser;
                  AuthCredential credential = EmailAuthProvider.credential(
                      email: currentUser!.email!, password: password);

                  await currentUser.reauthenticateWithCredential(credential);

                  // Eliminar rol y id de institución del usuario
                  DocumentReference userRef = FirebaseFirestore.instance
                      .collection('DatosUsuarios')
                      .doc(userId);

                  await userRef.update({
                    'rol': FieldValue.delete(),
                    'institucionid': FieldValue.delete(),
                  });

                  Navigator.of(context).pop();
                  mostrarSnackbar('Administrador eliminado correctamente');
                } catch (e) {
                  print('Error al eliminar administrador: $e');
                  mostrarSnackbar('Error al eliminar administrador');
                }
              },
              child: Text("Confirmar"),
            ),
          ],
        );
      },
    );
  }

  void cargarDatosInstitucion(Map<String, dynamic> institucion) {
    // Aquí se cargan los datos de la institución en los controladores
  }

  Future<void> editarDatos(DocumentReference docRef) async {
    // Aquí se actualizan los datos de la institución
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
        child: Column(
          children: [
            Row(children: [
              TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(
                      Color.fromARGB(200, 255, 223, 40)),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
                onPressed: _signOut,
                child: Row(
                  children: [
                    Text(
                      "Cerrar sesión",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 50,
              ),
              Text(
                "Bienvenido Desarrollador JUANCHO",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ]),
            SizedBox(
              height: 10,
            ),
            Container(
              width: 1500,
              height: 1,
              color: Colors.grey,
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.grey[200],
                    ),
                    child: TextField(
                      controller: search,
                      decoration: InputDecoration(
                        hintText: "Filtrar instituciones",
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                ),
                SizedBox(width: 30),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 15,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 80,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    agregarInstitucion(context);
                  },
                  label: Text(
                    "Agregar institución",
                    style: TextStyle(color: Colors.white),
                  ),
                  icon: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(200, 104, 70, 255),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('instituciones')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CustomLoadingIndicator();
                  }

                  return ListView(
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> institucion =
                          document.data()! as Map<String, dynamic>;

                      if (search.text.isNotEmpty &&
                          !institucion['name']
                              .toString()
                              .toLowerCase()
                              .contains(search.text.toLowerCase())) {
                        return SizedBox.shrink();
                      }

                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    institucion['nombre'] ?? '',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    cargarDatosInstitucion(institucion);
                                    editarDatos(document.reference);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    eliminarInstitucion(document.reference);
                                  },
                                ),
                              ],
                            ),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('DatosUsuarios')
                                  .where('institucionid',
                                      isEqualTo: document.reference.id)
                                  .snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CustomLoadingIndicator();
                                }

                                return Column(
                                  children: snapshot.data!.docs
                                      .map((DocumentSnapshot adminDocument) {
                                    Map<String, dynamic> adminData =
                                        adminDocument.data()!
                                            as Map<String, dynamic>;

                                    return ListTile(
                                      title: Text(adminData['nombre'] ?? ''),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(adminData['email'] ?? ''),
                                          Text(adminData['DNI'] ?? ''),
                                          // Agrega más datos aquí según lo que quieras mostrar
                                        ],
                                      ),
                                      trailing: IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          eliminarAdministrador(
                                              document.reference,
                                              adminDocument.id);
                                        },
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                agregarAdministrador(document.reference);
                              },
                              icon: Icon(Icons.add),
                              label: Text('Agregar Administrador'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(200, 104, 70, 255),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> agregarInstitucion(BuildContext context) async {
    // Aquí se implementará la lógica para agregar una institución.
    {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Agregar Producto'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Nombre...'),
                  onChanged: (value) => nombre = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Cuit...'),
                  onChanged: (value) => cuit = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Telefono...'),
                  onChanged: (value) => telefono = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Direccion...'),
                  onChanged: (value) => direccion = value,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  // ignore: unnecessary_null_comparison
                  if (nombre.isNotEmpty &&
                      cuit.isNotEmpty &&
                      direccion.isNotEmpty &&
                      telefono.isNotEmpty) {
                    agregarInstituciones(nombre, cuit, telefono, direccion);
                  }
                },
                child: Text('Agregar'),
              ),
            ],
          );
        },
      );
    }
  }


  Future<void> agregarInstituciones(nombre, cuit, telefono, direccion) async {
    try {
      await FirebaseFirestore.instance.collection('instituciones').doc().set({
        'nombre': nombre,
        'cuit': cuit,
        'telefono': telefono,
        'direccion': direccion,
      });

      // Actualizar la lista de productos filtrados para que incluya el nuevo producto
    } catch (e) {
      print('Error al agregar insitucion: $e');
    }
  }

  Future<void> eliminarInstitucion(DocumentReference docRef) async {
    // Aquí se implementará la lógica para eliminar una institución.
  }
}
