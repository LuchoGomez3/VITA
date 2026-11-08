// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'livestock_sale_amounts.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LivestockSaleAmounts {

 int? get totalCents; int? get initialPaymentCents; int? get pendingCents;
/// Create a copy of LivestockSaleAmounts
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LivestockSaleAmountsCopyWith<LivestockSaleAmounts> get copyWith => _$LivestockSaleAmountsCopyWithImpl<LivestockSaleAmounts>(this as LivestockSaleAmounts, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LivestockSaleAmounts&&(identical(other.totalCents, totalCents) || other.totalCents == totalCents)&&(identical(other.initialPaymentCents, initialPaymentCents) || other.initialPaymentCents == initialPaymentCents)&&(identical(other.pendingCents, pendingCents) || other.pendingCents == pendingCents));
}


@override
int get hashCode => Object.hash(runtimeType,totalCents,initialPaymentCents,pendingCents);

@override
String toString() {
  return 'LivestockSaleAmounts(totalCents: $totalCents, initialPaymentCents: $initialPaymentCents, pendingCents: $pendingCents)';
}


}

/// @nodoc
abstract mixin class $LivestockSaleAmountsCopyWith<$Res>  {
  factory $LivestockSaleAmountsCopyWith(LivestockSaleAmounts value, $Res Function(LivestockSaleAmounts) _then) = _$LivestockSaleAmountsCopyWithImpl;
@useResult
$Res call({
 int? totalCents, int? initialPaymentCents, int? pendingCents
});




}
/// @nodoc
class _$LivestockSaleAmountsCopyWithImpl<$Res>
    implements $LivestockSaleAmountsCopyWith<$Res> {
  _$LivestockSaleAmountsCopyWithImpl(this._self, this._then);

  final LivestockSaleAmounts _self;
  final $Res Function(LivestockSaleAmounts) _then;

/// Create a copy of LivestockSaleAmounts
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalCents = freezed,Object? initialPaymentCents = freezed,Object? pendingCents = freezed,}) {
  return _then(_self.copyWith(
totalCents: freezed == totalCents ? _self.totalCents : totalCents // ignore: cast_nullable_to_non_nullable
as int?,initialPaymentCents: freezed == initialPaymentCents ? _self.initialPaymentCents : initialPaymentCents // ignore: cast_nullable_to_non_nullable
as int?,pendingCents: freezed == pendingCents ? _self.pendingCents : pendingCents // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [LivestockSaleAmounts].
extension LivestockSaleAmountsPatterns on LivestockSaleAmounts {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LivestockSaleAmounts value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LivestockSaleAmounts() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LivestockSaleAmounts value)  $default,){
final _that = this;
switch (_that) {
case _LivestockSaleAmounts():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LivestockSaleAmounts value)?  $default,){
final _that = this;
switch (_that) {
case _LivestockSaleAmounts() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? totalCents,  int? initialPaymentCents,  int? pendingCents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LivestockSaleAmounts() when $default != null:
return $default(_that.totalCents,_that.initialPaymentCents,_that.pendingCents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? totalCents,  int? initialPaymentCents,  int? pendingCents)  $default,) {final _that = this;
switch (_that) {
case _LivestockSaleAmounts():
return $default(_that.totalCents,_that.initialPaymentCents,_that.pendingCents);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? totalCents,  int? initialPaymentCents,  int? pendingCents)?  $default,) {final _that = this;
switch (_that) {
case _LivestockSaleAmounts() when $default != null:
return $default(_that.totalCents,_that.initialPaymentCents,_that.pendingCents);case _:
  return null;

}
}

}

/// @nodoc


class _LivestockSaleAmounts implements LivestockSaleAmounts {
  const _LivestockSaleAmounts({this.totalCents, this.initialPaymentCents, this.pendingCents});
  

@override final  int? totalCents;
@override final  int? initialPaymentCents;
@override final  int? pendingCents;

/// Create a copy of LivestockSaleAmounts
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LivestockSaleAmountsCopyWith<_LivestockSaleAmounts> get copyWith => __$LivestockSaleAmountsCopyWithImpl<_LivestockSaleAmounts>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LivestockSaleAmounts&&(identical(other.totalCents, totalCents) || other.totalCents == totalCents)&&(identical(other.initialPaymentCents, initialPaymentCents) || other.initialPaymentCents == initialPaymentCents)&&(identical(other.pendingCents, pendingCents) || other.pendingCents == pendingCents));
}


@override
int get hashCode => Object.hash(runtimeType,totalCents,initialPaymentCents,pendingCents);

@override
String toString() {
  return 'LivestockSaleAmounts(totalCents: $totalCents, initialPaymentCents: $initialPaymentCents, pendingCents: $pendingCents)';
}


}

/// @nodoc
abstract mixin class _$LivestockSaleAmountsCopyWith<$Res> implements $LivestockSaleAmountsCopyWith<$Res> {
  factory _$LivestockSaleAmountsCopyWith(_LivestockSaleAmounts value, $Res Function(_LivestockSaleAmounts) _then) = __$LivestockSaleAmountsCopyWithImpl;
@override @useResult
$Res call({
 int? totalCents, int? initialPaymentCents, int? pendingCents
});




}
/// @nodoc
class __$LivestockSaleAmountsCopyWithImpl<$Res>
    implements _$LivestockSaleAmountsCopyWith<$Res> {
  __$LivestockSaleAmountsCopyWithImpl(this._self, this._then);

  final _LivestockSaleAmounts _self;
  final $Res Function(_LivestockSaleAmounts) _then;

/// Create a copy of LivestockSaleAmounts
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalCents = freezed,Object? initialPaymentCents = freezed,Object? pendingCents = freezed,}) {
  return _then(_LivestockSaleAmounts(
totalCents: freezed == totalCents ? _self.totalCents : totalCents // ignore: cast_nullable_to_non_nullable
as int?,initialPaymentCents: freezed == initialPaymentCents ? _self.initialPaymentCents : initialPaymentCents // ignore: cast_nullable_to_non_nullable
as int?,pendingCents: freezed == pendingCents ? _self.pendingCents : pendingCents // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
