import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:noor/core/services/http_service.dart';

void main() {
  test('reads a JSON reply without a charset as UTF-8, not Latin-1', () async {
    // What api.aladhan.com sends: UTF-8 under a bare application/json.
    final reply = utf8.encode(jsonEncode({
      'code': 200,
      'status': 'OK',
      'month': 'رجب',
    }));

    final body = await http.runWithClient(
      () => HttpService.getJson(Uri.https('api.aladhan.com', '/v1/methods')),
      () => MockClient((_) async => http.Response.bytes(reply, 200,
          headers: {'content-type': 'application/json'})),
    );

    expect(body['month'], 'رجب');
  });
}
