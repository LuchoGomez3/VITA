// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'senasa_menu_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SenasaMenuState {

 ResultState<List<SenasaEstablishment>> get establishments; ResultState<List<SenasaExportHistoryItem>> get history; ResultState<GeneratedSenasaReport> get download; String? get selectedEstablishmentId;
/// Create a copy of SenasaMenuState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SenasaMenuStateCopyWith<SenasaMenuState> get copyWith => _$SenasaMenuStateCopyWithImpl<SenasaMenuState>(this as SenasaMenuState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SenasaMenuState&&(identical(other.establishments, establishments) || other.establishments == establishments)&&(identical(other.history, history) || other.history == history)&&(identical(other.download, download) || other.download == download)&&(identical(other.selectedEstablishmentId, selectedEstablishmentId) || other.selectedEstablishmentId == selectedEstablishmentId));
}


@override
int get hashCode => Object.hash(runtimeType,establishments,history,download,selectedEstablishmentId);

@override
String toString() {
  return 'SenasaMenuState(establishments: $establishments, history: $history, download: $download, selectedEstablishmentId: $selectedEstablishmentId)';
}


}

/// @nodoc
abstract mixin class $SenasaMenuStateCopyWith<$Res>  {
  factory $SenasaMenuStateCopyWith(SenasaMenuState value, $Res Function(SenasaMenuState) _then) = _$SenasaMenuStateCopyWithImpl;
@useResult
$Res call({
 ResultState<List<SenasaEstablishment>> establishments, ResultState<List<SenasaExportHistoryItem>> history, ResultState<GeneratedSenasaReport> download, String? selectedEstablishmentId
});


$ResultStateCopyWith<List<SenasaEstablishment>, $Res> get establishments;$ResultStateCopyWith<List<SenasaExportHistoryItem>, $Res> get history;$ResultStateCopyWith<GeneratedSenasaReport, $Res> get download;

}
/// @nodoc
class _$SenasaMenuStateCopyWithImpl<$Res>
    implements $SenasaMenuStateCopyWith<$Res> {
  _$SenasaMenuStateCopyWithImpl(this._self, this._then);

  final SenasaMenuState _self;
  final $Res Function(SenasaMenuState) _then;

/// Create a copy of SenasaMenuState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? establishments = null,Object? history = null,Object? download = null,Object? selectedEstablishmentId = freezed,}) {
  return _then(_self.copyWith(
establishments: null == establishments ? _self.establishments : establishments // ignore: cast_nullable_to_non_nullable
as ResultState<List<SenasaEstablishment>>,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as ResultState<List<SenasaExportHistoryItem>>,download: null == download ? _self.download : download // ignore: cast_nullable_to_non_nullable
as ResultState<GeneratedSenasaReport>,selectedEstablishmentId: freezed == selectedEstablishmentId ? _self.selectedEstablishmentId : selectedEstablishmentId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of SenasaMenuState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<List<SenasaEstablishment>, $Res> get establishments {
  
  return $ResultStateCopyWith<List<SenasaEstablishment>, $Res>(_self.establishments, (value) {
    return _then(_self.copyWith(establishments: value));
  });
}/// Create a copy of SenasaMenuState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<List<SenasaExportHistoryItem>, $Res> get history {
  
  return $ResultStateCopyWith<List<SenasaExportHistoryItem>, $Res>(_self.history, (value) {
    return _then(_self.copyWith(history: value));
  });
}/// Create a copy of SenasaMenuState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<GeneratedSenasaReport, $Res> get download {
  
  return $ResultStateCopyWith<GeneratedSenasaReport, $Res>(_self.download, (value) {
    return _then(_self.copyWith(download: value));
  });
}
}


