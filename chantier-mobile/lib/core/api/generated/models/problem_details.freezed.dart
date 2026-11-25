// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'problem_details.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProblemDetails {

/// URI stable du type d'erreur, dérivée de `code`.
 String get type; String get title;/// Code HTTP.
 int get status;/// Code métier stable (`VALIDATION`, `INTROUVABLE`, `ZONE_EXISTANTE`...). Ensemble ouvert : un client ignore un code qu'il ne connaît pas et affiche `title`.
 String get code;/// Identifiant à communiquer au support.
 String get traceId; String? get detail; String? get instance;/// Détail par champ (400 `VALIDATION`) : nom du champ en camelCase, puis les messages.
 Map<String, List<String>>? get errors;/// 409 `CONFLIT_VERSION` : état actuel de la ressource (même JSON que sa réponse REST).
 dynamic get current;
/// Create a copy of ProblemDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProblemDetailsCopyWith<ProblemDetails> get copyWith => _$ProblemDetailsCopyWithImpl<ProblemDetails>(this as ProblemDetails, _$identity);

  /// Serializes this ProblemDetails to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProblemDetails&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.status, status) || other.status == status)&&(identical(other.code, code) || other.code == code)&&(identical(other.traceId, traceId) || other.traceId == traceId)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.instance, instance) || other.instance == instance)&&const DeepCollectionEquality().equals(other.errors, errors)&&const DeepCollectionEquality().equals(other.current, current));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,title,status,code,traceId,detail,instance,const DeepCollectionEquality().hash(errors),const DeepCollectionEquality().hash(current));

@override
String toString() {
  return 'ProblemDetails(type: $type, title: $title, status: $status, code: $code, traceId: $traceId, detail: $detail, instance: $instance, errors: $errors, current: $current)';
}


}

/// @nodoc
abstract mixin class $ProblemDetailsCopyWith<$Res>  {
  factory $ProblemDetailsCopyWith(ProblemDetails value, $Res Function(ProblemDetails) _then) = _$ProblemDetailsCopyWithImpl;
@useResult
$Res call({
 String type, String title, int status, String code, String traceId, String? detail, String? instance, Map<String, List<String>>? errors, dynamic current
});



}
/// @nodoc
class _$ProblemDetailsCopyWithImpl<$Res>
    implements $ProblemDetailsCopyWith<$Res> {
  _$ProblemDetailsCopyWithImpl(this._self, this._then);

  final ProblemDetails _self;
  final $Res Function(ProblemDetails) _then;

/// Create a copy of ProblemDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? title = null,Object? status = null,Object? code = null,Object? traceId = null,Object? detail = freezed,Object? instance = freezed,Object? errors = freezed,Object? current = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,traceId: null == traceId ? _self.traceId : traceId // ignore: cast_nullable_to_non_nullable
as String,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,instance: freezed == instance ? _self.instance : instance // ignore: cast_nullable_to_non_nullable
as String?,errors: freezed == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>?,current: freezed == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _ProblemDetails implements ProblemDetails {
  const _ProblemDetails({required this.type, required this.title, required this.status, required this.code, required this.traceId, this.detail, this.instance, final  Map<String, List<String>>? errors, this.current}): _errors = errors;
  factory _ProblemDetails.fromJson(Map<String, dynamic> json) => _$ProblemDetailsFromJson(json);

/// URI stable du type d'erreur, dérivée de `code`.
@override final  String type;
@override final  String title;
/// Code HTTP.
@override final  int status;
/// Code métier stable (`VALIDATION`, `INTROUVABLE`, `ZONE_EXISTANTE`...). Ensemble ouvert : un client ignore un code qu'il ne connaît pas et affiche `title`.
@override final  String code;
/// Identifiant à communiquer au support.
@override final  String traceId;
@override final  String? detail;
@override final  String? instance;
/// Détail par champ (400 `VALIDATION`) : nom du champ en camelCase, puis les messages.
 final  Map<String, List<String>>? _errors;
/// Détail par champ (400 `VALIDATION`) : nom du champ en camelCase, puis les messages.
@override Map<String, List<String>>? get errors {
  final value = _errors;
  if (value == null) return null;
  if (_errors is EqualUnmodifiableMapView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// 409 `CONFLIT_VERSION` : état actuel de la ressource (même JSON que sa réponse REST).
@override final  dynamic current;

/// Create a copy of ProblemDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProblemDetailsCopyWith<_ProblemDetails> get copyWith => __$ProblemDetailsCopyWithImpl<_ProblemDetails>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProblemDetailsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProblemDetails&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.status, status) || other.status == status)&&(identical(other.code, code) || other.code == code)&&(identical(other.traceId, traceId) || other.traceId == traceId)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.instance, instance) || other.instance == instance)&&const DeepCollectionEquality().equals(other._errors, _errors)&&const DeepCollectionEquality().equals(other.current, current));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,title,status,code,traceId,detail,instance,const DeepCollectionEquality().hash(_errors),const DeepCollectionEquality().hash(current));

@override
String toString() {
  return 'ProblemDetails(type: $type, title: $title, status: $status, code: $code, traceId: $traceId, detail: $detail, instance: $instance, errors: $errors, current: $current)';
}


}

/// @nodoc
abstract mixin class _$ProblemDetailsCopyWith<$Res> implements $ProblemDetailsCopyWith<$Res> {
  factory _$ProblemDetailsCopyWith(_ProblemDetails value, $Res Function(_ProblemDetails) _then) = __$ProblemDetailsCopyWithImpl;
@override @useResult
$Res call({
 String type, String title, int status, String code, String traceId, String? detail, String? instance, Map<String, List<String>>? errors, dynamic current
});



}
/// @nodoc
class __$ProblemDetailsCopyWithImpl<$Res>
    implements _$ProblemDetailsCopyWith<$Res> {
  __$ProblemDetailsCopyWithImpl(this._self, this._then);

  final _ProblemDetails _self;
  final $Res Function(_ProblemDetails) _then;

/// Create a copy of ProblemDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? title = null,Object? status = null,Object? code = null,Object? traceId = null,Object? detail = freezed,Object? instance = freezed,Object? errors = freezed,Object? current = freezed,}) {
  return _then(_ProblemDetails(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,traceId: null == traceId ? _self.traceId : traceId // ignore: cast_nullable_to_non_nullable
as String,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,instance: freezed == instance ? _self.instance : instance // ignore: cast_nullable_to_non_nullable
as String?,errors: freezed == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>?,current: freezed == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}

// dart format on
