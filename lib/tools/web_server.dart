import 'dart:io';

void main() async {
  final port = 8080;
  final localIP = await _getLocalIP();
  final host = InternetAddress.anyIPv4;
  
  final server = await HttpServer.bind(host, port);
  print('');
  print('═══════════════════════════════════════════════════════');
  print('🚀 SERVEUR WEB DÉMARRÉ AVEC SUCCÈS !');
  print('═══════════════════════════════════════════════════════');
  print('');
  print('📍 URLs disponibles:');
  print('   • http://localhost:$port');
  print('   • http://$localIP:$port');
  print('');
  print('📱 SUR VOTRE IPHONE (même WiFi):');
  print('   Ouvrez Safari et tapez EXACTEMENT:');
  print('   http://$localIP:$port');
  print('');
  print('⚠️  IMPORTANT: Utilisez l\'IP $localIP, PAS 0.0.0.0 !');
  print('');
  print('═══════════════════════════════════════════════════════');
  print('Appuyez sur Ctrl+C pour arrêter le serveur');
  print('');

  await for (final request in server) {
    await _handleRequest(request);
  }
}

Future<String> _getLocalIP() async {
  try {
    final interfaces = await NetworkInterface.list();
    for (final interface in interfaces) {
      for (final addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4 && 
            !addr.isLoopback &&
            addr.address.startsWith('192.168.')) {
          return addr.address;
        }
      }
    }
  } catch (e) {
    // Ignore
  }
  return '192.168.1.46'; // Fallback
}

Future<void> _handleRequest(HttpRequest request) async {
  // Logger les requêtes pour déboguer
  final path = request.uri.path;
  print('📥 ${request.method} $path');
  
  // Décoder les URLs encodées (espaces %20, etc.)
  final decodedPath = Uri.decodeComponent(path);
  var filePath = decodedPath == '/' ? '/index.html' : decodedPath;
  
  // Pour les fichiers audio, essayer avec et sans décodage
  File file = File('build/web$filePath');
  
  // Si le fichier n'existe pas et que c'est un fichier audio, essayer avec le chemin encodé
  if (!await file.exists() && (filePath.endsWith('.mp3') || filePath.endsWith('.wav') || filePath.endsWith('.ogg'))) {
    // Essayer avec le chemin original (encodé)
    file = File('build/web$path');
    if (await file.exists()) {
      filePath = path;
      print('✅ Fichier audio trouvé avec chemin encodé: $path');
    }
  }
  
  if (await file.exists()) {
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers.add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    request.response.headers.add('Access-Control-Allow-Headers', 'Content-Type');
    request.response.headers.add('Accept-Ranges', 'bytes');
    
    // Définir le Content-Type selon l'extension
    if (filePath.endsWith('.html')) {
      request.response.headers.contentType = ContentType.html;
    } else if (filePath.endsWith('.js')) {
      request.response.headers.contentType = ContentType('application', 'javascript');
    } else if (filePath.endsWith('.css')) {
      request.response.headers.contentType = ContentType('text', 'css');
    } else if (filePath.endsWith('.json')) {
      request.response.headers.contentType = ContentType.json;
    } else if (filePath.endsWith('.mp3')) {
      // CRITIQUE pour mobile : Content-Type correct pour les fichiers audio
      request.response.headers.contentType = ContentType('audio', 'mpeg');
      request.response.headers.add('Content-Length', (await file.length()).toString());
    } else if (filePath.endsWith('.png')) {
      request.response.headers.contentType = ContentType('image', 'png');
    } else if (filePath.endsWith('.jpg') || filePath.endsWith('.jpeg')) {
      request.response.headers.contentType = ContentType('image', 'jpeg');
    } else if (filePath.endsWith('.svg')) {
      request.response.headers.contentType = ContentType('image', 'svg+xml');
    }
    
    // Gérer les requêtes OPTIONS (CORS preflight)
    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
      return;
    }
    
    await request.response.addStream(file.openRead());
  } else {
    // Try index.html for any path (SPA routing)
    final indexFile = File('build/web/index.html');
    if (await indexFile.exists()) {
      request.response.headers.contentType = ContentType.html;
      await request.response.addStream(indexFile.openRead());
    } else {
      request.response.statusCode = HttpStatus.notFound;
      request.response.write('404 Not Found');
    }
  }
  
  await request.response.close();
}

