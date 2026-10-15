import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../data/csid_api.dart';

final csidApiProvider = Provider<CsidApi>((ref) {
  final dio = ref.watch(dioProvider);
  return CsidApi(dio);
});

final csidStatusProvider = FutureProvider<CsidStatusResponse>((ref) async {
  final api = ref.watch(csidApiProvider);
  return await api.getStatus();
});
