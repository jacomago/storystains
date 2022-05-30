import 'package:http/http.dart' as http;

const backendHost = 'localhost';
const localPort = 8080;

Uri local(String path) =>
    Uri(scheme: 'http', host: backendHost, port: localPort, path: path);
final client = http.Client();
