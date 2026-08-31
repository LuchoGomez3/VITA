// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppConfig {

 String get appName; String get environment; String get backendBaseUrl; bool get enableLogs;// TODO(field-sync): habilitar estos flags en builds desplegadas solamente
// después de validar ambos contratos REST y sus pruebas de integración.
 bool get enableLotRemoteSync; bool get enableLotMovementRemoteSync;
/// Create a copy of AppConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppConfigCopyWith<AppConfig> get copyWith => _$AppConfigCopyWithImpl<AppConfig>(this as AppConfig, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppConfig&&(identical(other.appName, appName) || other.appName == appName)&&(identical(other.environment, environment) || other.environment == environment)&&(identical(other.backendBaseUrl, backendBaseUrl) || other.backendBaseUrl == backendBaseUrl)&&(identical(other.enableLogs, enableLogs) || other.enableLogs == enableLogs)&&(identical(other.enableLotRemoteSync, enableLotRemoteSync) || other.enableLotRemoteSync == enableLotRemoteSync)&&(identical(other.enableLotMovementRemoteSync, enableLotMovementRemoteSync) || other.enableLotMovementRemoteSync == enableLotMovementRemoteSync));
}


@override
int get hashCode => Object.hash(runtimeType,appName,environment,backendBaseUrl,enableLogs,enableLotRemoteSync,enableLotMovementRemoteSync);

@override
String toString() {
  return 'AppConfig(appName: $appName, environment: $environment, backendBaseUrl: $backendBaseUrl, enableLogs: $enableLogs, enableLotRemoteSync: $enableLotRemoteSync, enableLotMovementRemoteSync: $enableLotMovementRemoteSync)';
}


}

/// @nodoc
abstract mixin class $AppConfigCopyWith<$Res>  {
  factory $AppConfigCopyWith(AppConfig value, $Res Function(AppConfig) _then) = _$AppConfigCopyWithImpl;
@useResult
$Res call({
 String appName, String environment, String backendBaseUrl, bool enableLogs, bool enableLotRemoteSync, bool enableLotMovementRemoteSync
});




}
/// @nodoc
class _$AppConfigCopyWithImpl<$Res>
    implements $AppConfigCopyWith<$Res> {
  _$AppConfigCopyWithImpl(this._self, this._then);

  final AppConfig _self;
  final $Res Function(AppConfig) _then;

/// Create a copy of AppConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? appName = null,Object? environment = null,Object? backendBaseUrl = null,Object? enableLogs = null,Object? enableLotRemoteSync = null,Object? enableLotMovementRemoteSync = null,}) {
  return _then(_self.copyWith(
appName: null == appName ? _self.appName : appName // ignore: cast_nullable_to_non_nullable
as String,environment: null == environment ? _self.environment : environment // ignore: cast_nullable_to_non_nullable
as String,backendBaseUrl: null == backendBaseUrl ? _self.backendBaseUrl : backendBaseUrl // ignore: cast_nullable_to_non_nullable
as String,enableLogs: null == enableLogs ? _self.enableLogs : enableLogs // ignore: cast_nullable_to_non_nullable
as bool,enableLotRemoteSync: null == enableLotRemoteSync ? _self.enableLotRemoteSync : enableLotRemoteSync // ignore: cast_nullable_to_non_nullable
as bool,enableLotMovementRemoteSync: null == enableLotMovementRemoteSync ? _self.enableLotMovementRemoteSync : enableLotMovementRemoteSync // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AppConfig].
extension AppConfigPatterns on AppConfig {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppConfig() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppConfig value)  $default,){
final _that = this;
switch (_that) {
case _AppConfig():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppConfig value)?  $default,){
final _that = this;
switch (_that) {
case _AppConfig() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String appName,  String environment,  String backendBaseUrl,  bool enableLogs,  bool enableLotRemoteSync,  bool enableLotMovementRemoteSync)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppConfig() when $default != null:
return $default(_that.appName,_that.environment,_that.backendBaseUrl,_that.enableLogs,_that.enableLotRemoteSync,_that.enableLotMovementRemoteSync);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String appName,  String environment,  String backendBaseUrl,  bool enableLogs,  bool enableLotRemoteSync,  bool enableLotMovementRemoteSync)  $default,) {final _that = this;
switch (_that) {
case _AppConfig():
return $default(_that.appName,_that.environment,_that.backendBaseUrl,_that.enableLogs,_that.enableLotRemoteSync,_that.enableLotMovementRemoteSync);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String appName,  String environment,  String backendBaseUrl,  bool enableLogs,  bool enableLotRemoteSync,  bool enableLotMovementRemoteSync)?  $default,) {final _that = this;
switch (_that) {
case _AppConfig() when $default != null:
return $default(_that.appName,_that.environment,_that.backendBaseUrl,_that.enableLogs,_that.enableLotRemoteSync,_that.enableLotMovementRemoteSync);case _:
  return null;

}
}

}

