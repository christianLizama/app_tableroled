import 'package:flutter/material.dart';

class Page404 extends StatefulWidget {
  const Page404({super.key});

  @override
  State<Page404> createState() => Page404State();
}

class Page404State extends State<Page404> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 34, 255),
        title: const Text('Page 404'),
      ),
      body: const Center(
        child: Text('Page 404'),
      ),
    );
  }
}
