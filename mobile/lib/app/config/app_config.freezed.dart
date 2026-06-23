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

/// Application display name.
 String get appName;/// Active deployment environment.
 String get environment;/// Root URL for backend API endpoints.
 String get apiBaseUrl;/// Bearer token supplied by the current authenticated session.
 String get apiAccessToken;/// Whether application logs are enabled.
 bool get enableLogs;
/// Create a copy of AppConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppConfigCopyWith<AppConfig> get copyWith => _$AppConfigCopyWithImpl<AppConfig>(this as AppConfig, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppConfig&&(identical(other.appName, appName) || other.appName == appName)&&(identical(other.environment, environment) || other.environment == environment)&&(identical(other.apiBaseUrl, apiBaseUrl) || other.apiBaseUrl == apiBaseUrl)&&(identical(other.apiAccessToken, apiAccessToken) || other.apiAccessToken == apiAccessToken)&&(identical(other.enableLogs, enableLogs) || other.enableLogs == enableLogs));
}


@override
int get hashCode => Object.hash(runtimeType,appName,environment,apiBaseUrl,apiAccessToken,enableLogs);

@override
String toString() {
  return 'AppConfig(appName: $appName, environment: $environment, apiBaseUrl: $apiBaseUrl, apiAccessToken: $apiAccessToken, enableLogs: $enableLogs)';
}


}

/// @nodoc
abstract mixin class $AppConfigCopyWith<$Res>  {
  factory $AppConfigCopyWith(AppConfig value, $Res Function(AppConfig) _then) = _$AppConfigCopyWithImpl;
@useResult
$Res call({
 String appName, String environment, String apiBaseUrl, String apiAccessToken, bool enableLogs
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
@pragma('vm:prefer-inline') @override $Res call({Object? appName = null,Object? environment = null,Object? apiBaseUrl = null,Object? apiAccessToken = null,Object? enableLogs = null,}) {
  return _then(_self.copyWith(
appName: null == appName ? _self.appName : appName // ignore: cast_nullable_to_non_nullable
as String,environment: null == environment ? _self.environment : environment // ignore: cast_nullable_to_non_nullable
as String,apiBaseUrl: null == apiBaseUrl ? _self.apiBaseUrl : apiBaseUrl // ignore: cast_nullable_to_non_nullable
as String,apiAccessToken: null == apiAccessToken ? _self.apiAccessToken : apiAccessToken // ignore: cast_nullable_to_non_nullable
as String,enableLogs: null == enableLogs ? _self.enableLogs : enableLogs // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String appName,  String environment,  String apiBaseUrl,  String apiAccessToken,  bool enableLogs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppConfig() when $default != null:
return $default(_that.appName,_that.environment,_that.apiBaseUrl,_that.apiAccessToken,_that.enableLogs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String appName,  String environment,  String apiBaseUrl,  String apiAccessToken,  bool enableLogs)  $default,) {final _that = this;
switch (_that) {
case _AppConfig():
return $default(_that.appName,_that.environment,_that.apiBaseUrl,_that.apiAccessToken,_that.enableLogs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String appName,  String environment,  String apiBaseUrl,  String apiAccessToken,  bool enableLogs)?  $default,) {final _that = this;
switch (_that) {
case _AppConfig() when $default != null:
return $default(_that.appName,_that.environment,_that.apiBaseUrl,_that.apiAccessToken,_that.enableLogs);case _:
  return null;

}
}

}

/// @nodoc


class _AppConfig implements AppConfig {
  const _AppConfig({required this.appName, required this.environment, required this.apiBaseUrl, required this.apiAccessToken, this.enableLogs = true});
  

/// Application display name.
@override final  String appName;
/// Active deployment environment.
@override final  String environment;
/// Root URL for backend API endpoints.
@override final  String apiBaseUrl;
/// Bearer token supplied by the current authenticated session.
@override final  String apiAccessToken;
/// Whether application logs are enabled.
@override@JsonKey() final  bool enableLogs;

/// Create a copy of AppConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppConfigCopyWith<_AppConfig> get copyWith => __$AppConfigCopyWithImpl<_AppConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppConfig&&(identical(other.appName, appName) || other.appName == appName)&&(identical(other.environment, environment) || other.environment == environment)&&(identical(other.apiBaseUrl, apiBaseUrl) || other.apiBaseUrl == apiBaseUrl)&&(identical(other.apiAccessToken, apiAccessToken) || other.apiAccessToken == apiAccessToken)&&(identical(other.enableLogs, enableLogs) || other.enableLogs == enableLogs));
}


@override
int get hashCode => Object.hash(runtimeType,appName,environment,apiBaseUrl,apiAccessToken,enableLogs);

@override
String toString() {
  return 'AppConfig(appName: $appName, environment: $environment, apiBaseUrl: $apiBaseUrl, apiAccessToken: $apiAccessToken, enableLogs: $enableLogs)';
}


}

/// @nodoc
abstract mixin class _$AppConfigCopyWith<$Res> implements $AppConfigCopyWith<$Res> {
  factory _$AppConfigCopyWith(_AppConfig value, $Res Function(_AppConfig) _then) = __$AppConfigCopyWithImpl;
@override @useResult
$Res call({
 String appName, String environment, String apiBaseUrl, String apiAccessToken, bool enableLogs
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
@override @pragma('vm:prefer-inline') $Res call({Object? appName = null,Object? environment = null,Object? apiBaseUrl = null,Object? apiAccessToken = null,Object? enableLogs = null,}) {
  return _then(_AppConfig(
appName: null == appName ? _self.appName : appName // ignore: cast_nullable_to_non_nullable
as String,environment: null == environment ? _self.environment : environment // ignore: cast_nullable_to_non_nullable
as String,apiBaseUrl: null == apiBaseUrl ? _self.apiBaseUrl : apiBaseUrl // ignore: cast_nullable_to_non_nullable
as String,apiAccessToken: null == apiAccessToken ? _self.apiAccessToken : apiAccessToken // ignore: cast_nullable_to_non_nullable
as String,enableLogs: null == enableLogs ? _self.enableLogs : enableLogs // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