/// @nodoc


class _AppConfig implements AppConfig {
  const _AppConfig({required this.appName, required this.environment, required this.backendBaseUrl, this.enableLogs = true, this.enableLotRemoteSync = const bool.fromEnvironment('VITA_ENABLE_LOT_REMOTE_SYNC'), this.enableLotMovementRemoteSync = const bool.fromEnvironment('VITA_ENABLE_LOT_MOVEMENT_REMOTE_SYNC')});
  

@override final  String appName;
@override final  String environment;
@override final  String backendBaseUrl;
@override@JsonKey() final  bool enableLogs;
// TODO(field-sync): habilitar estos flags en builds desplegadas solamente
// después de validar ambos contratos REST y sus pruebas de integración.
@override@JsonKey() final  bool enableLotRemoteSync;
@override@JsonKey() final  bool enableLotMovementRemoteSync;

/// Create a copy of AppConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppConfigCopyWith<_AppConfig> get copyWith => __$AppConfigCopyWithImpl<_AppConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppConfig&&(identical(other.appName, appName) || other.appName == appName)&&(identical(other.environment, environment) || other.environment == environment)&&(identical(other.backendBaseUrl, backendBaseUrl) || other.backendBaseUrl == backendBaseUrl)&&(identical(other.enableLogs, enableLogs) || other.enableLogs == enableLogs)&&(identical(other.enableLotRemoteSync, enableLotRemoteSync) || other.enableLotRemoteSync == enableLotRemoteSync)&&(identical(other.enableLotMovementRemoteSync, enableLotMovementRemoteSync) || other.enableLotMovementRemoteSync == enableLotMovementRemoteSync));
}


@override
int get hashCode => Object.hash(runtimeType,appName,environment,backendBaseUrl,enableLogs,enableLotRemoteSync,enableLotMovementRemoteSync);

@override
String toString() {
  return 'AppConfig(appName: $appName, environment: $environment, backendBaseUrl: $backendBaseUrl, enableLogs: $enableLogs, enableLotRemoteSync: $enableLotRemoteSync, enableLotMovementRemoteSync: $enableLotMovementRemoteSync)';
}


}

/// @nodoc
abstract mixin class _$AppConfigCopyWith<$Res> implements $AppConfigCopyWith<$Res> {
  factory _$AppConfigCopyWith(_AppConfig value, $Res Function(_AppConfig) _then) = __$AppConfigCopyWithImpl;
@override @useResult
$Res call({
 String appName, String environment, String backendBaseUrl, bool enableLogs, bool enableLotRemoteSync, bool enableLotMovementRemoteSync
});




}
/// @nodoc
class __$AppConfigCopyWithImpl<$Res>
    implements _$AppConfigCopyWith<$Res> {
  __$AppConfigCopyWithImpl(this._self, this._then);

  final _AppConfig _self;
  final $Res Function(_AppConfig) _then;

/// Create a copy of AppConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? appName = null,Object? environment = null,Object? backendBaseUrl = null,Object? enableLogs = null,Object? enableLotRemoteSync = null,Object? enableLotMovementRemoteSync = null,}) {
  return _then(_AppConfig(
appName: null == appName ? _self.appName : appName // ignore: cast_nullable_to_non_nullable
as String,environment: null == environment ? _self.environment : environment // ignore: cast_nullable_to_non_nullable
as String,backendBaseUrl: null == backendBaseUrl ? _self.backendBaseUrl : backendBaseUrl // ignore: cast_nullable_to_non_nullable
as String,enableLogs: null == enableLogs ? _self.enableLogs : enableLogs // ignore: cast_nullable_to_non_nullable
as bool,enableLotRemoteSync: null == enableLotRemoteSync ? _self.enableLotRemoteSync : enableLotRemoteSync // ignore: cast_nullable_to_non_nullable
as bool,enableLotMovementRemoteSync: null == enableLotMovementRemoteSync ? _self.enableLotMovementRemoteSync : enableLotMovementRemoteSync // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