/// Adds pattern-matching-related methods to [SenasaMenuState].
extension SenasaMenuStatePatterns on SenasaMenuState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SenasaMenuState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SenasaMenuState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SenasaMenuState value)  $default,){
final _that = this;
switch (_that) {
case _SenasaMenuState():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SenasaMenuState value)?  $default,){
final _that = this;
switch (_that) {
case _SenasaMenuState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ResultState<List<SenasaEstablishment>> establishments,  ResultState<List<SenasaExportHistoryItem>> history,  ResultState<GeneratedSenasaReport> download,  String? selectedEstablishmentId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SenasaMenuState() when $default != null:
return $default(_that.establishments,_that.history,_that.download,_that.selectedEstablishmentId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ResultState<List<SenasaEstablishment>> establishments,  ResultState<List<SenasaExportHistoryItem>> history,  ResultState<GeneratedSenasaReport> download,  String? selectedEstablishmentId)  $default,) {final _that = this;
switch (_that) {
case _SenasaMenuState():
return $default(_that.establishments,_that.history,_that.download,_that.selectedEstablishmentId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ResultState<List<SenasaEstablishment>> establishments,  ResultState<List<SenasaExportHistoryItem>> history,  ResultState<GeneratedSenasaReport> download,  String? selectedEstablishmentId)?  $default,) {final _that = this;
switch (_that) {
case _SenasaMenuState() when $default != null:
return $default(_that.establishments,_that.history,_that.download,_that.selectedEstablishmentId);case _:
  return null;

}
}

}

/// @nodoc


class _SenasaMenuState implements SenasaMenuState {
  const _SenasaMenuState({this.establishments = const ResultState<List<SenasaEstablishment>>.initial(), this.history = const ResultState<List<SenasaExportHistoryItem>>.initial(), this.download = const ResultState<GeneratedSenasaReport>.initial(), this.selectedEstablishmentId});
  

@override@JsonKey() final  ResultState<List<SenasaEstablishment>> establishments;
@override@JsonKey() final  ResultState<List<SenasaExportHistoryItem>> history;
@override@JsonKey() final  ResultState<GeneratedSenasaReport> download;
@override final  String? selectedEstablishmentId;

/// Create a copy of SenasaMenuState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SenasaMenuStateCopyWith<_SenasaMenuState> get copyWith => __$SenasaMenuStateCopyWithImpl<_SenasaMenuState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SenasaMenuState&&(identical(other.establishments, establishments) || other.establishments == establishments)&&(identical(other.history, history) || other.history == history)&&(identical(other.download, download) || other.download == download)&&(identical(other.selectedEstablishmentId, selectedEstablishmentId) || other.selectedEstablishmentId == selectedEstablishmentId));
}


@override
int get hashCode => Object.hash(runtimeType,establishments,history,download,selectedEstablishmentId);

@override
String toString() {
  return 'SenasaMenuState(establishments: $establishments, history: $history, download: $download, selectedEstablishmentId: $selectedEstablishmentId)';
}


}

/// @nodoc
abstract mixin class _$SenasaMenuStateCopyWith<$Res> implements $SenasaMenuStateCopyWith<$Res> {
  factory _$SenasaMenuStateCopyWith(_SenasaMenuState value, $Res Function(_SenasaMenuState) _then) = __$SenasaMenuStateCopyWithImpl;
@override @useResult
$Res call({
 ResultState<List<SenasaEstablishment>> establishments, ResultState<List<SenasaExportHistoryItem>> history, ResultState<GeneratedSenasaReport> download, String? selectedEstablishmentId
});


@override $ResultStateCopyWith<List<SenasaEstablishment>, $Res> get establishments;@override $ResultStateCopyWith<List<SenasaExportHistoryItem>, $Res> get history;@override $ResultStateCopyWith<GeneratedSenasaReport, $Res> get download;

}
/// @nodoc
class __$SenasaMenuStateCopyWithImpl<$Res>
    implements _$SenasaMenuStateCopyWith<$Res> {
  __$SenasaMenuStateCopyWithImpl(this._self, this._then);

  final _SenasaMenuState _self;
  final $Res Function(_SenasaMenuState) _then;

/// Create a copy of SenasaMenuState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? establishments = null,Object? history = null,Object? download = null,Object? selectedEstablishmentId = freezed,}) {
  return _then(_SenasaMenuState(
establishments: null == establishments ? _self.establishments : establishments // ignore: cast_nullable_to_non_nullable
as ResultState<List<SenasaEstablishment>>,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as ResultState<List<SenasaExportHistoryItem>>,download: null == download ? _self.download : download // ignore: cast_nullable_to_non_nullable
as ResultState<GeneratedSenasaReport>,selectedEstablishmentId: freezed == selectedEstablishmentId ? _self.selectedEstablishmentId : selectedEstablishmentId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of SenasaMenuState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<List<SenasaEstablishment>, $Res> get establishments {
  
  return $ResultStateCopyWith<List<SenasaEstablishment>, $Res>(_self.establishments, (value) {
    return _then(_self.copyWith(establishments: value));
  });
}/// Create a copy of SenasaMenuState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<List<SenasaExportHistoryItem>, $Res> get history {
  
  return $ResultStateCopyWith<List<SenasaExportHistoryItem>, $Res>(_self.history, (value) {
    return _then(_self.copyWith(history: value));
  });
}/// Create a copy of SenasaMenuState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<GeneratedSenasaReport, $Res> get download {
  
  return $ResultStateCopyWith<GeneratedSenasaReport, $Res>(_self.download, (value) {
    return _then(_self.copyWith(download: value));
  });
}
}

// dart format on
