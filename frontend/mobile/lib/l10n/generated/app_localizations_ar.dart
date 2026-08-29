// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'فارم بايلوت';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get home => 'الرئيسية';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get products => 'المنتجات';

  @override
  String get orders => 'الطلبات';

  @override
  String get categories => 'التصنيفات';

  @override
  String get favorites => 'المفضلة';

  @override
  String get cart => 'السلة';

  @override
  String get reviews => 'التقييمات';

  @override
  String get crops => 'المحاصيل';

  @override
  String get reminders => 'التذكيرات';

  @override
  String get diagnosis => 'التشخيص';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get english => 'الإنجليزية';

  @override
  String get arabic => 'العربية';

  @override
  String get welcomeToFarmPilot => 'مرحبًا بك في فارم بايلوت';

  @override
  String get pleaseEnterEmailPassword =>
      'يرجى إدخال البريد الإلكتروني وكلمة المرور';

  @override
  String get unsupportedRole => 'نوع الحساب غير مدعوم';

  @override
  String get unknown => 'غير معروف';

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String get changeLanguage => 'تغيير اللغة';

  @override
  String get farmerDashboard => 'لوحة تحكم المزارع';

  @override
  String get welcomeFarmer => 'مرحبًا بالمزارع 🌱';

  @override
  String get myProducts => 'منتجاتي';

  @override
  String get myCrops => 'محاصيلي';

  @override
  String get plantDiagnosis => 'تشخيص النبات';

  @override
  String get diagnosisHistory => 'سجل التشخيصات';

  @override
  String get myProfile => 'ملفي الشخصي';

  @override
  String get noData => 'لا توجد بيانات';

  @override
  String get aiDiagnoses => 'تشخيصات الذكاء الاصطناعي';

  @override
  String get totalSales => 'إجمالي المبيعات';

  @override
  String get customerDashboard => 'لوحة تحكم العميل';

  @override
  String get customer => 'العميل';

  @override
  String welcomeCustomer(String name) {
    return 'مرحبًا $name 👋';
  }

  @override
  String get customerDashboardSubtitle => 'تصفح المنتجات الطازجة وتابع طلباتك.';

  @override
  String get browseMarketplace => 'تصفح السوق';

  @override
  String get myOrders => 'طلباتي';

  @override
  String get myOrdersSubtitle => 'عرض طلباتك الحالية والسابقة';

  @override
  String get marketplace => 'السوق';

  @override
  String get marketplaceSubtitle =>
      'تصفح المنتجات المتاحة وأضفها إلى سلة التسوق';

  @override
  String get myFavorites => 'المفضلة';

  @override
  String get myFavoritesSubtitle => 'عرض المنتجات التي حفظتها لوقت لاحق';

  @override
  String get latestNotifications => 'عرض أحدث الإشعارات';

  @override
  String unreadNotifications(int count) {
    return '$count إشعارات غير مقروءة';
  }

  @override
  String get shoppingCart => 'سلة التسوق';

  @override
  String get shoppingCartSubtitle => 'راجع منتجاتك وأكمل عملية الشراء';

  @override
  String get myProfileSubtitle => 'عرض وتعديل معلوماتك الشخصية';

  @override
  String get adminDashboard => 'لوحة تحكم المسؤول';

  @override
  String get refresh => 'تحديث';

  @override
  String get unableToLoadAdminDashboard => 'تعذر تحميل لوحة تحكم المسؤول';

  @override
  String get tryAgain => 'إعادة المحاولة';

  @override
  String get welcomeAdmin => 'مرحبًا بالمسؤول';

  @override
  String get systemOverviewStatistics => 'نظرة عامة وإحصائيات النظام';

  @override
  String get totalUsers => 'إجمالي المستخدمين';

  @override
  String get farmers => 'المزارعون';

  @override
  String get customers => 'العملاء';

  @override
  String get diagnoses => 'التشخيصات';

  @override
  String get adminTools => 'أدوات المسؤول';

  @override
  String get manageUsers => 'إدارة المستخدمين';

  @override
  String get manageOrders => 'إدارة الطلبات';

  @override
  String get manageProducts => 'إدارة المنتجات';

  @override
  String get manageCategories => 'إدارة التصنيفات';

  @override
  String get addProduct => 'إضافة منتج';

  @override
  String get noProductsFound => 'لا توجد منتجات';

  @override
  String get unnamedProduct => 'منتج بدون اسم';

  @override
  String get price => 'السعر';

  @override
  String get quantity => 'الكمية';

  @override
  String get status => 'الحالة';

  @override
  String get category => 'التصنيف';

  @override
  String get editProduct => 'تعديل المنتج';

  @override
  String get deleteProduct => 'حذف المنتج';

  @override
  String deleteProductConfirmation(String productName) {
    return 'هل أنت متأكد من حذف \"$productName\"؟';
  }

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get productDeletedSuccessfully => 'تم حذف المنتج بنجاح';

  @override
  String failedToDeleteProduct(String error) {
    return 'فشل حذف المنتج: $error';
  }

  @override
  String get productUpdatedSuccessfully => 'تم تحديث المنتج بنجاح';

  @override
  String get productName => 'اسم المنتج';

  @override
  String get description => 'الوصف';

  @override
  String get unit => 'الوحدة';

  @override
  String get chooseProductImage => 'اختيار صورة المنتج';

  @override
  String get changeProductImage => 'تغيير صورة المنتج';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get pleaseSelectCategory => 'يرجى اختيار التصنيف';

  @override
  String get pleaseEnterValidProductData => 'يرجى إدخال بيانات منتج صحيحة';

  @override
  String failedToSelectImage(String error) {
    return 'فشل اختيار الصورة: $error';
  }

  @override
  String get pleaseEnterProductNameFirst => 'يرجى إدخال اسم المنتج أولًا';

  @override
  String get freshFarmProduct => 'منتج زراعي طازج';

  @override
  String get marketingContent => 'المحتوى التسويقي';

  @override
  String get suggestedTitle => 'العنوان المقترح';

  @override
  String get suggestedDescription => 'الوصف المقترح';

  @override
  String get keywords => 'الكلمات المفتاحية';

  @override
  String get marketingSuggestions => 'اقتراحات تسويقية';

  @override
  String get close => 'إغلاق';

  @override
  String get useContent => 'استخدام المحتوى';

  @override
  String get marketingContentAdded => 'تمت إضافة المحتوى التسويقي إلى النموذج';

  @override
  String get generateMarketingContent => 'إنشاء محتوى تسويقي';

  @override
  String get productIdNotFound => 'لم يتم العثور على معرف المنتج';

  @override
  String get available => 'متاح';

  @override
  String get outOfStock => 'غير متوفر';

  @override
  String get hidden => 'مخفي';

  @override
  String get loginBrandTitle => 'مزرعتك.\nأذكى.';

  @override
  String get loginBrandDescription =>
      'أدر محاصيلك، وشخّص صحة النباتات، ونظّم المهام الزراعية، وبِع منتجاتك مباشرة من خلال منصة ذكية واحدة.';

  @override
  String get smartCrops => 'محاصيل ذكية';

  @override
  String get aiDiagnosis => 'التشخيص بالذكاء الاصطناعي';

  @override
  String get secureAccessMessage =>
      'دخول آمن للمزارعين والعملاء والموردين والمسؤولين.';

  @override
  String get mobileBrandDescription =>
      'الزراعة الذكية والسوق المباشر في منصة واحدة.';

  @override
  String get quickActions => 'الإجراءات السريعة';

  @override
  String get quickActionsSubtitle => 'الوصول إلى الأدوات الأكثر استخدامًا';

  @override
  String get farmManagement => 'إدارة المزرعة';

  @override
  String get farmManagementSubtitle => 'كل ما تحتاجه لإدارة مزرعتك';

  @override
  String get farmerWelcomeSubtitle => 'إليك ما يحدث في مزرعتك اليوم.';

  @override
  String get manageListings => 'إدارة المنتجات';

  @override
  String get manageCustomerOrders => 'إدارة طلبات العملاء';

  @override
  String get trackYourCrops => 'متابعة محاصيلك';

  @override
  String get aiPoweredDiagnosis => 'تشخيص مدعوم بالذكاء الاصطناعي';

  @override
  String get reviewPreviousPlantAnalyses => 'مراجعة تشخيصات النباتات السابقة';

  @override
  String get stayOnTopFarmTasks => 'تابع مهام مزرعتك باستمرار';

  @override
  String get viewLatestUpdates => 'عرض آخر التحديثات';

  @override
  String get manageAccountDetails => 'إدارة بيانات الحساب';

  @override
  String get back => 'رجوع';

  @override
  String get myProductsSubtitle =>
      'أدر منتجات مزرعتك وأسعارها وكمياتها وحالة توفرها.';

  @override
  String productsCount(int count) {
    return '$count منتجات';
  }

  @override
  String get imagePreviewZoomHint =>
      'استخدم التكبير باللمس أو عجلة الفأرة لتكبير الصورة.';

  @override
  String get createFirstProductListing =>
      'أضف أول منتج لك وابدأ البيع من خلال السوق.';

  @override
  String get editProductSubtitle =>
      'حدّث تفاصيل المنتج والصورة ومعلومات عرضه في السوق.';

  @override
  String get addProductSubtitle =>
      'أنشئ منتجًا جديدًا في السوق واستخدم الذكاء الاصطناعي للمساعدة في إعداد المحتوى التسويقي.';

  @override
  String get productInformation => 'معلومات المنتج';

  @override
  String get productInformationSubtitle =>
      'أضف بيانات المنتج الأساسية التي سيشاهدها العملاء في السوق.';

  @override
  String get productImage => 'صورة المنتج';

  @override
  String get productImageSubtitle => 'اختر صورة واضحة للمنتج لعرضها في السوق.';

  @override
  String get saving => 'جارٍ الحفظ...';

  @override
  String get removeImage => 'إزالة الصورة';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get createAccountSubtitle => 'أنشئ حسابك وابدأ باستخدام فارم بايلوت.';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get loginHere => 'تسجيل الدخول';

  @override
  String get registerNow => 'إنشاء حساب';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get phone => 'رقم الهاتف';

  @override
  String get address => 'العنوان';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get accountType => 'نوع الحساب';

  @override
  String get farmer => 'مزارع';

  @override
  String get customerAccount => 'عميل';

  @override
  String get supplier => 'مورد';

  @override
  String get supplierAccount => 'مورد';

  @override
  String get selectAccountType => 'اختر نوع الحساب';

  @override
  String get createAccountButton => 'إنشاء الحساب';

  @override
  String get creatingAccount => 'جارٍ إنشاء الحساب...';

  @override
  String get accountCreatedSuccessfully =>
      'تم إنشاء الحساب بنجاح. يمكنك الآن تسجيل الدخول.';

  @override
  String get pleaseFillAllFields => 'يرجى تعبئة جميع الحقول';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get passwordTooShort => 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل';

  @override
  String get invalidEmail => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get joinFarmPilot => 'انضم إلى فارم بايلوت';

  @override
  String get registerBrandDescription =>
      'أنشئ حسابًا كمزارع أو عميل أو مورد واستفد من أدوات الزراعة الذكية والسوق المباشر.';

  @override
  String get supplierDashboard => 'لوحة تحكم المورد';

  @override
  String get welcomeSupplier => 'مرحبًا بالمورد';

  @override
  String get supplierDashboardSubtitle =>
      'أدر مستلزماتك الزراعية وطلبات المزارعين ومخزونك من مكان واحد.';

  @override
  String get supplierProducts => 'منتجات المورد';

  @override
  String get mySupplierProducts => 'منتجاتي';

  @override
  String get manageSupplierProducts =>
      'إدارة المستلزمات الزراعية التي تعرضها للمزارعين';

  @override
  String get supplierOrders => 'طلبات المزارعين';

  @override
  String get manageFarmerOrders =>
      'عرض وتحديث طلبات المستلزمات الواردة من المزارعين';

  @override
  String get supplierCategories => 'تصنيفات المستلزمات';

  @override
  String get browseSupplierCategories => 'عرض تصنيفات المستلزمات الزراعية';

  @override
  String get supplierInventory => 'المخزون';

  @override
  String get manageSupplierInventory => 'متابعة كميات المنتجات وحالة توفرها';

  @override
  String get storeLocation => 'موقع المتجر';

  @override
  String get manageStoreLocation => 'إدارة بيانات المورد وموقع استلام الطلبات';

  @override
  String get agriculturalSupplies => 'المستلزمات الزراعية';

  @override
  String get agriculturalSuppliesSubtitle =>
      'البذور والأسمدة والمبيدات وأدوات ومستلزمات الزراعة';

  @override
  String get supplierManagement => 'إدارة المورد';

  @override
  String get supplierManagementSubtitle =>
      'إدارة المنتجات والطلبات والمخزون وبيانات المتجر';

  @override
  String get addSupplierProduct => 'إضافة منتج للمورد';

  @override
  String get editSupplierProduct => 'تعديل منتج المورد';

  @override
  String get addSupplierProductSubtitle =>
      'أضف مستلزمًا زراعيًا جديدًا ليتمكن المزارعون من شرائه.';

  @override
  String get editSupplierProductSubtitle =>
      'حدّث تفاصيل المنتج وتعليماته وصورته ومعلومات توفره.';

  @override
  String get supplierProductInformation => 'معلومات المنتج';

  @override
  String get supplierProductInformationSubtitle =>
      'أضف المعلومات الأساسية للمستلزم الزراعي الذي سيظهر للمزارعين.';

  @override
  String get supplierProductImage => 'صورة المنتج';

  @override
  String get supplierProductImageSubtitle =>
      'اختر صورة واضحة للمستلزم الزراعي لعرضها في المتجر.';

  @override
  String get plantingInstructions => 'تعليمات الزراعة';

  @override
  String get plantingInstructionsHint =>
      'أدخل تعليمات الزراعة أو الغرس إن وجدت';

  @override
  String get irrigationInstructions => 'تعليمات الري';

  @override
  String get irrigationInstructionsHint => 'أدخل تعليمات الري إن وجدت';

  @override
  String get usageInstructions => 'تعليمات الاستخدام';

  @override
  String get usageInstructionsHint =>
      'أدخل تعليمات الاستخدام الآمن والصحيح للمنتج إن وجدت';

  @override
  String get productInstructions => 'تعليمات المنتج';

  @override
  String get productInstructionsSubtitle =>
      'أضف التعليمات المناسبة لهذا المنتج لمساعدة المزارع على استخدامه بشكل صحيح.';

  @override
  String get selectSupplierCategory => 'اختر تصنيف المستلزم';

  @override
  String get noSupplierCategoriesFound => 'لا توجد تصنيفات للمستلزمات متاحة';

  @override
  String get supplierProductAddedSuccessfully => 'تمت إضافة منتج المورد بنجاح';

  @override
  String get supplierProductUpdatedSuccessfully => 'تم تحديث منتج المورد بنجاح';

  @override
  String get supplierProductIdNotFound => 'لم يتم العثور على معرف منتج المورد';

  @override
  String get pleaseEnterValidSupplierProductData =>
      'يرجى إدخال بيانات صحيحة للمنتج';

  @override
  String get failedToSaveSupplierProduct => 'فشل حفظ منتج المورد';

  @override
  String get supplierProductImageUploadFailed => 'فشل رفع صورة المنتج';

  @override
  String get supplierProductNoDescription => 'لا يوجد وصف لهذا المنتج';

  @override
  String get noSupplierProductsFound => 'لا توجد منتجات للمورد';

  @override
  String get createFirstSupplierProduct =>
      'أضف أول مستلزم زراعي لك ليظهر للمزارعين ويتمكنوا من شرائه.';
}
