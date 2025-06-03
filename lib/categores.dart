import 'package:flutter/material.dart';

class Categores extends StatelessWidget {
  final String imageUrl;
  final String categoryName;

  const Categores({
    Key? key,
    required this.imageUrl,
    required this.categoryName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 5.0,
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Container(
        height: 10.0,
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imageUrl,
                width: 120.0,
                height: 120.0,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
                child: Text(
              categoryName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal[800],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
