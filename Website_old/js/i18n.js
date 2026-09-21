/* ============================================================
   ZATCA Engine — Bilingual Translation Engine (EN/AR)
   ============================================================ */

const translations = {
  en: {
    // Navbar
    'nav.home': 'Home',
    'nav.features': 'Features',
    'nav.pricing': 'Pricing',
    'nav.demo': 'Demo',
    'nav.about': 'About',
    'nav.contact': 'Contact',
    'nav.blog': 'Blog',
    'nav.getStarted': 'Get Started',
    'nav.langToggle': '🌐 العربية',

    // Hero
    'hero.badge': '🚀 ZATCA Phase 2 Compliant',
    'hero.title': 'The Ultimate ZATCA Phase 2 E-Invoicing & WhatsApp Engine',
    'hero.titleHighlight': 'for Saudi Service Companies',
    'hero.subtitle': 'One JSON API Call → ZATCA Phase 2 Clearance → WhatsApp Invoice Delivery. Built for agencies, loved by developers.',
    'hero.ctaPrimary': 'Start Free Trial',
    'hero.ctaSecondary': 'Explore API Docs',
    'hero.stat1Value': '< 300ms',
    'hero.stat1Label': 'API Latency',
    'hero.stat2Value': '100%',
    'hero.stat2Label': 'Compliance',
    'hero.stat3Value': '99.5%',
    'hero.stat3Label': 'Delivery Rate',
    'hero.stat4Value': '< 15min',
    'hero.stat4Label': 'Setup Time',

    // Trust Badges
    'trust.vision2030': 'Saudi Vision 2030 Aligned',
    'trust.zatca': 'ZATCA FATOORA Phase 2 Ready',
    'trust.aws': 'AWS Riyadh (me-central-1) Hosted',
    'trust.ccrf': 'CCRF Data Residency Compliant',
    'trust.archive': '6-Year Archiving (ZATCA Regulation)',
    'trust.encryption': 'AES-256 Encryption at Rest',

    // How It Works
    'hiw.badge': 'How It Works',
    'hiw.title': 'From API Call to WhatsApp Delivery in Under 300ms',
    'hiw.subtitle': 'Our engine handles the entire ZATCA compliance pipeline automatically.',
    'hiw.step1Label': 'Step 1 — API Call',
    'hiw.step1Title': 'Send JSON Payload',
    'hiw.step1Desc': 'Your ERP or system sends a single POST request to /api/v1/invoices/zatca-whatsapp with invoice data in JSON format. That\'s all you need to do.',
    'hiw.step2Label': 'Step 2 — ZATCA Engine',
    'hiw.step2Title': 'Cryptographic Processing',
    'hiw.step2Desc': 'Our engine automatically generates UBL 2.1 XML, computes SHA-256 hash, chains it with previous invoices, and applies ECDSA secp256k1 digital signature with your CSID.',
    'hiw.step3Label': 'Step 3 — Clearance',
    'hiw.step3Title': 'ZATCA Portal Integration',
    'hiw.step3Desc': 'B2B Standard Invoices get real-time mTLS clearance via FATOORA Portal. B2C Simplified Invoices are queued for async 24h batch reporting. Failed attempts go to DLQ with automatic retry.',
    'hiw.step4Label': 'Step 4 — PDF & QR',
    'hiw.step4Title': 'Document Generation',
    'hiw.step4Desc': 'System generates PDF/A-3 with embedded XML and Base64 TLV QR Code containing Seller Name, VAT Number, Timestamp, Total, VAT Amount, Hash, and ECDSA Signature.',
    'hiw.step5Label': 'Step 5 — Delivery',
    'hiw.step5Title': 'WhatsApp Delivery',
    'hiw.step5Desc': 'Meta WhatsApp Cloud API sends bilingual Arabic/English invoice template with PDF attachment and Click-to-Pay button (Moyasar/PayTabs). Real-time delivery tracking: SENT → DELIVERED → READ.',

    // Features
    'features.badge': 'Capabilities',
    'features.title': 'Everything You Need for ZATCA Compliance & WhatsApp Automation',
    'features.subtitle': 'Five powerful modules. One API call. Complete automation.',
    'feat1.title': 'ZATCA Phase 2 Cryptographic Engine',
    'feat1.desc': 'UBL 2.1 XML, SHA-256 hash chaining, ECDSA signing, mTLS clearance — all abstracted into one API call.',
    'feat2.title': 'WhatsApp Cloud API Middleware',
    'feat2.desc': 'Auto-deliver cleared invoices with bilingual templates, payment links, and real-time delivery tracking.',
    'feat3.title': 'White-Label Agency Portal',
    'feat3.desc': 'Custom domains, branded PDFs, tenant API keys, analytics dashboard — your brand, our engine.',
    'feat4.title': '< 15 Min Developer Onboarding',
    'feat4.desc': 'Sandbox → Production in minutes. Full REST API with comprehensive docs and code examples.',
    'feat5.title': 'Integrated Payment Gateway',
    'feat5.desc': 'Click-to-Pay via Moyasar/PayTabs. Auto-mark paid invoices. WhatsApp payment receipts.',
    'feat6.title': 'CSID Automation',
    'feat6.desc': 'Automated OTP-based Compliance CSID → Production CSID pipeline. Zero manual certificate management.',

    // Features Page Modules
    'featPage.title': 'Five Powerful Modules. One API Call.',
    'featPage.subtitle': 'Complete ZATCA + WhatsApp Automation',
    'moduleA.tag': 'Module A',
    'moduleA.title': 'ZATCA Phase 2 Cryptographic Engine',
    'moduleA.feat1Title': 'UBL 2.1 XML Builder',
    'moduleA.feat1Desc': 'Automatically transforms JSON payload into ZATCA-compliant UBL 2.1 XML format.',
    'moduleA.feat2Title': 'SHA-256 Hash & Chain Engine',
    'moduleA.feat2Desc': 'Computes cryptographic hash of canonicalized XML and chains with previous invoice hash.',
    'moduleA.feat3Title': 'ECDSA secp256k1 Digital Signature',
    'moduleA.feat3Desc': 'Signs invoices using vendor\'s private key and attaches production CSID stamp.',
    'moduleA.feat4Title': 'Base64 TLV QR Code Engine',
    'moduleA.feat4Desc': 'Encodes Seller Name, VAT, Timestamp, Amount, Hash, and Signature into compliant QR.',
    'moduleA.feat5Title': 'Dual Routing (B2B/B2C)',
    'moduleA.feat5Desc': 'B2B: Real-time mTLS clearance. B2C: Async 24h batch reporting. Automatic routing.',
    'moduleA.feat6Title': 'Dead Letter Queue & Retry',
    'moduleA.feat6Desc': 'Failed clearances go to DLQ with exponential backoff retry. Zero lost invoices.',

    'moduleB.tag': 'Module B',
    'moduleB.title': 'Meta WhatsApp Cloud API Engine',
    'moduleB.feat1Title': 'Bilingual Interactive Templates',
    'moduleB.feat1Desc': 'Pre-approved Arabic/English ZATCA message templates managed automatically.',
    'moduleB.feat2Title': 'Dynamic Payload Injection',
    'moduleB.feat2Desc': 'Injects QR preview, invoice totals, business name, and PDF URL into template parameters.',
    'moduleB.feat3Title': 'Click-to-Pay Buttons',
    'moduleB.feat3Desc': 'Embedded payment URLs for Moyasar/PayTabs with auto-mark invoices as PAID.',
    'moduleB.feat4Title': 'Real-time Delivery Webhooks',
    'moduleB.feat4Desc': 'Track SENT → DELIVERED → READ → FAILED status in real-time via Meta webhooks.',

    'moduleC.tag': 'Module C',
    'moduleC.title': 'White-Label Agency Management Portal',
    'moduleC.feat1Title': 'Custom Domain Mapping',
    'moduleC.feat1Desc': 'Route API calls through your subdomain: zatca-api.youragency.sa',
    'moduleC.feat2Title': 'Branded Templates & PDFs',
    'moduleC.feat2Desc': 'Customize WhatsApp headers, footers, and PDF themes with your branding.',
    'moduleC.feat3Title': 'Tenant API Key Management',
    'moduleC.feat3Desc': 'Create, revoke, and rate-limit client API keys from your dashboard.',
    'moduleC.feat4Title': 'Analytics Dashboard',
    'moduleC.feat4Desc': 'Monitor API usage, clearance rates, delivery stats, and billing per sub-tenant.',

    'moduleD.tag': 'Module D',
    'moduleD.title': 'CSID Onboarding Automation',
    'moduleD.feat1Title': 'OTP-Based Compliance CSID',
    'moduleD.feat1Desc': 'Automated endpoint triggers OTP-based Compliance CSID acquisition.',
    'moduleD.feat2Title': 'Auto Compliance Checks',
    'moduleD.feat2Desc': 'Sends test standard/simplified invoices to validate compliance automatically.',
    'moduleD.feat3Title': 'Production CSID Vaulting',
    'moduleD.feat3Desc': 'Fetches and encrypts Production CSID keys with AES-256 in secure vault.',

    'moduleE.tag': 'Module E',
    'moduleE.title': 'Billing & Monetization',
    'moduleE.feat1Title': 'Stripe/Paddle Integration',
    'moduleE.feat1Desc': 'Tier-based monthly SaaS subscriptions with automated billing.',
    'moduleE.feat2Title': 'Pay-per-Invoice Usage',
    'moduleE.feat2Desc': 'Metered billing based on actual API call and invoice volume.',
    'moduleE.feat3Title': 'Prepaid Credits Wallet',
    'moduleE.feat3Desc': 'Purchase wallet credits to fund WhatsApp conversations and API charges.',

    // Security Section
    'security.title': 'Enterprise-Grade Security & Compliance',
    'security1': 'AWS Riyadh (me-central-1) data residency',
    'security2': 'AES-256 encryption at rest for private keys',
    'security3': 'CCRF (Cloud Computing Regulatory Framework) compliant',
    'security4': '6-year ZATCA data archiving (S3 Standard-IA/Glacier)',
    'security5': '99.95% uptime SLA (multi-AZ deployment)',
    'security6': 'Zero non-compliance failures target',

    // Pricing
    'pricing.badge': 'Pricing',
    'pricing.title': 'Transparent Pricing for Every Scale',
    'pricing.subtitle': 'From startups to enterprise agencies. No hidden fees.',
    'pricing.monthly': 'Monthly',
    'pricing.yearly': 'Yearly',
    'pricing.save': 'Save 20%',
    'pricing.tier1.tag': 'Service Business',
    'pricing.tier1.name': 'Business',
    'pricing.tier1.desc': 'For Maintenance, IT, Consulting, Logistics, Restaurants, Clinics, HVAC, and Retailers.',
    'pricing.tier1.price.monthly': '299',
    'pricing.tier1.price.yearly': '239',
    'pricing.tier1.currency': 'SAR',
    'pricing.tier1.period.monthly': '/month',
    'pricing.tier1.period.yearly': '/month, billed yearly',
    'pricing.tier1.feat1': 'ZATCA Phase 1 & 2 Ready (XML + QR)',
    'pricing.tier1.feat2': 'WhatsApp auto-send invoices & reminders',
    'pricing.tier1.feat3': 'Unlimited client profiles',
    'pricing.tier1.feat4': 'Click-to-Pay payment links',
    'pricing.tier1.feat5': 'Guided CSID onboarding',
    'pricing.tier1.feat6': 'Email + WhatsApp support',
    'pricing.tier1.feat7': '99.9% uptime SLA',
    'pricing.tier1.cta': 'Start Free Trial',

    'pricing.tier2.tag': 'Agency / Reseller',
    'pricing.tier2.name': 'Agency',
    'pricing.tier2.desc': 'For Accounting Firms, IT Agencies, Software Vendors, POS Vendors, and ERP Providers.',
    'pricing.tier2.price.monthly': '999',
    'pricing.tier2.price.yearly': '799',
    'pricing.tier2.feat1': 'Multi-tenant ZATCA API distribution',
    'pricing.tier2.feat2': 'Custom sender ID + bulk API keys',
    'pricing.tier2.feat3': 'White-label Dashboard (custom domains)',
    'pricing.tier2.feat4': 'Branded WhatsApp templates & PDFs',
    'pricing.tier2.feat5': 'Automated CSID pipeline per tenant',
    'pricing.tier2.feat6': 'Pay-per-tenant + Prepaid Credits',
    'pricing.tier2.feat7': 'Dedicated account manager',
    'pricing.tier2.feat8': '99.95% uptime SLA (multi-AZ)',
    'pricing.tier2.cta': 'Contact Sales',
    'pricing.tier2.badge': 'Most Popular',

    'pricing.enterprise': 'Need a custom plan for your enterprise?',
    'pricing.enterpriseCta': 'Contact Our Team',

    // FAQ
    'faq.title': 'Frequently Asked Questions',
    'faq1.q': 'What is ZATCA Phase 2 and why do I need it?',
    'faq1.a': 'ZATCA Phase 2 (Integration Phase) requires all Saudi businesses to integrate their invoicing systems with the ZATCA Fatoora Portal. This means e-invoices must be cryptographically signed, hashed, and cleared/reported through ZATCA\'s API. Non-compliance can result in penalties of SAR 10,000+ per violation. Our engine handles all of this automatically with a single API call.',
    'faq2.q': 'How long does integration take?',
    'faq2.a': 'With our sandbox credentials, developers can integrate and test within 15 minutes. The full production deployment, including CSID onboarding, can be completed within 24-48 hours. We provide code examples in Node.js, Python, PHP, and cURL.',
    'faq3.q': 'Can I switch between tiers?',
    'faq3.a': 'Yes, you can upgrade or downgrade your plan at any time. Upgrades take effect immediately, while downgrades apply at the start of your next billing cycle. All your data and configurations are preserved.',
    'faq4.q': 'How does the prepaid credits system work?',
    'faq4.a': 'Agency tier users can purchase wallet credits to fund WhatsApp conversation charges and API calls. Credits are deducted per-use: each WhatsApp message delivery and each ZATCA API call consumes credits. You can set up auto-recharge to never run out.',
    'faq5.q': 'What payment gateways are supported?',
    'faq5.a': 'We currently integrate with Moyasar and PayTabs for Click-to-Pay buttons in WhatsApp invoice messages. Customers can pay via Mada, Visa, Mastercard, Apple Pay, and STC Pay. Payment webhook automatically marks invoices as PAID.',
    'faq6.q': 'Is my data stored in Saudi Arabia?',
    'faq6.a': 'Yes. All data is hosted exclusively on AWS Riyadh (me-central-1) to comply with Saudi Arabia\'s Cloud Computing Regulatory Framework (CCRF) and data residency requirements. Private keys are encrypted with AES-256 at rest.',

    // Demo
    'demo.badge': 'Try It Live',
    'demo.title': 'Go from Sandbox to Production in Under 15 Minutes',
    'demo.subtitle': 'Get test credentials and explore our full ZATCA + WhatsApp pipeline.',
    'demo.formTitle': 'Request Sandbox Access',
    'demo.formName': 'Full Name',
    'demo.formEmail': 'Business Email',
    'demo.formCompany': 'Company Name',
    'demo.formRole': 'Your Role',
    'demo.formRoleOpt1': 'Select your role',
    'demo.formRoleOpt2': 'Agency / Reseller',
    'demo.formRoleOpt3': 'Developer / Integrator',
    'demo.formRoleOpt4': 'Business Owner',
    'demo.formCta': 'Get Test Credentials',
    'demo.formNote': 'No credit card required. Full API access for 14 days.',
    'demo.step1Title': 'JSON API Payload',
    'demo.step1Desc': 'Send a single POST request with your invoice data in JSON format. Our API handles everything else.',
    'demo.step2Title': 'ZATCA Processing',
    'demo.step2Desc': 'The engine generates UBL 2.1 XML, computes SHA-256 hash, and applies ECDSA digital signature in under 300ms.',
    'demo.step3Title': 'Clearance & Response',
    'demo.step3Desc': 'B2B invoices get real-time mTLS clearance from ZATCA. B2C invoices are queued for batch reporting.',
    'demo.step4Title': 'PDF & QR Generation',
    'demo.step4Desc': 'PDF/A-3 with embedded XML and Phase 2 compliant Base64 TLV QR code is automatically generated.',
    'demo.step5Title': 'WhatsApp Delivery',
    'demo.step5Desc': 'Bilingual invoice message with PDF attachment and Click-to-Pay button delivered to customer\'s WhatsApp.',
    'demo.sandboxTitle': 'What\'s Included in Sandbox',
    'demo.sandbox1': 'Full ZATCA test portal integration (mock invoices)',
    'demo.sandbox2': 'API speed testing (see <300ms latency live)',
    'demo.sandbox3': 'WhatsApp template preview (sandbox number)',
    'demo.sandbox4': 'Sample B2B and B2C invoice flows',
    'demo.sandbox5': 'Code examples in Node.js, Python, PHP, cURL',

    // About
    'about.badge': 'About Us',
    'about.title': 'Powering Saudi Arabia\'s Digital Invoice Revolution',
    'about.subtitle': 'We believe every Saudi business deserves enterprise-grade ZATCA compliance — accessible through a single API call.',
    'about.missionTitle': 'Our Mission',
    'about.missionDesc': 'To eliminate the complexity of ZATCA Phase 2 compliance and WhatsApp business automation, enabling every Saudi company to focus on growth while we handle the technical infrastructure.',
    'about.whyTitle': 'Why Choose Us',
    'about.why1Title': 'Saudi-First Architecture',
    'about.why1Desc': 'AWS Riyadh me-central-1 hosting with CCRF compliance',
    'about.why2Title': 'ZATCA Fatoora Certified',
    'about.why2Desc': '100% pass rate on all ZATCA validation checks',
    'about.why3Title': 'Developer-Obsessed',
    'about.why3Desc': '<15 minute onboarding from sandbox to production',
    'about.why4Title': 'Agency-Ready',
    'about.why4Desc': 'White-label multi-tenant from day one',
    'about.why5Title': 'WhatsApp-Native',
    'about.why5Desc': 'Saudi Arabia\'s #1 business communication channel',
    'about.why6Title': 'Enterprise Security',
    'about.why6Desc': 'AES-256 encryption, 6-year ZATCA archiving',
    'about.techTitle': 'Our Technology Stack',
    'about.roadmapTitle': 'Product Roadmap',
    'about.phase1': 'ZATCA Core Engine & Crypto',
    'about.phase1Status': 'Complete',
    'about.phase2': 'WhatsApp Integration & Payment Gateway',
    'about.phase2Status': 'Complete',
    'about.phase3': 'White-Label Dashboard & Agency Multi-Tenancy',
    'about.phase3Status': 'Q1 2027',

    // Contact
    'contact.badge': 'Get In Touch',
    'contact.title': 'Let\'s Build Something Together',
    'contact.subtitle': 'Whether you\'re an agency, developer, or business owner — we\'re here to help.',
    'contact.formTitle': 'Send Us a Message',
    'contact.formName': 'Full Name',
    'contact.formEmail': 'Business Email',
    'contact.formCompany': 'Company Name',
    'contact.formType': 'Inquiry Type',
    'contact.formTypeOpt1': 'Select inquiry type',
    'contact.formTypeOpt2': 'Sales',
    'contact.formTypeOpt3': 'Technical Support',
    'contact.formTypeOpt4': 'Partnership',
    'contact.formTypeOpt5': 'Custom Enterprise',
    'contact.formPackage': 'Package Interest',
    'contact.formPackageOpt1': 'Select package',
    'contact.formPackageOpt2': 'Service Business',
    'contact.formPackageOpt3': 'Agency / Reseller',
    'contact.formPackageOpt4': 'Enterprise',
    'contact.formMessage': 'Your Message',
    'contact.formCta': 'Send Message',
    'contact.whatsappTitle': 'Chat on WhatsApp',
    'contact.whatsappDesc': 'Get an instant response from our sales team',
    'contact.whatsappCta': 'Start WhatsApp Chat',
    'contact.officeTitle': 'Our Office',
    'contact.officeAddress': 'King Fahd Road, Riyadh, Saudi Arabia',
    'contact.hoursTitle': 'Business Hours',
    'contact.hoursDetail': 'Sun – Thu: 9:00 AM – 6:00 PM (AST)',
    'contact.emailTitle': 'Email Us',
    'contact.emailAddress': 'info@zatcaengine.sa',

    // Blog
    'blog.badge': 'Resources',
    'blog.title': 'Insights & Guides',
    'blog.subtitle': 'Stay updated with the latest in ZATCA compliance, WhatsApp automation, and Saudi fintech.',
    'blog.featured': 'Featured',
    'blog.readMore': 'Read More →',
    'blog.newsletter': 'Stay Updated',
    'blog.newsletterDesc': 'Get weekly ZATCA compliance updates and Saudi fintech insights delivered to your inbox.',
    'blog.newsletterPlaceholder': 'Enter your email',
    'blog.newsletterCta': 'Subscribe',

    // Personas
    'personas.title': 'Built for Every Role in the Saudi Business Ecosystem',
    'persona1.title': 'For Agencies & Resellers',
    'persona1.feat1': 'White-label the engine under your brand',
    'persona1.feat2': 'Manage unlimited sub-tenants',
    'persona1.feat3': 'Revenue share per invoice',
    'persona2.title': 'For Developers & Integrators',
    'persona2.feat1': 'Single JSON endpoint, <15min setup',
    'persona2.feat2': 'Full REST API docs + code examples',
    'persona2.feat3': 'Sandbox → Production CSID automation',
    'persona3.title': 'For Service Businesses',
    'persona3.feat1': '1-click invoice, WhatsApp delivery',
    'persona3.feat2': 'No technical knowledge needed',
    'persona3.feat3': 'Mada/STC Pay payment links',

    // Testimonials
    'testimonials.title': 'Trusted by Saudi Businesses',

    // CTA Banner
    'cta.title': 'Ready to Automate Your ZATCA Compliance?',
    'cta.subtitle': 'Join hundreds of Saudi businesses already using our ZATCA + WhatsApp engine.',
    'cta.primary': 'Start Free Trial',
    'cta.secondary': 'Talk to Sales',

    // Footer
    'footer.desc': 'The ultimate ZATCA Phase 2 E-Invoicing & WhatsApp Engine built for Saudi Arabia\'s digital future.',
    'footer.product': 'Product',
    'footer.company': 'Company',
    'footer.resources': 'Resources',
    'footer.copyright': '© 2026 ZATCA Engine. Built for Saudi Arabia\'s Digital Future.',
    'footer.privacy': 'Privacy Policy',
    'footer.terms': 'Terms of Service',

    // ROI Calculator
    'roi.badge': 'ROI Calculator',
    'roi.title': 'Calculate Your Savings',
    'roi.subtitle': 'See how much time and money you can save with automated ZATCA compliance.',
    'roi.invoicesLabel': 'Monthly Invoices',
    'roi.hoursLabel': 'Hours per Manual Invoice',
    'roi.valueLabel': 'Avg Invoice Value (SAR)',
    'roi.resultHours': 'Hours Saved / Month',
    'roi.resultPenalty': 'ZATCA Penalties Avoided / Year',
    'roi.resultCost': 'Annual Cost Reduction',
    'roi.resultSpeed': 'Processing Time',
    'roi.cta': 'Start Saving Now',
  },

  ar: {
    // Navbar
    'nav.home': 'الرئيسية',
    'nav.features': 'المزايا',
    'nav.pricing': 'الأسعار',
    'nav.demo': 'تجربة',
    'nav.about': 'من نحن',
    'nav.contact': 'اتصل بنا',
    'nav.blog': 'المدونة',
    'nav.getStarted': 'ابدأ الآن',
    'nav.langToggle': '🌐 English',

    // Hero
    'hero.badge': '🚀 متوافق مع المرحلة الثانية لـ ZATCA',
    'hero.title': 'محرك الفوترة الإلكترونية ZATCA المرحلة الثانية و WhatsApp',
    'hero.titleHighlight': 'للشركات السعودية',
    'hero.subtitle': 'طلب API واحد بصيغة JSON ← تصديق ZATCA المرحلة الثانية ← تسليم الفاتورة عبر WhatsApp. مصمم للوكالات، محبوب من المطورين.',
    'hero.ctaPrimary': 'ابدأ التجربة المجانية',
    'hero.ctaSecondary': 'استكشف وثائق API',
    'hero.stat1Value': '< 300ms',
    'hero.stat1Label': 'زمن الاستجابة',
    'hero.stat2Value': '100%',
    'hero.stat2Label': 'الامتثال',
    'hero.stat3Value': '99.5%',
    'hero.stat3Label': 'معدل التسليم',
    'hero.stat4Value': '< 15 دقيقة',
    'hero.stat4Label': 'وقت الإعداد',

    // Trust Badges
    'trust.vision2030': 'متوافق مع رؤية السعودية 2030',
    'trust.zatca': 'جاهز لمنصة فاتورة ZATCA المرحلة الثانية',
    'trust.aws': 'مستضاف على AWS الرياض (me-central-1)',
    'trust.ccrf': 'متوافق مع إطار الحوسبة السحابية CCRF',
    'trust.archive': 'أرشفة 6 سنوات (نظام ZATCA)',
    'trust.encryption': 'تشفير AES-256 في حالة السكون',

    // How It Works
    'hiw.badge': 'كيف يعمل',
    'hiw.title': 'من طلب API إلى تسليم WhatsApp في أقل من 300 مللي ثانية',
    'hiw.subtitle': 'محركنا يتعامل مع خط أنابيب الامتثال الكامل لـ ZATCA تلقائيًا.',
    'hiw.step1Label': 'الخطوة 1 — طلب API',
    'hiw.step1Title': 'إرسال بيانات JSON',
    'hiw.step1Desc': 'يرسل نظام ERP الخاص بك طلب POST واحد إلى /api/v1/invoices/zatca-whatsapp مع بيانات الفاتورة بصيغة JSON. هذا كل ما تحتاج إليه.',
    'hiw.step2Label': 'الخطوة 2 — محرك ZATCA',
    'hiw.step2Title': 'المعالجة التشفيرية',
    'hiw.step2Desc': 'يقوم محركنا تلقائيًا بإنشاء XML بمعيار UBL 2.1، وحساب تجزئة SHA-256، وربطها بالفواتير السابقة، وتطبيق التوقيع الرقمي ECDSA secp256k1 مع CSID الخاص بك.',
    'hiw.step3Label': 'الخطوة 3 — التصديق',
    'hiw.step3Title': 'التكامل مع بوابة ZATCA',
    'hiw.step3Desc': 'فواتير B2B تحصل على تصديق فوري عبر mTLS من بوابة فاتورة. فواتير B2C يتم وضعها في قائمة الانتظار للتقرير الدفعي خلال 24 ساعة.',
    'hiw.step4Label': 'الخطوة 4 — PDF و QR',
    'hiw.step4Title': 'إنشاء المستندات',
    'hiw.step4Desc': 'يُنشئ النظام PDF/A-3 مع XML مضمن ورمز QR بصيغة Base64 TLV يحتوي على اسم البائع، رقم الضريبة، الطابع الزمني، المبلغ، التجزئة، والتوقيع.',
    'hiw.step5Label': 'الخطوة 5 — التسليم',
    'hiw.step5Title': 'التسليم عبر WhatsApp',
    'hiw.step5Desc': 'يرسل WhatsApp Cloud API قالب فاتورة ثنائي اللغة (عربي/إنجليزي) مع مرفق PDF وزر الدفع. تتبع التسليم الفوري: مُرسل ← مُسلّم ← مقروء.',

    // Features
    'features.badge': 'المزايا',
    'features.title': 'كل ما تحتاجه للامتثال لـ ZATCA وأتمتة WhatsApp',
    'features.subtitle': 'خمس وحدات قوية. طلب API واحد. أتمتة كاملة.',
    'feat1.title': 'محرك ZATCA التشفيري المرحلة الثانية',
    'feat1.desc': 'UBL 2.1 XML، تسلسل تجزئة SHA-256، توقيع ECDSA، تصديق mTLS — كل ذلك مُجرد في طلب API واحد.',
    'feat2.title': 'وسيط WhatsApp Cloud API',
    'feat2.desc': 'تسليم تلقائي للفواتير المعتمدة مع قوالب ثنائية اللغة وروابط الدفع وتتبع التسليم الفوري.',
    'feat3.title': 'بوابة وكالات العلامة البيضاء',
    'feat3.desc': 'نطاقات مخصصة، ملفات PDF بعلامتك التجارية، مفاتيح API للمستأجرين، لوحة تحليلات — علامتك التجارية، محركنا.',
    'feat4.title': 'إعداد المطور في أقل من 15 دقيقة',
    'feat4.desc': 'من بيئة الاختبار إلى الإنتاج في دقائق. REST API كامل مع وثائق شاملة وأمثلة برمجية.',
    'feat5.title': 'بوابة دفع متكاملة',
    'feat5.desc': 'الدفع بنقرة واحدة عبر Moyasar/PayTabs. تعليم الفواتير المدفوعة تلقائيًا. إيصالات الدفع عبر WhatsApp.',
    'feat6.title': 'أتمتة CSID',
    'feat6.desc': 'خط أنابيب آلي من CSID الامتثال إلى CSID الإنتاج. صفر إدارة يدوية للشهادات.',

    // Pricing
    'pricing.badge': 'الأسعار',
    'pricing.title': 'أسعار شفافة لكل مستوى',
    'pricing.subtitle': 'من الشركات الناشئة إلى الوكالات الكبرى. بدون رسوم مخفية.',
    'pricing.monthly': 'شهري',
    'pricing.yearly': 'سنوي',
    'pricing.save': 'وفّر 20%',
    'pricing.tier1.tag': 'الشركات الخدمية',
    'pricing.tier1.name': 'الأعمال',
    'pricing.tier1.desc': 'للصيانة، تقنية المعلومات، الاستشارات، اللوجستيات، المطاعم، العيادات، التكييف، والتجزئة.',
    'pricing.tier1.feat1': 'ZATCA المرحلة 1 و 2 جاهز (XML + QR)',
    'pricing.tier1.feat2': 'إرسال تلقائي للفواتير والتذكيرات عبر WhatsApp',
    'pricing.tier1.feat3': 'ملفات عملاء غير محدودة',
    'pricing.tier1.feat4': 'روابط الدفع بنقرة واحدة',
    'pricing.tier1.feat5': 'إعداد CSID موجّه',
    'pricing.tier1.feat6': 'دعم عبر البريد وWhatsApp',
    'pricing.tier1.feat7': 'اتفاقية مستوى خدمة 99.9%',
    'pricing.tier1.cta': 'ابدأ التجربة المجانية',
    'pricing.tier1.currency': 'ريال',
    'pricing.tier1.period.monthly': '/شهر',
    'pricing.tier1.period.yearly': '/شهر، يُدفع سنويًا',

    'pricing.tier2.tag': 'الوكالات / الموزعين',
    'pricing.tier2.name': 'الوكالة',
    'pricing.tier2.desc': 'لمكاتب المحاسبة، وكالات تقنية المعلومات، موردي البرمجيات، موردي نقاط البيع، ومزودي ERP.',
    'pricing.tier2.feat1': 'توزيع API ZATCA متعدد المستأجرين',
    'pricing.tier2.feat2': 'معرّف مرسل مخصص + مفاتيح API جماعية',
    'pricing.tier2.feat3': 'لوحة تحكم بعلامة بيضاء (نطاقات مخصصة)',
    'pricing.tier2.feat4': 'قوالب WhatsApp و PDF بعلامتك التجارية',
    'pricing.tier2.feat5': 'خط أنابيب CSID آلي لكل مستأجر',
    'pricing.tier2.feat6': 'الدفع لكل مستأجر + رصيد مسبق',
    'pricing.tier2.feat7': 'مدير حساب مخصص',
    'pricing.tier2.feat8': 'اتفاقية مستوى خدمة 99.95% (متعدد المناطق)',
    'pricing.tier2.cta': 'تواصل مع المبيعات',
    'pricing.tier2.badge': 'الأكثر شعبية',

    'pricing.enterprise': 'تحتاج خطة مخصصة لمؤسستك؟',
    'pricing.enterpriseCta': 'تواصل مع فريقنا',

    // FAQ
    'faq.title': 'الأسئلة الشائعة',
    'faq1.q': 'ما هي المرحلة الثانية من ZATCA ولماذا أحتاجها؟',
    'faq1.a': 'تتطلب المرحلة الثانية من ZATCA (مرحلة التكامل) من جميع الشركات السعودية دمج أنظمة الفوترة الخاصة بها مع بوابة فاتورة ZATCA. يجب توقيع الفواتير الإلكترونية رقميًا وتجزئتها وتصديقها/الإبلاغ عنها عبر API الخاص بـ ZATCA. عدم الامتثال قد يؤدي إلى غرامات تبدأ من 10,000 ريال سعودي لكل مخالفة. محركنا يتعامل مع كل هذا تلقائيًا بطلب API واحد.',
    'faq2.q': 'كم يستغرق التكامل؟',
    'faq2.a': 'مع بيانات اعتماد بيئة الاختبار، يمكن للمطورين التكامل والاختبار خلال 15 دقيقة. يمكن إكمال النشر الكامل للإنتاج، بما في ذلك إعداد CSID، خلال 24-48 ساعة. نوفر أمثلة برمجية بلغات Node.js و Python و PHP و cURL.',
    'faq3.q': 'هل يمكنني التبديل بين المستويات؟',
    'faq3.a': 'نعم، يمكنك الترقية أو التخفيض في أي وقت. الترقيات تسري فورًا، بينما التخفيضات تطبق في بداية دورة الفوترة التالية. جميع بياناتك وإعداداتك محفوظة.',
    'faq4.q': 'كيف يعمل نظام الرصيد المسبق؟',
    'faq4.a': 'يمكن لمستخدمي مستوى الوكالة شراء رصيد محفظة لتمويل رسوم محادثات WhatsApp ومكالمات API. يتم خصم الرصيد لكل استخدام: كل رسالة WhatsApp وكل طلب API ZATCA يستهلك رصيدًا. يمكنك إعداد الشحن التلقائي.',
    'faq5.q': 'ما بوابات الدفع المدعومة؟',
    'faq5.a': 'نتكامل حاليًا مع Moyasar و PayTabs لأزرار الدفع بنقرة واحدة في رسائل فواتير WhatsApp. يمكن للعملاء الدفع عبر مدى، فيزا، ماستركارد، Apple Pay، و STC Pay. webhook الدفع يعلّم الفواتير كمدفوعة تلقائيًا.',
    'faq6.q': 'هل بياناتي مخزنة في السعودية؟',
    'faq6.a': 'نعم. جميع البيانات مستضافة حصريًا على AWS الرياض (me-central-1) للامتثال لإطار الحوسبة السحابية السعودي (CCRF) ومتطلبات إقامة البيانات. المفاتيح الخاصة مشفرة بـ AES-256 في حالة السكون.',

    // Demo
    'demo.badge': 'جربها الآن',
    'demo.title': 'من بيئة الاختبار إلى الإنتاج في أقل من 15 دقيقة',
    'demo.subtitle': 'احصل على بيانات اعتماد اختبارية واستكشف خط أنابيب ZATCA + WhatsApp الكامل.',
    'demo.formTitle': 'طلب وصول بيئة الاختبار',
    'demo.formName': 'الاسم الكامل',
    'demo.formEmail': 'البريد الإلكتروني للأعمال',
    'demo.formCompany': 'اسم الشركة',
    'demo.formRole': 'دورك',
    'demo.formRoleOpt1': 'اختر دورك',
    'demo.formRoleOpt2': 'وكالة / موزع',
    'demo.formRoleOpt3': 'مطور / مُدمج',
    'demo.formRoleOpt4': 'صاحب عمل',
    'demo.formCta': 'احصل على بيانات الاختبار',
    'demo.formNote': 'لا حاجة لبطاقة ائتمان. وصول كامل لـ API لمدة 14 يومًا.',

    // About
    'about.badge': 'من نحن',
    'about.title': 'نقود ثورة الفوترة الرقمية في السعودية',
    'about.subtitle': 'نؤمن بأن كل شركة سعودية تستحق امتثال ZATCA بمستوى المؤسسات — يمكن الوصول إليه عبر طلب API واحد.',
    'about.missionTitle': 'مهمتنا',
    'about.missionDesc': 'القضاء على تعقيد الامتثال للمرحلة الثانية من ZATCA وأتمتة أعمال WhatsApp، مما يمكّن كل شركة سعودية من التركيز على النمو بينما نتولى البنية التحتية التقنية.',
    'about.whyTitle': 'لماذا تختارنا',
    'about.why1Title': 'بنية سعودية أولاً',
    'about.why1Desc': 'استضافة AWS الرياض me-central-1 مع امتثال CCRF',
    'about.why2Title': 'معتمد من ZATCA فاتورة',
    'about.why2Desc': 'معدل نجاح 100% في جميع فحوصات التحقق من ZATCA',
    'about.why3Title': 'مُهتم بالمطورين',
    'about.why3Desc': 'إعداد أقل من 15 دقيقة من الاختبار إلى الإنتاج',
    'about.why4Title': 'جاهز للوكالات',
    'about.why4Desc': 'علامة بيضاء متعددة المستأجرين من اليوم الأول',
    'about.why5Title': 'أصلي لـ WhatsApp',
    'about.why5Desc': 'قناة الاتصال التجاري الأولى في السعودية',
    'about.why6Title': 'أمان مؤسسي',
    'about.why6Desc': 'تشفير AES-256، أرشفة ZATCA لمدة 6 سنوات',
    'about.techTitle': 'مجموعتنا التقنية',
    'about.roadmapTitle': 'خارطة طريق المنتج',

    // Contact
    'contact.badge': 'تواصل معنا',
    'contact.title': 'لنبني شيئًا معًا',
    'contact.subtitle': 'سواء كنت وكالة، مطورًا، أو صاحب عمل — نحن هنا للمساعدة.',
    'contact.formTitle': 'أرسل لنا رسالة',
    'contact.formName': 'الاسم الكامل',
    'contact.formEmail': 'البريد الإلكتروني للأعمال',
    'contact.formCompany': 'اسم الشركة',
    'contact.formMessage': 'رسالتك',
    'contact.formCta': 'إرسال الرسالة',
    'contact.whatsappTitle': 'تحدث عبر WhatsApp',
    'contact.whatsappDesc': 'احصل على رد فوري من فريق المبيعات',
    'contact.whatsappCta': 'ابدأ محادثة WhatsApp',
    'contact.officeTitle': 'مكتبنا',
    'contact.officeAddress': 'طريق الملك فهد، الرياض، المملكة العربية السعودية',
    'contact.hoursTitle': 'ساعات العمل',
    'contact.hoursDetail': 'الأحد – الخميس: 9:00 صباحًا – 6:00 مساءً (توقيت السعودية)',

    // Blog
    'blog.badge': 'المصادر',
    'blog.title': 'رؤى وأدلة',
    'blog.subtitle': 'ابقَ على اطلاع بأحدث مستجدات الامتثال لـ ZATCA وأتمتة WhatsApp والتكنولوجيا المالية السعودية.',
    'blog.featured': 'مميز',
    'blog.readMore': 'اقرأ المزيد ←',
    'blog.newsletter': 'ابقَ على اطلاع',
    'blog.newsletterDesc': 'احصل على تحديثات أسبوعية حول الامتثال لـ ZATCA ورؤى التكنولوجيا المالية السعودية.',
    'blog.newsletterPlaceholder': 'أدخل بريدك الإلكتروني',
    'blog.newsletterCta': 'اشترك',

    // Personas
    'personas.title': 'مصمم لكل دور في منظومة الأعمال السعودية',
    'persona1.title': 'للوكالات والموزعين',
    'persona1.feat1': 'استخدم المحرك بعلامتك التجارية',
    'persona1.feat2': 'إدارة مستأجرين فرعيين غير محدودين',
    'persona1.feat3': 'مشاركة الإيرادات لكل فاتورة',
    'persona2.title': 'للمطورين والمدمجين',
    'persona2.feat1': 'نقطة نهاية JSON واحدة، إعداد <15 دقيقة',
    'persona2.feat2': 'وثائق REST API كاملة + أمثلة برمجية',
    'persona2.feat3': 'أتمتة CSID من الاختبار إلى الإنتاج',
    'persona3.title': 'للشركات الخدمية',
    'persona3.feat1': 'فاتورة بنقرة واحدة، تسليم WhatsApp',
    'persona3.feat2': 'لا حاجة لمعرفة تقنية',
    'persona3.feat3': 'روابط دفع مدى/STC Pay',

    // Testimonials
    'testimonials.title': 'موثوق من الشركات السعودية',

    // CTA Banner
    'cta.title': 'مستعد لأتمتة امتثالك لـ ZATCA؟',
    'cta.subtitle': 'انضم إلى مئات الشركات السعودية التي تستخدم بالفعل محرك ZATCA + WhatsApp.',
    'cta.primary': 'ابدأ التجربة المجانية',
    'cta.secondary': 'تحدث مع المبيعات',

    // Footer
    'footer.desc': 'محرك الفوترة الإلكترونية ZATCA المرحلة الثانية و WhatsApp المبني لمستقبل السعودية الرقمي.',
    'footer.product': 'المنتج',
    'footer.company': 'الشركة',
    'footer.resources': 'المصادر',
    'footer.copyright': '© 2026 محرك ZATCA. مبني لمستقبل السعودية الرقمي.',
    'footer.privacy': 'سياسة الخصوصية',
    'footer.terms': 'شروط الخدمة',

    // ROI Calculator
    'roi.badge': 'حاسبة العائد',
    'roi.title': 'احسب مدخراتك',
    'roi.subtitle': 'اكتشف مقدار الوقت والمال الذي يمكنك توفيره مع أتمتة الامتثال لـ ZATCA.',
    'roi.invoicesLabel': 'الفواتير الشهرية',
    'roi.hoursLabel': 'ساعات لكل فاتورة يدوية',
    'roi.valueLabel': 'متوسط قيمة الفاتورة (ريال)',
    'roi.resultHours': 'ساعات موفرة / شهر',
    'roi.resultPenalty': 'غرامات ZATCA المتجنبة / سنة',
    'roi.resultCost': 'تخفيض التكلفة السنوية',
    'roi.resultSpeed': 'وقت المعالجة',
    'roi.cta': 'ابدأ التوفير الآن',
  }
};

