import 'dart:convert';
import 'package:http/http.dart' as http;

Map<String, int> bahnhoefe = {};

Future<List<List<dynamic>>> getIds(String search_term) async {
  var data = {
    'search_term': search_term,
  };

  try {
    final response = await http.post(
      Uri.parse('https://xfywux3j0c.execute-api.us-east-1.amazonaws.com/prod'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );


    if (response.statusCode == 200) {
      // Parse the response body
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      List<List<dynamic>> results = [];

      // Assuming the response structure contains a "results" key
      if (responseBody.containsKey('results')) {
        for (var entry in responseBody['results']) {
          results.add(entry);
        }
      } else {
        print('No results found.');
      }
      return results;
    } else {
      // Handle error response
      print('Failed to get station IDs. Status code: ${response.body}');
      return [];
    }
  } catch (e) {
    print('Error occurred: $e');
    return [];
  }
}
