import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../domain/driver_model.dart';

class DriversState {
  final List<DriverModel> drivers;
  final bool isLoading;
  final String? error;

  const DriversState({
    this.drivers = const [],
    this.isLoading = false,
    this.error,
  });

  DriversState copyWith({
    List<DriverModel>? drivers,
    bool? isLoading,
    String? error,
  }) {
    return DriversState(
      drivers: drivers ?? this.drivers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  List<DriverModel> get availableDrivers => drivers.where((d) => d.isAvailable && d.isActive).toList();
}

class DriversNotifier extends StateNotifier<DriversState> {
  final Dio _dio;

  DriversNotifier(this._dio) : super(const DriversState()) {
    fetchDrivers();
  }

  Future<void> fetchDrivers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.get('/orders/drivers');
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data['drivers'] as List<dynamic>? ?? [];
        final parsed = list.map((e) => DriverModel.fromJson(e as Map<String, dynamic>)).toList();
        state = state.copyWith(drivers: parsed, isLoading: false, error: null);
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to load drivers');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<DriverModel?> createDriver({
    required String name,
    required String phone,
    String vehicleType = 'bike',
    String? vehiclePlate,
  }) async {
    try {
      final response = await _dio.post('/orders/drivers', data: {
        'name': name,
        'phone': phone,
        'vehicleType': vehicleType,
        if (vehiclePlate != null && vehiclePlate.isNotEmpty) 'vehiclePlate': vehiclePlate,
        'isActive': true,
        'isAvailable': true,
      });

      if (response.statusCode == 201 && response.data != null) {
        final created = DriverModel.fromJson(response.data['driver'] as Map<String, dynamic>);
        state = state.copyWith(drivers: [created, ...state.drivers]);
        return created;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

final driversProvider = StateNotifierProvider<DriversNotifier, DriversState>((ref) {
  final dio = ref.watch(dioProvider);
  return DriversNotifier(dio);
});
