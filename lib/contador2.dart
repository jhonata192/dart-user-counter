import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:uuid/uuid.dart';

const String jsonFilePath = '/var/www/html/contador.json';

Future<Map<String, dynamic>> loadJsonData() async {
  try {
    final file = File(jsonFilePath);
    if (await file.exists()) {
      final content = await file.readAsString();
      final data = jsonDecode(content);

      if (data['usuarios'] is! Map<String, dynamic>) {
        data['usuarios'] = {};
      }

      return data as Map<String, dynamic>;
    } else {
      final initialData = {
        "usuarios": {},
        "quantidade_usuarios": 0,
      };
      await saveJsonData(initialData);
      return initialData;
    }
  } catch (e) {
    print('Erro ao carregar o JSON: $e');
    rethrow;
  }
}

Future<void> saveJsonData(Map<String, dynamic> data) async {
  try {
    final file = File(jsonFilePath);
    final prettyJson = const JsonEncoder.withIndent('    ').convert(data);
    await file.writeAsString(prettyJson, flush: true);
  } catch (e) {
    print('Erro ao salvar o JSON: $e');
    rethrow;
  }
}

Middleware addClientIpMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final ip = (request.context['shelf.io.connection_info'] as HttpConnectionInfo?)
              ?.remoteAddress
              .address ??
          'unknown';
      final updatedRequest = request.change(context: {'clientIp': ip});
      return innerHandler(updatedRequest);
    };
  };
}

Future<Response> handleRequest(Request request) async {
  try {
    final ip = request.context['clientIp'] as String? ?? 'unknown';
    final userAgent = request.headers['User-Agent'] ?? 'unknown';
    final sessionId = const Uuid().v4();
    final now = DateTime.now();
    final dataConexao = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    var jsonData = await loadJsonData();
    var usuarios = jsonData['usuarios'] as Map<String, dynamic>;

    if (request.url.path == 'conectar' && request.method == 'POST') {
      if (usuarios.containsKey(ip)) {
        return Response.ok(
          jsonEncode({'message': 'Você já está conectado'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      usuarios[ip] = {
        'cookie': null,
        'session_id': sessionId,
        'browser': userAgent,
        'data_conexao': dataConexao,
      };

      jsonData['usuarios'] = usuarios;
      jsonData['quantidade_usuarios'] = usuarios.length;

      await saveJsonData(jsonData);

      return Response.ok(
        jsonEncode({'message': 'Usuário conectado com sucesso!'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    else if (request.url.path == 'desconectar' && request.method == 'DELETE') {
      if (usuarios.containsKey(ip)) {
        usuarios.remove(ip);
        jsonData['usuarios'] = usuarios;
        jsonData['quantidade_usuarios'] = usuarios.length;

        await saveJsonData(jsonData);

        return Response.ok(
          jsonEncode({'message': 'Usuário desconectado com sucesso!'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({'message': 'Usuário não encontrado.'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    return Response.notFound(
      jsonEncode({'message': 'Método não suportado'}),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    print('Erro ao processar a requisição: $e');
    return Response.internalServerError(
      body: jsonEncode({'message': 'Erro interno do servidor'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

void main() async {
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(addClientIpMiddleware())
      .addHandler(handleRequest);

  const port = 6000;
  final server = await serve(handler, InternetAddress.anyIPv4, port);
  print('Servidor iniciado na porta $port');
}
