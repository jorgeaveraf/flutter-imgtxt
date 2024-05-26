import 'package:flutter/material.dart';
import 'package:flutter_graphql/services/OCR.dart';
import '../services/graphql_service.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

final Map<String, dynamic> jsonData = {
  "status": true,
  "text": "UNIDOS\nESTADOS\nMEXICANOS\nM\u00c9XICO\nINSTITUTO NACIONAL ELECTORAL\nCREDENCIAL PARA VOTAR\nNOMBRE\nVERA\nFUENTES\nJORGE ALFREDO\nDOMICILIO\nC NORTE 7 142\nCOL CENTRO 94300\nORIZABA, VER.\nCLAVE DE ELECTOR VRFNJR95081130H900\nCURP VEFJ950811HVZRNR01\nESTADO 30\nLOCALIDAD 0001\nFECHA DE NACIMIENTO\n11\/08\/1995\nSEXO H\nA\u00d1O DE REGISTRO 2013 01\nMUNICIPIO 119\nSECCI\u00d3N 2731\nEMISI\u00d3N 2014 VIGENCIA 2024",
  "detectedLanguages": [
    {"languageCode": "es", "confidence": 0.8189754},
    {"languageCode": "pt", "confidence": 0.09109919},
    {"languageCode": "it", "confidence": 0.044518284}
  ],
  "executionTimeMS": 1775
};

final ocrInstance = OCR();

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

  bool _consultButtonEnabled = false;
  Image? _imagePreview;

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

  void _consultImage() async {
    final String url = _urlController.text;
    if (url.isNotEmpty) {
      try {
        final http.Response response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          setState(() {
            _imagePreview = Image.network(url);
            _consultButtonEnabled = true;
          });

          ocrInstance.agregarINE(url, (ocrData) {
            if (ocrData.isNotEmpty) {
              setState(() {
                _controllers['nombre']!.text = ocrData['name'] ?? '';
                _controllers['calle']!.text = ocrData['calle'] ?? '';
                _controllers['colonia']!.text = ocrData['colonia'] ?? '';
                _controllers['codigo_postal']!.text = ocrData['cp'] ?? '';
                _controllers['ciudad']!.text = ocrData['ciudad'] ?? '';
                _controllers['estado']!.text = ocrData['estado'] ?? '';
                _controllers['fecha_nacimiento']!.text = ocrData['fechaNacimiento'] ?? '';
                _controllers['sexo']!.text = ocrData['sexo'] ?? '';
              });
            }
          });
        } else {
          Fluttertoast.showToast(msg: 'Error: Failed to load image');
        }
      } catch (e) {
        Fluttertoast.showToast(msg: 'Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create INE')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _urlController,
                      decoration: InputDecoration(labelText: 'URL Firebase'),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _consultImage,
                    child: Text('Consult'),
                  ),
                ],
              ),
              ..._controllers.entries.map((entry) {
                return TextField(
                  controller: entry.value,
                  decoration: InputDecoration(
                    labelText: entry.key,
                    enabled: _consultButtonEnabled,
                  ),
                  enabled: _consultButtonEnabled,
                );
              }).toList(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text('Submit'),
              ),
              if (_imagePreview != null) ...[
                SizedBox(height: 20),
                _imagePreview!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
