// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'نومو إي آر بي';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get invoices => 'الفواتير';

  @override
  String get createInvoice => 'إنشاء فاتورة';

  @override
  String get zatcaCleared => 'تمت تخليص زاتكا';

  @override
  String sarAmount(String amount) {
    return 'ر.س $amount';
  }
}
