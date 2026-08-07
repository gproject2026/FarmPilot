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
}
