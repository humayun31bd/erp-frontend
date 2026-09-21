import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../data/invoice_api.dart';
import '../domain/invoice_model.dart';

final invoiceApiProvider = Provider<InvoiceApi>((ref) {
  final dio = ref.watch(dioProvider);
  return InvoiceApi(dio);
});

final invoiceListProvider = FutureProvider<List<InvoiceModel>>((ref) async {
  final api = ref.watch(invoiceApiProvider);
  return await api.getInvoices();
});

class CreateInvoiceNotifier extends StateNotifier<AsyncValue<InvoiceModel?>> {
  final InvoiceApi _api;

  CreateInvoiceNotifier(this._api) : super(const AsyncValue.data(null));

  Future<void> createInvoice(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      final invoice = await _api.createInvoice(data);
      state = AsyncValue.data(invoice);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final createInvoiceProvider = StateNotifierProvider<CreateInvoiceNotifier, AsyncValue<InvoiceModel?>>((ref) {
  final api = ref.watch(invoiceApiProvider);
  return CreateInvoiceNotifier(api);
});
