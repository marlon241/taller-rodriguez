import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/credenciales.dart';

class SupabaseDataSource {
  final http.Client _client;
  final bool _useServiceRole;

  SupabaseDataSource({http.Client? client, bool useServiceRole = false}) 
      : _client = client ?? http.Client(),
        _useServiceRole = useServiceRole;

  Map<String, String> get _headers => 
      _useServiceRole ? SupabaseHeaders.serviceHeaders : SupabaseHeaders.headers;

  String get _baseUrl {
    final url = Credenciales.supabaseUrl;
    if (url.contains('/rest/v1/')) {
      return url.split('/rest/v1/').first;
    }
    return url;
  }

  Future<List<Map<String, dynamic>>> select(
    String tabla, {
    String? filtros,
    String? orderBy,
    int? limit,
    String? select,
  }) async {
    String queryParams = '';

    if (select != null && select.isNotEmpty) {
      queryParams = '?select=$select';
    }
    if (filtros != null && filtros.isNotEmpty) {
      queryParams += queryParams.isEmpty ? '?$filtros' : '&$filtros';
    }
    if (orderBy != null && orderBy.isNotEmpty) {
      queryParams += queryParams.isEmpty ? '?order=$orderBy' : '&order=$orderBy';
    }
    if (limit != null) {
      queryParams += queryParams.isEmpty ? '?limit=$limit' : '&limit=$limit';
    }

    final url = Uri.parse('$_baseUrl/rest/v1/$tabla$queryParams');

    final response = await _client.get(url, headers: _headers);

    if (response.statusCode == 200) {
      if (response.body.isEmpty || response.body == '[]') {
        return [];
      }
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      }
      return [decoded.cast<Map<String, dynamic>>()];
    }

