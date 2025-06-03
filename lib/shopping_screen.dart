import 'package:flutter/material.dart';
import 'package:orderio/categores.dart';
import 'log_in_screen.dart';
import 'main.dart';

class Shopping extends StatelessWidget {
  const Shopping({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping'),
        backgroundColor: Color(0xFFCAB7AC),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => orderio()),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        children: [
          Categores(
            imageUrl: 'images/c1.jpg',
            categoryName: 'daily',
          )
        ],
      ),
    );
  }
}
