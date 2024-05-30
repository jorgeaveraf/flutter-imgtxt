import 'dart:convert';
import 'package:http/http.dart' as http;

class OCR {
  final String _url = "https://complete-verve-417716.uc.r.appspot.com/Api/ines";
  final String _apiKey = 'c80baa9392mshe16729980e0637cp15f02bjsnb33394412403';
  final String _apiHost = 'ocr-extract-text.p.rapidapi.com';

  void agregarINE(String ineUrl, Function(Map<String, String>) callback) {
    if (ineUrl.isNotEmpty) {
      getOcrText(ineUrl, callback);
    } else {
      print("Debe proporcionar una URL de INE.");
    }
  }

  void postUser(Map<String, dynamic> user) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(user),
      );
      if (response.statusCode == 200) {
        print(jsonDecode(response.body)['user']);
      } else {
        print('Failed to post user: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void getOcrText(String imageUrl, Function(Map<String, String>) callback) async {
    final response = await http.get(
      Uri.parse('https://ocr-extract-text.p.rapidapi.com/ocr?url=${Uri.encodeComponent(imageUrl)}'),
      headers: {
        'X-RapidAPI-Key': _apiKey,
        'X-RapidAPI-Host': _apiHost,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final processedData = mostrarInformacion(data);
      if (processedData.isNotEmpty) {
        callback(processedData);
      } else {
        print("Error: No se pudo procesar la información del OCR");
      }
    } else {
      print('Error: ${response.reasonPhrase}');
    }
  }

  Map<String, String> mostrarInformacion(Map<String, dynamic> jsonData) {
    if (jsonData['status'] == true) {
      final text = jsonData['text'];

      final RegExp nombreRegExp = RegExp(r'NOMBRE\n([\s\S]+?)\nDOMICILIO');
      final RegExp domicilioRegExp = RegExp(r'DOMICILIO\n([\s\S]+?)\n(?:CLAVE DE ELECTOR|CURP|FECHA DE NACIMIENTO)');
      final RegExp curpRegExp = RegExp(r'CURP (.+?)\nESTADO');
      final RegExp fechaNacimientoRegExp = RegExp(r'FECHA DE NACIMIENTO\n(.+?)\nSEXO');
      final RegExp sexoRegExp = RegExp(r'SEXO\s*(\w)');

      final nombreMatch = nombreRegExp.firstMatch(text);
      final domicilioMatch = domicilioRegExp.firstMatch(text);
      final curpMatch = curpRegExp.firstMatch(text);
      final fechaNacimientoMatch = fechaNacimientoRegExp.firstMatch(text);
      final sexoMatch = sexoRegExp.firstMatch(text);

      final name = nombreMatch?.group(1)?.replaceAll('\n', ' ').trim() ?? '';
      final domicilio = domicilioMatch?.group(1)?.trim() ?? '';

      final domicilioParts = domicilio.split('\n');
      final calle = domicilioParts.isNotEmpty ? domicilioParts[0] : '';
      final addressPart = domicilioParts.length > 2 ? domicilioParts[domicilioParts.length - 2] : '';
      final addressComponents = addressPart.split(' ');

      final cpIndex = addressComponents.indexWhere((part) => RegExp(r'^\d{5}$').hasMatch(part));
      final coloniaCiudadParts = addressComponents.sublist(1, cpIndex).join(' ').split(',');

      final colonia = coloniaCiudadParts.isNotEmpty ? coloniaCiudadParts[0].trim() : '';
      final ciudad = domicilioParts.length > 2 ? domicilioParts[2].split(',').first.trim() : '';
      final cp = cpIndex >= 0 ? addressComponents[cpIndex] : '';
      final estado = domicilioParts.isNotEmpty ? domicilioParts.last.split(',').last.trim() : '';

      final curp = curpMatch?.group(1)?.trim() ?? '';
      final fechaNacimiento = fechaNacimientoMatch?.group(1)?.trim() ?? '';
      final sexo = sexoMatch?.group(1)?.trim() ?? '';

      return {
        'name': name,
        'calle': calle,
        'colonia': colonia,
        'cp': cp,
        'ciudad': ciudad,
        'estado': estado,
        'curp': curp,
        'fechaNacimiento': fechaNacimiento,
        'sexo': sexo
      };
    } else {
      print("La respuesta del servidor indica un estado falso.");
      return {};
    }
  }


  String agregarImagenURL(String url) {
    return '<img src="$url" style="width: 300px; height: 300px;">';
  }
}
