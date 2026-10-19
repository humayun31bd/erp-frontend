import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../domain/payroll_model.dart';

class HrPdfGenerator {
  static Future<Uint8List> generatePayslipPdf(PayrollRecord payroll) async {
    final pdf = pw.Document();

    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final monthText = (payroll.month >= 1 && payroll.month <= 12)
        ? monthNames[payroll.month - 1]
        : 'Month ${payroll.month}';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Card
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue900,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'OFFICIAL SALARY PAYSLIP',
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Pay Period: $monthText ${payroll.year}',
                          style: const pw.TextStyle(color: PdfColors.grey300, fontSize: 12),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('ERP Enterprise Hub', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                        pw.Text('Status: ${payroll.status}', style: pw.TextStyle(color: payroll.status == 'PAID' ? PdfColors.green300 : PdfColors.amber300, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // Employee Info Box
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Employee Name: ${payroll.firstName ?? ''} ${payroll.lastName ?? ''}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                        pw.SizedBox(height: 4),
                        pw.Text('Department: ${payroll.departmentName ?? 'General'}', style: const pw.TextStyle(fontSize: 11)),
                        pw.SizedBox(height: 4),
                        pw.Text('Designation: ${payroll.designationName ?? 'Staff Member'}', style: const pw.TextStyle(fontSize: 11)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('National ID/Iqama: ${payroll.nationalId ?? '—'}', style: const pw.TextStyle(fontSize: 11)),
                        pw.SizedBox(height: 4),
                        pw.Text('GOSI Number: ${payroll.gosiNumber ?? '—'}', style: const pw.TextStyle(fontSize: 11)),
                        pw.SizedBox(height: 4),
                        pw.Text('Payment Method: ${payroll.paymentMethod}', style: const pw.TextStyle(fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // Attendance & Overtime Summary Box
              pw.Text('Attendance & Overtime Summary', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Text('Present Days: ${payroll.presentDays}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                    pw.Text('Absent Days: ${payroll.absentDays}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
                    pw.Text('Late Days: ${payroll.lateDays}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.amber800)),
                    pw.Text('OT Hours: ${payroll.overtimeHours.toStringAsFixed(1)} hrs', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // Itemized Earnings & Deductions Tables Side-by-Side
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Earnings Column
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Earnings (Allowances & OT)', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.green900)),
                        pw.SizedBox(height: 6),
                        pw.Table(
                          border: pw.TableBorder.all(color: PdfColors.grey300, width: 1),
                          children: [
                            pw.TableRow(
                              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                              children: [
                                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Item', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Amount (SAR)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                              ],
                            ),
                            pw.TableRow(children: [
                              pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Basic Salary')),
                              pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(payroll.basicSalary, textAlign: pw.TextAlign.right)),
                            ]),
                            pw.TableRow(children: [
                              pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Housing Allowance')),
                              pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(payroll.housingAllowance, textAlign: pw.TextAlign.right)),
                            ]),
                            pw.TableRow(children: [
                              pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Transport Allowance')),
                              pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(payroll.transportAllowance, textAlign: pw.TextAlign.right)),
                            ]),
                            pw.TableRow(children: [
                              pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Other Allowances')),
                              pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(payroll.otherAllowance, textAlign: pw.TextAlign.right)),
                            ]),
                            pw.TableRow(children: [
                              pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Overtime Pay')),
                              pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(payroll.overtimePay, textAlign: pw.TextAlign.right)),
                            ]),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 16),

                  // Deductions Column
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Deductions & Fines', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.red900)),
                        pw.SizedBox(height: 6),
                        pw.Table(
                          border: pw.TableBorder.all(color: PdfColors.grey300, width: 1),
                          children: [
                            pw.TableRow(
                              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                              children: [
                                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Item', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Amount (SAR)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                              ],
                            ),
                            pw.TableRow(children: [
                              pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('GOSI Social Insurance')),
                              pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(payroll.gosiDeduction, textAlign: pw.TextAlign.right)),
                            ]),
                            pw.TableRow(children: [
                              pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Loan Installment')),
                              pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(payroll.loanDeduction, textAlign: pw.TextAlign.right)),
                            ]),
                            pw.TableRow(children: [
                              pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Fines & Penalties')),
                              pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(payroll.finesPenalties, textAlign: pw.TextAlign.right)),
                            ]),
                            pw.TableRow(children: [
                              pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Total Deductions')),
                              pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(payroll.deductions, textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                            ]),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Net Payable Card
              pw.Container(
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  border: pw.Border.all(color: PdfColors.blue900, width: 2),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('NET PAYABLE SALARY:', style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                    pw.Text('SAR ${payroll.netSalary}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                  ],
                ),
              ),
              pw.SizedBox(height: 32),

              // Signatures
              pw.Spacer(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(width: 150, height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 5),
                      pw.Text('Employee Signature', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(width: 150, height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 5),
                      pw.Text('HR & Finance Officer', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<void> printPayslip(PayrollRecord payroll) async {
    final bytes = await generatePayslipPdf(payroll);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
      name: 'Payslip_${payroll.firstName}_${payroll.month}_${payroll.year}.pdf',
    );
  }
}
