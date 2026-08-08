// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'senasa_report_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SenasaReportState {

 ResultState<List<SenasaEstablishment>> get establishments; ResultState<GeneratedSenasaReport> get generation; ResultState<SenasaValidationResult> get validation;
/// Create a copy of SenasaReportState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SenasaReportStateCopyWith<SenasaReportState> get copyWith => _$SenasaReportStateCopyWithImpl<SenasaReportState>(this as SenasaReportState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SenasaReportState&&(identical(other.establishments, establishments) || other.establishments == establishments)&&(identical(other.generation, generation) || other.generation == generation)&&(identical(other.validation, validation) || other.validation == validation));
}


@override
int get hashCode => Object.hash(runtimeType,establishments,generation,validation);

@override
String toString() {
  return 'SenasaReportState(establishments: $establishments, generation: $generation, validation: $validation)';
}


}

/// @nodoc
abstract mixin class $SenasaReportStateCopyWith<$Res>  {
  factory $SenasaReportStateCopyWith(SenasaReportState value, $Res Function(SenasaReportState) _then) = _$SenasaReportStateCopyWithImpl;
@useResult
$Res call({
 ResultState<List<SenasaEstablishment>> establishments, ResultState<GeneratedSenasaReport> generation, ResultState<SenasaValidationResult> validation
});


$ResultStateCopyWith<List<SenasaEstablishment>, $Res> get establishments;$ResultStateCopyWith<GeneratedSenasaReport, $Res> get generation;$ResultStateCopyWith<SenasaValidationResult, $Res> get validation;

}
/// @nodoc
class _$SenasaReportStateCopyWithImpl<$Res>
    implements $SenasaReportStateCopyWith<$Res> {
  _$SenasaReportStateCopyWithImpl(this._self, this._then);

  final SenasaReportState _self;
  final $Res Function(SenasaReportState) _then;

/// Create a copy of SenasaReportState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? establishments = null,Object? generation = null,Object? validation = null,}) {
  return _then(_self.copyWith(
establishments: null == establishments ? _self.establishments : establishments // ignore: cast_nullable_to_non_nullable
as ResultState<List<SenasaEstablishment>>,generation: null == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as ResultState<GeneratedSenasaReport>,validation: null == validation ? _self.validation : validation // ignore: cast_nullable_to_non_nullable
as ResultState<SenasaValidationResult>,
  ));
}
/// Create a copy of SenasaReportState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<List<SenasaEstablishment>, $Res> get establishments {
  
  return $ResultStateCopyWith<List<SenasaEstablishment>, $Res>(_self.establishments, (value) {
    return _then(_self.copyWith(establishments: value));
  });
}/// Create a copy of SenasaReportState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<GeneratedSenasaReport, $Res> get generation {
  
  return $ResultStateCopyWith<GeneratedSenasaReport, $Res>(_self.generation, (value) {
    return _then(_self.copyWith(generation: value));
  });
}/// Create a copy of SenasaReportState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<SenasaValidationResult, $Res> get validation {
  
  return $ResultStateCopyWith<SenasaValidationResult, $Res>(_self.validation, (value) {
    return _then(_self.copyWith(validation: value));
  });
}
}


/// Adds pattern-matching-related methods to [SenasaReportState].
extension SenasaReportStatePatterns on SenasaReportState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SenasaReportState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SenasaReportState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SenasaReportState value)  $default,){
final _that = this;
switch (_that) {
case _SenasaReportState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SenasaReportState value)?  $default,){
final _that = this;
switch (_that) {
case _SenasaReportState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ResultState<List<SenasaEstablishment>> establishments,  ResultState<GeneratedSenasaReport> generation,  ResultState<SenasaValidationResult> validation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SenasaReportState() when $default != null:
return $default(_that.establishments,_that.generation,_that.validation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ResultState<List<SenasaEstablishment>> establishments,  ResultState<GeneratedSenasaReport> generation,  ResultState<SenasaValidationResult> validation)  $default,) {final _that = this;
switch (_that) {
case _SenasaReportState():
return $default(_that.establishments,_that.generation,_that.validation);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ResultState<List<SenasaEstablishment>> establishments,  ResultState<GeneratedSenasaReport> generation,  ResultState<SenasaValidationResult> validation)?  $default,) {final _that = this;
switch (_that) {
case _SenasaReportState() when $default != null:
return $default(_that.establishments,_that.generation,_that.validation);case _:
  return null;

}
}

}

