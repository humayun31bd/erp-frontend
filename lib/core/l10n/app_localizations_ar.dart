// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'Intelligent ERP';

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

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get phone => 'رقم الهاتف';

  @override
  String get password => 'كلمة المرور';

  @override
  String get loginButtonText => 'دخول';

  @override
  String get loginError => 'فشل المصادقة. يرجى التحقق من بياناتك.';

  @override
  String get welcomeBack => 'مرحباً بعودتك';

  @override
  String get customers => 'العملاء';

  @override
  String get suppliers => 'الموردين';

  @override
  String get purchases => 'المشتريات';

  @override
  String get cashBook => 'دفتر النقدية';

  @override
  String get inventory => 'المخزون';

  @override
  String get posCashier => 'نقطة البيع';

  @override
  String get posDashboard => 'لوحة نقاط البيع';

  @override
  String get aiCopilot => 'المساعد الذكي';

  @override
  String get whatsappLogs => 'سجلات الواتساب';

  @override
  String get payments => 'المدفوعات';

  @override
  String get reports => 'التقارير';

  @override
  String get agencyPortal => 'بوابة الوكالة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get languageSettings => 'إعدادات اللغة';

  @override
  String get labelKey => 'مفتاح التسمية';

  @override
  String get englishValue => 'القيمة بالإنجليزية';

  @override
  String get arabicValue => 'القيمة بالعربية';

  @override
  String get actions => 'إجراءات';

  @override
  String get update => 'تحديث';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get manageBranches => 'إدارة الفروع';

  @override
  String get addBranch => 'إضافة فرع';

  @override
  String get branchName => 'اسم الفرع';

  @override
  String get branchLocation => 'الموقع';

  @override
  String get edit => 'تعديل';

  @override
  String get delete => 'حذف';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get changeLanguage => 'تغيير اللغة';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get aiAndLogs => 'الذكاء الاصطناعي والسجلات';

  @override
  String get management => 'الإدارة';

  @override
  String get expandMenu => 'توسيع القائمة';

  @override
  String get collapseMenu => 'طي القائمة';

  @override
  String get tenants => 'العملاء';

  @override
  String get marketingPlans => 'خطط التسويق';

  @override
  String get noClientsFound => 'لا يوجد عملاء. قم بإضافة عميل جديد.';

  @override
  String get addTenant => 'إضافة عميل';

  @override
  String get editPlan => 'تعديل الخطة';

  @override
  String get noOfBranches => 'عدد الفروع (1- لغير محدود)';

  @override
  String get noOfCounters => 'عدد نقاط البيع (1- لغير محدود)';

  @override
  String get invoicesPerMonth => 'عدد الفواتير شهرياً (1- لغير محدود)';

  @override
  String get planUpdated => 'تم التحديث';

  @override
  String get branches => 'الفروع';

  @override
  String get counters => 'نقاط البيع';

  @override
  String get invoicesMo => 'فواتير / شهر';

  @override
  String get unlimited => 'غير محدود';

  @override
  String get dashboardTitle => 'لوحة القيادة';

  @override
  String get refreshDashboard => 'تحديث اللوحة';

  @override
  String get zatcaOffline =>
      'محرك هيئة الزكاة غير متصل أو لا يمكن الوصول إليه حالياً.';

  @override
  String get totalRevenue => 'إجمالي الإيرادات';

  @override
  String get clearedInvoices => 'الفواتير المعتمدة';

  @override
  String get overdueAmount => 'المبالغ المتأخرة';

  @override
  String get recentActivity => 'النشاط الأخير';

  @override
  String get failedToLoadDashboard => 'فشل تحميل لوحة القيادة';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String get salesInvoice => 'فاتورة مبيعات';

  @override
  String get purchaseOrder => 'أمر شراء';

  @override
  String get shipments => 'الشحنات';

  @override
  String get paymentReceipts => 'الدفع والإيصالات';

  @override
  String get expenses => 'المصروفات';

  @override
  String get customer => 'العميل';

  @override
  String get vendor => 'المورد';

  @override
  String get receiptsSettings => 'إعدادات الإيصالات';

  @override
  String get summary => 'ملخص';

  @override
  String get salesOrder => 'أمر مبيعات';

  @override
  String get cashLedger => 'دفتر النقدية';

  @override
  String get more => 'المزيد...';

  @override
  String get configurationSettings => 'الإعدادات والتهيئة';

  @override
  String get enableRestaurantMode => 'تفعيل وضع المطعم';

  @override
  String get currencyConfiguration => 'إعدادات العملة';

  @override
  String get lowStockProducts => 'المنتجات منخفضة المخزون';

  @override
  String get printerSettings => 'إعدادات الطابعة';

  @override
  String get contactUs => 'اتصل بنا';

  @override
  String get salesReporting => 'المبيعات والتقارير';

  @override
  String get revenueReport => 'تقرير الإيرادات';

  @override
  String get topProductsRevenue => 'أفضل المنتجات حسب الإيرادات';

  @override
  String get inventoryReport => 'تقرير المخزون';

  @override
  String get lowStockAlerts => 'تنبيهات المخزون المنخفض';

  @override
  String get noSalesData => 'لا توجد بيانات مبيعات';

  @override
  String get sold => 'تم بيعه';

  @override
  String get stockLevelsGood => 'مستويات المخزون جيدة';

  @override
  String get dateSearch => 'البحث بالتاريخ';

  @override
  String get posTerminal => 'نقطة البيع';

  @override
  String get session => 'الجلسة';

  @override
  String get onlineSyncing => 'متصل ومتزامن';

  @override
  String get searchProductHint =>
      'امسح الباركود أو ابحث عن منتج (مثلاً برمجيات)...';

  @override
  String get item => 'العنصر';

  @override
  String get qty => 'الكمية';

  @override
  String get price => 'السعر';

  @override
  String get discount => 'الخصم';

  @override
  String get total => 'الإجمالي';

  @override
  String get cartIsEmpty => 'السلة فارغة';

  @override
  String get scanToAdd => 'امسح باركود أو ابحث لإضافة عناصر';

  @override
  String get baseUnit => 'الوحدة الأساسية';

  @override
  String get addPurchaseInvoice => 'إضافة فاتورة مشتريات';

  @override
  String get noPurchasesFound => 'لا توجد مشتريات.';

  @override
  String get supplierId => 'معرف المورد';

  @override
  String get errorPrefix => 'حدث خطأ';

  @override
  String get walkInCustomer => 'عميل نقدي';

  @override
  String get addAtLeastOneItem => 'يرجى إضافة عنصر واحد على الأقل';

  @override
  String get splitPaymentCredit => 'تقسيم الدفع / آجل';

  @override
  String totalDue(String amount) {
    return 'الإجمالي المستحق: SAR $amount';
  }

  @override
  String get cashAmount => 'المبلغ النقدي (SAR)';

  @override
  String get cardAmount => 'مبلغ البطاقة (SAR)';

  @override
  String get bankAmount => 'التحويل البنكي (SAR)';

  @override
  String get creditDues => 'آجل / مستحقات (SAR)';

  @override
  String get fullyAllocated => 'موزع بالكامل';

  @override
  String remainingAmount(String amount) {
    return 'المتبقي: SAR $amount';
  }

  @override
  String overpaidAmount(String amount) {
    return 'مدفوع بالزيادة: SAR $amount';
  }

  @override
  String get confirmAndPay => 'تأكيد ودفع';

  @override
  String get selectCounter => 'اختر نقطة البيع';

  @override
  String get noCountersFound => 'لم يتم العثور على نقاط بيع لهذا الفرع.';

  @override
  String get branch => 'الفرع';

  @override
  String get close => 'إغلاق';

  @override
  String get assignCustomer => 'تعيين عميل';

  @override
  String get customerName => 'اسم العميل';

  @override
  String get requiredText => 'مطلوب';

  @override
  String get vatNumber => 'الرقم الضريبي';

  @override
  String get phoneWhatsapp => 'الهاتف (واتساب)';

  @override
  String get invoiceCreatedSuccessfully => 'تم إنشاء الفاتورة بنجاح!';

  @override
  String get noItemsInInvoice => 'لا توجد عناصر في الفاتورة';

  @override
  String get holdBtn => 'تعليق';

  @override
  String get recallBtn => 'استدعاء';

  @override
  String get voidBtn => 'إلغاء';

  @override
  String get returnExchangeBtn => 'إرجاع / استبدال';

  @override
  String get printBtn => 'طباعة';

  @override
  String get whatsappBtn => 'واتساب';

  @override
  String get tapToAssignCustomer => 'انقر لتعيين عميل';

  @override
  String get noCounterSelected => 'لم يتم تحديد نقطة بيع';

  @override
  String get subtotal => 'المجموع الفرعي';

  @override
  String get discountText => 'الخصم';

  @override
  String get vat15 => 'ضريبة القيمة المضافة (15%)';

  @override
  String get totalText => 'الإجمالي';

  @override
  String get cash => 'نقدي';

  @override
  String get card => 'بطاقة';

  @override
  String get bank => 'بنك';

  @override
  String get wallet => 'محفظة';

  @override
  String get splitPaymentBtn => 'تقسيم الدفع / آجل';

  @override
  String saveAndPay(String amount) {
    return 'حفظ ودفع SAR $amount';
  }

  @override
  String get invoiceSentWhatsApp => 'تم إرسال الفاتورة عبر واتساب!';

  @override
  String get paymentLinkGenerated => 'تم إنشاء رابط الدفع! جاري الفتح...';

  @override
  String get invoiceDetail => 'تفاصيل الفاتورة';

  @override
  String get issueCreditNote => 'إصدار إشعار دائن (إرجاع)';

  @override
  String get issueDebitNote => 'إصدار إشعار مدين';

  @override
  String get payNow => 'ادفع الآن';

  @override
  String get taxInvoiceTitle => 'TAX INVOICE / فاتورة ضريبية';

  @override
  String invoiceNo(String no) {
    return 'رقم الفاتورة: $no';
  }

  @override
  String dateText(String date) {
    return 'التاريخ: $date';
  }

  @override
  String statusText(String status) {
    return 'الحالة: $status';
  }

  @override
  String get billedTo => 'مفوتر إلى:';

  @override
  String vatNo(String vat) {
    return 'الرقم الضريبي: $vat';
  }

  @override
  String get description => 'الوصف';

  @override
  String get zatcaQrCode => 'رمز الاستجابة السريعة لهيئة الزكاة';

  @override
  String subtotalAmount(String amount) {
    return 'المجموع الفرعي: SAR $amount';
  }

  @override
  String vat15Amount(String amount) {
    return 'ضريبة القيمة المضافة (15%): SAR $amount';
  }

  @override
  String totalAmountSAR(String amount) {
    return 'الإجمالي: SAR $amount';
  }

  @override
  String get hrDashboard => 'لوحة الموارد البشرية';

  @override
  String get hrEmployees => 'الموظفين';
}