    throw Exception(
      'Error en SELECT: ${response.statusCode} - ${response.body}',
    );
  }

  Future<Map<String, dynamic>> insert(
    String tabla,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$_baseUrl/rest/v1/$tabla');

    final response = await _client.post(
      url,
      headers: _headers,
      body: _encodeJson(data),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      if (response.body.isEmpty) {
        if (data.containsKey('id')) {
          return {'id': data['id']};
        }
        return data;
      }
      return _parseJson(response.body).first;
    }

    throw Exception(
      'Error en INSERT: ${response.statusCode} - ${response.body}',
    );
  }

  Future<List<Map<String, dynamic>>> insertMultiple(
    String tabla,
    List<Map<String, dynamic>> data,
  ) async {
    final url = Uri.parse('$_baseUrl/rest/v1/$tabla');

    final response = await _client.post(
      url,
      headers: _headers,
      body: _encodeJsonList(data),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return data;
    }

    throw Exception(
      'Error en INSERT Multiple: ${response.statusCode} - ${response.body}',
    );
  }

  Future<Map<String, dynamic>> update(
    String tabla,
    Map<String, dynamic> data,
    String filtros,
  ) async {
    final url = Uri.parse('$_baseUrl/rest/v1/$tabla?$filtros');

    final response = await _client.patch(
      url,
      headers: _headers,
      body: _encodeJson(data),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return data;
    }

    throw Exception(
      'Error en UPDATE: ${response.statusCode} - ${response.body}',
    );
  }

  Future<bool> delete(String tabla, String filtros) async {
    final url = Uri.parse('$_baseUrl/rest/v1/$tabla?$filtros');

    final response = await _client.delete(url, headers: _headers);

    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<int> rpc(String nombreFuncion, Map<String, dynamic> parametros) async {
    final url = Uri.parse('$_baseUrl/rest/v1/rpc/$nombreFuncion');

    final response = await _client.post(
      url,
      headers: _headers,
      body: _encodeJson(parametros),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isEmpty) {
        throw Exception('RPC $nombreFuncion no devolvio resultado');
      }
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is int) {
        return decoded;
      }
      if (decoded is Map && decoded.containsKey('id')) {
        return decoded['id'] as int;
      }
      throw Exception('RPC $nombreFuncion devolvio formato inesperado: $response.body');
    }

    throw Exception(
      'Error en RPC $nombreFuncion: ${response.statusCode} - ${response.body}',
    );
  }

  Future<List<Map<String, dynamic>>> getDocuments(
    String coleccion, {
    String? filtros,
  }) async {
    return select('${coleccion}_docs', filtros: filtros);
  }

  Future<Map<String, dynamic>> insertDocument(
    String coleccion,
    Map<String, dynamic> data,
  ) async {
    return insert('${coleccion}_docs', data);
  }

  dynamic _parseJson(String body) {
    if (body.isEmpty || body == '[]') return [];
    return body.startsWith('[') ? _jsonDecode(body) : [_jsonDecode(body)];
  }

  String _encodeJson(Map<String, dynamic> data) {
    return _jsonEncode(data);
  }

  String _jsonEncode(Map<String, dynamic> data) {
    final buffer = StringBuffer('{');
    var first = true;
    data.forEach((key, value) {
      if (!first) buffer.write(',');
      first = false;
      buffer.write('"$key":');
      buffer.write(_encodeValue(value));
    });
    buffer.write('}');
    return buffer.toString();
  }

  String _encodeJsonList(List<Map<String, dynamic>> dataList) {
    final buffer = StringBuffer('[');
    for (var i = 0; i < dataList.length; i++) {
      if (i > 0) buffer.write(',');
      buffer.write(_jsonEncode(dataList[i]));
    }
    buffer.write(']');
    return buffer.toString();
  }

  String _encodeValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return '"${value.replaceAll('"', '\\"')}"';
    if (value is num || value is bool) return value.toString();
    if (value is List) {
      return '[${value.map(_encodeValue).join(',')}]';
    }
    if (value is Map) return _jsonEncode(Map<String, dynamic>.from(value));
    return '"$value"';
  }

  dynamic _jsonDecode(String body) {
    var index = 0;
    return _parseValue(body.trim(), () {
      index++;
      return index < body.length ? body[index - 1] : '';
    });
  }

  dynamic _parseValue(String body, String Function() nextChar) {
    body = body.trim();
    if (body.isEmpty) return null;

    final first = body[0];
    if (first == '{') return _parseObject(body, nextChar);
    if (first == '[') return _parseArray(body, nextChar);
    if (first == '"') return _parseString(body);
    if (first == 't' || first == 'f') return _parseBool(body);
    if (first == 'n') return _parseNull(body);
    return _parseNumber(body);
  }

  Map<String, dynamic> _parseObject(String body, String Function() nextChar) {
    final map = <String, dynamic>{};
    var content = body.substring(1, body.length - 1).trim();
    if (content.isEmpty) return map;

    var key = '';
    var value = '';
    var inKey = true;
    var depth = 0;
    var inString = false;

    for (var i = 0; i < content.length; i++) {
      final char = content[i];

      if (char == '"' && (i == 0 || content[i - 1] != '\\')) {
        inString = !inString;
      }

      if (!inString) {
        if (char == '{' || char == '[') depth++;
        if (char == '}' || char == ']') depth--;

        if (char == ':' && depth == 0 && inKey) {
          inKey = false;
          key = value.trim().replaceAll('"', '');
          value = '';
          continue;
        }

        if ((char == ',' || char == '}') && depth == 0 && !inKey) {
          map[key] = _parseValue(value.trim(), nextChar);
          key = '';
          value = '';
          inKey = true;
          continue;
        }
      }

      if (inKey || !inString) value += char;
    }

    return map;
  }

  List<dynamic> _parseArray(String body, String Function() nextChar) {
    final list = <dynamic>[];
    var content = body.substring(1, body.length - 1).trim();
    if (content.isEmpty) return list;

    var value = '';
    var depth = 0;
    var inString = false;

    for (var i = 0; i < content.length; i++) {
      final char = content[i];

      if (char == '"' && (i == 0 || content[i - 1] != '\\')) {
        inString = !inString;
      }

      if (!inString) {
        if (char == '{' || char == '[') depth++;
        if (char == '}' || char == ']') depth--;

        if ((char == ',' || char == '}') && depth == 0) {
          if (value.trim().isNotEmpty) {
            list.add(_parseValue(value.trim(), nextChar));
          }
          value = '';
          continue;
        }
      }

      value += char;
    }

    if (value.trim().isNotEmpty) {
      list.add(_parseValue(value.trim(), nextChar));
    }

    return list;
  }

  String _parseString(String body) {
    return body.substring(1, body.length - 1).replaceAll('\\"', '"');
  }

  bool _parseBool(String body) => body.startsWith('true');

  dynamic _parseNull(String body) =>
      body.startsWith('null') ? null : _parseNumber(body);

  num _parseNumber(String body) {
    final numStr = body.replaceAll(',', '');
    return numStr.contains('.')
        ? double.tryParse(numStr) ?? 0
        : int.tryParse(numStr) ?? 0;
  }
}