import 'package:flutter/material.dart';

class IneWidget extends StatelessWidget {
  final Map ine;

  IneWidget({required this.ine});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(ine['nombre']),
        subtitle: Text('Calle: ${ine['calle']}, Colonia: ${ine['colonia']}'),
        trailing: Text('Ciudad: ${ine['ciudad']}'),
      ),
    );
  }
}
