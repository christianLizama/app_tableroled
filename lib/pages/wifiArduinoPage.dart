import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:tablero_led/pages/misAnuncios_page.dart';

class WiFiScreen extends StatefulWidget {
  const WiFiScreen({Key? key});

  @override
  _WiFiScreenState createState() => _WiFiScreenState();
}

class _WiFiScreenState extends State<WiFiScreen> {
  final TextEditingController ssidController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String esp32Ip = "192.168.4.1"; // IP por defecto del ESP32
  bool _passwordVisible = false;

  final List<String> imagePaths = [
    'assets/foto1.jpg',
    // Agrega más rutas de imágenes aquí
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CarouselSlider(
            items: imagePaths.map((path) {
              return Image.asset(
                path,
                fit: BoxFit.cover,
                width: double.infinity,
              );
            }).toList(),
            options: CarouselOptions(
              height: double.infinity,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              autoPlay: true,
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.8), // Fondo oscuro con opacidad
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.wifi,
                      size: 120,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Configuración de WiFi',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: ssidController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la red (SSID)',
                        prefixIcon:
                            Icon(Icons.network_wifi, color: Colors.white),
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      obscureText: false,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock, color: Colors.white),
                        labelStyle: const TextStyle(color: Colors.white),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            semanticLabel: _passwordVisible
                                ? 'ocultar contraseña'
                                : 'mostrar contraseña',
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                      obscureText: !_passwordVisible,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        enviarDatos(
                            ssidController.text, passwordController.text);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 113, 191, 255),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Conectar WIFI',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> enviarDatos(String ssid, String password) async {
    print("wifi: " + ssid);
    print("password: " + password);
    final url = Uri.parse('http://192.168.4.1/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: 'ssid=$ssid&password=$password',
    );

    if (!mounted) return;
    if (response.statusCode == 200) {
      print('Datos enviados exitosamente!');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MisAnunciosPage()),
      );
    } else {
      // Mostrar diálogo de error
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(
                'Hubo un error al enviar los datos. Código de estado: ${response.statusCode}'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Aceptar'),
              ),
            ],
          );
        },
      );
      print('Error al enviar datos: ${response.statusCode}');
    }
  }
}
