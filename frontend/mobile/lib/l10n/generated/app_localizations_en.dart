// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'FarmPilot';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get logout => 'Logout';

  @override
  String get home => 'Home';

  @override
  String get profile => 'Profile';

  @override
  String get notifications => 'Notifications';

  @override
  String get products => 'Products';

  @override
  String get orders => 'Orders';

  @override
  String get categories => 'Categories';

  @override
  String get favorites => 'Favorites';

  @override
  String get cart => 'Cart';

  @override
  String get reviews => 'Reviews';

  @override
  String get crops => 'Crops';

  @override
  String get reminders => 'Reminders';

  @override
  String get diagnosis => 'Diagnosis';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get welcomeToFarmPilot => 'Welcome to FarmPilot';

  @override
  String get pleaseEnterEmailPassword => 'Please enter email and password';

  @override
  String get unsupportedRole => 'Unsupported role';

  @override
  String get unknown => 'Unknown';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get changeLanguage => 'Change language';

  @override
  String get farmerDashboard => 'Farmer Dashboard';

  @override
  String get welcomeFarmer => 'Welcome Farmer 🌱';

  @override
  String get myProducts => 'My Products';

  @override
  String get myCrops => 'My Crops';

  @override
  String get plantDiagnosis => 'Plant Diagnosis';

  @override
  String get diagnosisHistory => 'Diagnosis History';

  @override
  String get myProfile => 'My Profile';

  @override
  String get noData => 'No Data';

  @override
  String get aiDiagnoses => 'AI Diagnoses';

  @override
  String get totalSales => 'Total Sales';

  @override
  String get customerDashboard => 'Customer Dashboard';

  @override
  String get customer => 'Customer';

  @override
  String welcomeCustomer(String name) {
    return 'Welcome $name 👋';
  }

  @override
  String get customerDashboardSubtitle =>
      'Browse fresh products and follow your orders.';

  @override
  String get browseMarketplace => 'Browse Marketplace';

  @override
  String get myOrders => 'My Orders';

  @override
  String get myOrdersSubtitle => 'View your current and previous orders';

  @override
  String get marketplace => 'Marketplace';

  @override
  String get marketplaceSubtitle =>
      'Browse available products and add them to your cart';

  @override
  String get myFavorites => 'My Favorites';

  @override
  String get myFavoritesSubtitle => 'View products you saved for later';

  @override
  String get latestNotifications => 'View your latest notifications';

  @override
  String unreadNotifications(int count) {
    return '$count unread notifications';
  }

  @override
  String get shoppingCart => 'Shopping Cart';

  @override
  String get shoppingCartSubtitle =>
      'Review your products and complete checkout';

  @override
  String get myProfileSubtitle => 'View and edit your personal information';

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get refresh => 'Refresh';

  @override
  String get unableToLoadAdminDashboard => 'Unable to load admin dashboard';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get welcomeAdmin => 'Welcome Admin';

  @override
  String get systemOverviewStatistics => 'System overview and statistics';

  @override
  String get totalUsers => 'Total Users';

  @override
  String get farmers => 'Farmers';

  @override
  String get customers => 'Customers';

  @override
  String get diagnoses => 'Diagnoses';

  @override
  String get adminTools => 'Admin Tools';

  @override
  String get manageUsers => 'Manage Users';

  @override
  String get manageOrders => 'Manage Orders';

  @override
  String get manageProducts => 'Manage Products';

  @override
  String get manageCategories => 'Manage Categories';

  @override
  String get addProduct => 'Add Product';

  @override
  String get noProductsFound => 'No Products Found';

  @override
  String get unnamedProduct => 'Unnamed Product';

  @override
  String get price => 'Price';

  @override
  String get quantity => 'Quantity';

  @override
  String get status => 'Status';

  @override
  String get category => 'Category';

  @override
  String get editProduct => 'Edit Product';

  @override
  String get deleteProduct => 'Delete Product';

  @override
  String deleteProductConfirmation(String productName) {
    return 'Are you sure you want to delete \"$productName\"?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get productDeletedSuccessfully => 'Product deleted successfully';

  @override
  String failedToDeleteProduct(String error) {
    return 'Failed to delete product: $error';
  }

  @override
  String get productUpdatedSuccessfully => 'Product updated successfully';

  @override
  String get productName => 'Product Name';

  @override
  String get description => 'Description';

  @override
  String get unit => 'Unit';

  @override
  String get chooseProductImage => 'Choose Product Image';

  @override
  String get changeProductImage => 'Change Product Image';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get pleaseSelectCategory => 'Please select a category';

  @override
  String get pleaseEnterValidProductData => 'Please enter valid product data';

  @override
  String failedToSelectImage(String error) {
    return 'Failed to select image: $error';
  }

  @override
  String get pleaseEnterProductNameFirst =>
      'Please enter the product name first';

  @override
  String get freshFarmProduct => 'Fresh farm product';

  @override
  String get marketingContent => 'Marketing Content';

  @override
  String get suggestedTitle => 'Suggested Title';

  @override
  String get suggestedDescription => 'Suggested Description';

  @override
  String get keywords => 'Keywords';

  @override
  String get marketingSuggestions => 'Marketing Suggestions';

  @override
  String get close => 'Close';

  @override
  String get useContent => 'Use Content';

  @override
  String get marketingContentAdded => 'Marketing content added to the form';

  @override
  String get generateMarketingContent => 'Generate Marketing Content';

  @override
  String get productIdNotFound => 'Product ID was not found';

  @override
  String get available => 'Available';

  @override
  String get outOfStock => 'Out of Stock';

  @override
  String get hidden => 'Hidden';

  @override
  String get loginBrandTitle => 'YOUR FARM.\nSMARTER.';

  @override
  String get loginBrandDescription =>
      'Manage crops, diagnose plant health, organize farm tasks and sell products directly through one smart platform.';

  @override
  String get smartCrops => 'Smart Crops';

  @override
  String get aiDiagnosis => 'AI Diagnosis';

  @override
  String get secureAccessMessage =>
      'Secure access for farmers, customers, suppliers and administrators.';

  @override
  String get mobileBrandDescription =>
      'Smart farming and direct marketplace in one platform.';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get quickActionsSubtitle => 'Access the tools you use most';

  @override
  String get farmManagement => 'Farm Management';

  @override
  String get farmManagementSubtitle =>
      'Everything you need to manage your farm';

  @override
  String get farmerWelcomeSubtitle =>
      'Here is what is happening on your farm today.';

  @override
  String get manageListings => 'Manage listings';

  @override
  String get manageCustomerOrders => 'Manage customer orders';

  @override
  String get trackYourCrops => 'Track your crops';

  @override
  String get aiPoweredDiagnosis => 'AI-powered diagnosis';

  @override
  String get reviewPreviousPlantAnalyses => 'Review previous plant analyses';

  @override
  String get stayOnTopFarmTasks => 'Stay on top of farm tasks';

  @override
  String get viewLatestUpdates => 'View your latest updates';

  @override
  String get manageAccountDetails => 'Manage account details';

  @override
  String get back => 'Back';

  @override
  String get myProductsSubtitle =>
      'Manage your farm listings, prices, quantities and product availability.';

  @override
  String productsCount(int count) {
    return '$count products';
  }

  @override
  String get imagePreviewZoomHint => 'Use pinch or scroll to zoom the image.';

  @override
  String get createFirstProductListing =>
      'Create your first product listing to start selling through the marketplace.';

  @override
  String get editProductSubtitle =>
      'Update product details, image and marketplace information.';

  @override
  String get addProductSubtitle =>
      'Create a marketplace listing and use AI to help prepare the marketing content.';

  @override
  String get productInformation => 'Product Information';

  @override
  String get productInformationSubtitle =>
      'Add the core product details customers will see in the marketplace.';

  @override
  String get productImage => 'Product Image';

  @override
  String get productImageSubtitle =>
      'Choose a clear product photo for the marketplace listing.';

  @override
  String get saving => 'Saving...';

  @override
  String get removeImage => 'Remove image';

  @override
  String get createAccount => 'Create Account';

  @override
  String get createAccountSubtitle =>
      'Create your account and start using FarmPilot.';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get loginHere => 'Login';

  @override
  String get registerNow => 'Create Account';

  @override
  String get fullName => 'Full Name';

  @override
  String get phone => 'Phone Number';

  @override
  String get address => 'Address';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get accountType => 'Account Type';

  @override
  String get farmer => 'Farmer';

  @override
  String get customerAccount => 'Customer';

  @override
  String get supplier => 'Supplier';

  @override
  String get supplierAccount => 'Supplier';

  @override
  String get selectAccountType => 'Select Account Type';

  @override
  String get createAccountButton => 'Create Account';

  @override
  String get creatingAccount => 'Creating account...';

  @override
  String get accountCreatedSuccessfully =>
      'Account created successfully. You can now log in.';

  @override
  String get pleaseFillAllFields => 'Please fill in all fields';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get invalidEmail => 'Please enter a valid email address';

  @override
  String get joinFarmPilot => 'Join FarmPilot';

  @override
  String get registerBrandDescription =>
      'Create a farmer, customer or supplier account and access smart farming tools and the direct marketplace.';

  @override
  String get supplierDashboard => 'Supplier Dashboard';

  @override
  String get welcomeSupplier => 'Welcome Supplier';

  @override
  String get supplierDashboardSubtitle =>
      'Manage your agricultural supplies, farmer orders and inventory in one place.';

  @override
  String get supplierProducts => 'Supplier Products';

  @override
  String get mySupplierProducts => 'My Products';

  @override
  String get manageSupplierProducts =>
      'Manage the agricultural supplies you offer to farmers';

  @override
  String get supplierOrders => 'Farmer Orders';

  @override
  String get manageFarmerOrders =>
      'View and update agricultural supply orders from farmers';

  @override
  String get supplierCategories => 'Supply Categories';

  @override
  String get browseSupplierCategories =>
      'Browse agricultural supply categories';

  @override
  String get supplierInventory => 'Inventory';

  @override
  String get manageSupplierInventory =>
      'Track product quantities and availability';

  @override
  String get storeLocation => 'Store Location';

  @override
  String get manageStoreLocation =>
      'Manage supplier details and pickup location';

  @override
  String get agriculturalSupplies => 'Agricultural Supplies';

  @override
  String get agriculturalSuppliesSubtitle =>
      'Seeds, fertilizers, pesticides, tools and farming supplies';

  @override
  String get supplierManagement => 'Supplier Management';

  @override
  String get supplierManagementSubtitle =>
      'Manage products, orders, inventory and store information';

  @override
  String get addSupplierProduct => 'Add Supplier Product';

  @override
  String get editSupplierProduct => 'Edit Supplier Product';

  @override
  String get addSupplierProductSubtitle =>
      'Add a new agricultural supply for farmers to purchase.';

  @override
  String get editSupplierProductSubtitle =>
      'Update product details, instructions, image and availability information.';

  @override
  String get supplierProductInformation => 'Product Information';

  @override
  String get supplierProductInformationSubtitle =>
      'Add the main details of the agricultural supply that farmers will see.';

  @override
  String get supplierProductImage => 'Product Image';

  @override
  String get supplierProductImageSubtitle =>
      'Choose a clear photo of the agricultural supply for the store listing.';

  @override
  String get plantingInstructions => 'Planting Instructions';

  @override
  String get plantingInstructionsHint =>
      'Enter planting or sowing instructions if applicable';

  @override
  String get irrigationInstructions => 'Irrigation Instructions';

  @override
  String get irrigationInstructionsHint =>
      'Enter irrigation instructions if applicable';

  @override
  String get usageInstructions => 'Usage Instructions';

  @override
  String get usageInstructionsHint =>
      'Enter safe and proper usage instructions if applicable';

  @override
  String get productInstructions => 'Product Instructions';

  @override
  String get productInstructionsSubtitle =>
      'Add relevant instructions to help farmers use this product correctly.';

  @override
  String get selectSupplierCategory => 'Select Supply Category';

  @override
  String get noSupplierCategoriesFound => 'No supply categories are available';

  @override
  String get supplierProductAddedSuccessfully =>
      'Supplier product added successfully';

  @override
  String get supplierProductUpdatedSuccessfully =>
      'Supplier product updated successfully';

  @override
  String get supplierProductIdNotFound => 'Supplier product ID was not found';

  @override
  String get pleaseEnterValidSupplierProductData =>
      'Please enter valid product data';

  @override
  String get failedToSaveSupplierProduct => 'Failed to save supplier product';

  @override
  String get supplierProductImageUploadFailed =>
      'Failed to upload product image';

  @override
  String get supplierProductNoDescription =>
      'No description is available for this product';

  @override
  String get noSupplierProductsFound => 'No Supplier Products Found';

  @override
  String get createFirstSupplierProduct =>
      'Add your first agricultural supply so farmers can view and purchase it';

  @override
  String get inventoryManagement => 'Inventory Management';

  @override
  String get inventoryManagementSubtitle =>
      'Update product quantities and availability';

  @override
  String get updateInventory => 'Update Inventory';

  @override
  String get inventoryUpdatedSuccessfully => 'Inventory updated successfully';

  @override
  String get failedToUpdateInventory => 'Failed to update inventory';

  @override
  String get enterValidQuantity => 'Please enter a valid quantity';

  @override
  String get currentStock => 'Current Stock';

  @override
  String get stockStatus => 'Stock Status';

  @override
  String get noInventoryProducts => 'No products available in inventory';
}
