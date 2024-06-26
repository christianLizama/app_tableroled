import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:tablero_led/pages/nuevo_anuncio_page.dart';

class MisAnunciosPage extends StatefulWidget {
  const MisAnunciosPage({super.key});

  @override
  createState() => _MisAnunciosPageState();
}

class _MisAnunciosPageState extends State<MisAnunciosPage> {
  final List<Map<String, String>> _anuncios = [];
  List<Map<String, String>> _filteredAnuncios = [];
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
                  'texto': item['texto'].toString(),
                  'color': item['color'].toString()
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
          .where((anuncio) => anuncio['texto']!.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _sendRequest(String message, String colorName) async {
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['URL']}/texto/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'message': message,
          'color': colorName,
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
        return Colors.black; // Default color if no match is found
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis anuncios'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const SizedBox(
              height: 120, // Set the height you want here
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
                // Update the state of the app
                // Then close the drawer
                Navigator.pushNamed(context, '/');
              },
            ),
            ListTile(
              title: const Text('Wifi'),
              onTap: () {
                // Update the state of the app
                // Then close the drawer
                Navigator.pushNamed(context, '/wifiConnect');
              },
            ),
            ListTile(
              title: const Text('Wifi arduino'),
              onTap: () {
                // Update the state of the app
                // Then close the drawer
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
                          ),
                        ),
                      ),
                      const SizedBox(width: 8), // Espacio entre los botones
                      CircleAvatar(
                        backgroundColor: Colors.amber,
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () {
                            // Aquí va la lógica para editar el anuncio
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
