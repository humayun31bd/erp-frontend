import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShiftReport {
  final double expectedCash;
  final double totalCardSales;
  final double totalStoreCreditSales;
  final double totalRefunds;

  ShiftReport({
    required this.expectedCash,
    required this.totalCardSales,
    required this.totalStoreCreditSales,
    required this.totalRefunds,
  });
}

class ShiftState {
  final bool isShiftOpen;
  final DateTime? shiftStartTime;
  final double openingCashAmount;

  ShiftState({
    this.isShiftOpen = false,
    this.shiftStartTime,
    this.openingCashAmount = 0.0,
  });

  ShiftState copyWith({
    bool? isShiftOpen,
    DateTime? shiftStartTime,
    double? openingCashAmount,
  }) {
    return ShiftState(
      isShiftOpen: isShiftOpen ?? this.isShiftOpen,
      shiftStartTime: shiftStartTime ?? this.shiftStartTime,
      openingCashAmount: openingCashAmount ?? this.openingCashAmount,
    );
  }
}

class ShiftNotifier extends StateNotifier<ShiftState> {
  ShiftNotifier() : super(ShiftState());

  void openShift(double initialCash) {
    state = state.copyWith(
      isShiftOpen: true,
      shiftStartTime: DateTime.now(),
      openingCashAmount: initialCash,
    );
  }

  /// Calculates mid-shift totals (X-Report) or End of shift totals (Z-Report)
  Future<ShiftReport> generateReport() async {
    // TODO: Replace with API call to aggregate all transactions since [shiftStartTime]
    await Future.delayed(const Duration(seconds: 1)); // Mock network
    
    // Mock calculations based on opening cash + cash sales - cash refunds
    return ShiftReport(
      expectedCash: state.openingCashAmount + 500.00, // example cash sales
      totalCardSales: 1200.50,
      totalStoreCreditSales: 0.0,
      totalRefunds: 50.0,
    );
  }

  Future<bool> closeShift(double actualCountedCash, String notes) async {
    final report = await generateReport();
    final variance = actualCountedCash - report.expectedCash;
    
    // TODO: Call API to close shift, passing variance and totals
    print('Closing Shift...');
    print('Expected: \${report.expectedCash} | Actual: \$actualCountedCash | Variance: \$variance');
    print('Notes: \$notes');
    
    await Future.delayed(const Duration(seconds: 1)); // Mock API save
    
    // Reset state after successful close
    state = ShiftState();
    return true;
  }
}

final shiftProvider = StateNotifierProvider<ShiftNotifier, ShiftState>((ref) {
  return ShiftNotifier();
});
