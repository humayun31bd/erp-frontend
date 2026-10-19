// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Intelligent ERP';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get invoices => 'Invoices';

  @override
  String get createInvoice => 'Create Invoice';

  @override
  String get zatcaCleared => 'ZATCA Cleared';

  @override
  String sarAmount(String amount) {
    return 'SAR $amount';
  }

  @override
  String get login => 'Login';

  @override
  String get phone => 'Phone Number';

  @override
  String get password => 'Password';

  @override
  String get loginButtonText => 'Sign In';

  @override
  String get loginError =>
      'Authentication failed. Please check your credentials.';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get customers => 'Customers';

  @override
  String get suppliers => 'Suppliers';

  @override
  String get purchases => 'Purchases';

  @override
  String get cashBook => 'Cash Book';

  @override
  String get inventory => 'Inventory';

  @override
  String get posCashier => 'POS Cashier';

  @override
  String get posDashboard => 'POS Dashboard';

  @override
  String get aiCopilot => 'AI Copilot';

  @override
  String get whatsappLogs => 'WhatsApp Logs';

  @override
  String get payments => 'Payments';

  @override
  String get reports => 'Reports';

  @override
  String get agencyPortal => 'Agency Portal';

  @override
  String get settings => 'Settings';

  @override
  String get languageSettings => 'Language Settings';

  @override
  String get labelKey => 'Label Key';

  @override
  String get englishValue => 'English Value';

  @override
  String get arabicValue => 'Arabic Value';

  @override
  String get actions => 'Actions';

  @override
  String get update => 'Update';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get manageBranches => 'Manage Branches';

  @override
  String get addBranch => 'Add Branch';

  @override
  String get branchName => 'Branch Name';

  @override
  String get branchLocation => 'Location';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get logout => 'Logout';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get aiAndLogs => 'AI & LOGS';

  @override
  String get management => 'MANAGEMENT';

  @override
  String get expandMenu => 'Expand Menu';

  @override
  String get collapseMenu => 'Collapse Menu';

  @override
  String get tenants => 'Tenants';

  @override
  String get marketingPlans => 'Marketing Plans';

  @override
  String get noClientsFound => 'No clients found. Add a new tenant.';

  @override
  String get addTenant => 'Add Tenant';

  @override
  String get editPlan => 'Edit Plan';

  @override
  String get noOfBranches => 'No. of Branches (-1 for unlimited)';

  @override
  String get noOfCounters => 'No. of Counters (-1 for unlimited)';

  @override
  String get invoicesPerMonth => 'Invoices per Month (-1 for unlimited)';

  @override
  String get planUpdated => 'Plan Updated';

  @override
  String get branches => 'Branches';

  @override
  String get counters => 'Counters';

  @override
  String get invoicesMo => 'Invoices / Mo';

  @override
  String get unlimited => 'Unlimited';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get refreshDashboard => 'Refresh Dashboard';

  @override
  String get zatcaOffline =>
      'ZATCA Engine is currently offline or unreachable.';

  @override
  String get totalRevenue => 'Total Revenue';

  @override
  String get clearedInvoices => 'Cleared Invoices';

  @override
  String get overdueAmount => 'Overdue Amount';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get failedToLoadDashboard => 'Failed to load dashboard';

  @override
  String get retry => 'Retry';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get salesInvoice => 'Sales Invoice';

  @override
  String get purchaseOrder => 'Purchase Order';

  @override
  String get shipments => 'Shipments';

  @override
  String get paymentReceipts => 'Payment & Receipts';

  @override
  String get expenses => 'Expenses';

  @override
  String get customer => 'Customer';

  @override
  String get vendor => 'Vendor';

  @override
  String get receiptsSettings => 'Receipts Settings';

  @override
  String get summary => 'Summary';

  @override
  String get salesOrder => 'Sales Order';

  @override
  String get cashLedger => 'Cash Ledger';

  @override
  String get more => 'More...';

  @override
  String get configurationSettings => 'Configuration & Settings';

  @override
  String get enableRestaurantMode => 'Enable Restaurant POS Mode';

  @override
  String get currencyConfiguration => 'Currency Configuration';

  @override
  String get lowStockProducts => 'Low Stock Products';

  @override
  String get printerSettings => 'Printer Settings';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get salesReporting => 'Sales & Reporting';

  @override
  String get revenueReport => 'Revenue Report';

  @override
  String get topProductsRevenue => 'Top products by revenue';

  @override
  String get inventoryReport => 'Inventory Report';

  @override
  String get lowStockAlerts => 'Low stock alerts';

  @override
  String get noSalesData => 'No sales data';

  @override
  String get sold => 'Sold';

  @override
  String get stockLevelsGood => 'Stock levels are good';

  @override
  String get dateSearch => 'Date Search';

  @override
  String get posTerminal => 'POS Terminal';

  @override
  String get session => 'Session';

  @override
  String get onlineSyncing => 'Online & Syncing';

  @override
  String get searchProductHint =>
      'Scan Barcode or Search Product (e.g. Software)...';

  @override
  String get item => 'ITEM';

  @override
  String get qty => 'QTY';

  @override
  String get price => 'PRICE';

  @override
  String get discount => 'DISCOUNT';

  @override
  String get total => 'TOTAL';

  @override
  String get cartIsEmpty => 'Cart is empty';

  @override
  String get scanToAdd => 'Scan a barcode or search to add items';

  @override
  String get baseUnit => 'Base Unit';

  @override
  String get addPurchaseInvoice => 'Add Purchase Invoice';

  @override
  String get noPurchasesFound => 'No purchases found.';

  @override
  String get supplierId => 'Supplier ID';

  @override
  String get errorPrefix => 'Error';

  @override
  String get walkInCustomer => 'Walk-in Customer';

  @override
  String get addAtLeastOneItem => 'Please add at least one item';

  @override
  String get splitPaymentCredit => 'Split Payment / Credit';

  @override
  String totalDue(String amount) {
    return 'Total Due: SAR $amount';
  }

  @override
  String get cashAmount => 'Cash Amount (SAR)';

  @override
  String get cardAmount => 'Card Amount (SAR)';

  @override
  String get bankAmount => 'Bank Amount (SAR)';

  @override
  String get creditDues => 'Credit / Dues (SAR)';

  @override
  String get fullyAllocated => 'Fully Allocated';

  @override
  String remainingAmount(String amount) {
    return 'Remaining: SAR $amount';
  }

  @override
  String overpaidAmount(String amount) {
    return 'Overpaid: SAR $amount';
  }

  @override
  String get confirmAndPay => 'Confirm & Pay';

  @override
  String get selectCounter => 'Select Counter';

  @override
  String get noCountersFound => 'No counters found for this branch/tenant.';

  @override
  String get branch => 'Branch';

  @override
  String get close => 'Close';

  @override
  String get assignCustomer => 'Assign Customer';

  @override
  String get customerName => 'Customer Name';

  @override
  String get requiredText => 'Required';

  @override
  String get vatNumber => 'VAT Number';

  @override
  String get phoneWhatsapp => 'Phone (WhatsApp)';

  @override
  String get invoiceCreatedSuccessfully => 'Invoice created successfully!';

  @override
  String get noItemsInInvoice => 'No items in invoice';

  @override
  String get holdBtn => 'Hold';

  @override
  String get recallBtn => 'Recall';

  @override
  String get voidBtn => 'Void';

  @override
  String get returnExchangeBtn => 'Return / Exchange';

  @override
  String get printBtn => 'Print';

  @override
  String get whatsappBtn => 'WhatsApp';

  @override
  String get tapToAssignCustomer => 'Tap to assign customer';

  @override
  String get noCounterSelected => 'No Counter Selected';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get discountText => 'Discount';

  @override
  String get vat15 => 'VAT (15%)';

  @override
  String get totalText => 'Total';

  @override
  String get cash => 'Cash';

  @override
  String get card => 'Card';

  @override
  String get bank => 'Bank';

  @override
  String get wallet => 'Wallet';

  @override
  String get splitPaymentBtn => 'SPLIT PAYMENT / CREDIT';

  @override
  String saveAndPay(String amount) {
    return 'SAVE & PAY SAR $amount';
  }

  @override
  String get invoiceSentWhatsApp => 'Invoice sent via WhatsApp!';

  @override
  String get paymentLinkGenerated => 'Payment link generated! Opening...';

  @override
  String get invoiceDetail => 'Invoice Detail';

  @override
  String get issueCreditNote => 'Issue Credit Note (Return)';

  @override
  String get issueDebitNote => 'Issue Debit Note';

  @override
  String get payNow => 'Pay Now';

  @override
  String get taxInvoiceTitle => 'TAX INVOICE / فاتورة ضريبية';

  @override
  String invoiceNo(String no) {
    return 'Invoice No: $no';
  }

  @override
  String dateText(String date) {
    return 'Date: $date';
  }

  @override
  String statusText(String status) {
    return 'Status: $status';
  }

  @override
  String get billedTo => 'Billed To:';

  @override
  String vatNo(String vat) {
    return 'VAT No: $vat';
  }

  @override
  String get description => 'Description';

  @override
  String get zatcaQrCode => 'ZATCA QR Code';

  @override
  String subtotalAmount(String amount) {
    return 'Subtotal: SAR $amount';
  }

  @override
  String vat15Amount(String amount) {
    return 'VAT (15%): SAR $amount';
  }

  @override
  String totalAmountSAR(String amount) {
    return 'Total Amount: SAR $amount';
  }

  @override
  String get hrDashboard => 'HR Dashboard';

  @override
  String get hrEmployees => 'Employees';
}
