import 'package:flutter/material.dart';
import '../services/graphql_service.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

const String CREATE_INE_MUTATION = """
  mutation CreateIneMutation(
    \$nombre: String!,
    \$calle: String!,
    \$colonia: String!,
    \$codigo_postal: String!,
    \$ciudad: String!,
    \$estado: String!,
    \$fecha_nacimiento: String!,
    \$sexo: String!,
    \$url: String!
  ) {
    createIne(
      nombre: \$nombre,
      calle: \$calle,
      colonia: \$colonia,
      codigoPostal: \$codigo_postal,
      ciudad: \$ciudad,
      estado: \$estado,
      fechaNacimiento: \$fecha_nacimiento,
      sexo: \$sexo,
      url: \$url
    ) {
      id
    }
  }
""";

class CreateInePage extends StatefulWidget {
  @override
  _CreateInePageState createState() => _CreateInePageState();
}

class _CreateInePageState extends State<CreateInePage> {
  final TextEditingController _urlController = TextEditingController();
  final Map<String, TextEditingController> _controllers = {
    'nombre': TextEditingController(),
    'calle': TextEditingController(),
    'colonia': TextEditingController(),
    'codigo_postal': TextEditingController(),
    'ciudad': TextEditingController(),
    'estado': TextEditingController(),
    'fecha_nacimiento': TextEditingController(),
    'sexo': TextEditingController(),
  };

  void _submit() async {
    final MutationOptions options = MutationOptions(
      document: gql(CREATE_INE_MUTATION),
      variables: {
        'nombre': _controllers['nombre']!.text,
        'calle': _controllers['calle']!.text,
        'colonia': _controllers['colonia']!.text,
        'codigo_postal': _controllers['codigo_postal']!.text,
        'ciudad': _controllers['ciudad']!.text,
        'estado': _controllers['estado']!.text,
        'fecha_nacimiento': _controllers['fecha_nacimiento']!.text,
        'sexo': _controllers['sexo']!.text,
        'url': _urlController.text,
      },
    );

    final QueryResult result = await GraphQLService.client.mutate(options);

    if (result.hasException) {
      Fluttertoast.showToast(msg: result.exception.toString());
    } else {
      Fluttertoast.showToast(msg: 'INE created successfully!');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create INE')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _urlController,
              decoration: InputDecoration(labelText: 'URL Firebase'),
            ),
            ..._controllers.entries.map((entry) {
              return TextField(
                controller: entry.value,
                decoration: InputDecoration(labelText: entry.key),
              );
            }).toList(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
