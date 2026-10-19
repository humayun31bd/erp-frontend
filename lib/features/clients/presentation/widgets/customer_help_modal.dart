import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app.dart';

class CustomerHelpModal extends ConsumerStatefulWidget {
  final int initialTab;
  const CustomerHelpModal({super.key, this.initialTab = 0});

  @override
  ConsumerState<CustomerHelpModal> createState() => _CustomerHelpModalState();
}

class _CustomerHelpModalState extends ConsumerState<CustomerHelpModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820, maxHeight: 720),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 12),
              decoration: const BoxDecoration(
                color: Color(0xFF1A237E), // Deep Navy
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.menu_book_rounded, color: Colors.white, size: 26),
                          const SizedBox(width: 12),
                          Text(
                            isArabic ? 'دليل إدارة العملاء' : 'Customer Management Guide',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(isArabic ? Icons.g_translate : Icons.language, color: Colors.white70),
                            tooltip: isArabic ? 'تغيير اللغة إلى الإنجليزية' : 'Switch Language to Arabic',
                            onPressed: () {
                              ref.read(localeProvider.notifier).state =
                                  isArabic ? const Locale('en') : const Locale('ar');
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white70),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isArabic
                        ? 'الدليل الشامل لإضافة وتعديل وإدارة حدود الائتمان وحذف العملاء.'
                        : 'Complete manual for adding, editing, managing credit limits, and deleting customers.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  // Navigation Tabs
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicatorColor: const Color(0xFF00BFA5),
                    indicatorWeight: 3,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white60,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    tabAlignment: TabAlignment.start,
                    tabs: [
                      Tab(icon: const Icon(Icons.dashboard_outlined, size: 18), text: isArabic ? 'نظرة عامة' : 'Overview'),
                      Tab(icon: const Icon(Icons.person_add_outlined, size: 18), text: isArabic ? 'الإضافة والمدخلات' : 'Add & Inputs'),
                      Tab(icon: const Icon(Icons.edit_note, size: 18), text: isArabic ? 'التعديل والأنواع' : 'Edit & Types'),
                      Tab(icon: const Icon(Icons.credit_score, size: 18), text: isArabic ? 'الائتمان وقواعد POS' : 'Credit & POS Rules'),
                      Tab(icon: const Icon(Icons.file_upload_outlined, size: 18), text: isArabic ? 'استيراد CSV' : 'CSV Import'),
                    ],
                  ),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(isArabic),
                  _buildAddAndInputsTab(isArabic),
                  _buildEditAndDeleteTab(isArabic),
                  _buildCreditAndPosRulesTab(isArabic),
                  _buildCsvImportTab(isArabic),
                ],
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isArabic
                        ? 'نظام دفتر حسابات العملاء المتوافق مع هيئة الزكاة والضريبة والجمارك'
                        : 'ZATCA Compliant Customer Ledger System',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(isArabic ? 'إغلاق الدليل' : 'Close Guide', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // TAB 1: OVERVIEW
  // ─────────────────────────────────────────────
  Widget _buildOverviewTab(bool isArabic) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _tipCard(
          icon: Icons.info_outline,
          title: isArabic ? 'ما هي إدارة العملاء؟' : 'What is Customer Management?',
          content: isArabic
              ? 'تتيح لك وحدة العملاء تتبع حسابات العملاء، وإدارة المستحقات (الذمم)، والدفعات المقدمة (الرصيد المودع)، وإصدار فواتير متوافقة مع هيئة الزكاة، والتحكم في المبيعات الآجلة بسقوف ائتمانية مخصصة.'
              : 'The Customers module enables you to track client accounts, manage receivables (dues), advance payments (funds), issue ZATCA compliant invoices, and control credit sales with custom credit ceilings.',
          color: Colors.indigo,
        ),
        const SizedBox(height: 16),
        _sectionHeader(isArabic ? 'القدرات الأساسية' : 'Key Capabilities'),
        _bulletPoint(
          isArabic ? 'البحث الفوري' : 'Live Search',
          isArabic ? 'البحث الفوري باسم العميل أو رقم الهاتف أو البريد الإلكتروني أو المدينة.' : 'Search instantly by customer name, phone number, email address, or city.',
        ),
        _bulletPoint(
          isArabic ? 'شريط الفلاتر المتعددة' : 'Multi-Filter Bar',
          isArabic ? 'تصفية دليل العملاء حسب الدولة، المنطقة، المدينة، ونوع العميل (جديد، متكرر، دائم، جملة).' : 'Filter customer directory by Country, State, City, and Customer Type (New, Regular, VIP, Wholesale).',
        ),
        _bulletPoint(
          isArabic ? 'أعمدة قابلة للفرز' : 'Sortable Columns',
          isArabic ? 'انقر على رأس أي عمود (الاسم، النوع، الرصيد، المستحقات، حد الائتمان، تاريخ الانضمام) للفرز تصاعدياً أو تنازلياً.' : 'Click any column header (Name, Type, Funds, Dues, Credit Limit, Joined Date) to sort ascending or descending.',
        ),
        _bulletPoint(
          isArabic ? 'شارات حد الائتمان' : 'Credit Limit Badges',
          isArabic ? 'معرفة ما إذا كان العميل يمتلك صلاحية الائتمان ("مسموح" بالأخضر أو "معطل" بالرمادي) فوراً مع حده المعتمد.' : 'Instantly see if a customer has credit permissions ("Permitted" in green or "Disabled" in grey) alongside their approved limit.',
        ),
        _bulletPoint(
          isArabic ? 'مزامنة مع نقطة البيع (POS)' : 'Integrated POS Checkout',
          isArabic ? 'تتم مزامنة العملاء المحددين مباشرة مع شاشة نقطة البيع للتحقق التلقائي من الائتمان وإرسال الإيصالات عبر الواتساب.' : 'Assigned customers synchronize directly with the Point of Sale screen for automatic credit validation and WhatsApp receipts.',
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // TAB 2: ADD & INPUTS
  // ─────────────────────────────────────────────
  Widget _buildAddAndInputsTab(bool isArabic) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _tipCard(
          icon: Icons.add_circle_outline,
          title: isArabic ? 'كيفية إضافة عميل' : 'How to Add a Customer',
          content: isArabic
              ? 'انقر على زر "+ إضافة عميل" في أعلى يمين شاشة العملاء، أو استخدم "+ عميل جديد" داخل نافذة اختيار العميل في شاشة نقطة البيع.'
              : 'Click the "+ Add Customer" button in the top right of the customer screen, or use "+ New Customer" inside the POS customer selection dialog.',
          color: Colors.teal,
        ),
        const SizedBox(height: 20),
        _sectionHeader(isArabic ? 'شرح جميع حقول المدخلات' : 'All Input Fields Explained'),
        const SizedBox(height: 10),

        _fieldSpec(
          name: isArabic ? 'اسم العميل' : 'Customer Name',
          required: true,
          type: isArabic ? 'نص' : 'Text',
          description: isArabic
              ? 'الاسم القانوني الأساسي للعميل أو الشركة أو المؤسسة. يجب أن يكون فريداً لكل منظمة.'
              : 'The primary legal name of the customer, company, or establishment. Must be unique per organization.',
        ),
        _fieldSpec(
          name: isArabic ? 'نوع العميل' : 'Customer Type',
          required: true,
          type: isArabic ? 'قائمة منسدلة (قياسي، جملة، VIP، عابر)' : 'Dropdown (Standard, Wholesale, VIP, Walk-in)',
          description: isArabic
              ? 'التصنيف الخاص بفئات التسعير، وسقوف الائتمان، وتنسيق فواتير هيئة الزكاة. يحدد تطبيق خصومات التجزئة أو الجملة أو VIP، ويتحكم في صلاحيات البيع الآجل.'
              : 'Classification for pricing tiers, credit ceilings, and ZATCA invoice formatting. Governs whether retail, wholesale, or VIP discounts apply, and controls credit sales privileges.',
        ),
        _fieldSpec(
          name: isArabic ? 'عنوان البريد الإلكتروني' : 'Email Address',
          required: false,
          type: isArabic ? 'بريد إلكتروني' : 'Email',
          description: isArabic
              ? 'يُستخدم لإرسال الفواتير، كشوفات الحساب، وإيصالات الدفع الآلية.'
              : 'Used for sending invoices, statements of account, and automated payment receipts.',
        ),
        _fieldSpec(
          name: isArabic ? 'رقم الهاتف' : 'Phone Number',
          required: false,
          type: isArabic ? 'هاتف / رقم' : 'Phone / Number',
          description: isArabic
              ? 'يُستخدم للبحث عن العميل في شاشة الـ POS وإرسال فواتير PDF فورية عبر الواتساب.'
              : 'Used for customer lookups at the POS and sending instant PDF invoices via WhatsApp.',
        ),
        _fieldSpec(
          name: isArabic ? 'الموقع (الدولة، المنطقة، المدينة، العنوان)' : 'Location (Country, State, City, Address)',
          required: false,
          type: isArabic ? 'نص' : 'Text',
          description: isArabic
              ? 'العنوان الفعلي المطبوع على الفواتير الضريبية القياسية المطلوبة للامتثال لـ المرحلة الثانية من هيئة الزكاة (B2B).'
              : 'Physical address printed on Standard Tax Invoices required for B2B ZATCA Phase 2 compliance.',
        ),
        _fieldSpec(
          name: isArabic ? 'الرصيد المودع (الدفعة المقدمة)' : 'Funds (Credit Balance / Advance)',
          required: false,
          type: isArabic ? 'عشري / عملة' : 'Decimal / Currency',
          description: isArabic
              ? 'المدفوعات المسبقة للعميل أو رصيد محفظته. يمكن استخدامه لتغطية المشتريات المستقبلية.'
              : 'Customer pre-payments or wallet balance. Can be used to offset future purchases.',
        ),
        _fieldSpec(
          name: isArabic ? 'المستحقات (الذمم المدينة القائمة)' : 'Dues (Outstanding Payable)',
          required: false,
          type: isArabic ? 'عشري / عملة' : 'Decimal / Currency',
          description: isArabic
              ? 'الرصيد المستحق غير المدفوع أو الديون الحالية المستحقة على العميل لصالح عملك.'
              : 'Existing unpaid balance or debt currently owed by the customer to your business.',
        ),
        _fieldSpec(
          name: isArabic ? 'السماح بالائتمان (البيع على الحساب)' : 'Permit Credit (On Account)',
          required: true,
          type: isArabic ? 'مفتاح (نعم / لا)' : 'Switch (Yes / No)',
          description: isArabic
              ? 'المفتاح الرئيسي للسماح لهذا العميل بشراء البضائع بالآجل / على الحساب. عند الإيقاف، تمنع شاشة الـ POS المبيعات الآجلة.'
              : 'Master switch to allow this customer to purchase goods on credit/account. When OFF, POS blocks on-account sales.',
        ),
        _fieldSpec(
          name: isArabic ? 'مبلغ حد الائتمان (ر.س)' : 'Credit Limit Amount (SAR)',
          required: false,
          type: isArabic ? 'عشري / عملة' : 'Decimal / Currency',
          description: isArabic
              ? 'الحد الأقصى المسموح به لإجمالي الائتمان/الدين لهذا العميل. يجب أن يكون أكبر من 0 للسماح بالمبيعات الآجلة.'
              : 'The maximum allowable total credit/debt for this customer. Must be greater than 0 to allow on-account sales.',
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // TAB 3: EDIT & CUSTOMER TYPES
  // ─────────────────────────────────────────────
  Widget _buildEditAndDeleteTab(bool isArabic) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _tipCard(
          icon: Icons.manage_accounts_outlined,
          title: isArabic ? 'إدارة الملفات الشخصية وتصنيفات العملاء' : 'Managing Profiles & Customer Classifications',
          content: isArabic
              ? 'تتحكم ملفات تعريف العملاء في كيفية تسعير المعاملات، وكيفية تطبيق حدود الائتمان في الـ POS، وما إذا كانت هيئة الزكاة تصدر فواتير مبسطة (B2C) أو فواتير ضريبية قياسية (B2B).'
              : 'Customer profiles control how transactions are priced, how credit limits are enforced at the POS, and whether ZATCA generates B2C Simplified Invoices or B2B Standard Tax Invoices.',
          color: Colors.indigo,
        ),
        const SizedBox(height: 20),

        _sectionHeader(isArabic ? '1. كيفية تعديل بيانات العميل' : '1. How to Edit Customer Details'),
        const SizedBox(height: 8),
        _buildStep(
          step: '1',
          title: isArabic ? 'التعديل السريع المباشر (✏️)' : 'Inline Quick Edit (✏️)',
          description: isArabic
              ? 'في جدول قائمة العملاء، انقر على أيقونة القلم (✏️) في عمود الإجراءات. يفتح نافذة سريعة تتيح لك تحديث معلومات الاتصال، العنوان، نوع العميل، وحدود الائتمان دون مغادرة نتائج البحث.'
              : 'On the Customers list table, click the pencil icon (✏️) in the Actions column. A fast dialog opens allowing you to update contact information, address, customer type, and credit limits without leaving your active search or filters.',
        ),
        _buildStep(
          step: '2',
          title: isArabic ? 'شاشة دفتر حساب العميل الكاملة' : 'Full Customer Ledger Screen',
          description: isArabic
              ? 'انقر على أي صف عميل أو زر "عرض" للانتقال إلى صفحة تفاصيل العميل المخصصة. يمكنك هنا فحص تقرير أعمار الحسابات المدينة (AR)، وتصفية الفواتير السابقة، والنقر على "تعديل البيانات".'
              : 'Click on any customer row or the "View" button to navigate to their dedicated Customer Details page. Here you can inspect their complete Accounts Receivable (AR) Aging Report, filter past invoices, and click "Edit Details".',
        ),
        _buildStep(
          step: '3',
          title: isArabic ? 'سقوف ومفاتيح الائتمان' : 'Credit Ceilings & Switches',
          description: isArabic
              ? 'يتم تطبيق تعديل "السماح بالائتمان" أو "مبلغ حد الائتمان (ر.س)" فورياً عبر جميع محطات أمناء الصندوق وشاشات إنشاء الفواتير.'
              : 'Adjusting "Permit Credit" or "Credit Limit Amount (SAR)" takes effect immediately across all POS cashier stations and invoicing creation forms.',
        ),
        const SizedBox(height: 24),

        _sectionHeader(isArabic ? '2. كيفية تغيير نوع العميل (خطوة بخطوة)' : '2. How to Change Customer Type (Step-by-Step)'),
        const SizedBox(height: 8),
        _buildStep(
          step: 'A',
          title: isArabic ? 'فتح نموذج تعديل العميل' : 'Open Customer Edit Form',
          description: isArabic
              ? 'انقر على أيقونة القلم (✏️) في صف العميل، أو افتح صفحة تفاصيل العميل وانقر على "تعديل البيانات".'
              : 'Click the pencil icon (✏️) on the customer table row, or open their Customer Detail page and tap "Edit Details".',
        ),
        _buildStep(
          step: 'B',
          title: isArabic ? 'اختيار نوع العميل الجديد من القائمة' : 'Select New Customer Type from Dropdown',
          description: isArabic
              ? 'انقر على قائمة "نوع العميل" المنسدلة واختر التصنيف الجديد: قياسي، جملة، VIP، أو عابر.'
              : 'Click the "Customer Type" dropdown menu and choose the new classification: Standard, Wholesale, VIP, or Walk-in.',
        ),
        _buildStep(
          step: 'C',
          title: isArabic ? 'إدخال البيانات الإلزامية للأنواع المترقية' : 'Provide Mandatory Details for Upgraded Types',
          description: isArabic
              ? '• عند الترقية إلى جملة (B2B): أدخل الرقم الضريبي للعميل (15 رقماً) والعنوان الفعلي الكامل للامتثال لفواتير الزكاة القياسية.\n• عند منح الائتمان: فعّل مفتاح "السماح بالائتمان" وحدد حد الائتمان المناسب (مثلاً 10,000.00 ر.س).'
              : '• If upgrading to Wholesale (B2B): Enter the customer\'s 15-digit VAT Registration Number and full street address for ZATCA Standard Tax Invoice compliance.\n• If granting credit: Turn ON the "Permit Credit" switch and set an appropriate Credit Limit (e.g., SAR 10,000.00).',
        ),
        _buildStep(
          step: 'D',
          title: isArabic ? 'الحفظ والمزامنة الفورية' : 'Save & Instant Synchronization',
          description: isArabic
              ? 'انقر على "حفظ التغييرات". يتم كود المزامنة فوراً مع محطات POS النشطة ومحركات تسعير الكتالوج.'
              : 'Click "Save Changes". The new classification synchronizes immediately with active POS registers, catalog pricing engines, and billing workflows.',
        ),
        const SizedBox(height: 24),

        _sectionHeader(isArabic ? '3. أنواع العملاء وصلاحيات النظام' : '3. Customer Types & System Privileges'),
        const SizedBox(height: 8),
        _typeClassificationCard(
          title: isArabic ? 'عميل قياسي' : 'Standard Customer',
          badge: isArabic ? 'فئة أسعار التجزئة' : 'Retail Pricing Tier',
          color: Colors.blue.shade700,
          desc: isArabic ? 'متسوقو التجزئة الأفراد والمستهلكون العاديون.' : 'Individual retail shoppers and everyday private consumers.',
          bulletPoints: isArabic
              ? [
                  'يطبق أسعار التجزئة القياسية في الـ POS والفواتير.',
                  'مؤهل للمبيعات الآجلة إذا كان مفتاح الائتمان مفعلاً.',
                  'تصدر الفواتير كـ فواتير ضريبية مبسطة (B2C) مع رمز QR.',
                  'إرسال فوري لإيصالات الواتساب والبريد الإلكتروني.',
                ]
              : [
                  'Applies standard retail catalog prices at POS and invoices.',
                  'Eligible for on-account credit sales if Permit Credit is enabled.',
                  'Invoices issued as ZATCA Simplified Tax Invoices (B2C) with QR code.',
                  'Instant WhatsApp and Email receipt dispatch.',
                ],
        ),
        const SizedBox(height: 12),
        _typeClassificationCard(
          title: isArabic ? 'عميل جملة' : 'Wholesale Customer',
          badge: isArabic ? 'تسعير الجملة والشركات B2B' : 'B2B Trade & Bulk Pricing',
          color: Colors.amber.shade800,
          desc: isArabic ? 'الشركات، الموّزعون، والمؤسسات التجارية.' : 'Commercial corporate clients, bulk purchasers, distributors, and business establishments.',
          bulletPoints: isArabic
              ? [
                  'يفعل قوائم أسعار الجملة المخفضة عبر الأصناف.',
                  'مؤهل لحدود الائتمان التجارية مع فترات سداد ممتدة.',
                  'يتطلب الرقم الضريبي (15 رقماً) والعنوان للفواتير الضريبية القياسية (UBL 2.1).',
                  'تتبع الحسابات ضمن دفتر الذمم المدينة التجارية.',
                ]
              : [
                  'Unlocks wholesale discounted price lists across inventory items.',
                  'Eligible for commercial credit limits with extended settlement terms.',
                  'Requires 15-digit VAT number and physical address for ZATCA Standard Tax Invoices (UBL 2.1).',
                  'Tracked under commercial accounts receivable ledger.',
                ],
        ),
        const SizedBox(height: 12),
        _typeClassificationCard(
          title: isArabic ? 'عميل VIP' : 'VIP Customer',
          badge: isArabic ? 'فئة كبار العملاء المميزة' : 'Preferred Loyalty Tier',
          color: Colors.purple.shade700,
          desc: isArabic ? 'العملاء المخلصون وكبار المشترين.' : 'Top-tier loyal customers and high-volume corporate accounts.',
          bulletPoints: isArabic
              ? [
                  'يطبق خصومات VIP ترويجية وتخفيضات خاصة.',
                  'سقوف ائتمان أعلى مع فترات سماح أولوية للسداد.',
                  'شارات حالة ممتازة تظهر على شاشات أمناء الصندوق.',
                ]
              : [
                  'Applies preferential VIP promotional discounts and custom margins.',
                  'Higher credit allowance thresholds with priority payment grace periods.',
                  'Flagged with high-priority status badge across POS cashier queues.',
                ],
        ),
        const SizedBox(height: 12),
        _typeClassificationCard(
          title: isArabic ? 'عميل عابر' : 'Walk-in Customer',
          badge: isArabic ? 'دفع نقدي / شبكة فورية فقط' : 'Immediate Cash / Card Only',
          color: Colors.blueGrey.shade700,
          desc: isArabic ? 'الزوار غير المسجلين الذين يشترون لمرة واحدة.' : 'Anonymous or unregistered store visitors making one-time over-the-counter purchases.',
          bulletPoints: isArabic
              ? [
                  'الخيار الافتراضي عند عدم اختيار عميل في الـ POS.',
                  'البيع الآجل / على الحساب محظور تماماً لهذا الخيار.',
                  'يجب تسديد المبلغ كاملاً فورياً نقداً أو شبكة أو تحويل.',
                  'يستلم إيصالاً ضريبياً مبسطاً عادياً.',
                ]
              : [
                  'Default fallback customer when no profile is selected at POS.',
                  'Credit / On-Account payment is STRICTLY DISABLED.',
                  'Must settle full balance immediately via Cash, Card, or Bank transfer.',
                  'Receives standard Simplified B2C receipt.',
                ],
        ),
        const SizedBox(height: 24),

        _sectionHeader(isArabic ? '4. قواعد العمل عند تغيير نوع العميل' : '4. Business Rules When Changing Customer Type'),
        const SizedBox(height: 8),
        _changeRuleItem(
          icon: Icons.sell_outlined,
          ruleNumber: isArabic ? 'قاعدة 1' : 'Rule 1',
          title: isArabic ? 'التسعير الديناميكي وانتقال فئات الأسعار' : 'Dynamic Pricing & Price Tier Transition',
          desc: isArabic
              ? 'تغيير نوع العميل يغير فوراً فئة الأسعار المطبقة على السلات والفواتير المستقبلية.'
              : 'Changing a customer\'s type immediately alters the pricing tier applied to future POS carts and sales invoices.',
          accentColor: Colors.teal.shade700,
        ),
        _changeRuleItem(
          icon: Icons.credit_score,
          ruleNumber: isArabic ? 'قاعدة 2' : 'Rule 2',
          title: isArabic ? 'سياسة الائتمان والسقوف' : 'Credit Privileges & Ceilings Policy',
          desc: isArabic
              ? 'العميل العابر لا يمكن منحه ائتماناً إطلاقاً. عند التحويل لـ جملة أو VIP، يجب مراجعة وتعيين حد الائتمان وتفعيل المفتاح.'
              : 'Walk-in customers can never be granted credit. If changing a customer from Walk-in to Wholesale or VIP, you must review and assign a credit limit.',
          accentColor: Colors.indigo.shade700,
        ),
        _changeRuleItem(
          icon: Icons.receipt_long_outlined,
          ruleNumber: isArabic ? 'قاعدة 3' : 'Rule 3',
          title: isArabic ? 'متطلبات امتثال الزكاة B2B مقابل B2C' : 'ZATCA B2B vs B2C Compliance Requirements',
          desc: isArabic
              ? 'حسابات الجملة تتطلب فواتير ضريبية قياسية برقم ضريبي 15 رقماً وعنوان كامل قبل التقديم لمنع الرفض من هيئة الزكاة.'
              : 'Wholesale accounts engage in B2B transactions, requiring Standard Tax Invoices with the buyer\'s 15-digit VAT number and physical address.',
          accentColor: Colors.amber.shade800,
        ),
        _changeRuleItem(
          icon: Icons.lock_clock_outlined,
          ruleNumber: isArabic ? 'قاعدة 4' : 'Rule 4',
          title: isArabic ? 'عدم المساس بالفواتير التاريخية' : 'Historical Invoices Immutability (Legal Lock)',
          desc: isArabic
              ? 'تغيير نوع العميل يؤثر فقط على الطلبات المستقبلية. الفواتير الصادرة سابقاً تحتفظ ببياناتها التاريخية كما هي قانونياً.'
              : 'Changing a customer type affects ONLY future orders. Past invoices retain their historical customer snapshot mandated by ZATCA.',
          accentColor: Colors.blueGrey.shade800,
        ),
        _changeRuleItem(
          icon: Icons.timeline_outlined,
          ruleNumber: isArabic ? 'قاعدة 5' : 'Rule 5',
          title: isArabic ? 'استمرارية دفتر الحسابات وتقارير الأعمار' : 'AR Aging Report & Ledger Continuity',
          desc: isArabic
              ? 'تغيير نوع العميل لا يصفر دفتر الحسابات. تبقى جميع المستحقات وأعمار الديون (0-30، 31-60، إلخ) محفوظة.'
              : 'Changing a customer\'s type does NOT reset or erase their historical ledger. All recorded dues and aging buckets remain intact.',
          accentColor: Colors.purple.shade700,
        ),
        const SizedBox(height: 24),

        _sectionHeader(isArabic ? '5. سياسة حذف العملاء الآمنة' : '5. Safe Customer Deletion Policy'),
        const SizedBox(height: 8),
        _tipCard(
          icon: Icons.warning_amber_rounded,
          title: isArabic ? 'سلامة الحذف وحماية التدقيق' : 'Deletion Safety & Audit Protection',
          content: isArabic
              ? 'لحذف عميل، انقر على أيقونة سلة المهملات (🗑️) في عمود الإجراءات.\n\nقاعدة التدقيق الضريبي: حذف العميل يزيله من عمليات البحث المستقبلية، ولكن لا يحذف فواتيره الضريبية الصادرة سابقاً لضمان سلامة الفحص الضريبي القانوني.'
              : 'To delete a customer, click the trash icon (🗑️) in the Actions column. Deleting a customer removes their entry from future lookups, but does NOT delete previously issued tax invoices.',
          color: Colors.red,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // TAB 4: CREDIT & POS RULES
  // ─────────────────────────────────────────────
  Widget _buildCreditAndPosRulesTab(bool isArabic) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _tipCard(
          icon: Icons.shield_outlined,
          title: isArabic ? 'قواعد حماية الائتمان والبيع على الحساب في الـ POS' : 'POS Credit & On Account Protection Rules',
          content: isArabic
              ? 'لمنع الديون المعدومة والمبيعات الآجلة غير المعتمدة، يتحقق محرك الـ POS تلقائياً من كل معاملة مقارنة بملف العميل.'
              : 'To prevent bad debts and unapproved credit sales, the POS checkout engine automatically validates every transaction against the assigned customer profile.',
          color: Colors.indigo,
        ),
        const SizedBox(height: 20),
        _sectionHeader(isArabic ? 'متى يتم تعطيل الائتمان / البيع على الحساب في الـ POS؟' : 'When is Credit / On Account Disabled in POS?'),
        const SizedBox(height: 12),

        _ruleItem(
          icon: Icons.person_off_outlined,
          title: isArabic ? '1. عميل عابر (لم يتم اختيار عميل)' : '1. Walk-in Customer (No Customer Assigned)',
          description: isArabic
              ? 'البيع الآجل يتطلب سجل عميل مسجل. إذا اختار أمين الصندوق "عميل عابر"، يتم تعطيل خيار الائتمان بشارة "مطلوب عميل مسجل".'
              : 'Credit sales require a registered customer record. If a cashier selects "Walk-in Customer", the Credit option is disabled with badge "Customer required".',
        ),
        _ruleItem(
          icon: Icons.cancel_outlined,
          title: isArabic ? '2. الائتمان غير مسموح (مفتاح الائتمان معطل)' : '2. Credit Not Permitted (Permit Credit is OFF)',
          description: isArabic
              ? 'إذا كان مفتاح "السماح بالائتمان" الخاص بالعميل مغلقاً، يتم شطب خيار الائتمان بشارة "الائتمان غير مسموح".'
              : 'If the customer\'s "Permit Credit" switch is toggled OFF, the Credit option is crossed out and locked with badge "Credit not permitted".',
        ),
        _ruleItem(
          icon: Icons.exposure_zero_outlined,
          title: isArabic ? '3. حد الائتمان يساوي صفر (الحد <= 0.00)' : '3. Credit Limit is Zero (Limit <= 0.00)',
          description: isArabic
              ? 'إذا كان حد الائتمان 0.00 ر.س، لا يمكن إتمام البيع الآجل ويتم عرض "حد الائتمان 0.00".'
              : 'If a customer has a credit limit of SAR 0.00, credit sales cannot be processed and the option displays "Credit limit is 0.00".',
        ),
        _ruleItem(
          icon: Icons.trending_up_outlined,
          title: isArabic ? '4. تجاوز حد الائتمان المسموح' : '4. Credit Limit Exceeded',
          description: isArabic
              ? 'الائتمان المتاح = حد الائتمان - المستحقات الحالية.\nإذا تجاوزت الفاتورة الجديدة + المستحقات حد الائتمان، يمنع الـ POS العملية ويرفض التجاوز.'
              : 'Available Credit = Credit Limit - Current Dues.\nIf Current Dues + New Bill exceeds Credit Limit, POS blocks the transaction.',
        ),
        _ruleItem(
          icon: Icons.call_split_outlined,
          title: isArabic ? '5. حماية الدفع الجزئي والسداد المتعدد' : '5. Partial Payments & Split Tender Protection',
          description: isArabic
              ? 'عند دفع جزء نقداً/شبكة وترك المتبقي، لن يسمح الـ POS بترك المتبقي على الحساب إلا إذا كان لدى العميل رصيد ائتماني متاح.'
              : 'If a customer tenders a partial cash/card payment leaving a remaining balance, POS will NOT allow leaving the balance on account unless approved credit exists.',
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // TAB 5: CSV IMPORT
  // ─────────────────────────────────────────────
  Widget _buildCsvImportTab(bool isArabic) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _tipCard(
          icon: Icons.file_download_outlined,
          title: isArabic ? 'استيراد العملاء بالجملة' : 'Bulk Customer Import',
          content: isArabic
              ? 'يمكنك استيراد مئات العملاء في وقت واحد عبر رفع ملف CSV بتنسيق UTF-8.'
              : 'You can import hundreds of customers simultaneously by uploading a UTF-8 encoded CSV (Comma Separated Values) file.',
          color: Colors.blue,
        ),
        const SizedBox(height: 20),
        _sectionHeader(isArabic ? 'تنسيق رؤوس أعمدة CSV المتوقع' : 'Expected CSV Header Format'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const SelectableText(
            'name,email,phone,country,city,address,type,funds,dues,permit_credit,credit_limit',
            style: TextStyle(color: Colors.lightGreenAccent, fontFamily: 'monospace', fontSize: 13),
          ),
        ),
        const SizedBox(height: 16),
        _sectionHeader(isArabic ? 'صف نموذج عينة CSV' : 'Sample CSV Row'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const SelectableText(
            'Al-Amal Trading,amal@example.com,+966501234567,Saudi Arabia,Riyadh,Olaya St,regular,0.00,0.00,true,5000.00',
            style: TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 13),
          ),
        ),
        const SizedBox(height: 20),
        _bulletPoint(
          isArabic ? 'قيم permit_credit' : 'permit_credit values',
          isArabic ? 'استخدم "true" أو "1" أو "yes" للتفعيل، و "false" أو "0" للتعطيل.' : 'Use "true", "1", or "yes" to enable; "false" or "0" to disable.',
        ),
        _bulletPoint(
          isArabic ? 'قيم credit_limit' : 'credit_limit values',
          isArabic ? 'مبلغ عشري بالريال السعودي (مثال: 1000.00، 5000، 0).' : 'Decimal amount in SAR (e.g. 1000.00, 5000, 0).',
        ),
        _bulletPoint(
          isArabic ? 'الأسماء المكررة' : 'Duplicate Names',
          isArabic ? 'سيتم تحديث أسماء العملاء الموجودين أو التنبيه عليها لمنع تكرار البيانات.' : 'Existing customer names will be updated or flagged to prevent accidental data duplication.',
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // UI HELPER WIDGETS
  // ─────────────────────────────────────────────
  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
      ),
    );
  }

  Widget _tipCard({required IconData icon, required String title, required String content, required MaterialColor color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color.shade700, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color.shade900)),
                const SizedBox(height: 4),
                Text(content, style: TextStyle(fontSize: 13, height: 1.4, color: color.shade900)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bulletPoint(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                children: [
                  TextSpan(text: '$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: desc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldSpec({required String name, required bool required, required String type, required String description}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: required ? Colors.red.shade50 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: required ? Colors.red.shade200 : Colors.grey.shade300),
                ),
                child: Text(
                  required ? 'Required' : 'Optional',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: required ? Colors.red.shade700 : Colors.grey.shade700),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  type,
                  style: TextStyle(fontSize: 11, color: Colors.indigo.shade700, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(description, style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.3)),
        ],
      ),
    );
  }

  Widget _buildStep({required String step, required String title, required String description}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFF1A237E),
            child: Text(step, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(color: Colors.grey.shade800, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ruleItem({required IconData icon, required String title, required String description}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF1A237E), size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1A237E))),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeClassificationCard({
    required String title,
    required String badge,
    required Color color,
    required String desc,
    required List<String> bulletPoints,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  badge,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          ...bulletPoints.map(
            (bp) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_outline, size: 14, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      bp,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade800, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _changeRuleItem({
    required IconData icon,
    required String ruleNumber,
    required String title,
    required String desc,
    required Color accentColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        ruleNumber,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: accentColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.blueGrey.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
