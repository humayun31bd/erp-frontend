import 'package:flutter/material.dart';

class VoucherBalanceIndicator extends StatelessWidget {
  final double totalDebit;
  final double totalCredit;
  final String? missingAccountMessage;

  const VoucherBalanceIndicator({
    super.key,
    required this.totalDebit,
    required this.totalCredit,
    this.missingAccountMessage,
  });

  @override
  Widget build(BuildContext context) {
    final difference = (totalDebit - totalCredit).abs();
    final isBalanced = difference < 0.01 && totalDebit > 0;
    final isZero = totalDebit == 0 && totalCredit == 0;

    final color = isZero
        ? Colors.grey
        : isBalanced
            ? Colors.green
            : Colors.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(
            isZero
                ? Icons.info_outline
                : isBalanced
                    ? Icons.check_circle
                    : Icons.error_outline,
            color: color,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isZero
                      ? 'Double-Entry Invariant: Enter line item amounts'
                      : isBalanced
                          ? 'Voucher Balanced (Total Dr == Total Cr)'
                          : (missingAccountMessage != null && !isBalanced
                              ? missingAccountMessage!
                              : 'Imbalanced Voucher: Difference Δ = ${difference.toStringAsFixed(2)} BDT'),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('Total Debit: ${totalDebit.toStringAsFixed(2)} BDT', style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 24),
                    Text('Total Credit: ${totalCredit.toStringAsFixed(2)} BDT', style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isBalanced ? 'READY' : 'IMBALANCED',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
