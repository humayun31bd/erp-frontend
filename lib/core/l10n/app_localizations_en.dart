// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Numou ERP';

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
}
