// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, unnecessary_cast, unnecessary_string_interpolations, avoid_unnecessary_containers, avoid_print, prefer_const_literals_to_create_immutables, use_build_context_synchronously, unused_import

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control de stock ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginPage(),
    );
  }
}

Widget _buildTextField(String hintText, TextEditingController controller) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      hintText: hintText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
      contentPadding: EdgeInsets.symmetric(horizontal: 15.0),
    ),
  );
}

class Admins extends StatefulWidget {
  @override
  State<Admins> createState() => _Admins();
}

class _Admins extends State<Admins> {
  TextEditingController gnamecontroller = TextEditingController();
  TextEditingController namecontroller = TextEditingController();
  TextEditingController pricecontroller = TextEditingController();
  TextEditingController quantitycontroller = TextEditingController();
  TextEditingController gestorEmailController = TextEditingController();
  TextEditingController confirmGestorPasswordController =
      TextEditingController();

  String selectedCategoryToAdd = 'Categoria1';
  String? selectedCategoryToFilter;
  String? selectedCategoryToEdit;

  String nombre1 = '';
  String precio1 = '';
  String cantidad1 = '';
  String categoria1 = '';

  void mostrarSnackbar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        duration: Duration(seconds: 2),
        backgroundColor: const Color.fromARGB(255, 105, 105, 105),
      ),
    );
  }

  void cargarDatosProducto(Map<String, dynamic> producto) {
    namecontroller.text = producto['Nombre'];
    pricecontroller.text = producto['Price'];
    quantitycontroller.text = producto['Cantidad'];

    nombre1 = producto['Nombre'];
    precio1 = producto['Price'];
    cantidad1 = producto['Cantidad'];
    categoria1 = producto['Categoria'];
  }

  Future<void> agregarAdministrador(DocumentReference institucionRef) async {
    // Limpiar controlador de texto
    gestorEmailController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Agregar gestor'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: gestorEmailController,
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
                String gestorEmail = gestorEmailController.text;

                if (gestorEmail.isEmpty) {
                  mostrarSnackbar('El email no puede estar vacío.');
                  return;
                }

                try {
                  QuerySnapshot userSnapshot = await FirebaseFirestore.instance
                      .collection('DatosUsuarios')
                      .where('email', isEqualTo: gestorEmail)
                      .get();

                  if (userSnapshot.docs.isNotEmpty) {
                    DocumentReference userRef =
                        userSnapshot.docs.first.reference;

                    await userRef.update({
                      'rol': 'gestor',
                      'institucionid': institucionRef.id,
                    });

                    Navigator.of(context).pop();
                    mostrarSnackbar('Gestor agregado correctamente');
                  } else {
                    mostrarSnackbar('No se encontró un usuario con ese email');
                  }
                } catch (e) {
                  print('Error al agregar gestor: $e');
                  mostrarSnackbar('Error al agregar gestor');
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
    confirmGestorPasswordController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar gestor'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: confirmGestorPasswordController,
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
                String password = confirmGestorPasswordController.text;

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
                  mostrarSnackbar('Gestor eliminado correctamente');
                } catch (e) {
                  print('Error al eliminar gestor: $e');
                  mostrarSnackbar('Error al eliminar gestor');
                }
              },
              child: Text("Confirmar"),
            ),
          ],
        );
      },
    );
  }

  Future<void> editarDatos(DocumentReference docRef) async {
    await docRef.update({
      'Nombre': nombre1,
      'Price': precio1,
      'Cantidad': cantidad1,
      'Categoria': categoria1,
    });
  }

  Future<void> confirmarEliminacion(DocumentReference docRef) async {
    try {
      await docRef.delete();
      print('Documento eliminado exitosamente');
    } catch (error) {
      print('Error al eliminar el documento: $error');
    }
  }

  Future<void> confirmarEliminaciones() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('productos').get();

      for (DocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
        await doc.reference.delete();
      }

      print('Todos los cos han sido eliminados exitosamente');
    } catch (error) {
      print('Error al eliminar registros: $error');
    }
  }

  void agregarInstitucion(BuildContext context) {
    namecontroller.clear();
    pricecontroller.clear();
    quantitycontroller.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Agregar productos'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration:
                        InputDecoration(labelText: "Nombre del producto"),
                    controller: namecontroller,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: "Precio"),
                    keyboardType: TextInputType.number,
                    controller: pricecontroller,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: "Cantidad"),
                    controller: quantitycontroller,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedCategoryToAdd,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategoryToAdd = newValue!;
                        });
                      },
                      items: <String>['Categoria1', 'Categoria2', 'Categoria3']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: SizedBox(
                            child: Center(
                              child: Text(
                                value,
                                style: TextStyle(
                                  color: Color.fromARGB(255, 70, 70, 70),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      underline: SizedBox(),
                      borderRadius: BorderRadius.circular(15),
                    ),
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
                String name = namecontroller.text;
                String price = pricecontroller.text;
                String quantity = quantitycontroller.text;
                if (name.isNotEmpty &&
                    price.isNotEmpty &&
                    quantity.isNotEmpty &&
                    loggedInstitucionID != null) {
                  // Verifica si loggedInstitucionID está disponible
                  await FirebaseFirestore.instance.collection('productos').add({
                    'Nombre': name,
                    'Price': price,
                    'Cantidad': quantity,
                    'Categoria': selectedCategoryToAdd,
                    'institucionid':
                        loggedInstitucionID, // Agregar institucionid
                  });
                  Navigator.of(context).pop();
                  mostrarSnackbar('Producto agregado correctamente');
                } else {
                  mostrarSnackbar('Debe cargar los datos correctamente');
                }
              },
              child: Text("Confirmar"),
            ),
          ],
        );
      },
    );
  }

  void updateSelectedCategoryToEdit(String? newValue) {
    setState(() {
      selectedCategoryToEdit = newValue;
    });
  }

  void gestoruser(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Agregar gestor'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 15),
                  _buildTextField('Ingrese el DNI del gestor', gnamecontroller),
                  SizedBox(height: 30),
                  TextButton(
                    onPressed: () async {
                      String dniGestor = gnamecontroller.text.trim();
                      if (dniGestor.isEmpty) {
                        Navigator.of(context).pop();
                        mostrarSnackbar('Se deben completar todos los campos');
                        return;
                      }
                      QuerySnapshot querySnapshot = await FirebaseFirestore
                          .instance
                          .collection('DatosUsuarios')
                          .where('DNI', isEqualTo: dniGestor)
                          .limit(1)
                          .get();

                      if (querySnapshot.size > 0) {
                        String userId = querySnapshot.docs.first.id;
                        await FirebaseFirestore.instance
                            .collection('DatosUsuarios')
                            .doc(userId)
                            .update({
                          'rol': 'gestor',
                          'institucionid': loggedInstitucionID
                        });
                        Navigator.of(context).pop();
                        mostrarSnackbar(
                            'Se ha agregado el gestor correctamente');
                      } else {
                        print(
                            "No se encontró un usuario con el DNI ingresado.");
                        mostrarSnackbar(
                            'No se encontró un usuario con el DNI ingresado.');
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(
                          Color.fromARGB(255, 255, 223, 40)),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Aceptar",
                            style: TextStyle(fontSize: 17, color: Colors.black),
                          ),
                          Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.black,
                            size: 15,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  TextEditingController search = TextEditingController();

  var loggedInstitucionID;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        // Suponiendo que el ID de la institución está almacenado en el perfil del usuario
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('DatosUsuarios')
            .doc(user!.uid)
            .get();
        setState(() {
          loggedInstitucionID = userDoc['institucionid'];
        });
      }
    });
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
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
                      )),
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
                  )),
              SizedBox(
                width: 20,
              ),
              TextButton(
                  style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(
                          Color.fromARGB(200, 255, 223, 40)),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      )),
                  onPressed: () {
                    gestoruser(context);
                  },
                  child: Row(
                    children: [
                      Text(
                        "Gestores",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                    ],
                  )),
              SizedBox(
                width: 50,
              ),
              Text(
                "Bienvenido, usuario administraDOR",
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
                        hintText: "Filtrar productos",
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
                  child: DropdownButton<String>(
                    value: selectedCategoryToFilter,
                    onChanged: (String? newValue) {
                      setState(() {
                        if (newValue == 'Todas') {
                          selectedCategoryToFilter = null;
                        } else {
                          selectedCategoryToFilter = newValue;
                        }
                      });
                    },
                    items: <String?>[
                      null,
                      'Categoria1',
                      'Categoria2',
                      'Categoria3'
                    ].map<DropdownMenuItem<String>>((String? value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: SizedBox(
                          child: Center(
                            child: Text(
                              value ?? 'Todas',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    underline: SizedBox(),
                    borderRadius: BorderRadius.circular(15),
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
                    agregarInstitucion(
                      context,
                    );
                  },
                  label: Text(
                    "Agregar producto",
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
              height: 10,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('DatosUsuarios')
                    .where('institucionid',
                        isEqualTo:
                            loggedInstitucionID) // Filtra por la institución logueada
                    .where('rol', isEqualTo: 'gestor') // Solo muestra gestores
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CustomLoadingIndicator();
                  }

                  // Verificar si no hay gestores para mostrar un mensaje
                  if (snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No hay gestores para esta institución',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView(
                    children: snapshot.data!.docs
                        .map((DocumentSnapshot adminDocument) {
                      Map<String, dynamic> adminData =
                          adminDocument.data()! as Map<String, dynamic>;

                      DocumentReference institucionRef = FirebaseFirestore
                          .instance
                          .collection('instituciones')
                          .doc(loggedInstitucionID);

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
                        child: ListTile(
                          title: Text(
                            adminData['nombre'] ?? '',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(adminData['email'] ?? ''),
                              Text(adminData['DNI'] ?? ''),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              eliminarAdministrador(
                                  institucionRef, adminDocument.id);
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            SizedBox(
              width: 65,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0),
                ),
                color: Color.fromARGB(255, 44, 44, 44),
              ),
              padding: EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: Text(
                    'Producto',
                    style: TextStyle(color: Colors.white),
                  )),
                  Expanded(
                      child: Text(
                    'Precio',
                    style: TextStyle(color: Colors.white),
                  )),
                  Expanded(
                      child: Text('Cantidad',
                          style: TextStyle(color: Colors.white))),
                  Expanded(
                      child: Text(
                    'Categoria',
                    style: TextStyle(color: Colors.white),
                  )),
                  SizedBox(
                    width: 65,
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Alerta"),
                            content: Text(
                                "¿Está seguro que desea eliminar todos los registros?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("Cancelar"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  confirmarEliminaciones();
                                  Navigator.of(context).pop();
                                  mostrarSnackbar(
                                      'Productos eliminados correctamente');
                                },
                                child: Text("Confirmar"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: Icon(Icons.delete_sweep),
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Expanded(
                child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("productos")
                  .where("Categoria", isEqualTo: selectedCategoryToFilter)
                  .where("institucionid", isEqualTo: loggedInstitucionID)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CustomLoadingIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                var filteredProducts = snapshot.data!.docs.where((document) {
                  final Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  final nombre = data["Nombre"] as String;
                  return nombre
                      .toLowerCase()
                      .contains(search.text.toLowerCase());
                }).toList();

                return Expanded(
                    child: Container(
                  child: ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (BuildContext context, int index) {
                      Map<String, dynamic> productdata = filteredProducts[index]
                          .data() as Map<String, dynamic>;
                      String name = productdata["Nombre"];
                      String price = productdata["Price"];
                      String quantity = productdata["Cantidad"];
                      String category = productdata["Categoria"];
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(
                                index == filteredProducts.length - 1
                                    ? 15.0
                                    : 0.0),
                          ),
                          color: index % 2 == 0
                              ? Color.fromARGB(255, 219, 219, 219)
                              : Color.fromARGB(255, 230, 230, 230),
                        ),
                        width: double.infinity,
                        padding: EdgeInsets.all(8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                                child: Text(
                              '$name',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                            Expanded(child: Text('$price')),
                            Expanded(child: Text('$quantity')),
                            Expanded(child: Text('$category')),
                            IconButton(
                              onPressed: () {
                                cargarDatosProducto(productdata);
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Agregar producto'),
                                      content: StatefulBuilder(
                                        builder: (BuildContext context,
                                            StateSetter setState) {
                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TextField(
                                                controller: namecontroller,
                                                onChanged: (value) =>
                                                    nombre1 = value,
                                                decoration: InputDecoration(
                                                    labelText: 'Nombre'),
                                              ),
                                              TextField(
                                                controller: pricecontroller,
                                                onChanged: (value) =>
                                                    precio1 = value,
                                                decoration: InputDecoration(
                                                    labelText: 'Precio'),
                                              ),
                                              TextField(
                                                controller: quantitycontroller,
                                                onChanged: (value) =>
                                                    cantidad1 = value,
                                                decoration: InputDecoration(
                                                    labelText: 'Cantidad'),
                                              ),
                                              SizedBox(height: 20),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[200],
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 15,
                                                ),
                                                child: DropdownButton<String>(
                                                  isExpanded: true,
                                                  value:
                                                      selectedCategoryToEdit ??
                                                          categoria1,
                                                  onChanged:
                                                      (String? newValue) {
                                                    setState(() {
                                                      selectedCategoryToEdit =
                                                          newValue!;
                                                      categoria1 = newValue;
                                                    });
                                                  },
                                                  items: <String>[
                                                    'Categoria1',
                                                    'Categoria2',
                                                    'Categoria3'
                                                  ].map<
                                                          DropdownMenuItem<
                                                              String>>(
                                                      (String value) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: value,
                                                      child: SizedBox(
                                                        child: Center(
                                                          child: Text(
                                                            value,
                                                            style: TextStyle(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      70,
                                                                      70,
                                                                      70),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                  underline: SizedBox(),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text("Cancelar"),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            String nuevoNombre =
                                                namecontroller.text;
                                            String nuevoPrecio =
                                                pricecontroller.text;
                                            String nuevaCantidad =
                                                quantitycontroller.text;
                                            String nuevaCategoria =
                                                selectedCategoryToEdit ??
                                                    categoria1;

                                            String nombreOriginal =
                                                productdata['Nombre'];
                                            String precioOriginal =
                                                productdata['Price'];
                                            String cantidadOriginal =
                                                productdata['Cantidad'];
                                            String categoriaOriginal =
                                                productdata['Categoria'];

                                            if (nuevoNombre == nombreOriginal &&
                                                nuevoPrecio == precioOriginal &&
                                                nuevaCantidad ==
                                                    cantidadOriginal &&
                                                nuevaCategoria ==
                                                    categoriaOriginal) {
                                              final snackBar = SnackBar(
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 105, 105, 105),
                                                content: Text(
                                                  'No se realizaron cambios',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                duration: Duration(seconds: 2),
                                              );
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(snackBar);
                                            } else {
                                              if (nuevoNombre.isNotEmpty &&
                                                  nuevoPrecio.isNotEmpty &&
                                                  nuevaCantidad.isNotEmpty) {
                                                editarDatos(snapshot.data!
                                                    .docs[index].reference);

                                                mostrarSnackbar(
                                                    'Registro editado correctamente');
                                                Navigator.of(context).pop();
                                              } else {
                                                final snackBar = SnackBar(
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                          255, 105, 105, 105),
                                                  content: Text(
                                                    'Debe cargar los datos correctamente',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  duration:
                                                      Duration(seconds: 2),
                                                );
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(snackBar);
                                              }
                                            }
                                          },
                                          child: Text("Confirmar"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Eliminar \"$name\""),
                                      content: Text(
                                          "¿Está seguro que desea eliminar este registro? "),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text("Cancelar"),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            confirmarEliminacion(snapshot
                                                .data!.docs[index].reference);
                                            Navigator.of(context).pop();
                                            mostrarSnackbar(
                                                'Producto eliminado correctamente');
                                          },
                                          child: Text("Confirmar"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: Icon(Icons.cancel),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ));
              },
            ))
          ],
        ),
      ),
    );
  }
}
