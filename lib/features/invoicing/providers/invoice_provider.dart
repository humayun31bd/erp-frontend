import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../data/invoice_api.dart';
import '../domain/invoice_model.dart';
import '../domain/invoice_responses.dart';

final invoiceApiProvider = Provider<InvoiceApi>((ref) {
  final dio = ref.watch(dioProvider);
  return InvoiceApi(dio);
});

final invoiceListProvider = FutureProvider.autoDispose<List<InvoiceModel>>((ref) async {
  final api = ref.watch(invoiceApiProvider);
  final response = await api.getInvoices();
  return response.invoices;
});

final customerInvoicesProvider = FutureProvider.family.autoDispose<List<InvoiceModel>, String>((ref, clientId) async {
  final api = ref.watch(invoiceApiProvider);
  final response = await api.getInvoices(clientId: clientId);
  return response.invoices;
});

final invoiceDetailProvider = FutureProvider.family.autoDispose<InvoiceDetail, String>((ref, id) async {
  final api = ref.watch(invoiceApiProvider);
  final response = await api.getInvoiceById(id);
  return response.invoice;
});

class CreateInvoiceState {
  final bool isLoading;
  final String? error;
  final String? successInvoiceId;

  CreateInvoiceState({this.isLoading = false, this.error, this.successInvoiceId});
}

class CreateInvoiceNotifier extends StateNotifier<CreateInvoiceState> {
  final InvoiceApi _api;
  final Ref _ref;

  CreateInvoiceNotifier(this._api, this._ref) : super(CreateInvoiceState());

  Future<void> submitInvoice(Map<String, dynamic> payload) async {
    state = CreateInvoiceState(isLoading: true);
    try {
      final isCreditNote = payload['typeCode'] == '381';
      final isDebitNote = payload['typeCode'] == '383';
      
      final dynamic response;
      if (isCreditNote && payload['originalInvoiceId'] != null) {
        response = await _api.createCreditNote(payload['originalInvoiceId'], payload);
      } else if (isDebitNote && payload['originalInvoiceId'] != null) {
        response = await _api.createDebitNote(payload['originalInvoiceId'], payload);
      } else {
        response = await _api.createInvoice(payload);
      }
      
      if (response.success) {
        state = CreateInvoiceState(isLoading: false, successInvoiceId: response.invoiceId);
        // Refresh the list after successful creation
        _ref.invalidate(invoiceListProvider);
      } else {
        state = CreateInvoiceState(isLoading: false, error: "Failed to create invoice");
      }
    } catch (e) {
      state = CreateInvoiceState(isLoading: false, error: e.toString());
    }
  }
}

final createInvoiceProvider = StateNotifierProvider.autoDispose<CreateInvoiceNotifier, CreateInvoiceState>((ref) {
  final api = ref.watch(invoiceApiProvider);
  return CreateInvoiceNotifier(api, ref);
});
