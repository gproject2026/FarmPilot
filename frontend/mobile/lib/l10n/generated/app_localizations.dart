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
/// import 'generated/app_localizations.dart';
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
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'FarmPilot'**
  String get appName;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @crops.
  ///
  /// In en, this message translates to:
  /// **'Crops'**
  String get crops;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @diagnosis.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis'**
  String get diagnosis;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @welcomeToFarmPilot.
  ///
  /// In en, this message translates to:
  /// **'Welcome to FarmPilot'**
  String get welcomeToFarmPilot;

  /// No description provided for @pleaseEnterEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter email and password'**
  String get pleaseEnterEmailPassword;

  /// No description provided for @unsupportedRole.
  ///
  /// In en, this message translates to:
  /// **'Unsupported role'**
  String get unsupportedRole;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get changeLanguage;

  /// No description provided for @farmerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Farmer Dashboard'**
  String get farmerDashboard;

  /// No description provided for @welcomeFarmer.
  ///
  /// In en, this message translates to:
  /// **'Welcome Farmer 🌱'**
  String get welcomeFarmer;

  /// No description provided for @myProducts.
  ///
  /// In en, this message translates to:
  /// **'My Products'**
  String get myProducts;

  /// No description provided for @myCrops.
  ///
  /// In en, this message translates to:
  /// **'My Crops'**
  String get myCrops;

  /// No description provided for @plantDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Plant Diagnosis'**
  String get plantDiagnosis;

  /// No description provided for @diagnosisHistory.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis History'**
  String get diagnosisHistory;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get noData;

  /// No description provided for @aiDiagnoses.
  ///
  /// In en, this message translates to:
  /// **'AI Diagnoses'**
  String get aiDiagnoses;

  /// No description provided for @totalSales.
  ///
  /// In en, this message translates to:
  /// **'Total Sales'**
  String get totalSales;

  /// No description provided for @customerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Customer Dashboard'**
  String get customerDashboard;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @welcomeCustomer.
  ///
  /// In en, this message translates to:
  /// **'Welcome {name} 👋'**
  String welcomeCustomer(String name);

  /// No description provided for @customerDashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse fresh products and follow your orders.'**
  String get customerDashboardSubtitle;

  /// No description provided for @browseMarketplace.
  ///
  /// In en, this message translates to:
  /// **'Browse Marketplace'**
  String get browseMarketplace;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @myOrdersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View your current and previous orders'**
  String get myOrdersSubtitle;

  /// No description provided for @marketplace.
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get marketplace;

  /// No description provided for @marketplaceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse available products and add them to your cart'**
  String get marketplaceSubtitle;

  /// No description provided for @myFavorites.
  ///
  /// In en, this message translates to:
  /// **'My Favorites'**
  String get myFavorites;

  /// No description provided for @myFavoritesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View products you saved for later'**
  String get myFavoritesSubtitle;

  /// No description provided for @latestNotifications.
  ///
  /// In en, this message translates to:
  /// **'View your latest notifications'**
  String get latestNotifications;

  /// No description provided for @unreadNotifications.
  ///
  /// In en, this message translates to:
  /// **'{count} unread notifications'**
  String unreadNotifications(int count);

  /// No description provided for @shoppingCart.
  ///
  /// In en, this message translates to:
  /// **'Shopping Cart'**
  String get shoppingCart;

  /// No description provided for @shoppingCartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review your products and complete checkout'**
  String get shoppingCartSubtitle;

  /// No description provided for @myProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View and edit your personal information'**
  String get myProfileSubtitle;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @unableToLoadAdminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Unable to load admin dashboard'**
  String get unableToLoadAdminDashboard;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @welcomeAdmin.
  ///
  /// In en, this message translates to:
  /// **'Welcome Admin'**
  String get welcomeAdmin;

  /// No description provided for @systemOverviewStatistics.
  ///
  /// In en, this message translates to:
  /// **'System overview and statistics'**
  String get systemOverviewStatistics;

  /// No description provided for @totalUsers.
  ///
  /// In en, this message translates to:
  /// **'Total Users'**
  String get totalUsers;

  /// No description provided for @farmers.
  ///
  /// In en, this message translates to:
  /// **'Farmers'**
  String get farmers;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @diagnoses.
  ///
  /// In en, this message translates to:
  /// **'Diagnoses'**
  String get diagnoses;

  /// No description provided for @adminTools.
  ///
  /// In en, this message translates to:
  /// **'Admin Tools'**
  String get adminTools;

  /// No description provided for @manageUsers.
  ///
  /// In en, this message translates to:
  /// **'Manage Users'**
  String get manageUsers;

  /// No description provided for @manageOrders.
  ///
  /// In en, this message translates to:
  /// **'Manage Orders'**
  String get manageOrders;

  /// No description provided for @manageProducts.
  ///
  /// In en, this message translates to:
  /// **'Manage Products'**
  String get manageProducts;

  /// No description provided for @manageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get manageCategories;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No Products Found'**
  String get noProductsFound;

  /// No description provided for @unnamedProduct.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Product'**
  String get unnamedProduct;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProduct;

  /// No description provided for @deleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Delete Product'**
  String get deleteProduct;

  /// No description provided for @deleteProductConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{productName}\"?'**
  String deleteProductConfirmation(String productName);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @productDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Product deleted successfully'**
  String get productDeletedSuccessfully;

  /// No description provided for @failedToDeleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete product: {error}'**
  String failedToDeleteProduct(String error);

  /// No description provided for @productUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Product updated successfully'**
  String get productUpdatedSuccessfully;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productName;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @chooseProductImage.
  ///
  /// In en, this message translates to:
  /// **'Choose Product Image'**
  String get chooseProductImage;

  /// No description provided for @changeProductImage.
  ///
  /// In en, this message translates to:
  /// **'Change Product Image'**
  String get changeProductImage;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @pleaseSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get pleaseSelectCategory;

  /// No description provided for @pleaseEnterValidProductData.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid product data'**
  String get pleaseEnterValidProductData;

  /// No description provided for @failedToSelectImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to select image: {error}'**
  String failedToSelectImage(String error);

  /// No description provided for @pleaseEnterProductNameFirst.
  ///
  /// In en, this message translates to:
  /// **'Please enter the product name first'**
  String get pleaseEnterProductNameFirst;

  /// No description provided for @freshFarmProduct.
  ///
  /// In en, this message translates to:
  /// **'Fresh farm product'**
  String get freshFarmProduct;

  /// No description provided for @marketingContent.
  ///
  /// In en, this message translates to:
  /// **'Marketing Content'**
  String get marketingContent;

  /// No description provided for @suggestedTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggested Title'**
  String get suggestedTitle;

  /// No description provided for @suggestedDescription.
  ///
  /// In en, this message translates to:
  /// **'Suggested Description'**
  String get suggestedDescription;

  /// No description provided for @keywords.
  ///
  /// In en, this message translates to:
  /// **'Keywords'**
  String get keywords;

  /// No description provided for @marketingSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Marketing Suggestions'**
  String get marketingSuggestions;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @useContent.
  ///
  /// In en, this message translates to:
  /// **'Use Content'**
  String get useContent;

  /// No description provided for @marketingContentAdded.
  ///
  /// In en, this message translates to:
  /// **'Marketing content added to the form'**
  String get marketingContentAdded;

  /// No description provided for @generateMarketingContent.
  ///
  /// In en, this message translates to:
  /// **'Generate Marketing Content'**
  String get generateMarketingContent;

  /// No description provided for @productIdNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product ID was not found'**
  String get productIdNotFound;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @hidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get hidden;

  /// No description provided for @loginBrandTitle.
  ///
  /// In en, this message translates to:
  /// **'YOUR FARM.\nSMARTER.'**
  String get loginBrandTitle;

  /// No description provided for @loginBrandDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage crops, diagnose plant health, organize farm tasks and sell products directly through one smart platform.'**
  String get loginBrandDescription;

  /// No description provided for @smartCrops.
  ///
  /// In en, this message translates to:
  /// **'Smart Crops'**
  String get smartCrops;

  /// No description provided for @aiDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'AI Diagnosis'**
  String get aiDiagnosis;

  /// No description provided for @secureAccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Secure access for farmers, customers, suppliers and administrators.'**
  String get secureAccessMessage;

  /// No description provided for @mobileBrandDescription.
  ///
  /// In en, this message translates to:
  /// **'Smart farming and direct marketplace in one platform.'**
  String get mobileBrandDescription;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @quickActionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Access the tools you use most'**
  String get quickActionsSubtitle;

  /// No description provided for @farmManagement.
  ///
  /// In en, this message translates to:
  /// **'Farm Management'**
  String get farmManagement;

  /// No description provided for @farmManagementSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Everything you need to manage your farm'**
  String get farmManagementSubtitle;

  /// No description provided for @farmerWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Here is what is happening on your farm today.'**
  String get farmerWelcomeSubtitle;

  /// No description provided for @manageListings.
  ///
  /// In en, this message translates to:
  /// **'Manage listings'**
  String get manageListings;

  /// No description provided for @manageCustomerOrders.
  ///
  /// In en, this message translates to:
  /// **'Manage customer orders'**
  String get manageCustomerOrders;

  /// No description provided for @trackYourCrops.
  ///
  /// In en, this message translates to:
  /// **'Track your crops'**
  String get trackYourCrops;

  /// No description provided for @aiPoweredDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'AI-powered diagnosis'**
  String get aiPoweredDiagnosis;

  /// No description provided for @reviewPreviousPlantAnalyses.
  ///
  /// In en, this message translates to:
  /// **'Review previous plant analyses'**
  String get reviewPreviousPlantAnalyses;

  /// No description provided for @stayOnTopFarmTasks.
  ///
  /// In en, this message translates to:
  /// **'Stay on top of farm tasks'**
  String get stayOnTopFarmTasks;

  /// No description provided for @viewLatestUpdates.
  ///
  /// In en, this message translates to:
  /// **'View your latest updates'**
  String get viewLatestUpdates;

  /// No description provided for @manageAccountDetails.
  ///
  /// In en, this message translates to:
  /// **'Manage account details'**
  String get manageAccountDetails;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @myProductsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your farm listings, prices, quantities and product availability.'**
  String get myProductsSubtitle;

  /// No description provided for @productsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} products'**
  String productsCount(int count);

  /// No description provided for @imagePreviewZoomHint.
  ///
  /// In en, this message translates to:
  /// **'Use pinch or scroll to zoom the image.'**
  String get imagePreviewZoomHint;

  /// No description provided for @createFirstProductListing.
  ///
  /// In en, this message translates to:
  /// **'Create your first product listing to start selling through the marketplace.'**
  String get createFirstProductListing;

  /// No description provided for @editProductSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update product details, image and marketplace information.'**
  String get editProductSubtitle;

  /// No description provided for @addProductSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a marketplace listing and use AI to help prepare the marketing content.'**
  String get addProductSubtitle;

  /// No description provided for @productInformation.
  ///
  /// In en, this message translates to:
  /// **'Product Information'**
  String get productInformation;

  /// No description provided for @productInformationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add the core product details customers will see in the marketplace.'**
  String get productInformationSubtitle;

  /// No description provided for @productImage.
  ///
  /// In en, this message translates to:
  /// **'Product Image'**
  String get productImage;

  /// No description provided for @productImageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a clear product photo for the marketplace listing.'**
  String get productImageSubtitle;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @removeImage.
  ///
  /// In en, this message translates to:
  /// **'Remove image'**
  String get removeImage;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @createAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account and start using FarmPilot.'**
  String get createAccountSubtitle;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @loginHere.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginHere;

  /// No description provided for @registerNow.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerNow;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @accountType.
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get accountType;

  /// No description provided for @farmer.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get farmer;

  /// No description provided for @customerAccount.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customerAccount;

  /// No description provided for @supplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get supplier;

  /// No description provided for @supplierAccount.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get supplierAccount;

  /// No description provided for @selectAccountType.
  ///
  /// In en, this message translates to:
  /// **'Select Account Type'**
  String get selectAccountType;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountButton;

  /// No description provided for @creatingAccount.
  ///
  /// In en, this message translates to:
  /// **'Creating account...'**
  String get creatingAccount;

  /// No description provided for @accountCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully. You can now log in.'**
  String get accountCreatedSuccessfully;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get pleaseFillAllFields;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @joinFarmPilot.
  ///
  /// In en, this message translates to:
  /// **'Join FarmPilot'**
  String get joinFarmPilot;

  /// No description provided for @registerBrandDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a farmer, customer or supplier account and access smart farming tools and the direct marketplace.'**
  String get registerBrandDescription;

  /// No description provided for @supplierDashboard.
  ///
  /// In en, this message translates to:
  /// **'Supplier Dashboard'**
  String get supplierDashboard;

  /// No description provided for @welcomeSupplier.
  ///
  /// In en, this message translates to:
  /// **'Welcome Supplier'**
  String get welcomeSupplier;

  /// No description provided for @supplierDashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your agricultural supplies, farmer orders and inventory in one place.'**
  String get supplierDashboardSubtitle;

  /// No description provided for @supplierProducts.
  ///
  /// In en, this message translates to:
  /// **'Supplier Products'**
  String get supplierProducts;

  /// No description provided for @mySupplierProducts.
  ///
  /// In en, this message translates to:
  /// **'My Products'**
  String get mySupplierProducts;

  /// No description provided for @manageSupplierProducts.
  ///
  /// In en, this message translates to:
  /// **'Manage the agricultural supplies you offer to farmers'**
  String get manageSupplierProducts;

  /// No description provided for @supplierOrders.
  ///
  /// In en, this message translates to:
  /// **'Farmer Orders'**
  String get supplierOrders;

  /// No description provided for @manageFarmerOrders.
  ///
  /// In en, this message translates to:
  /// **'View and update agricultural supply orders from farmers'**
  String get manageFarmerOrders;

  /// No description provided for @supplierCategories.
  ///
  /// In en, this message translates to:
  /// **'Supply Categories'**
  String get supplierCategories;

  /// No description provided for @browseSupplierCategories.
  ///
  /// In en, this message translates to:
  /// **'Browse agricultural supply categories'**
  String get browseSupplierCategories;

  /// No description provided for @supplierInventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get supplierInventory;

  /// No description provided for @manageSupplierInventory.
  ///
  /// In en, this message translates to:
  /// **'Track product quantities and availability'**
  String get manageSupplierInventory;

  /// No description provided for @storeLocation.
  ///
  /// In en, this message translates to:
  /// **'Store Location'**
  String get storeLocation;

  /// No description provided for @manageStoreLocation.
  ///
  /// In en, this message translates to:
  /// **'Manage supplier details and pickup location'**
  String get manageStoreLocation;

  /// No description provided for @agriculturalSupplies.
  ///
  /// In en, this message translates to:
  /// **'Agricultural Supplies'**
  String get agriculturalSupplies;

  /// No description provided for @agriculturalSuppliesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Seeds, fertilizers, pesticides, tools and farming supplies'**
  String get agriculturalSuppliesSubtitle;

  /// No description provided for @supplierManagement.
  ///
  /// In en, this message translates to:
  /// **'Supplier Management'**
  String get supplierManagement;

  /// No description provided for @supplierManagementSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage products, orders, inventory and store information'**
  String get supplierManagementSubtitle;

  /// No description provided for @addSupplierProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Supplier Product'**
  String get addSupplierProduct;

  /// No description provided for @editSupplierProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Supplier Product'**
  String get editSupplierProduct;

  /// No description provided for @addSupplierProductSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a new agricultural supply for farmers to purchase.'**
  String get addSupplierProductSubtitle;

  /// No description provided for @editSupplierProductSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update product details, instructions, image and availability information.'**
  String get editSupplierProductSubtitle;

  /// No description provided for @supplierProductInformation.
  ///
  /// In en, this message translates to:
  /// **'Product Information'**
  String get supplierProductInformation;

  /// No description provided for @supplierProductInformationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add the main details of the agricultural supply that farmers will see.'**
  String get supplierProductInformationSubtitle;

  /// No description provided for @supplierProductImage.
  ///
  /// In en, this message translates to:
  /// **'Product Image'**
  String get supplierProductImage;

  /// No description provided for @supplierProductImageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a clear photo of the agricultural supply for the store listing.'**
  String get supplierProductImageSubtitle;

  /// No description provided for @plantingInstructions.
  ///
  /// In en, this message translates to:
  /// **'Planting Instructions'**
  String get plantingInstructions;

  /// No description provided for @plantingInstructionsHint.
  ///
  /// In en, this message translates to:
  /// **'Enter planting or sowing instructions if applicable'**
  String get plantingInstructionsHint;

  /// No description provided for @irrigationInstructions.
  ///
  /// In en, this message translates to:
  /// **'Irrigation Instructions'**
  String get irrigationInstructions;

  /// No description provided for @irrigationInstructionsHint.
  ///
  /// In en, this message translates to:
  /// **'Enter irrigation instructions if applicable'**
  String get irrigationInstructionsHint;

  /// No description provided for @usageInstructions.
  ///
  /// In en, this message translates to:
  /// **'Usage Instructions'**
  String get usageInstructions;

  /// No description provided for @usageInstructionsHint.
  ///
  /// In en, this message translates to:
  /// **'Enter safe and proper usage instructions if applicable'**
  String get usageInstructionsHint;

  /// No description provided for @productInstructions.
  ///
  /// In en, this message translates to:
  /// **'Product Instructions'**
  String get productInstructions;

  /// No description provided for @productInstructionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add relevant instructions to help farmers use this product correctly.'**
  String get productInstructionsSubtitle;

  /// No description provided for @selectSupplierCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Supply Category'**
  String get selectSupplierCategory;

  /// No description provided for @noSupplierCategoriesFound.
  ///
  /// In en, this message translates to:
  /// **'No supply categories are available'**
  String get noSupplierCategoriesFound;

  /// No description provided for @supplierProductAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Supplier product added successfully'**
  String get supplierProductAddedSuccessfully;

  /// No description provided for @supplierProductUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Supplier product updated successfully'**
  String get supplierProductUpdatedSuccessfully;

  /// No description provided for @supplierProductIdNotFound.
  ///
  /// In en, this message translates to:
  /// **'Supplier product ID was not found'**
  String get supplierProductIdNotFound;

  /// No description provided for @pleaseEnterValidSupplierProductData.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid product data'**
  String get pleaseEnterValidSupplierProductData;

  /// No description provided for @failedToSaveSupplierProduct.
  ///
  /// In en, this message translates to:
  /// **'Failed to save supplier product'**
  String get failedToSaveSupplierProduct;

  /// No description provided for @supplierProductImageUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload product image'**
  String get supplierProductImageUploadFailed;

  /// No description provided for @supplierProductNoDescription.
  ///
  /// In en, this message translates to:
  /// **'No description is available for this product'**
  String get supplierProductNoDescription;

  /// No description provided for @noSupplierProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No Supplier Products Found'**
  String get noSupplierProductsFound;

  /// No description provided for @createFirstSupplierProduct.
  ///
  /// In en, this message translates to:
  /// **'Add your first agricultural supply so farmers can view and purchase it.'**
  String get createFirstSupplierProduct;
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
    'that was used.',
  );
}
