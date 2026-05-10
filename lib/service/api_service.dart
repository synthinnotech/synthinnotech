import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static final baseUrl = 'http://10.35.210.176:5000/api';

  static Future fetch(String endPoint) async {
    try {
      var url = Uri.parse('$baseUrl/$endPoint');
      final res =
          await http.get(url, headers: {'Content-Type': 'Application/Json'});
      print(res.body);
      if (res.statusCode == 200) {
        return res.body;
      } else {
        return null;
      }
    } catch (e) {
      return false;
    }
  }

  static Future send(String endPoint, Object object) async {
    try {
      var url = Uri.parse('$baseUrl/$endPoint');
      final res = await http.post(url,
          body: jsonEncode(object),
          headers: {'Content-Type': 'Application/Json'});
      print(res.body);
      if (res.statusCode == 200) {
        return res.body;
      } else {
        return null;
      }
    } catch (e) {
      return false;
    }
  }
}