/// @nodoc


class _SenasaReportState implements SenasaReportState {
  const _SenasaReportState({this.establishments = const ResultState<List<SenasaEstablishment>>.initial(), this.generation = const ResultState<GeneratedSenasaReport>.initial(), this.validation = const ResultState<SenasaValidationResult>.initial()});
  

@override@JsonKey() final  ResultState<List<SenasaEstablishment>> establishments;
@override@JsonKey() final  ResultState<GeneratedSenasaReport> generation;
@override@JsonKey() final  ResultState<SenasaValidationResult> validation;

/// Create a copy of SenasaReportState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SenasaReportStateCopyWith<_SenasaReportState> get copyWith => __$SenasaReportStateCopyWithImpl<_SenasaReportState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SenasaReportState&&(identical(other.establishments, establishments) || other.establishments == establishments)&&(identical(other.generation, generation) || other.generation == generation)&&(identical(other.validation, validation) || other.validation == validation));
}


@override
int get hashCode => Object.hash(runtimeType,establishments,generation,validation);

@override
String toString() {
  return 'SenasaReportState(establishments: $establishments, generation: $generation, validation: $validation)';
}


}

/// @nodoc
abstract mixin class _$SenasaReportStateCopyWith<$Res> implements $SenasaReportStateCopyWith<$Res> {
  factory _$SenasaReportStateCopyWith(_SenasaReportState value, $Res Function(_SenasaReportState) _then) = __$SenasaReportStateCopyWithImpl;
@override @useResult
$Res call({
 ResultState<List<SenasaEstablishment>> establishments, ResultState<GeneratedSenasaReport> generation, ResultState<SenasaValidationResult> validation
});


@override $ResultStateCopyWith<List<SenasaEstablishment>, $Res> get establishments;@override $ResultStateCopyWith<GeneratedSenasaReport, $Res> get generation;@override $ResultStateCopyWith<SenasaValidationResult, $Res> get validation;

}
/// @nodoc
class __$SenasaReportStateCopyWithImpl<$Res>
    implements _$SenasaReportStateCopyWith<$Res> {
  __$SenasaReportStateCopyWithImpl(this._self, this._then);

  final _SenasaReportState _self;
  final $Res Function(_SenasaReportState) _then;

/// Create a copy of SenasaReportState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? establishments = null,Object? generation = null,Object? validation = null,}) {
  return _then(_SenasaReportState(
establishments: null == establishments ? _self.establishments : establishments // ignore: cast_nullable_to_non_nullable
as ResultState<List<SenasaEstablishment>>,generation: null == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as ResultState<GeneratedSenasaReport>,validation: null == validation ? _self.validation : validation // ignore: cast_nullable_to_non_nullable
as ResultState<SenasaValidationResult>,
  ));
}

/// Create a copy of SenasaReportState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<List<SenasaEstablishment>, $Res> get establishments {
  
  return $ResultStateCopyWith<List<SenasaEstablishment>, $Res>(_self.establishments, (value) {
    return _then(_self.copyWith(establishments: value));
  });
}/// Create a copy of SenasaReportState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<GeneratedSenasaReport, $Res> get generation {
  
  return $ResultStateCopyWith<GeneratedSenasaReport, $Res>(_self.generation, (value) {
    return _then(_self.copyWith(generation: value));
  });
}/// Create a copy of SenasaReportState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<SenasaValidationResult, $Res> get validation {
  
  return $ResultStateCopyWith<SenasaValidationResult, $Res>(_self.validation, (value) {
    return _then(_self.copyWith(validation: value));
  });
}
}

// dart format on
