import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:tablero_led/pages/addAnuncioPage.dart';

class MisAnunciosPage extends StatefulWidget {
  const MisAnunciosPage({super.key});

  @override
  createState() => _MisAnunciosPageState();
}

class _MisAnunciosPageState extends State<MisAnunciosPage> {
  final List<Map<String, String>> _anuncios = [];

  @override
  void initState() {
    super.initState();
    cargarAnuncios();
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
      body: Column(
        children: <Widget>[
          ElevatedButton(
            child: const Text('Añadir nuevo anuncio'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddAnuncioPage()),
              ).then((_) {
                cargarAnuncios();
              });
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _anuncios.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    _anuncios[index]['texto']!,
                    style: TextStyle(
                        color: getColorFromName(_anuncios[index]['color']!)),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _sendRequest(
                      _anuncios[index]['texto']!,
                      _anuncios[index]['color']!,
                    ),
                    child: const Text('Mostrar'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
