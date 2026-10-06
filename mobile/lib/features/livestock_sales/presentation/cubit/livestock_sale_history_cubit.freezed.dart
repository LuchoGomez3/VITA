// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'livestock_sale_history_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LivestockSaleHistoryState {

 ResultState<List<LivestockSale>> get history; ResultState<LivestockSale> get payment;
/// Create a copy of LivestockSaleHistoryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LivestockSaleHistoryStateCopyWith<LivestockSaleHistoryState> get copyWith => _$LivestockSaleHistoryStateCopyWithImpl<LivestockSaleHistoryState>(this as LivestockSaleHistoryState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LivestockSaleHistoryState&&(identical(other.history, history) || other.history == history)&&(identical(other.payment, payment) || other.payment == payment));
}


@override
int get hashCode => Object.hash(runtimeType,history,payment);

@override
String toString() {
  return 'LivestockSaleHistoryState(history: $history, payment: $payment)';
}


}

/// @nodoc
abstract mixin class $LivestockSaleHistoryStateCopyWith<$Res>  {
  factory $LivestockSaleHistoryStateCopyWith(LivestockSaleHistoryState value, $Res Function(LivestockSaleHistoryState) _then) = _$LivestockSaleHistoryStateCopyWithImpl;
@useResult
$Res call({
 ResultState<List<LivestockSale>> history, ResultState<LivestockSale> payment
});


$ResultStateCopyWith<List<LivestockSale>, $Res> get history;$ResultStateCopyWith<LivestockSale, $Res> get payment;

}
/// @nodoc
class _$LivestockSaleHistoryStateCopyWithImpl<$Res>
    implements $LivestockSaleHistoryStateCopyWith<$Res> {
  _$LivestockSaleHistoryStateCopyWithImpl(this._self, this._then);

  final LivestockSaleHistoryState _self;
  final $Res Function(LivestockSaleHistoryState) _then;

/// Create a copy of LivestockSaleHistoryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? history = null,Object? payment = null,}) {
  return _then(_self.copyWith(
history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as ResultState<List<LivestockSale>>,payment: null == payment ? _self.payment : payment // ignore: cast_nullable_to_non_nullable
as ResultState<LivestockSale>,
  ));
}
/// Create a copy of LivestockSaleHistoryState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<List<LivestockSale>, $Res> get history {
  
  return $ResultStateCopyWith<List<LivestockSale>, $Res>(_self.history, (value) {
    return _then(_self.copyWith(history: value));
  });
}/// Create a copy of LivestockSaleHistoryState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<LivestockSale, $Res> get payment {
  
  return $ResultStateCopyWith<LivestockSale, $Res>(_self.payment, (value) {
    return _then(_self.copyWith(payment: value));
  });
}
}


/// Adds pattern-matching-related methods to [LivestockSaleHistoryState].
extension LivestockSaleHistoryStatePatterns on LivestockSaleHistoryState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LivestockSaleHistoryState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LivestockSaleHistoryState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LivestockSaleHistoryState value)  $default,){
final _that = this;
switch (_that) {
case _LivestockSaleHistoryState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LivestockSaleHistoryState value)?  $default,){
final _that = this;
switch (_that) {
case _LivestockSaleHistoryState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ResultState<List<LivestockSale>> history,  ResultState<LivestockSale> payment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LivestockSaleHistoryState() when $default != null:
return $default(_that.history,_that.payment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ResultState<List<LivestockSale>> history,  ResultState<LivestockSale> payment)  $default,) {final _that = this;
switch (_that) {
case _LivestockSaleHistoryState():
return $default(_that.history,_that.payment);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ResultState<List<LivestockSale>> history,  ResultState<LivestockSale> payment)?  $default,) {final _that = this;
switch (_that) {
case _LivestockSaleHistoryState() when $default != null:
return $default(_that.history,_that.payment);case _:
  return null;

}
}

}

/// @nodoc


class _LivestockSaleHistoryState implements LivestockSaleHistoryState {
  const _LivestockSaleHistoryState({this.history = const ResultState<List<LivestockSale>>.initial(), this.payment = const ResultState<LivestockSale>.initial()});
  

@override@JsonKey() final  ResultState<List<LivestockSale>> history;
@override@JsonKey() final  ResultState<LivestockSale> payment;

/// Create a copy of LivestockSaleHistoryState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LivestockSaleHistoryStateCopyWith<_LivestockSaleHistoryState> get copyWith => __$LivestockSaleHistoryStateCopyWithImpl<_LivestockSaleHistoryState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LivestockSaleHistoryState&&(identical(other.history, history) || other.history == history)&&(identical(other.payment, payment) || other.payment == payment));
}


@override
int get hashCode => Object.hash(runtimeType,history,payment);

@override
String toString() {
  return 'LivestockSaleHistoryState(history: $history, payment: $payment)';
}


}

/// @nodoc
abstract mixin class _$LivestockSaleHistoryStateCopyWith<$Res> implements $LivestockSaleHistoryStateCopyWith<$Res> {
  factory _$LivestockSaleHistoryStateCopyWith(_LivestockSaleHistoryState value, $Res Function(_LivestockSaleHistoryState) _then) = __$LivestockSaleHistoryStateCopyWithImpl;
@override @useResult
$Res call({
 ResultState<List<LivestockSale>> history, ResultState<LivestockSale> payment
});


@override $ResultStateCopyWith<List<LivestockSale>, $Res> get history;@override $ResultStateCopyWith<LivestockSale, $Res> get payment;

}
/// @nodoc
class __$LivestockSaleHistoryStateCopyWithImpl<$Res>
    implements _$LivestockSaleHistoryStateCopyWith<$Res> {
  __$LivestockSaleHistoryStateCopyWithImpl(this._self, this._then);

  final _LivestockSaleHistoryState _self;
  final $Res Function(_LivestockSaleHistoryState) _then;

/// Create a copy of LivestockSaleHistoryState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? history = null,Object? payment = null,}) {
  return _then(_LivestockSaleHistoryState(
history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as ResultState<List<LivestockSale>>,payment: null == payment ? _self.payment : payment // ignore: cast_nullable_to_non_nullable
as ResultState<LivestockSale>,
  ));
}

/// Create a copy of LivestockSaleHistoryState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<List<LivestockSale>, $Res> get history {
  
  return $ResultStateCopyWith<List<LivestockSale>, $Res>(_self.history, (value) {
    return _then(_self.copyWith(history: value));
  });
}/// Create a copy of LivestockSaleHistoryState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<LivestockSale, $Res> get payment {
  
  return $ResultStateCopyWith<LivestockSale, $Res>(_self.payment, (value) {
    return _then(_self.copyWith(payment: value));
  });
}
}

// dart format on
