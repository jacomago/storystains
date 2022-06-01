import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../config/config.dart';

part 'api_constant.dart';
part 'api_exception.dart';
part 'api_handler.dart';

class Api {
  static final ApiHandler _handler = ApiHandler();

  static Future register(String username, String password) async {
    return await _handler.post(
        registerUrl,
        jsonEncode({
          'user': {
            'username': username,
            'password': password,
          }
        }));
  }

  static Future login(String username, String password) async {
    return await _handler.post(
        loginUrl,
        jsonEncode({
          'user': {
            'username': username,
            'password': password,
          }
        }));
  }

  static Future user(int id) async {
    return await _handler.get('$userUrl?id=$id');
  }

  static Future users([String? query, int? page]) async {
    String url = '$userUrl?';
    if (query is String && query.isNotEmpty) url += 'name=$query';
    if (page is int && page > 0) url += 'page=$page';
    return await _handler.get(url);
  }
}
