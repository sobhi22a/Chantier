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
}
