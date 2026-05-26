import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../../config/credenciales.dart';

class FirebaseDataSource {
  final http.Client _client;

  FirebaseDataSource({http.Client? client}) : _client = client ?? http.Client();

  String get _baseUrl => Credenciales.firestoreBaseUrl;

  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  Future<List<Map<String, dynamic>>> getCollection(String coleccion) async {
    final url = Uri.parse('$_baseUrl/$coleccion');

    final response = await _client.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final data = _parseFirestoreResponse(response.body);
      return data;
    }

    throw Exception(
      'Error al obtener coleccion: ${response.statusCode} - ${response.body}',
    );
  }

  Future<List<Map<String, dynamic>>> getCollectionWhere(
    String coleccion,
    String campo,
    String operador,
    dynamic valor,
  ) async {
    final todos = await getCollection(coleccion);
    return todos.where((doc) {
      final docValue = doc[campo];
      switch (operador) {
        case '==':
          return docValue == valor;
        case '>':
          return docValue != null && (docValue as num) > valor;
        case '<':
          return docValue != null && (docValue as num) < valor;
        case '>=':
          return docValue != null && (docValue as num) >= valor;
        case '<=':
          return docValue != null && (docValue as num) <= valor;
        default:
          return true;
      }
    }).toList();
  }

  Future<Map<String, dynamic>?> getDocument(
    String coleccion,
    String documentoId,
  ) async {
    final url = Uri.parse('$_baseUrl/$coleccion/$documentoId');

    final response = await _client.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final data = _parseFirestoreDocument(response.body);
      return data;
    }

    if (response.statusCode == 404) return null;
    throw Exception(
      'Error al obtener documento: ${response.statusCode} - ${response.body}',
    );
  }

  Future<Map<String, dynamic>> createDocument(
    String coleccion,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$_baseUrl/$coleccion');

    final body = _encodeFirestoreDocument(data);

    final response = await _client.post(url, headers: _headers, body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final name = responseData['name'] as String?;
      final documentId = name?.split('/').last ?? '';
      final result = Map<String, dynamic>.from(data);
      result['id'] = documentId;
      return result;
    }

    throw Exception(
      'Error al crear documento: ${response.statusCode} - ${response.body}',
    );
  }

  Future<bool> updateDocument(
    String coleccion,
    String documentoId,
    Map<String, dynamic> data,
  ) async {
    final docActual = await getDocument(coleccion, documentoId);
    
    if (docActual == null) {
      return false;
    }
    
    final Map<String, dynamic> datosCompletos = {};
    docActual.forEach((key, value) {
      datosCompletos[key] = value;
    });
    
    data.forEach((key, value) {
      datosCompletos[key] = value;
    });
    
    final url = Uri.parse('$_baseUrl/$coleccion/$documentoId');
    final body = _encodeFirestoreDocument(datosCompletos);
    
    final response = await _client.patch(url, headers: _headers, body: body);
    
    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<bool> deleteDocument(String coleccion, String documentoId) async {
    final url = Uri.parse('$_baseUrl/$coleccion/$documentoId');

    final response = await _client.delete(url, headers: _headers);

    return response.statusCode == 200 || response.statusCode == 204;
  }

  List<Map<String, dynamic>> _parseFirestoreResponse(String body) {
    if (body.isEmpty || body == '{}') return [];

    final Map<String, dynamic> json = jsonDecode(body);
    final documents = json['documents'] as List<dynamic>?;

    if (documents == null) return [];

    return documents.map((doc) {
      final name = doc['name'] as String? ?? '';
      final fields = doc['fields'] as Map<String, dynamic>?;
      final documentId = name.split('/').last;

      final Map<String, dynamic> result = {'id': documentId};

      if (fields != null) {
        fields.forEach((key, value) {
          result[key] = _extractFirestoreValue(value);
        });
      }

      return result;
    }).toList();
  }

  Map<String, dynamic>? _parseFirestoreDocument(String body) {
    if (body.isEmpty) return null;

    final Map<String, dynamic> json = jsonDecode(body);
    final name = json['name'] as String?;
    final fields = json['fields'] as Map<String, dynamic>?;

    if (name == null) return null;

    final documentId = name.split('/').last;
    final Map<String, dynamic> result = {'id': documentId};

    if (fields != null) {
      fields.forEach((key, value) {
        result[key] = _extractFirestoreValue(value);
      });
    }

    return result;
  }

  dynamic _extractFirestoreValue(Map<String, dynamic> value) {
    if (value.containsKey('stringValue')) {
      return value['stringValue'];
    }
    if (value.containsKey('integerValue')) {
      return int.tryParse(value['integerValue'].toString()) ?? 0;
    }
    if (value.containsKey('doubleValue')) {
      return double.tryParse(value['doubleValue'].toString()) ?? 0.0;
    }
    if (value.containsKey('booleanValue')) {
      return value['booleanValue'];
    }
    if (value.containsKey('timestampValue')) {
      return value['timestampValue'];
    }
    if (value.containsKey('nullValue')) {
      return null;
    }
    return value.toString();
  }

  String _encodeFirestoreDocument(Map<String, dynamic> data) {
    final Map<String, dynamic> fields = {};

    data.forEach((key, value) {
      fields[key] = _encodeFirestoreValue(value);
    });

    return jsonEncode({'fields': fields});
  }

  Map<String, dynamic> _encodeFirestoreValue(dynamic value) {
    if (value == null) return {'nullValue': null};
    if (value is String) return {'stringValue': value};
    if (value is int) return {'integerValue': value.toString()};
    if (value is double) return {'doubleValue': value.toString()};
    if (value is bool) return {'booleanValue': value};
    if (value is List) {
      return {
        'arrayValue': {'values': value.map(_encodeFirestoreValue).toList()},
      };
    }
    return {'stringValue': value.toString()};
  }
}