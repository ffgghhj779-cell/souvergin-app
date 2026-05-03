class AppStrings {
  final String locale;
  const AppStrings._(this.locale);

  static AppStrings of(String locale) => AppStrings._(locale);

  bool get isAr => locale == 'ar';

  // --- Home Screen ---
  String get appName => isAr ? 'معارج السيادية' : 'Sovereign Maareg';
  String get homeHeaderTitle => isAr ? 'المسارات السيادية' : 'Sovereign Frameworks';
  String get homeHeaderSubtitle => isAr ? 'أبرز البرامج لمحفظتك الاستثمارية' : 'Top-tier programs for elite capital';
  String get viewAll => isAr ? 'الكل' : 'View All';
  String get languageToggle => isAr ? 'EN' : 'AR';
  
  // --- Hero Section ---
  String get heroSystemStatus => isAr ? 'النظام قيد التشغيل' : 'SYSTEM OPERATIONAL';
  String get heroHeadline1 => isAr ? 'بوابتك السيادية' : 'Your Sovereign';
  String get heroHeadline2 => isAr ? 'إلى ' : 'Gateway to';
  String get heroHeadline3 => isAr ? 'الأسواق العالمية' : 'The Global Market';
  String get heroDescription => isAr 
      ? 'اختبر خدمات تأشيرات استثنائية مصممة خصيصاً للمستثمرين والتنفيذيين ذوي الملاءة المالية العالية، بمعايير سيادية من الموثوقية والسرعة المطلقة.'
      : 'Experience exceptional visa services engineered for high-net-worth investors and executives, wielding sovereign standards of reliability and absolute speed.';
  String get initializeApp => isAr ? 'بدء الطلب' : 'Initialize Application';
  String get exploreFrameworks => isAr ? 'استكشاف المسارات' : 'Explore Frameworks';
  String get encryptedConnection => isAr ? 'اتصال مشفر' : 'ENCRYPTED CONNECTION';

  // --- Trust Section ---
  String get secureProcessing => isAr ? 'معالجة آمنة بنسبة ١٠٠٪' : '100% SECURE PROCESSING';
  String get globalNetwork => isAr ? 'شبكة عالمية' : 'GLOBAL NETWORK';
  String get sovereignStandards => isAr ? 'معايير سيادية' : 'SOVEREIGN STANDARDS';

  // --- Services Section ---
  String get coreServices => isAr ? 'الخدمات الأساسية' : 'Core Services';
  String get precisionEngineered => isAr ? 'مصممة بدقة لتلبي متطلبات النخبة' : 'Precision-engineered for the elite';

  // --- Bottom Nav Bar ---
  String get navHome => isAr ? 'الرئيسية' : 'Home';
  String get navVisas => isAr ? 'المسارات' : 'Visas';
  String get navAbout => isAr ? 'عن الصندوق' : 'About';
  String get navContact => isAr ? 'تواصل معنا' : 'Contact';
  // --- Visa Card ---
  String get jurisdiction => isAr ? 'نطاق الاختصاص' : 'Jurisdiction';
  String get clearance => isAr ? 'المدة' : 'Clearance';
  String get capitalReq => isAr ? 'رأس المال' : 'Capital Req';
  String get verifiedRoute => isAr ? 'مسار موثق' : 'Verified Route';
}
