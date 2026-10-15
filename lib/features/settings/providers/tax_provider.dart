import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_endpoints.dart';
import '../../auth/providers/auth_provider.dart';
import '../domain/tax_model.dart';

final taxesProvider = FutureProvider<List<TaxModel>>((ref) async {
  final token = ref.watch(authProvider).token;
  if (token == null) throw Exception('Unauthorized');

  final response = await http.get(
    Uri.parse('${ApiEndpoints.baseUrl}/settings/taxes'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    if (data['success'] == true) {
      final List<dynamic> list = data['taxes'];
      return list.map((e) => TaxModel.fromJson(e)).toList();
    }
    return [];
  } else {
    throw Exception('Failed to load taxes: ${response.statusCode}');
  }
});
