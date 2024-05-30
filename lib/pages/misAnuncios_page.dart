import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tablero_led/pages/addAnuncioPage.dart';

class MisAnunciosPage extends StatefulWidget {
  const MisAnunciosPage({super.key});

  @override
  _MisAnunciosPageState createState() => _MisAnunciosPageState();
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
      Uri.parse('http://192.168.0.11:3030/texto/getAll'),
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
    final url = Uri.parse('http://192.168.4.1/');
    message = message.toUpperCase();
    String body = 'message=$message&color=$colorName';

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: body,
    );

    if (response.statusCode == 200) {
      setState(() {
        print(response.body);
      });
    } else {
      setState(() {
        print("Error en la solicitud: ${response.statusCode}");
      });
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
