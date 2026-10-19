import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'Intelligent ERP'**
  String get appName;

  /// No description provided for @dashboard.
  ///
  /// In ar, this message translates to:
  /// **'لوحة التحكم'**
  String get dashboard;

  /// No description provided for @invoices.
  ///
  /// In ar, this message translates to:
  /// **'الفواتير'**
  String get invoices;

  /// No description provided for @createInvoice.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء فاتورة'**
  String get createInvoice;

  /// No description provided for @zatcaCleared.
  ///
  /// In ar, this message translates to:
  /// **'تمت تخليص زاتكا'**
  String get zatcaCleared;

  /// No description provided for @sarAmount.
  ///
  /// In ar, this message translates to:
  /// **'ر.س {amount}'**
  String sarAmount(String amount);

  /// No description provided for @login.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get login;

  /// No description provided for @phone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phone;

  /// No description provided for @password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// No description provided for @loginButtonText.
  ///
  /// In ar, this message translates to:
  /// **'دخول'**
  String get loginButtonText;

  /// No description provided for @loginError.
  ///
  /// In ar, this message translates to:
  /// **'فشل المصادقة. يرجى التحقق من بياناتك.'**
  String get loginError;

  /// No description provided for @welcomeBack.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بعودتك'**
  String get welcomeBack;

  /// No description provided for @customers.
  ///
  /// In ar, this message translates to:
  /// **'العملاء'**
  String get customers;

  /// No description provided for @suppliers.
  ///
  /// In ar, this message translates to:
  /// **'الموردين'**
  String get suppliers;

  /// No description provided for @purchases.
  ///
  /// In ar, this message translates to:
  /// **'المشتريات'**
  String get purchases;

  /// No description provided for @cashBook.
  ///
  /// In ar, this message translates to:
  /// **'دفتر النقدية'**
  String get cashBook;

  /// No description provided for @inventory.
  ///
  /// In ar, this message translates to:
  /// **'المخزون'**
  String get inventory;

  /// No description provided for @posCashier.
  ///
  /// In ar, this message translates to:
  /// **'نقطة البيع'**
  String get posCashier;

  /// No description provided for @posDashboard.
  ///
  /// In ar, this message translates to:
  /// **'لوحة نقاط البيع'**
  String get posDashboard;

  /// No description provided for @aiCopilot.
  ///
  /// In ar, this message translates to:
  /// **'المساعد الذكي'**
  String get aiCopilot;

  /// No description provided for @whatsappLogs.
  ///
  /// In ar, this message translates to:
  /// **'سجلات الواتساب'**
  String get whatsappLogs;

  /// No description provided for @payments.
  ///
  /// In ar, this message translates to:
  /// **'المدفوعات'**
  String get payments;

  /// No description provided for @reports.
  ///
  /// In ar, this message translates to:
  /// **'التقارير'**
  String get reports;

  /// No description provided for @agencyPortal.
  ///
  /// In ar, this message translates to:
  /// **'بوابة الوكالة'**
  String get agencyPortal;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @languageSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات اللغة'**
  String get languageSettings;

  /// No description provided for @labelKey.
  ///
  /// In ar, this message translates to:
  /// **'مفتاح التسمية'**
  String get labelKey;

  /// No description provided for @englishValue.
  ///
  /// In ar, this message translates to:
  /// **'القيمة بالإنجليزية'**
  String get englishValue;

  /// No description provided for @arabicValue.
  ///
  /// In ar, this message translates to:
  /// **'القيمة بالعربية'**
  String get arabicValue;

  /// No description provided for @actions.
  ///
  /// In ar, this message translates to:
  /// **'إجراءات'**
  String get actions;

  /// No description provided for @update.
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get update;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @manageBranches.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الفروع'**
  String get manageBranches;

  /// No description provided for @addBranch.
  ///
  /// In ar, this message translates to:
  /// **'إضافة فرع'**
  String get addBranch;

  /// No description provided for @branchName.
  ///
  /// In ar, this message translates to:
  /// **'اسم الفرع'**
  String get branchName;

  /// No description provided for @branchLocation.
  ///
  /// In ar, this message translates to:
  /// **'الموقع'**
  String get branchLocation;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @changeLanguage.
  ///
  /// In ar, this message translates to:
  /// **'تغيير اللغة'**
  String get changeLanguage;

  /// No description provided for @english.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @aiAndLogs.
  ///
  /// In ar, this message translates to:
  /// **'الذكاء الاصطناعي والسجلات'**
  String get aiAndLogs;

  /// No description provided for @management.
  ///
  /// In ar, this message translates to:
  /// **'الإدارة'**
  String get management;

  /// No description provided for @expandMenu.
  ///
  /// In ar, this message translates to:
  /// **'توسيع القائمة'**
  String get expandMenu;

  /// No description provided for @collapseMenu.
  ///
  /// In ar, this message translates to:
  /// **'طي القائمة'**
  String get collapseMenu;

  /// No description provided for @tenants.
  ///
  /// In ar, this message translates to:
  /// **'العملاء'**
  String get tenants;

  /// No description provided for @marketingPlans.
  ///
  /// In ar, this message translates to:
  /// **'خطط التسويق'**
  String get marketingPlans;

  /// No description provided for @noClientsFound.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد عملاء. قم بإضافة عميل جديد.'**
  String get noClientsFound;

  /// No description provided for @addTenant.
  ///
  /// In ar, this message translates to:
  /// **'إضافة عميل'**
  String get addTenant;

  /// No description provided for @editPlan.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الخطة'**
  String get editPlan;

  /// No description provided for @noOfBranches.
  ///
  /// In ar, this message translates to:
  /// **'عدد الفروع (1- لغير محدود)'**
  String get noOfBranches;

  /// No description provided for @noOfCounters.
  ///
  /// In ar, this message translates to:
  /// **'عدد نقاط البيع (1- لغير محدود)'**
  String get noOfCounters;

  /// No description provided for @invoicesPerMonth.
  ///
  /// In ar, this message translates to:
  /// **'عدد الفواتير شهرياً (1- لغير محدود)'**
  String get invoicesPerMonth;

  /// No description provided for @planUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم التحديث'**
  String get planUpdated;

  /// No description provided for @branches.
  ///
  /// In ar, this message translates to:
  /// **'الفروع'**
  String get branches;

  /// No description provided for @counters.
  ///
  /// In ar, this message translates to:
  /// **'نقاط البيع'**
  String get counters;

  /// No description provided for @invoicesMo.
  ///
  /// In ar, this message translates to:
  /// **'فواتير / شهر'**
  String get invoicesMo;

  /// No description provided for @unlimited.
  ///
  /// In ar, this message translates to:
  /// **'غير محدود'**
  String get unlimited;

  /// No description provided for @dashboardTitle.
  ///
  /// In ar, this message translates to:
  /// **'لوحة القيادة'**
  String get dashboardTitle;

  /// No description provided for @refreshDashboard.
  ///
  /// In ar, this message translates to:
  /// **'تحديث اللوحة'**
  String get refreshDashboard;

  /// No description provided for @zatcaOffline.
  ///
  /// In ar, this message translates to:
  /// **'محرك هيئة الزكاة غير متصل أو لا يمكن الوصول إليه حالياً.'**
  String get zatcaOffline;

  /// No description provided for @totalRevenue.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الإيرادات'**
  String get totalRevenue;

  /// No description provided for @clearedInvoices.
  ///
  /// In ar, this message translates to:
  /// **'الفواتير المعتمدة'**
  String get clearedInvoices;

  /// No description provided for @overdueAmount.
  ///
  /// In ar, this message translates to:
  /// **'المبالغ المتأخرة'**
  String get overdueAmount;

  /// No description provided for @recentActivity.
  ///
  /// In ar, this message translates to:
  /// **'النشاط الأخير'**
  String get recentActivity;

  /// No description provided for @failedToLoadDashboard.
  ///
  /// In ar, this message translates to:
  /// **'فشل تحميل لوحة القيادة'**
  String get failedToLoadDashboard;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @quickActions.
  ///
  /// In ar, this message translates to:
  /// **'إجراءات سريعة'**
  String get quickActions;

  /// No description provided for @salesInvoice.
  ///
  /// In ar, this message translates to:
  /// **'فاتورة مبيعات'**
  String get salesInvoice;

  /// No description provided for @purchaseOrder.
  ///
  /// In ar, this message translates to:
  /// **'أمر شراء'**
  String get purchaseOrder;

  /// No description provided for @shipments.
  ///
  /// In ar, this message translates to:
  /// **'الشحنات'**
  String get shipments;

  /// No description provided for @paymentReceipts.
  ///
  /// In ar, this message translates to:
  /// **'الدفع والإيصالات'**
  String get paymentReceipts;

  /// No description provided for @expenses.
  ///
  /// In ar, this message translates to:
  /// **'المصروفات'**
  String get expenses;

  /// No description provided for @customer.
  ///
  /// In ar, this message translates to:
  /// **'العميل'**
  String get customer;

  /// No description provided for @vendor.
  ///
  /// In ar, this message translates to:
  /// **'المورد'**
  String get vendor;

  /// No description provided for @receiptsSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الإيصالات'**
  String get receiptsSettings;

  /// No description provided for @summary.
  ///
  /// In ar, this message translates to:
  /// **'ملخص'**
  String get summary;

  /// No description provided for @salesOrder.
  ///
  /// In ar, this message translates to:
  /// **'أمر مبيعات'**
  String get salesOrder;

  /// No description provided for @cashLedger.
  ///
  /// In ar, this message translates to:
  /// **'دفتر النقدية'**
  String get cashLedger;

  /// No description provided for @more.
  ///
  /// In ar, this message translates to:
  /// **'المزيد...'**
  String get more;

  /// No description provided for @configurationSettings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات والتهيئة'**
  String get configurationSettings;

  /// No description provided for @enableRestaurantMode.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل وضع المطعم'**
  String get enableRestaurantMode;

  /// No description provided for @currencyConfiguration.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات العملة'**
  String get currencyConfiguration;

  /// No description provided for @lowStockProducts.
  ///
  /// In ar, this message translates to:
  /// **'المنتجات منخفضة المخزون'**
  String get lowStockProducts;

  /// No description provided for @printerSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الطابعة'**
  String get printerSettings;

  /// No description provided for @contactUs.
  ///
  /// In ar, this message translates to:
  /// **'اتصل بنا'**
  String get contactUs;

  /// No description provided for @salesReporting.
  ///
  /// In ar, this message translates to:
  /// **'المبيعات والتقارير'**
  String get salesReporting;

  /// No description provided for @revenueReport.
  ///
  /// In ar, this message translates to:
  /// **'تقرير الإيرادات'**
  String get revenueReport;

  /// No description provided for @topProductsRevenue.
  ///
  /// In ar, this message translates to:
  /// **'أفضل المنتجات حسب الإيرادات'**
  String get topProductsRevenue;

  /// No description provided for @inventoryReport.
  ///
  /// In ar, this message translates to:
  /// **'تقرير المخزون'**
  String get inventoryReport;

  /// No description provided for @lowStockAlerts.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات المخزون المنخفض'**
  String get lowStockAlerts;

  /// No description provided for @noSalesData.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات مبيعات'**
  String get noSalesData;

  /// No description provided for @sold.
  ///
  /// In ar, this message translates to:
  /// **'تم بيعه'**
  String get sold;

  /// No description provided for @stockLevelsGood.
  ///
  /// In ar, this message translates to:
  /// **'مستويات المخزون جيدة'**
  String get stockLevelsGood;

  /// No description provided for @dateSearch.
  ///
  /// In ar, this message translates to:
  /// **'البحث بالتاريخ'**
  String get dateSearch;

  /// No description provided for @posTerminal.
  ///
  /// In ar, this message translates to:
  /// **'نقطة البيع'**
  String get posTerminal;

  /// No description provided for @session.
  ///
  /// In ar, this message translates to:
  /// **'الجلسة'**
  String get session;

  /// No description provided for @onlineSyncing.
  ///
  /// In ar, this message translates to:
  /// **'متصل ومتزامن'**
  String get onlineSyncing;

  /// No description provided for @searchProductHint.
  ///
  /// In ar, this message translates to:
  /// **'امسح الباركود أو ابحث عن منتج (مثلاً برمجيات)...'**
  String get searchProductHint;

  /// No description provided for @item.
  ///
  /// In ar, this message translates to:
  /// **'العنصر'**
  String get item;

  /// No description provided for @qty.
  ///
  /// In ar, this message translates to:
  /// **'الكمية'**
  String get qty;

  /// No description provided for @price.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get price;

  /// No description provided for @discount.
  ///
  /// In ar, this message translates to:
  /// **'الخصم'**
  String get discount;

  /// No description provided for @total.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get total;

  /// No description provided for @cartIsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'السلة فارغة'**
  String get cartIsEmpty;

  /// No description provided for @scanToAdd.
  ///
  /// In ar, this message translates to:
  /// **'امسح باركود أو ابحث لإضافة عناصر'**
  String get scanToAdd;

  /// No description provided for @baseUnit.
  ///
  /// In ar, this message translates to:
  /// **'الوحدة الأساسية'**
  String get baseUnit;

  /// No description provided for @addPurchaseInvoice.
  ///
  /// In ar, this message translates to:
  /// **'إضافة فاتورة مشتريات'**
  String get addPurchaseInvoice;

  /// No description provided for @noPurchasesFound.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مشتريات.'**
  String get noPurchasesFound;

  /// No description provided for @supplierId.
  ///
  /// In ar, this message translates to:
  /// **'معرف المورد'**
  String get supplierId;

  /// No description provided for @errorPrefix.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ'**
  String get errorPrefix;

  /// No description provided for @walkInCustomer.
  ///
  /// In ar, this message translates to:
  /// **'عميل نقدي'**
  String get walkInCustomer;

  /// No description provided for @addAtLeastOneItem.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إضافة عنصر واحد على الأقل'**
  String get addAtLeastOneItem;

  /// No description provided for @splitPaymentCredit.
  ///
  /// In ar, this message translates to:
  /// **'تقسيم الدفع / آجل'**
  String get splitPaymentCredit;

  /// No description provided for @totalDue.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي المستحق: SAR {amount}'**
  String totalDue(String amount);

  /// No description provided for @cashAmount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ النقدي (SAR)'**
  String get cashAmount;

  /// No description provided for @cardAmount.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ البطاقة (SAR)'**
  String get cardAmount;

  /// No description provided for @bankAmount.
  ///
  /// In ar, this message translates to:
  /// **'التحويل البنكي (SAR)'**
  String get bankAmount;

  /// No description provided for @creditDues.
  ///
  /// In ar, this message translates to:
  /// **'آجل / مستحقات (SAR)'**
  String get creditDues;

  /// No description provided for @fullyAllocated.
  ///
  /// In ar, this message translates to:
  /// **'موزع بالكامل'**
  String get fullyAllocated;

  /// No description provided for @remainingAmount.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي: SAR {amount}'**
  String remainingAmount(String amount);

  /// No description provided for @overpaidAmount.
  ///
  /// In ar, this message translates to:
  /// **'مدفوع بالزيادة: SAR {amount}'**
  String overpaidAmount(String amount);

  /// No description provided for @confirmAndPay.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد ودفع'**
  String get confirmAndPay;

  /// No description provided for @selectCounter.
  ///
  /// In ar, this message translates to:
  /// **'اختر نقطة البيع'**
  String get selectCounter;

  /// No description provided for @noCountersFound.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على نقاط بيع لهذا الفرع.'**
  String get noCountersFound;

  /// No description provided for @branch.
  ///
  /// In ar, this message translates to:
  /// **'الفرع'**
  String get branch;

  /// No description provided for @close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// No description provided for @assignCustomer.
  ///
  /// In ar, this message translates to:
  /// **'تعيين عميل'**
  String get assignCustomer;

  /// No description provided for @customerName.
  ///
  /// In ar, this message translates to:
  /// **'اسم العميل'**
  String get customerName;

  /// No description provided for @requiredText.
  ///
  /// In ar, this message translates to:
  /// **'مطلوب'**
  String get requiredText;

  /// No description provided for @vatNumber.
  ///
  /// In ar, this message translates to:
  /// **'الرقم الضريبي'**
  String get vatNumber;

  /// No description provided for @phoneWhatsapp.
  ///
  /// In ar, this message translates to:
  /// **'الهاتف (واتساب)'**
  String get phoneWhatsapp;

  /// No description provided for @invoiceCreatedSuccessfully.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء الفاتورة بنجاح!'**
  String get invoiceCreatedSuccessfully;

  /// No description provided for @noItemsInInvoice.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عناصر في الفاتورة'**
  String get noItemsInInvoice;

  /// No description provided for @holdBtn.
  ///
  /// In ar, this message translates to:
  /// **'تعليق'**
  String get holdBtn;

  /// No description provided for @recallBtn.
  ///
  /// In ar, this message translates to:
  /// **'استدعاء'**
  String get recallBtn;

  /// No description provided for @voidBtn.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get voidBtn;

  /// No description provided for @returnExchangeBtn.
  ///
  /// In ar, this message translates to:
  /// **'إرجاع / استبدال'**
  String get returnExchangeBtn;

  /// No description provided for @printBtn.
  ///
  /// In ar, this message translates to:
  /// **'طباعة'**
  String get printBtn;

  /// No description provided for @whatsappBtn.
  ///
  /// In ar, this message translates to:
  /// **'واتساب'**
  String get whatsappBtn;

  /// No description provided for @tapToAssignCustomer.
  ///
  /// In ar, this message translates to:
  /// **'انقر لتعيين عميل'**
  String get tapToAssignCustomer;

  /// No description provided for @noCounterSelected.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تحديد نقطة بيع'**
  String get noCounterSelected;

  /// No description provided for @subtotal.
  ///
  /// In ar, this message translates to:
  /// **'المجموع الفرعي'**
  String get subtotal;

  /// No description provided for @discountText.
  ///
  /// In ar, this message translates to:
  /// **'الخصم'**
  String get discountText;

  /// No description provided for @vat15.
  ///
  /// In ar, this message translates to:
  /// **'ضريبة القيمة المضافة (15%)'**
  String get vat15;

  /// No description provided for @totalText.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get totalText;

  /// No description provided for @cash.
  ///
  /// In ar, this message translates to:
  /// **'نقدي'**
  String get cash;

  /// No description provided for @card.
  ///
  /// In ar, this message translates to:
  /// **'بطاقة'**
  String get card;

  /// No description provided for @bank.
  ///
  /// In ar, this message translates to:
  /// **'بنك'**
  String get bank;

  /// No description provided for @wallet.
  ///
  /// In ar, this message translates to:
  /// **'محفظة'**
  String get wallet;

  /// No description provided for @splitPaymentBtn.
  ///
  /// In ar, this message translates to:
  /// **'تقسيم الدفع / آجل'**
  String get splitPaymentBtn;

  /// No description provided for @saveAndPay.
  ///
  /// In ar, this message translates to:
  /// **'حفظ ودفع SAR {amount}'**
  String saveAndPay(String amount);

  /// No description provided for @invoiceSentWhatsApp.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال الفاتورة عبر واتساب!'**
  String get invoiceSentWhatsApp;

  /// No description provided for @paymentLinkGenerated.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء رابط الدفع! جاري الفتح...'**
  String get paymentLinkGenerated;

  /// No description provided for @invoiceDetail.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الفاتورة'**
  String get invoiceDetail;

  /// No description provided for @issueCreditNote.
  ///
  /// In ar, this message translates to:
  /// **'إصدار إشعار دائن (إرجاع)'**
  String get issueCreditNote;

  /// No description provided for @issueDebitNote.
  ///
  /// In ar, this message translates to:
  /// **'إصدار إشعار مدين'**
  String get issueDebitNote;

  /// No description provided for @payNow.
  ///
  /// In ar, this message translates to:
  /// **'ادفع الآن'**
  String get payNow;

  /// No description provided for @taxInvoiceTitle.
  ///
  /// In ar, this message translates to:
  /// **'TAX INVOICE / فاتورة ضريبية'**
  String get taxInvoiceTitle;

  /// No description provided for @invoiceNo.
  ///
  /// In ar, this message translates to:
  /// **'رقم الفاتورة: {no}'**
  String invoiceNo(String no);

  /// No description provided for @dateText.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ: {date}'**
  String dateText(String date);

  /// No description provided for @statusText.
  ///
  /// In ar, this message translates to:
  /// **'الحالة: {status}'**
  String statusText(String status);

  /// No description provided for @billedTo.
  ///
  /// In ar, this message translates to:
  /// **'مفوتر إلى:'**
  String get billedTo;

  /// No description provided for @vatNo.
  ///
  /// In ar, this message translates to:
  /// **'الرقم الضريبي: {vat}'**
  String vatNo(String vat);

  /// No description provided for @description.
  ///
  /// In ar, this message translates to:
  /// **'الوصف'**
  String get description;

  /// No description provided for @zatcaQrCode.
  ///
  /// In ar, this message translates to:
  /// **'رمز الاستجابة السريعة لهيئة الزكاة'**
  String get zatcaQrCode;

  /// No description provided for @subtotalAmount.
  ///
  /// In ar, this message translates to:
  /// **'المجموع الفرعي: SAR {amount}'**
  String subtotalAmount(String amount);

  /// No description provided for @vat15Amount.
  ///
  /// In ar, this message translates to:
  /// **'ضريبة القيمة المضافة (15%): SAR {amount}'**
  String vat15Amount(String amount);

  /// No description provided for @totalAmountSAR.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي: SAR {amount}'**
  String totalAmountSAR(String amount);

  /// No description provided for @hrDashboard.
  ///
  /// In ar, this message translates to:
  /// **'لوحة الموارد البشرية'**
  String get hrDashboard;

  /// No description provided for @hrEmployees.
  ///
  /// In ar, this message translates to:
  /// **'الموظفين'**
  String get hrEmployees;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
