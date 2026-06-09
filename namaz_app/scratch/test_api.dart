import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  try {
    final response = await http.get(Uri.parse('https://ezanvakti.emushaf.net/ilceler/539'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print("ALL DISTRICTS:");
      for (var item in data) {
        print("- ${item['IlceAdi']} (ID: ${item['IlceID']})");
      }
    }
  } catch (e) {
    print("ERROR: $e");
  }
}
