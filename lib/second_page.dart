import 'package:flutter/material.dart';
import 'package:crud_lab/third_page.dart';

class SecondPage extends StatelessWidget {
  final String result;

  const SecondPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PREFFERENCE PAGE'),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              'Hello world, result: $result',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
                onPressed: () => {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ThirdPage(name: 'Jose')
                      )
                  )
                },
                child: Text('Go To Third Screen'))
          ],
        ),
      ),
    );
  }
}