// ---- i18n Engine ----
class I18nEngine {
  constructor() {
    this.currentLang = localStorage.getItem('zatca-lang') || 'en';
    this.init();
  }

  init() {
    this.applyLanguage(this.currentLang);
    this.bindToggle();
  }

  bindToggle() {
    document.querySelectorAll('[data-action="toggle-lang"]').forEach(btn => {
      btn.addEventListener('click', () => {
        const newLang = this.currentLang === 'en' ? 'ar' : 'en';
        this.applyLanguage(newLang);
      });
    });
  }

  applyLanguage(lang) {
    this.currentLang = lang;
    localStorage.setItem('zatca-lang', lang);

    // Set dir and lang
    const html = document.documentElement;
    html.setAttribute('dir', lang === 'ar' ? 'rtl' : 'ltr');
    html.setAttribute('lang', lang);

    // Swap font
    document.body.style.fontFamily = lang === 'ar'
      ? "'Noto Sans Arabic', 'Inter', system-ui, sans-serif"
      : "'Inter', system-ui, sans-serif";

    // Translate all [data-i18n] elements
    document.querySelectorAll('[data-i18n]').forEach(el => {
      const key = el.getAttribute('data-i18n');
      const dict = translations[lang];
      if (dict && dict[key]) {
        if (el.tagName === 'INPUT' || el.tagName === 'TEXTAREA') {
          el.placeholder = dict[key];
        } else if (el.tagName === 'OPTION') {
          el.textContent = dict[key];
        } else {
          el.textContent = dict[key];
        }
      }
    });

    // Update lang toggle buttons text
    document.querySelectorAll('[data-action="toggle-lang"]').forEach(btn => {
      btn.textContent = translations[lang]['nav.langToggle'];
    });
  }

  t(key) {
    const dict = translations[this.currentLang];
    return (dict && dict[key]) || key;
  }
}

// Export
window.i18n = new I18nEngine();
