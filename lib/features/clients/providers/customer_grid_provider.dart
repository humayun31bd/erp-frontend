import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/client_model.dart';
import '../domain/customer_enums.dart';

// ─────────────────────────────────────────────
// Local extended customer model (UI-layer only).
// Wraps ClientModel + adds fields that may come
// from the API response or be stored locally.
// ─────────────────────────────────────────────
class CustomerRow {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? country;
  final String? state;
  final String? city;
  final String? address;
  final CustomerType type;
  final double funds;  // credit / available balance
  final double dues;   // outstanding payable
  final bool permitCredit;
  final double creditLimit;
  final DateTime createdAt;

  const CustomerRow({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.country,
    this.state,
    this.city,
    this.address,
    this.type = CustomerType.newCustomer,
    this.funds = 0.0,
    this.dues = 0.0,
    this.permitCredit = false,
    this.creditLimit = 0.0,
    required this.createdAt,
  });

  /// Build from the API ClientModel (new fields default to empty until API is extended).
  factory CustomerRow.fromClient(ClientModel c) => CustomerRow(
        id: c.id,
        name: c.name,
        email: c.email,
        phone: c.phoneNumber,
        address: c.address,
        country: c.country,
        state: c.state,
        city: c.city,
        type: CustomerType.values.firstWhere((t) => t.name == c.customerType, orElse: () => CustomerType.newCustomer),
        funds: c.funds ?? 0.0,
        dues: c.dues ?? 0.0,
        permitCredit: c.permitCredit,
        creditLimit: c.creditLimit,
        createdAt: c.createdAt,
      );

  Map<String, dynamic> toPayload() => {
        'name': name,
        if (email != null && email!.isNotEmpty) 'email': email,
        if (phone != null && phone!.isNotEmpty) 'phoneNumber': phone,
        if (address != null && address!.isNotEmpty) 'address': address,
        if (country != null && country!.isNotEmpty) 'country': country,
        if (state != null && state!.isNotEmpty) 'state': state,
        if (city != null && city!.isNotEmpty) 'city': city,
        'customerType': type.name,
        'funds': funds,
        'dues': dues,
        'permitCredit': permitCredit,
        'creditLimit': creditLimit,
      };
}

// ─────────────────────────────────────────────
// Filter + sort state
// ─────────────────────────────────────────────
class CustomerFilterState {
  final String search;
  final String? country;
  final String? state;
  final String? city;
  final CustomerType? type;
  final String sortColumn;  // field name
  final bool sortAsc;

  const CustomerFilterState({
    this.search = '',
    this.country,
    this.state,
    this.city,
    this.type,
    this.sortColumn = 'name',
    this.sortAsc = true,
  });

  CustomerFilterState copyWith({
    String? search,
    Object? country = _sentinel,
    Object? state = _sentinel,
    Object? city = _sentinel,
    Object? type = _sentinel,
    String? sortColumn,
    bool? sortAsc,
  }) {
    return CustomerFilterState(
      search: search ?? this.search,
      country: country == _sentinel ? this.country : country as String?,
      state: state == _sentinel ? this.state : state as String?,
      city: city == _sentinel ? this.city : city as String?,
      type: type == _sentinel ? this.type : type as CustomerType?,
      sortColumn: sortColumn ?? this.sortColumn,
      sortAsc: sortAsc ?? this.sortAsc,
    );
  }
}

// Sentinel so we can distinguish null from "not provided"
const Object _sentinel = Object();

class CustomerFilterNotifier extends StateNotifier<CustomerFilterState> {
  CustomerFilterNotifier() : super(const CustomerFilterState());

  void setSearch(String v) => state = state.copyWith(search: v);
  void setCountry(String? v) => state = state.copyWith(country: v);
  void setState2(String? v) => state = state.copyWith(state: v);
  void setCity(String? v) => state = state.copyWith(city: v);
  void setType(CustomerType? v) => state = state.copyWith(type: v);
  void clearFilters() => state = const CustomerFilterState();

  void sort(String column) {
    if (state.sortColumn == column) {
      state = state.copyWith(sortAsc: !state.sortAsc);
    } else {
      state = state.copyWith(sortColumn: column, sortAsc: true);
    }
  }
}

final customerFilterProvider =
    StateNotifierProvider<CustomerFilterNotifier, CustomerFilterState>(
  (ref) => CustomerFilterNotifier(),
);
