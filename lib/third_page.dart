import 'package:flutter/material.dart';

class ThirdPage extends StatelessWidget {
  final String name;
  const ThirdPage({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Third Page')
      ),
      body: Container(
        child: Column(
          children: [
            Text('COFFEE $name'),
            TextButton(onPressed: () {
              Navigator.pop(context);
            }, child: Text('Close'))
          ],
        ),
      ),
    );
  }
}
