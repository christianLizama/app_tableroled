import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:tablero_led/pages/nuevo_anuncio_page.dart';
import 'package:tablero_led/pages/editar_anuncio_page.dart'; // Importa la nueva pantalla de edición

class MisAnunciosPage extends StatefulWidget {
  const MisAnunciosPage({Key? key}) : super(key: key);

  @override
  _MisAnunciosPageState createState() => _MisAnunciosPageState();
}

class _MisAnunciosPageState extends State<MisAnunciosPage> {
  final List<Map<String, dynamic>> _anuncios = [];
  List<Map<String, dynamic>> _filteredAnuncios = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargarAnuncios();
    _searchController.addListener(_filterAnuncios);
  }

  Future<void> cargarAnuncios() async {
    var get = await http.get(
      Uri.parse('${dotenv.env['URL']}/texto/getAll'),
    );
    List<dynamic> data = json.decode(get.body);
    setState(() {
      _anuncios
        ..clear()
        ..addAll(data
            .map((item) => {
                  'id': item['_id'].toString(),
                  'texto': item['texto'].toString(),
                  'color': item['color'].toString(),
                  'velocidad': item['velocidad'] as int,
                })
            .toList());
      _filteredAnuncios = List.from(
          _anuncios); // Actualiza la lista filtrada con los anuncios cargados
    });
  }

  void _filterAnuncios() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredAnuncios = _anuncios
          .where((anuncio) => anuncio['texto'].toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _sendRequest(String message, String colorName, int velocidad) async {
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['URL']}/texto/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'message': message,
          'color': colorName,
          'velocidad': velocidad.toString(),
        }),
      );

      if (response.statusCode == 200) {
        // Si el servidor devuelve una respuesta OK, parseamos el JSON
        print('Mensaje enviado al ESP32: ${response.body}');
      } else {
        // Si el servidor no devuelve una respuesta OK, lanzamos un error
        print('Falló la solicitud: ${response.body}');
      }
    } catch (e) {
      print('Error al enviar el mensaje: $e');
    }
  }

  Color getColorFromName(String colorName) {
    switch (colorName) {
      case 'blanco':
        return Colors.white;
      case 'rojo':
        return Colors.red;
      case 'verde':
        return Colors.green;
      case 'azul':
        return Colors.blue;
      case 'amarillo':
        return Colors.yellow;
      default:
        return Colors.black; // Color predeterminado si no hay coincidencia
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis anuncios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              cargarAnuncios();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const SizedBox(
              height: 120, // Ajusta la altura según lo necesites
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text('Drawer Header'),
              ),
            ),
            ListTile(
              title: const Text('Mis anuncios'),
              onTap: () {
                // Actualiza el estado de la aplicación
                // Luego cierra el drawer
                Navigator.pushNamed(context, '/');
              },
            ),
            ListTile(
              title: const Text('Wifi'),
              onTap: () {
                // Actualiza el estado de la aplicación
                // Luego cierra el drawer
                Navigator.pushNamed(context, '/wifiConnect');
              },
            ),
            ListTile(
              title: const Text('Wifi arduino'),
              onTap: () {
                // Actualiza el estado de la aplicación
                // Luego cierra el drawer
                Navigator.pushNamed(context, '/wifiArduino');
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredAnuncios.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    _filteredAnuncios[index]['texto']!,
                    style: TextStyle(
                        color: getColorFromName(
                            _filteredAnuncios[index]['color']!)),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: IconButton(
                          icon:
                              const Icon(Icons.play_arrow, color: Colors.white),
                          onPressed: () => _sendRequest(
                            _filteredAnuncios[index]['texto']!,
                            _filteredAnuncios[index]['color']!,
                            _filteredAnuncios[index]['velocidad'] as int,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8), // Espacio entre los botones
                      CircleAvatar(
                        backgroundColor: Colors.amber,
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditarAnuncioScreen(
                                    texto: _filteredAnuncios[index]['texto']!,
                                    color: _filteredAnuncios[index]['color']!,
                                    id: _filteredAnuncios[index]['id']!, 
                                    velocidad: _filteredAnuncios[index]['velocidad'] as int),
                              ),
                            ).then((_) {
                              cargarAnuncios();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Colors.red,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white),
                          onPressed: () async {
                            // Obtén una referencia segura al BuildContext antes de la función asíncrona
                            final scaffoldContext =
                                ScaffoldMessenger.of(context);

                            final response = await http.delete(
                              Uri.parse(
                                  '${dotenv.env['URL']}/texto/delete/${_filteredAnuncios[index]['id']}'),
                            );

                            if (response.statusCode == 200) {
                              // Si la solicitud fue exitosa (código de estado 200),
                              // muestra un SnackBar indicando el éxito.
                              scaffoldContext.showSnackBar(
                                const SnackBar(
                                  content: Text('Eliminación exitosa'),
                                  duration: Duration(
                                      seconds: 2), // Duración del SnackBar
                                ),
                              );
                              cargarAnuncios(); // Cargar anuncios después del éxito
                            } else {
                              // Si la solicitud falló, muestra el mensaje de error en la consola.
                              scaffoldContext.showSnackBar(
                                const SnackBar(
                                  content: Text('Error al eliminar el anuncio, verifique la conexión a internet'),
                                  duration: Duration(
                                      seconds: 2), // Duración del SnackBar
                                ),
                              );
                              // Aquí podrías mostrar otro tipo de feedback al usuario si lo deseas.
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NuevoAnuncioScreen()),
          ).then((_) {
            cargarAnuncios();
          });
        },
        label: const Text(
          'Nuevo anuncio',
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
