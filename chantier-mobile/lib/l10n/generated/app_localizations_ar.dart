// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'ورشاتي';

  @override
  String get sitesTitle => 'ورشاتي';

  @override
  String get languageLabel => 'اللغة';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageArabic => 'العربية';

  @override
  String get actionRetry => 'إعادة المحاولة';

  @override
  String get errorValidation => 'بعض المعلومات غير صحيحة. تحقق من الحقول.';

  @override
  String get errorDateInvalide =>
      'تاريخ غير صالح: اليوم والشهر والسنة إجبارية.';

  @override
  String get errorQuantiteInvalide => 'يجب أن تكون الكمية أكبر من الصفر.';

  @override
  String get errorCurseurInvalide =>
      'يجب إعادة المزامنة من البداية. إدخالاتك المعلقة محفوظة.';

  @override
  String get errorNonAuthentifie => 'انتهت الجلسة. أعد تسجيل الدخول.';

  @override
  String get errorIdentifiantsInvalides =>
      'اسم المستخدم أو كلمة المرور غير صحيحة، أو الحساب غير نشط. اتصل بالمسؤول.';

  @override
  String get errorRefreshInvalide =>
      'لم تعد جلستك صالحة. أعد تسجيل الدخول: إدخالاتك المعلقة محفوظة.';

  @override
  String get errorAccesRetire => 'تم سحب الوصول، اتصل بالمسؤول.';

  @override
  String get errorInterdit => 'ليس لديك صلاحية لتنفيذ هذا الإجراء.';

  @override
  String get errorIntrouvable => 'العنصر غير موجود.';

  @override
  String get errorConflitVersion =>
      'تم تعديل هذا العنصر في هذه الأثناء. أعد تحميله.';

  @override
  String get errorLotTropGrand => 'حجم الإرسال كبير جدا.';

  @override
  String get errorCodeChantierExistant => 'رمز الورشة موجود مسبقا.';

  @override
  String get errorZoneExistante => 'هذه المنطقة موجودة مسبقا في هذه الورشة.';

  @override
  String get errorChantierArchive =>
      'هذه الورشة مؤرشفة: لا يمكن إدخال أي بيانات.';

  @override
  String get errorCompteDesactive => 'هذا الحساب معطل.';

  @override
  String get errorMotDePasseFaible =>
      'كلمة المرور ضعيفة. اختر كلمة أطول وأكثر تنوعا.';

  @override
  String get errorMotDePasseAChanger =>
      'كلمة مرور مؤقتة: اختر كلمة المرور الخاصة بك قبل المتابعة.';

  @override
  String get errorEntiteNonSynchronisable =>
      'لا يمكن إرسال هذا النوع من الإدخال بعد.';

  @override
  String get errorTropDEssais => 'محاولات كثيرة، أعد المحاولة لاحقا.';

  @override
  String get errorTropDeRequetes => 'طلبات كثيرة، انتظر قليلا.';

  @override
  String get errorErreurInterne => 'خطأ في الخادم. أعد المحاولة لاحقا.';

  @override
  String get errorUniteObligatoire => 'الوحدة إجبارية.';

  @override
  String get errorUnitesIncompatibles => 'وحدات غير متوافقة: لا يمكن جمعها.';

  @override
  String get errorExpressionInvalide => 'عبارة القياس غير صالحة.';

  @override
  String get errorTransitionInterdite => 'تغيير الحالة هذا غير مسموح.';

  @override
  String get errorDemandeVerrouillee =>
      'تمت المصادقة على الطلب: لا يمكن تعديل الكمية والمادة. ألغِه وأنشئ طلباً جديداً.';

  @override
  String get errorDemandeNonOuverte => 'هذا الطلب لا يقبل تسليماً جديداً.';

  @override
  String get errorCommandeExistante => 'تم تقديم طلبية لهذا الطلب من قبل.';

  @override
  String get errorProduitDifferent => 'مادة التسليم ليست مادة الطلب.';

  @override
  String get errorQuantiteEntiereRequise => 'يجب إدخال عدد صحيح.';

  @override
  String get errorUniteNonAutorisee => 'هذه الوحدة غير مسموح بها لهذه المادة.';

  @override
  String get errorMasseSacObligatoire => 'حدد وزن الكيس لهذه المادة.';

  @override
  String get errorProduitExistant => 'هذه المادة موجودة مسبقاً.';

  @override
  String get errorFournisseurExistant => 'هذا المورّد موجود مسبقاً.';

  @override
  String get errorProduitInactif => 'هذه المادة معطّلة: اختر مادة أخرى.';

  @override
  String get errorFournisseurInactif => 'هذا المورّد معطّل.';

  @override
  String get errorZoneHorsChantier => 'هذه المنطقة لا تنتمي إلى هذه الورشة.';

  @override
  String get errorLivraisonDejaRattachee => 'هذا التسليم مرتبط بطلب آخر.';

  @override
  String get errorPhotosTropNombreuses =>
      'تم بلوغ العدد الأقصى للصور لهذا التسليم.';

  @override
  String get errorPhotoDejaEnvoyee => 'تم إرسال هذه الصورة من قبل.';

  @override
  String get errorFichierTropGros => 'الصورة كبيرة جداً.';

  @override
  String get errorTypeFichierRefuse => 'تُقبل صور JPEG فقط.';

  @override
  String get errorNetwork =>
      'لا يوجد اتصال. إدخالاتك محفوظة وسيتم إرسالها عند عودة الاتصال.';

  @override
  String get errorTimeout => 'الخادم بطيء في الرد. أعد المحاولة.';

  @override
  String get errorUnknown => 'حدث خطأ. أعد المحاولة.';

  @override
  String get actionCancel => 'إلغاء';

  @override
  String get actionConfirm => 'تأكيد';

  @override
  String get actionRefresh => 'تحديث';

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get loginUserName => 'اسم المستخدم';

  @override
  String get loginPassword => 'كلمة المرور';

  @override
  String get loginShowPassword => 'إظهار كلمة المرور';

  @override
  String get loginHidePassword => 'إخفاء كلمة المرور';

  @override
  String get loginSubmit => 'تسجيل الدخول';

  @override
  String get loginSubmitting => 'جارٍ تسجيل الدخول…';

  @override
  String get loginFieldRequired => 'حقل إجباري';

  @override
  String get loginFirstConnectionTitle => 'أول تسجيل دخول: الشبكة ضرورية';

  @override
  String get loginFirstConnectionBody =>
      'اتصل بالإنترنت لفتح جلستك. ستتوفر ورشاتك بعد ذلك بدون شبكة.';

  @override
  String get noticeSessionExpired =>
      'انتهت جلستك. أعد تسجيل الدخول: إدخالاتك المعلقة محفوظة.';

  @override
  String get passwordChangeTitle => 'كلمة مرور جديدة';

  @override
  String get passwordChangeIntro =>
      'كلمة مرورك مؤقتة. اختر كلمة مرور جديدة قبل المتابعة.';

  @override
  String get passwordCurrent => 'كلمة المرور المؤقتة';

  @override
  String get passwordNew => 'كلمة المرور الجديدة';

  @override
  String get passwordConfirm => 'تأكيد كلمة المرور الجديدة';

  @override
  String get passwordMismatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get passwordChangeSubmit => 'حفظ كلمة المرور';

  @override
  String get logoutTitle => 'تسجيل الخروج';

  @override
  String get logoutConfirmBody =>
      'ستغلق جلستك. ستُمحى بيانات الورشات من هذا الهاتف.';

  @override
  String get logoutConfirm => 'تسجيل الخروج';

  @override
  String logoutPendingTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count إدخال لم يُرسل بعد',
      many: '$count إدخالاً لم يُرسل بعد',
      few: '$count إدخالات لم تُرسل بعد',
      two: 'إدخالان لم يُرسلا بعد',
      one: 'إدخال واحد لم يُرسل بعد',
      zero: 'لا توجد إدخالات غير مرسلة',
    );
    return '$_temp0';
  }

  @override
  String get logoutSendFirst => 'أرسل أولاً';

  @override
  String get logoutStay => 'البقاء متصلاً';

  @override
  String get logoutAnyway => 'تسجيل الخروج رغم ذلك';

  @override
  String get logoutAnywayTitle => 'تسجيل الخروج مع وجود إدخالات معلقة؟';

  @override
  String get logoutAnywayBody =>
      'تبقى على هذا الهاتف، ولن تُرسل إلا بعد إعادة تسجيل الدخول بنفس الحساب.';

  @override
  String get logoutSending => 'جارٍ الإرسال…';

  @override
  String get logoutSendFailed => 'لم يكتمل الإرسال. إدخالاتك محفوظة.';

  @override
  String get syncUpToDate => 'محدّث';

  @override
  String syncUpToDateAt(String when) {
    return 'محدّث · $when';
  }

  @override
  String get syncOffline => 'بدون اتصال';

  @override
  String syncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count في انتظار الإرسال',
      one: '1 في انتظار الإرسال',
    );
    return '$_temp0';
  }

  @override
  String get syncSyncing => 'جارٍ المزامنة…';

  @override
  String syncProblem(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count للمراجعة',
      one: '1 للمراجعة',
    );
    return '$_temp0';
  }

  @override
  String get syncProblemServer => 'مشكلة في المزامنة';

  @override
  String get syncAuthRequired => 'يلزم تسجيل الدخول من جديد';

  @override
  String syncWhenToday(String time) {
    return 'اليوم $time';
  }

  @override
  String syncStaleBanner(String when) {
    return 'بيانات بتاريخ $when';
  }

  @override
  String get syncNow => 'مزامنة الآن';

  @override
  String get syncDetailsHint => 'عرض الإدخالات في انتظار الإرسال';

  @override
  String get sitesEmpty => 'لا توجد ورشة معينة لك. اتصل بالمسؤول.';

  @override
  String get sitesPreparing => 'جارٍ تجهيز ورشاتك…';

  @override
  String sitesPreparingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم استلام $count عنصر',
      many: 'تم استلام $count عنصراً',
      few: 'تم استلام $count عناصر',
      two: 'تم استلام عنصرين',
      one: 'تم استلام عنصر واحد',
      zero: 'لم يتم استلام أي عنصر بعد',
    );
    return '$_temp0';
  }

  @override
  String get sitesFirstSyncOffline =>
      'لا توجد شبكة: لم تصل ورشاتك بعد. اتصل بالإنترنت لتجهيزها.';

  @override
  String get sitesSearchHint => 'بحث عن ورشة';

  @override
  String get sitesShowArchived => 'إظهار المؤرشفة';

  @override
  String get sitesNoResult => 'لا توجد ورشة مطابقة.';

  @override
  String get sitesCurrentBadge => 'الورشة الحالية';

  @override
  String get sitesArchivedBadge => 'مؤرشفة';

  @override
  String sitesDataFrom(String when) {
    return 'بيانات بتاريخ $when';
  }

  @override
  String get sitesChooseTitle => 'اختيار ورشة';

  @override
  String get sitesChooseRequired => 'اختر ورشتك قبل إجراء أي إدخال.';

  @override
  String get sitesCurrentRemoved =>
      'لم تعد ورشتك الحالية معينة لك. اختر ورشة أخرى.';

  @override
  String get siteInfoTitle => 'معلومات';

  @override
  String get siteType => 'نوع المشروع';

  @override
  String get siteTypeSchool => 'مدرسة';

  @override
  String get siteTypeHousing => 'سكنات';

  @override
  String get siteTypePublicFacility => 'مرفق عمومي';

  @override
  String get siteTypeOther => 'أخرى';

  @override
  String get siteWilaya => 'ولاية';

  @override
  String get siteCommune => 'بلدية';

  @override
  String get siteCoordinates => 'إحداثيات GPS';

  @override
  String get siteOwner => 'صاحب المشروع';

  @override
  String get siteContractNumber => 'رقم الصفقة';

  @override
  String get siteContractAmount => 'المبلغ';

  @override
  String get siteDelay => 'الأجل';

  @override
  String siteDelayDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count يوم',
      many: '$count يوماً',
      few: '$count أيام',
      two: 'يومان',
      one: 'يوم واحد',
    );
    return '$_temp0';
  }

  @override
  String get siteOds => 'أمر بالخدمة (بداية الأشغال)';

  @override
  String get siteEndDate => 'النهاية التعاقدية';

  @override
  String get siteToDefine => 'يحدد لاحقاً';

  @override
  String get siteZonesTitle => 'المناطق';

  @override
  String get siteNoZones => 'لا توجد مناطق في هذه الورشة.';

  @override
  String get siteMembersTitle => 'الأشخاص المعينون';

  @override
  String siteCreatedBy(String name, String when) {
    return 'أنشأه $name بتاريخ $when';
  }

  @override
  String siteUpdatedBy(String name, String when) {
    return 'عدّله $name بتاريخ $when';
  }

  @override
  String get siteNotFound => 'الورشة غير موجودة.';

  @override
  String get roleAdmin => 'المسؤول';

  @override
  String get roleDirection => 'الإدارة';

  @override
  String get roleConducteurTravaux => 'مسؤول متابعة الأشغال';

  @override
  String get roleAchats => 'المشتريات';

  @override
  String get roleChefChantier => 'رئيس الورشة';

  @override
  String get roleChefEquipe => 'رئيس الفريق';

  @override
  String get roomTypeClassroom => 'قسم';

  @override
  String get roomTypeCorridor => 'رواق';

  @override
  String get roomTypeCanteen => 'مطعم مدرسي';

  @override
  String get roomTypeRefectory => 'قاعة الأكل';

  @override
  String get roomTypeKitchen => 'مطبخ';

  @override
  String get roomTypeOffice => 'مكتب';

  @override
  String get roomTypeSanitary => 'مرافق صحية';

  @override
  String get roomTypeTechnicalRoom => 'محل تقني';

  @override
  String get roomTypeFacade => 'واجهة';

  @override
  String get roomTypeOther => 'أخرى';

  @override
  String get zonePendingBadge => 'في انتظار الإرسال';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String settingsVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get settingsAccount => 'الحساب';

  @override
  String get zoneAddButton => '+ منطقة';

  @override
  String get zoneAddTitle => 'إضافة منطقة';

  @override
  String get zoneBlock => 'بلوك';

  @override
  String get zoneBlockNew => 'بلوك جديد';

  @override
  String get zoneBlockNewLabel => 'اسم البلوك';

  @override
  String get zoneElevation => 'المنسوب';

  @override
  String get zoneElevationOther => 'منسوب آخر';

  @override
  String get zoneElevationNone => 'بدون منسوب';

  @override
  String get zoneElevationUnit => 'بالمتر';

  @override
  String get zoneElevationLabel => 'المنسوب (م)';

  @override
  String zoneElevationHelp(String min, String max) {
    return 'بالمتر، من $min إلى $max.';
  }

  @override
  String get zoneElevationInvalid => 'منسوب غير صالح: أرقام فقط (مثلاً 3,4).';

  @override
  String zoneElevationOutOfRange(String min, String max) {
    return 'يجب أن يكون المنسوب بين $min و $max م.';
  }

  @override
  String get zoneRoomType => 'نوع المحل';

  @override
  String get zoneRoomNone => 'بدون محل';

  @override
  String get zoneRoomNumber => 'الرقم';

  @override
  String get zoneRoomNumberMore => 'الرقم التالي';

  @override
  String get zoneRoomNumberLess => 'الرقم السابق';

  @override
  String get zoneRoomLabel => 'تسمية المحل';

  @override
  String get zoneRoomLabelRequired => 'حدد المحل.';

  @override
  String get zoneBlockRequired => 'اختر بلوكاً أو أنشئ بلوكاً جديداً.';

  @override
  String get zoneSave => 'حفظ';

  @override
  String get zoneSavedPending => 'تم حفظ المنطقة. في انتظار الإرسال.';

  @override
  String get zoneExists => 'هذه المنطقة موجودة مسبقاً.';

  @override
  String get zoneSearchHint => 'بحث (مثلاً «cl 02»)';

  @override
  String get zonePickerTitle => 'اختيار منطقة';

  @override
  String get zonePickerConfirm => 'تأكيد';

  @override
  String get zonePickerNone => 'غير محددة';

  @override
  String get zonePickerNoResult => 'لا توجد منطقة مطابقة.';

  @override
  String get pendingTitle => 'الإدخالات في انتظار الإرسال';

  @override
  String get pendingEmpty => 'لا شيء للإرسال. كل شيء محدّث.';

  @override
  String pendingSavedAt(String when) {
    return 'أُدخل بتاريخ $when';
  }

  @override
  String get pendingStatusPending => 'في انتظار الإرسال';

  @override
  String get pendingStatusSending => 'جارٍ الإرسال';

  @override
  String get pendingStatusToCheck => 'للمراجعة';

  @override
  String get pendingEntityZone => 'منطقة';

  @override
  String get pendingCorrect => 'تصحيح';

  @override
  String get pendingAbandon => 'إلغاء الإدخال';

  @override
  String get pendingAbandonTitle => 'إلغاء هذا الإدخال؟';

  @override
  String get pendingAbandonBody => 'سيُحذف من هذا الهاتف. هذا الإجراء نهائي.';

  @override
  String pendingReason(String reason) {
    return 'السبب: $reason';
  }

  @override
  String get pendingSyncFailed => 'لم تكتمل المزامنة. إدخالاتك محفوظة.';

  @override
  String get requestStatusRequested => 'تم الطلب';

  @override
  String get requestStatusValidated => 'تمت المصادقة';

  @override
  String get requestStatusRejected => 'تم الرفض';

  @override
  String get requestStatusOrdered => 'تم تقديم الطلبية';

  @override
  String get requestStatusPartiallyDelivered => 'تسليم جزئي';

  @override
  String get requestStatusDelivered => 'تم التسليم';

  @override
  String get requestStatusReceived => 'تم الاستلام';

  @override
  String get requestStatusCancelled => 'ملغى';

  @override
  String get priorityNormal => 'عادية';

  @override
  String get priorityUrgent => 'مستعجلة';

  @override
  String get priorityBlocking => 'معطِّلة للورشة';

  @override
  String get deliveryStatusRecorded => 'مسجّلة';

  @override
  String get deliveryStatusCancelled => 'ملغاة';

  @override
  String get conformityConform => 'مطابق';

  @override
  String get conformityWithReserve => 'مع تحفظ';

  @override
  String get unitPiece => 'قطعة';

  @override
  String get unitLinearMeter => 'م.ط';

  @override
  String get unitSquareMeter => 'م²';

  @override
  String get unitCubicMeter => 'م³';

  @override
  String get unitKilogram => 'كغ';

  @override
  String get unitTonne => 'طن';

  @override
  String get unitBag => 'كيس';

  @override
  String get unitLiter => 'لتر';

  @override
  String get unitHour => 'ساعة';

  @override
  String get unitDay => 'يوم';

  @override
  String get unitManDay => 'يوم عمل';

  @override
  String get unitLumpSum => 'جزافي';

  @override
  String get productCategoryBinders => 'مواد رابطة';

  @override
  String get productCategorySteel => 'حديد';

  @override
  String get productCategoryMasonry => 'بناء';

  @override
  String get productCategoryAggregates => 'ركام';

  @override
  String get productCategoryAdmixtures => 'مواد مضافة';

  @override
  String get productCategoryFinishingWorks => 'أشغال التهيئة';

  @override
  String get productCategoryOther => 'أخرى';

  @override
  String get reasonAlreadyOrdered => 'تم طلبه من قبل';

  @override
  String get reasonStockSufficient => 'المخزون كافٍ في الورشة';

  @override
  String get reasonQuantityToReview => 'الكمية تحتاج مراجعة';

  @override
  String get reasonOverBudget => 'خارج الميزانية';

  @override
  String get reasonEntryError => 'خطأ في الإدخال';

  @override
  String get reasonNoLongerNeeded => 'لم تعد هناك حاجة';

  @override
  String get reasonDuplicate => 'تكرار';

  @override
  String get reasonSupplierUnavailable => 'المورّد غير متاح';

  @override
  String get reasonPriceRefused => 'تم رفض السعر';

  @override
  String get reasonSupplierWillNotDeliver => 'لن يسلّم المورّد المتبقي';

  @override
  String get reasonQuantitySufficient => 'الكمية كافية';

  @override
  String get reasonDoubleEntry => 'إدخال مزدوج';

  @override
  String get reasonQuantityError => 'خطأ في الكمية';

  @override
  String get reasonRefusedAtReception => 'مرفوض عند الاستلام';

  @override
  String get reasonQuantityMissing => 'كمية ناقصة';

  @override
  String get reasonDamagedProduct => 'مادة تالفة';

  @override
  String get reasonWrongProduct => 'مادة خاطئة';

  @override
  String get reasonOther => 'أخرى';

  @override
  String get materialNumberPending => 'الرقم قيد الانتظار';

  @override
  String get materialToConfirm => 'بانتظار التأكيد';

  @override
  String materialOverdueDays(String days) {
    return 'متأخر بـ $days يوم';
  }

  @override
  String get requestsTitle => 'طلبات المواد';

  @override
  String get requestNew => 'طلب جديد';

  @override
  String get requestNewShort => '+ طلب';

  @override
  String get requestsOpen => 'الطلبات';

  @override
  String get approvalsTitle => 'للمصادقة';

  @override
  String get approvalsEmpty => 'لا توجد طلبات للمصادقة.';

  @override
  String get requestsViewToFollow => 'قيد المتابعة';

  @override
  String get requestsViewReceived => 'المنتهية';

  @override
  String get requestsViewClosed => 'المرفوضة والملغاة';

  @override
  String get requestsViewArchived => 'المؤرشفة';

  @override
  String get requestsMine => 'طلباتي';

  @override
  String get requestsAll => 'الكل';

  @override
  String get requestsEmpty => 'لا توجد طلبات هنا.';

  @override
  String get requestsSearchHint => 'بحث (DEM-014، إسمنت…)';

  @override
  String get requestPendingSend => 'بانتظار الإرسال';

  @override
  String get requestNeedsCheck => 'للمراجعة';

  @override
  String requestNeededBy(String date) {
    return 'لتاريخ $date';
  }

  @override
  String get requestFormProduct => 'المادة';

  @override
  String get requestFormSearchHint => 'ابحث عن مادة';

  @override
  String get requestFormNoProduct => 'لم يتم العثور على مادة.';

  @override
  String get requestFormTopProducts => 'الأكثر طلبًا';

  @override
  String get requestFormOtherProduct => 'مادة أخرى';

  @override
  String get requestFormFreeName => 'اسم المادة';

  @override
  String get requestFormFreeNameInvalid => 'أدخل من 3 إلى 100 حرف.';

  @override
  String get requestFormQuantity => 'الكمية';

  @override
  String get requestFormUnit => 'الوحدة';

  @override
  String get requestFormZone => 'المنطقة';

  @override
  String get requestFormZoneOther => 'منطقة أخرى';

  @override
  String get requestFormNeededBy => 'لتاريخ';

  @override
  String get requestFormTomorrow => 'غدًا';

  @override
  String requestFormInDays(String days) {
    return '+ $days أيام';
  }

  @override
  String get requestFormNextWeek => 'الأسبوع القادم';

  @override
  String get requestFormOtherDate => 'تاريخ آخر';

  @override
  String get requestFormPriority => 'درجة الاستعجال';

  @override
  String get requestFormNote => 'ملاحظة (اختياري)';

  @override
  String get requestFormSend => 'إرسال';

  @override
  String get requestFormSendAnother => 'إرسال وإضافة مادة أخرى';

  @override
  String get requestFormPastDate => 'هذا التاريخ مضى بالفعل.';

  @override
  String get requestFormSendAnyway => 'إرسال على أي حال';

  @override
  String requestFormDuplicate(String number) {
    return 'الطلب $number مفتوح بالفعل لهذه المادة ولهذه المنطقة.';
  }

  @override
  String get requestFormSeeDuplicate => 'عرض الطلب';

  @override
  String get requestFormOtherRequest => 'إنه طلب آخر';

  @override
  String get requestSaved => 'تم حفظ الطلب. بانتظار الإرسال.';

  @override
  String get requestEditTitle => 'تصحيح الطلب';

  @override
  String get requestEditSave => 'حفظ';

  @override
  String get requestEditNothing => 'لا توجد تعديلات.';

  @override
  String get requestEditProductLocked =>
      'لا يمكن تصحيح المادة: ألغِ الطلب ثم أنشئه من جديد.';

  @override
  String get requestEditBusy =>
      'هذا الإدخال قيد الإرسال. أعد المحاولة بعد لحظة.';

  @override
  String get requestDetailHistory => 'السجل';

  @override
  String requestDetailRequestedBy(String name) {
    return 'طلبها $name';
  }

  @override
  String get requestDetailZone => 'المنطقة';

  @override
  String get requestDetailNote => 'ملاحظة';

  @override
  String get requestDetailReason => 'السبب';

  @override
  String get requestDetailReceived => 'المستلم';

  @override
  String get requestDetailRemaining => 'المتبقي';

  @override
  String get requestDetailVariance => 'الفرق';

  @override
  String requestDetailDuplicate(String number) {
    return 'قد يكون مكررًا للطلب $number';
  }

  @override
  String get requestDetailNotFound => 'لم يعد هذا الطلب على هذا الهاتف.';

  @override
  String requestDetailSavedAt(String when) {
    return 'أُدخل في $when';
  }

  @override
  String get requestZoneNone => 'غير محددة';

  @override
  String get requestActionEdit => 'تصحيح';

  @override
  String get requestActionCancel => 'إلغاء الطلب';

  @override
  String get requestCancelTitle => 'هل تريد إلغاء هذا الطلب؟';

  @override
  String get requestCancelConfirm => 'إلغاء الطلب';

  @override
  String get requestCancelKeep => 'الإبقاء على الطلب';

  @override
  String get requestReasonTitle => 'السبب';

  @override
  String get requestReasonNoteLabel => 'وضّح السبب';

  @override
  String get requestReasonNoteRequired => 'وضّح السبب (أخرى).';

  @override
  String get requestReasonRequired => 'اختر سببًا.';

  @override
  String get requestActionQueued => 'تم الحفظ. بانتظار الإرسال.';

  @override
  String get requestActionAlreadyQueued =>
      'هناك إجراء بانتظار الإرسال لهذا الطلب بالفعل.';

  @override
  String get approvalApprove => 'مصادقة';

  @override
  String get approvalReject => 'رفض';

  @override
  String get approvalAdjust => 'كمية أخرى';

  @override
  String get approvalAdjustTitle => 'المصادقة بكمية أخرى';

  @override
  String get approvalAdjustConfirm => 'المصادقة على هذه الكمية';

  @override
  String get approvalPending => 'المصادقة بانتظار الإرسال';

  @override
  String get approvalRejectTitle => 'رفض الطلب';

  @override
  String get approvalRejectConfirm => 'رفض';

  @override
  String get historyCreated => 'تم إنشاء الطلب';

  @override
  String get historyEdited => 'تم تعديل الطلب';

  @override
  String get historyApproved => 'تمت المصادقة';

  @override
  String get historyQuantityAdjusted => 'تم تعديل الكمية';

  @override
  String get historyRejected => 'تم الرفض';

  @override
  String get historyCancelled => 'تم الإلغاء';

  @override
  String get historyReceived => 'تم الاستلام';

  @override
  String historyStatusChange(String fromStatus, String toStatus) {
    return 'من $fromStatus إلى $toStatus';
  }

  @override
  String historyBy(String name) {
    return 'بواسطة $name';
  }

  @override
  String get fieldQuantity => 'الكمية';

  @override
  String get fieldZone => 'المنطقة';

  @override
  String get fieldNeededBy => 'لتاريخ';

  @override
  String get fieldPriority => 'درجة الاستعجال';

  @override
  String get fieldNote => 'ملاحظة';

  @override
  String get fieldProduct => 'المادة';

  @override
  String fieldChange(String field, String newValue, String oldValue) {
    return '$field: من $oldValue إلى $newValue';
  }

  @override
  String get fieldEmpty => 'فارغ';

  @override
  String get pendingEntityRequest => 'طلب مادة';

  @override
  String get pendingView => 'عرض';

  @override
  String get conflictTitle => 'للمراجعة';

  @override
  String get conflictIntro => 'يحتفظ الخادم بنسخته. لا يُحذف شيء قبل أن تختار.';

  @override
  String get conflictYourVersion => 'نسختك';

  @override
  String get conflictServerVersion => 'نسخة الخادم';

  @override
  String conflictFieldsInDisagreement(String fields) {
    return 'الحقول المتعارضة: $fields';
  }

  @override
  String conflictYourAction(String action) {
    return 'إجراؤك: $action';
  }

  @override
  String get conflictActionApprove => 'مصادقة';

  @override
  String get conflictActionReject => 'رفض';

  @override
  String get conflictActionCancel => 'إلغاء';

  @override
  String get conflictActionReceive => 'استلام';

  @override
  String conflictServerStatus(String status) {
    return 'الحالة على الخادم: $status';
  }

  @override
  String get conflictKeepServer => 'الاحتفاظ بنسخة الخادم';

  @override
  String get conflictRedo => 'إعادة تعديلي';

  @override
  String get conflictCreateNew => 'إنشاء طلب جديد بقيمي';

  @override
  String get conflictCorrect => 'تصحيح إدخالي';

  @override
  String get conflictKeepServerTitle => 'هل تحتفظ بنسخة الخادم؟';

  @override
  String get conflictKeepServerBody =>
      'سيُحذف إدخالك من هذا الهاتف. هذا الإجراء نهائي.';

  @override
  String get conflictGone => 'لم يعد هذا الإدخال بحاجة إلى مراجعة.';

  @override
  String get deliveriesTitle => 'التسليمات';

  @override
  String get toReceiveTitle => 'للاستلام';

  @override
  String get toReceptionTitle => 'للمعاينة والقبول';

  @override
  String get homeDeliveriesTitle => 'التسليمات والاستلام';

  @override
  String get toReceiveEmpty => 'لا توجد طلبيات للاستلام.';

  @override
  String get toReceiveSearchHint => 'بحث (مورّد، مادة، DEM-014)';

  @override
  String toReceiveExpectedOn(String date) {
    return 'موعد التسليم $date';
  }

  @override
  String get toReceiveNoDate => 'موعد التسليم غير محدد';

  @override
  String toReceiveRemaining(String quantity) {
    return 'المتبقي: $quantity';
  }

  @override
  String get toReceiveWithoutRequest => 'تسليم بدون طلب';

  @override
  String get receiveFilterAll => 'الكل';

  @override
  String get receiveFilterToday => 'اليوم';

  @override
  String get receiveFilterWeek => 'هذا الأسبوع';

  @override
  String get receiveFilterLate => 'متأخرة';

  @override
  String get toReceptionEmpty => 'لا توجد طلبات للمعاينة والقبول.';

  @override
  String get toReceptionAction => 'تأكيد الاستلام';

  @override
  String receiveNowPrompt(String number) {
    return '$number تم تسليمها. هل تؤكد الاستلام الآن؟';
  }

  @override
  String get receiveNowYes => 'تأكيد الاستلام';

  @override
  String get receiveNowLater => 'لاحقًا';

  @override
  String get deliveryNewTitle => 'استلام تسليم';

  @override
  String get deliveryNoRequestTitle => 'تسليم بدون طلب';

  @override
  String get deliveryEditTitle => 'تصحيح التسليم';

  @override
  String get deliveryFormSupplier => 'المورّد';

  @override
  String get deliveryFormOtherSupplier => 'مورّد آخر';

  @override
  String get deliveryFormSupplierName => 'اسم المورّد';

  @override
  String get deliveryFormSupplierInvalid => 'أدخل من 3 إلى 100 حرف.';

  @override
  String get deliveryFormQuantity => 'الكمية المستلمة';

  @override
  String get deliveryFormDate => 'تاريخ التسليم';

  @override
  String get deliveryFormToday => 'اليوم';

  @override
  String get deliveryFormYesterday => 'أمس';

  @override
  String get deliveryFormOtherDate => 'تاريخ آخر';

  @override
  String get deliveryFormNote => 'رقم وصل التسليم (اختياري)';

  @override
  String get deliveryFormConformity => 'المطابقة';

  @override
  String get deliveryFormReserveReason => 'سبب التحفظ';

  @override
  String get deliveryFormReserveNote => 'وضّح التحفظ';

  @override
  String get deliveryFormReserveRequired => 'اختر سبب التحفظ.';

  @override
  String get deliveryFormPhotos => 'صور وصل التسليم';

  @override
  String get deliveryFormSave => 'حفظ التسليم';

  @override
  String get deliveryFormBeforeRequest => 'هذا التاريخ سابق للطلب.';

  @override
  String deliveryAnnouncePartial(String quantity) {
    return 'تسليم جزئي: سيتبقى $quantity';
  }

  @override
  String get deliveryAnnounceComplete => 'تسليم كامل';

  @override
  String deliveryAnnounceSurplus(String quantity, String percent) {
    return 'زيادة قدرها +$quantity (+$percent %)';
  }

  @override
  String deliveryDuplicateNote(String number) {
    return 'هذا الوصل مسجّل مسبقًا: $number.';
  }

  @override
  String get deliveryDuplicateSee => 'عرض التسليم';

  @override
  String get deliveryDuplicateOther => 'إنه تسليم آخر';

  @override
  String get deliverySaved => 'تم حفظ التسليم. بانتظار الإرسال.';

  @override
  String get deliveryProductLocked => 'المادة هي مادة الطلب.';

  @override
  String get deliveryProductNeeded => 'اختر المادة.';

  @override
  String get photoAdd => 'تصوير وصل التسليم';

  @override
  String get photoRetake => 'إعادة التصوير';

  @override
  String get photoKeep => 'الاحتفاظ';

  @override
  String photoMax(String max) {
    return '$max صور كحد أقصى.';
  }

  @override
  String photoCountLabel(String count) {
    return 'الصور: $count';
  }

  @override
  String get photoErrorNotImage => 'هذا الملف ليس صورة JPEG.';

  @override
  String get photoErrorTooLarge => 'هذه الصورة ثقيلة جدًا. أعد تصويرها.';

  @override
  String get photoErrorUnreadable => 'الصورة غير مقروءة. أعد تصويرها.';

  @override
  String get photoErrorNoCamera => 'لا توجد كاميرا متاحة.';

  @override
  String get photoPendingSend => 'صورة بانتظار الإرسال';

  @override
  String photoPendingSendCount(String count) {
    return 'صور بانتظار الإرسال ($count)';
  }

  @override
  String get photoUploaded => 'تم إرسالها';

  @override
  String get photoShow => 'عرض الصورة';

  @override
  String get photoHide => 'إخفاء';

  @override
  String get photoNeedsNetwork => 'يلزم اتصال بالشبكة لعرض الصورة.';

  @override
  String get photoNotFound => 'الصورة غير موجودة.';

  @override
  String photoFileProblem(String reason) {
    return 'ملف يحتاج إلى مراجعة: $reason';
  }

  @override
  String get photoAbandon => 'التخلي عن الصورة';

  @override
  String get photoAbandonBody =>
      'ستُحذف هذه الصورة من هذا الهاتف. هذا الإجراء نهائي.';

  @override
  String get deliveriesEmpty => 'لا توجد تسليمات هنا.';

  @override
  String get deliveriesSearchHint => 'بحث (LIV-006، إسمنت…)';

  @override
  String get deliveriesFilterAll => 'الكل';

  @override
  String get deliveriesFilterUnattached => 'غير مرتبطة';

  @override
  String get deliveriesFilterReserve => 'مع تحفظ';

  @override
  String get deliveriesFilterNoteMissing => 'الوصل مفقود';

  @override
  String get deliveryUnattachedBadge => 'غير مرتبطة';

  @override
  String get deliveryNoteMissingBadge => 'الوصل مفقود';

  @override
  String get deliveryDetailNotFound => 'لم يعد هذا التسليم على هذا الهاتف.';

  @override
  String get deliveryDetailQuantity => 'الكمية';

  @override
  String get deliveryDetailInRequest => 'ما يعادلها في الطلب';

  @override
  String get deliveryDetailSupplier => 'المورّد';

  @override
  String get deliveryDetailRequest => 'الطلب';

  @override
  String get deliveryDetailDate => 'تاريخ التسليم';

  @override
  String get deliveryDetailNote => 'وصل رقم';

  @override
  String get deliveryDetailReserve => 'التحفظ';

  @override
  String get deliveryDetailCancelReason => 'سبب الإلغاء';

  @override
  String get deliveryDetailUnattachedReason => 'سبب عدم الارتباط';

  @override
  String get deliveryDetailPhotos => 'صور الوصل';

  @override
  String get deliveryDetailNoPhotos => 'لا توجد صور.';

  @override
  String deliveryDetailSavedAt(String when) {
    return 'أُدخل في $when';
  }

  @override
  String get deliveryActionEdit => 'تصحيح';

  @override
  String get deliveryActionCancel => 'إلغاء التسليم';

  @override
  String get deliveryCancelTitle => 'هل تريد إلغاء هذا التسليم؟';

  @override
  String get deliveryCancelConfirm => 'إلغاء التسليم';

  @override
  String get deliveryAttachInfo =>
      'لربط هذا التسليم بطلب يلزم اتصال بالشبكة: افعل ذلك من المكتب أو عند توفر الاتصال.';

  @override
  String get unattachedNoRequestChosen => 'لم يُختر أي طلب';

  @override
  String get unattachedRequestNotOpen => 'لم يعد الطلب مفتوحًا';

  @override
  String get unattachedRequestMissing => 'الطلب غير موجود';

  @override
  String get requestDetailDeliveries => 'التسليمات';

  @override
  String get requestDetailSupplier => 'المورّد';

  @override
  String requestDetailExpected(String date) {
    return 'التسليم المتوقع في $date';
  }

  @override
  String get requestActionReceive => 'استلام تسليم';

  @override
  String get requestActionReception => 'تأكيد الاستلام';

  @override
  String get supplierCall => 'الاتصال بالمورّد';

  @override
  String get supplierCallNeedsNetwork => 'يلزم اتصال بالشبكة لعرض الرقم.';

  @override
  String get supplierCallNoNumber => 'لا يوجد رقم مسجّل لهذا المورّد.';

  @override
  String supplierCallTitle(String name) {
    return 'المورّد: $name';
  }

  @override
  String get supplierCallDial => 'اتصال';

  @override
  String get supplierCallClose => 'إغلاق';

  @override
  String get supplierCallNoApp => 'تعذّر فتح تطبيق الهاتف.';

  @override
  String get historyDeliveryRegistered => 'تم تسجيل التسليم';

  @override
  String get historyDeliveryEdited => 'تم تصحيح التسليم';

  @override
  String get historyDeliveryCancelled => 'تم إلغاء التسليم';

  @override
  String get historyDeliveryAttached => 'تم ربط التسليم';

  @override
  String get historyStatusRecomputed => 'أُعيد حساب الحالة';

  @override
  String get historyPhotoAdded => 'أُضيفت صورة';

  @override
  String get historyOrdered => 'تم الطلب لدى المورّد';

  @override
  String get fieldDeliveryDate => 'تاريخ التسليم';

  @override
  String get fieldDeliveryNote => 'وصل رقم';

  @override
  String get fieldConformity => 'المطابقة';

  @override
  String get fieldReserveReason => 'سبب التحفظ';

  @override
  String get fieldReserveNote => 'ملاحظة التحفظ';

  @override
  String get pendingEntityDelivery => 'تسليم';

  @override
  String get pendingEntityPhoto => 'صورة الوصل';

  @override
  String get conflictRequestNotComplete =>
      'لم يعد الطلب مكتملًا: لم تُسجَّل معاينتك وقبولك.';

  @override
  String get conflictDeliveryCancelled => 'أُلغي هذا التسليم في هذه الأثناء.';

  @override
  String get conflictDeliveryRequestClosed =>
      'تم قبول استلام الطلب مسبقًا: لا يمكن تعديل تسليماته.';

  @override
  String conflictServerDeliveryStatus(String status) {
    return 'حالة التسليم على الخادم: $status';
  }

  @override
  String conflictYourPhoto(String when) {
    return 'صورة وصل التُقطت في $when';
  }

  @override
  String get pendingPhotosTitle => 'صور بانتظار الإرسال';

  @override
  String get pendingPhotosRefused => 'رفض الخادم هذه الصورة';

  @override
  String get errorErreurTemporaire =>
      'الخادم مشغول لحظة. لم يُسجَّل شيء: أعد المحاولة.';

  @override
  String get historyUnavailableOffline => 'السجل غير متاح دون اتصال.';
}
