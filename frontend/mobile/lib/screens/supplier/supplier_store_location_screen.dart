import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../providers/profile_provider.dart';

class SupplierStoreLocationScreen extends StatefulWidget {
  const SupplierStoreLocationScreen({
    super.key,
  });

  @override
  State<SupplierStoreLocationScreen> createState() =>
      _SupplierStoreLocationScreenState();
}

class _SupplierStoreLocationScreenState
    extends State<SupplierStoreLocationScreen> {
  static const Color _darkGreen =
      Color(0xFF173F24);

  static const Color _primaryGreen =
      Color(0xFF2F6B3D);

  static const Color _background =
      Color(0xFFF8FAF4);

  static const Color _textPrimary =
      Color(0xFF1D2C21);

  static const Color _textSecondary =
      Color(0xFF68756B);

  final TextEditingController
      _addressController =
      TextEditingController();

  bool _fieldsInitialized = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _loadProfile();
      },
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final provider =
        Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    await provider.loadProfile();

    if (!mounted) {
      return;
    }

    _initializeFields(
      provider,
      force: true,
    );
  }

  void _initializeFields(
    ProfileProvider provider, {
    bool force = false,
  }) {
    if (provider.user == null) {
      return;
    }

    if (_fieldsInitialized && !force) {
      return;
    }

    _addressController.text =
        provider.user!.address ?? '';

    _fieldsInitialized = true;
  }

  Future<void> _saveLocation() async {
    final provider =
        Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    final user = provider.user;

    if (user == null) {
      return;
    }

    final address =
        _addressController.text.trim();

    final isArabic =
        Localizations.localeOf(
              context,
            ).languageCode ==
            'ar';

    if (address.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              isArabic
                  ? 'يرجى إدخال عنوان المتجر'
                  : 'Please enter the store address',
            ),
            behavior:
                SnackBarBehavior.floating,
          ),
        );

      return;
    }

    try {
      await provider.updateProfile(
        fullName: user.fullName,
        phone: user.phone ?? '',
        address: address,
        profileImage:
            user.profileImage,
      );

      if (!mounted) {
        return;
      }

      _addressController.text =
          provider.user?.address ??
              address;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              isArabic
                  ? 'تم تحديث موقع المتجر بنجاح'
                  : 'Store location updated successfully',
            ),
            behavior:
                SnackBarBehavior.floating,
          ),
        );
    } catch (error) {
      if (!mounted) {
        return;
      }

      final message = provider
                  .errorMessage
                  ?.trim()
                  .isNotEmpty ==
              true
          ? provider.errorMessage!
          : error
              .toString()
              .replaceFirst(
                'Exception: ',
                '',
              );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              message,
            ),
            behavior:
                SnackBarBehavior.floating,
          ),
        );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final l10n =
        AppLocalizations.of(context)!;

    final isArabic =
        Localizations.localeOf(
              context,
            ).languageCode ==
            'ar';

    return Scaffold(
      backgroundColor:
          _background,
      appBar: AppBar(
        backgroundColor:
            _primaryGreen,
        foregroundColor:
            Colors.white,
        elevation: 0,
        title: Text(
          l10n.storeLocation,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.w800,
          ),
        ),
        actions: [
          Consumer<ProfileProvider>(
            builder: (
              context,
              provider,
              child,
            ) {
              return IconButton(
                tooltip: isArabic
                    ? 'تحديث'
                    : 'Refresh',
                onPressed:
                    provider.isLoading
                        ? null
                        : () async {
                            _fieldsInitialized =
                                false;

                            await _loadProfile();
                          },
                icon:
                    const Icon(
                  Icons.refresh_rounded,
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ProfileProvider>(
        builder: (
          context,
          provider,
          child,
        ) {
          if (provider.isLoading &&
              provider.user == null) {
            return const Center(
              child:
                  CircularProgressIndicator(
                color:
                    _primaryGreen,
              ),
            );
          }

          if (provider.errorMessage !=
                  null &&
              provider.user == null) {
            return _buildErrorState(
              provider:
                  provider,
              isArabic:
                  isArabic,
            );
          }

          if (provider.user == null) {
            return Center(
              child: Text(
                isArabic
                    ? 'لم يتم العثور على بيانات المورد'
                    : 'Supplier profile data was not found',
              ),
            );
          }

          _initializeFields(
            provider,
          );

          return RefreshIndicator(
            color: _primaryGreen,
            onRefresh:
                _loadProfile,
            child:
                SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                24,
                20,
                40,
              ),
              child: Center(
                child:
                    ConstrainedBox(
                  constraints:
                      const BoxConstraints(
                    maxWidth: 950,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      _buildHero(
                        l10n: l10n,
                        isArabic:
                            isArabic,
                      ),
                      const SizedBox(
                        height: 22,
                      ),
                      _buildLocationCard(
                        provider:
                            provider,
                        isArabic:
                            isArabic,
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      _buildPickupInfo(
                        isArabic:
                            isArabic,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHero({
    required AppLocalizations l10n,
    required bool isArabic,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
        24,
      ),
      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          begin:
              AlignmentDirectional
                  .centerStart,
          end:
              AlignmentDirectional
                  .centerEnd,
          colors: [
            Colors.white,
            Color(
              0xFFFFFEFA,
            ),
            Color(
              0xFFF2F7EA,
            ),
          ],
        ),
        borderRadius:
            BorderRadius.circular(
          24,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFDCE6D7,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
                _darkGreen.withValues(
              alpha: 0.05,
            ),
            blurRadius: 22,
            offset:
                const Offset(
              0,
              7,
            ),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFE8F2DD,
              ),
              borderRadius:
                  BorderRadius
                      .circular(
                19,
              ),
            ),
            child:
                const Icon(
              Icons
                  .store_mall_directory_outlined,
              color:
                  _primaryGreen,
              size: 33,
            ),
          ),
          const SizedBox(
            width: 18,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  l10n.storeLocation,
                  style:
                      const TextStyle(
                    color:
                        _textPrimary,
                    fontSize: 24,
                    fontWeight:
                        FontWeight
                            .w800,
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
                Text(
                  isArabic
                      ? 'حدّث عنوان متجرك الذي سيظهر للمزارعين عند اختيار الاستلام من المورد.'
                      : 'Update the store address farmers use when choosing pickup from supplier.',
                  style:
                      const TextStyle(
                    color:
                        _textSecondary,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard({
    required ProfileProvider provider,
    required bool isArabic,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
        24,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white,
        borderRadius:
            BorderRadius.circular(
          24,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFDCE6D7,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
                _darkGreen.withValues(
              alpha: 0.04,
            ),
            blurRadius: 20,
            offset:
                const Offset(
              0,
              6,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFEAF3DF,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    14,
                  ),
                ),
                child:
                    const Icon(
                  Icons
                      .location_on_outlined,
                  color:
                      _primaryGreen,
                  size: 24,
                ),
              ),
              const SizedBox(
                width: 13,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      isArabic
                          ? 'عنوان المتجر'
                          : 'Store Address',
                      style:
                          const TextStyle(
                        color:
                            _textPrimary,
                        fontSize: 18,
                        fontWeight:
                            FontWeight
                                .w800,
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      isArabic
                          ? 'اكتب عنوانًا واضحًا ليسهل على المزارع الوصول إليك.'
                          : 'Enter a clear address so farmers can find your store easily.',
                      style:
                          const TextStyle(
                        color:
                            _textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 24,
          ),
          TextField(
            controller:
                _addressController,
            enabled:
                !provider.isSaving,
            minLines: 3,
            maxLines: 5,
            textInputAction:
                TextInputAction.newline,
            style:
                const TextStyle(
              color:
                  _textPrimary,
              fontWeight:
                  FontWeight.w600,
              fontSize: 14,
            ),
            decoration:
                InputDecoration(
              labelText: isArabic
                  ? 'العنوان'
                  : 'Address',
              hintText: isArabic
                  ? 'مثال: رام الله - شارع ...'
                  : 'Example: Ramallah - Street ...',
              alignLabelWithHint:
                  true,
              prefixIcon:
                  const Padding(
                padding:
                    EdgeInsets.only(
                  bottom: 56,
                ),
                child: Icon(
                  Icons
                      .place_outlined,
                  color:
                      _primaryGreen,
                ),
              ),
              filled: true,
              fillColor:
                  const Color(
                0xFFFCFDFB,
              ),
              border:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius
                        .circular(
                  16,
                ),
                borderSide:
                    const BorderSide(
                  color:
                      Color(
                    0xFFD8E2D4,
                  ),
                ),
              ),
              enabledBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius
                        .circular(
                  16,
                ),
                borderSide:
                    const BorderSide(
                  color:
                      Color(
                    0xFFD8E2D4,
                  ),
                ),
              ),
              focusedBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius
                        .circular(
                  16,
                ),
                borderSide:
                    const BorderSide(
                  color:
                      _primaryGreen,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 22,
          ),
          SizedBox(
            width: double.infinity,
            height: 52,
            child:
                ElevatedButton.icon(
              onPressed:
                  provider.isSaving
                      ? null
                      : _saveLocation,
              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    _primaryGreen,
                foregroundColor:
                    Colors.white,
                disabledBackgroundColor:
                    _primaryGreen
                        .withValues(
                  alpha: 0.55,
                ),
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    15,
                  ),
                ),
              ),
              icon:
                  provider.isSaving
                      ? const SizedBox(
                          width: 19,
                          height: 19,
                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2,
                            color:
                                Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons
                              .save_outlined,
                          size: 20,
                        ),
              label: Text(
                provider.isSaving
                    ? isArabic
                        ? 'جارٍ الحفظ...'
                        : 'Saving...'
                    : isArabic
                        ? 'حفظ موقع المتجر'
                        : 'Save Store Location',
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupInfo({
    required bool isArabic,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
        18,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFF1F7E9,
        ),
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFDCE6D7,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration:
                BoxDecoration(
              color:
                  Colors.white,
              borderRadius:
                  BorderRadius
                      .circular(
                13,
              ),
            ),
            child:
                const Icon(
              Icons
                  .local_shipping_outlined,
              color:
                  _primaryGreen,
              size: 21,
            ),
          ),
          const SizedBox(
            width: 13,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  isArabic
                      ? 'الاستلام من المورد'
                      : 'Pickup from Supplier',
                  style:
                      const TextStyle(
                    color:
                        _textPrimary,
                    fontSize: 15,
                    fontWeight:
                        FontWeight
                            .w800,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  isArabic
                      ? 'عند اختيار المزارع الاستلام من المورد، سيتم استخدام هذا العنوان كموقع استلام الطلب.'
                      : 'When a farmer chooses pickup from supplier, this address will be used as the order pickup location.',
                  style:
                      const TextStyle(
                    color:
                        _textSecondary,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState({
    required ProfileProvider provider,
    required bool isArabic,
  }) {
    return Center(
      child: Container(
        constraints:
            const BoxConstraints(
          maxWidth: 450,
        ),
        margin:
            const EdgeInsets.all(
          24,
        ),
        padding:
            const EdgeInsets.all(
          28,
        ),
        decoration:
            BoxDecoration(
          color:
              Colors.white,
          borderRadius:
              BorderRadius.circular(
            22,
          ),
          border:
              Border.all(
            color:
                const Color(
              0xFFDCE6D7,
            ),
          ),
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons
                  .error_outline_rounded,
              color:
                  Color(
                0xFFC65353,
              ),
              size: 55,
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              provider.errorMessage ??
                  (isArabic
                      ? 'فشل تحميل موقع المتجر'
                      : 'Failed to load store location'),
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    _textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            ElevatedButton.icon(
              onPressed:
                  _loadProfile,
              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    _primaryGreen,
                foregroundColor:
                    Colors.white,
              ),
              icon:
                  const Icon(
                Icons
                    .refresh_rounded,
              ),
              label: Text(
                isArabic
                    ? 'حاول مرة أخرى'
                    : 'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}