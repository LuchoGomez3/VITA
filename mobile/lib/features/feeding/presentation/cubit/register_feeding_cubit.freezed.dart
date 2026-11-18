// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_feeding_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RegisterFeedingState {

 ResultState<FeedingFormData> get preparation; String get establishmentId; List<FeedingAnimal> get animals; List<Food> get foods; List<FeedingLot> get lots; FeedingType get type; String? get foodId; NewFoodInput? get newFood; String? get lotId; String get unitCode; FeedingQuantityBasis get basis; FeedingDuration get duration; DateTime? get startDate; DateTime? get endDate; ResultState<FeedingAnimal> get tagResolution; ResultState<int> get submission;
/// Create a copy of RegisterFeedingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterFeedingStateCopyWith<RegisterFeedingState> get copyWith => _$RegisterFeedingStateCopyWithImpl<RegisterFeedingState>(this as RegisterFeedingState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterFeedingState&&(identical(other.preparation, preparation) || other.preparation == preparation)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&const DeepCollectionEquality().equals(other.animals, animals)&&const DeepCollectionEquality().equals(other.foods, foods)&&const DeepCollectionEquality().equals(other.lots, lots)&&(identical(other.type, type) || other.type == type)&&(identical(other.foodId, foodId) || other.foodId == foodId)&&(identical(other.newFood, newFood) || other.newFood == newFood)&&(identical(other.lotId, lotId) || other.lotId == lotId)&&(identical(other.unitCode, unitCode) || other.unitCode == unitCode)&&(identical(other.basis, basis) || other.basis == basis)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.tagResolution, tagResolution) || other.tagResolution == tagResolution)&&(identical(other.submission, submission) || other.submission == submission));
}


@override
int get hashCode => Object.hash(runtimeType,preparation,establishmentId,const DeepCollectionEquality().hash(animals),const DeepCollectionEquality().hash(foods),const DeepCollectionEquality().hash(lots),type,foodId,newFood,lotId,unitCode,basis,duration,startDate,endDate,tagResolution,submission);

@override
String toString() {
  return 'RegisterFeedingState(preparation: $preparation, establishmentId: $establishmentId, animals: $animals, foods: $foods, lots: $lots, type: $type, foodId: $foodId, newFood: $newFood, lotId: $lotId, unitCode: $unitCode, basis: $basis, duration: $duration, startDate: $startDate, endDate: $endDate, tagResolution: $tagResolution, submission: $submission)';
}


}

/// @nodoc
abstract mixin class $RegisterFeedingStateCopyWith<$Res>  {
  factory $RegisterFeedingStateCopyWith(RegisterFeedingState value, $Res Function(RegisterFeedingState) _then) = _$RegisterFeedingStateCopyWithImpl;
@useResult
$Res call({
 ResultState<FeedingFormData> preparation, String establishmentId, List<FeedingAnimal> animals, List<Food> foods, List<FeedingLot> lots, FeedingType type, String? foodId, NewFoodInput? newFood, String? lotId, String unitCode, FeedingQuantityBasis basis, FeedingDuration duration, DateTime? startDate, DateTime? endDate, ResultState<FeedingAnimal> tagResolution, ResultState<int> submission
});


$ResultStateCopyWith<FeedingFormData, $Res> get preparation;$ResultStateCopyWith<FeedingAnimal, $Res> get tagResolution;$ResultStateCopyWith<int, $Res> get submission;

}
/// @nodoc
class _$RegisterFeedingStateCopyWithImpl<$Res>
    implements $RegisterFeedingStateCopyWith<$Res> {
  _$RegisterFeedingStateCopyWithImpl(this._self, this._then);

  final RegisterFeedingState _self;
  final $Res Function(RegisterFeedingState) _then;

/// Create a copy of RegisterFeedingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? preparation = null,Object? establishmentId = null,Object? animals = null,Object? foods = null,Object? lots = null,Object? type = null,Object? foodId = freezed,Object? newFood = freezed,Object? lotId = freezed,Object? unitCode = null,Object? basis = null,Object? duration = null,Object? startDate = freezed,Object? endDate = freezed,Object? tagResolution = null,Object? submission = null,}) {
  return _then(_self.copyWith(
preparation: null == preparation ? _self.preparation : preparation // ignore: cast_nullable_to_non_nullable
as ResultState<FeedingFormData>,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,animals: null == animals ? _self.animals : animals // ignore: cast_nullable_to_non_nullable
as List<FeedingAnimal>,foods: null == foods ? _self.foods : foods // ignore: cast_nullable_to_non_nullable
as List<Food>,lots: null == lots ? _self.lots : lots // ignore: cast_nullable_to_non_nullable
as List<FeedingLot>,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FeedingType,foodId: freezed == foodId ? _self.foodId : foodId // ignore: cast_nullable_to_non_nullable
as String?,newFood: freezed == newFood ? _self.newFood : newFood // ignore: cast_nullable_to_non_nullable
as NewFoodInput?,lotId: freezed == lotId ? _self.lotId : lotId // ignore: cast_nullable_to_non_nullable
as String?,unitCode: null == unitCode ? _self.unitCode : unitCode // ignore: cast_nullable_to_non_nullable
as String,basis: null == basis ? _self.basis : basis // ignore: cast_nullable_to_non_nullable
as FeedingQuantityBasis,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as FeedingDuration,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,tagResolution: null == tagResolution ? _self.tagResolution : tagResolution // ignore: cast_nullable_to_non_nullable
as ResultState<FeedingAnimal>,submission: null == submission ? _self.submission : submission // ignore: cast_nullable_to_non_nullable
as ResultState<int>,
  ));
}
/// Create a copy of RegisterFeedingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<FeedingFormData, $Res> get preparation {
  
  return $ResultStateCopyWith<FeedingFormData, $Res>(_self.preparation, (value) {
    return _then(_self.copyWith(preparation: value));
  });
}/// Create a copy of RegisterFeedingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<FeedingAnimal, $Res> get tagResolution {
  
  return $ResultStateCopyWith<FeedingAnimal, $Res>(_self.tagResolution, (value) {
    return _then(_self.copyWith(tagResolution: value));
  });
}/// Create a copy of RegisterFeedingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<int, $Res> get submission {
  
  return $ResultStateCopyWith<int, $Res>(_self.submission, (value) {
    return _then(_self.copyWith(submission: value));
  });
}
}


/// Adds pattern-matching-related methods to [RegisterFeedingState].
extension RegisterFeedingStatePatterns on RegisterFeedingState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisterFeedingState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisterFeedingState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisterFeedingState value)  $default,){
final _that = this;
switch (_that) {
case _RegisterFeedingState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisterFeedingState value)?  $default,){
final _that = this;
switch (_that) {
case _RegisterFeedingState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ResultState<FeedingFormData> preparation,  String establishmentId,  List<FeedingAnimal> animals,  List<Food> foods,  List<FeedingLot> lots,  FeedingType type,  String? foodId,  NewFoodInput? newFood,  String? lotId,  String unitCode,  FeedingQuantityBasis basis,  FeedingDuration duration,  DateTime? startDate,  DateTime? endDate,  ResultState<FeedingAnimal> tagResolution,  ResultState<int> submission)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterFeedingState() when $default != null:
return $default(_that.preparation,_that.establishmentId,_that.animals,_that.foods,_that.lots,_that.type,_that.foodId,_that.newFood,_that.lotId,_that.unitCode,_that.basis,_that.duration,_that.startDate,_that.endDate,_that.tagResolution,_that.submission);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ResultState<FeedingFormData> preparation,  String establishmentId,  List<FeedingAnimal> animals,  List<Food> foods,  List<FeedingLot> lots,  FeedingType type,  String? foodId,  NewFoodInput? newFood,  String? lotId,  String unitCode,  FeedingQuantityBasis basis,  FeedingDuration duration,  DateTime? startDate,  DateTime? endDate,  ResultState<FeedingAnimal> tagResolution,  ResultState<int> submission)  $default,) {final _that = this;
switch (_that) {
case _RegisterFeedingState():
return $default(_that.preparation,_that.establishmentId,_that.animals,_that.foods,_that.lots,_that.type,_that.foodId,_that.newFood,_that.lotId,_that.unitCode,_that.basis,_that.duration,_that.startDate,_that.endDate,_that.tagResolution,_that.submission);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ResultState<FeedingFormData> preparation,  String establishmentId,  List<FeedingAnimal> animals,  List<Food> foods,  List<FeedingLot> lots,  FeedingType type,  String? foodId,  NewFoodInput? newFood,  String? lotId,  String unitCode,  FeedingQuantityBasis basis,  FeedingDuration duration,  DateTime? startDate,  DateTime? endDate,  ResultState<FeedingAnimal> tagResolution,  ResultState<int> submission)?  $default,) {final _that = this;
switch (_that) {
case _RegisterFeedingState() when $default != null:
return $default(_that.preparation,_that.establishmentId,_that.animals,_that.foods,_that.lots,_that.type,_that.foodId,_that.newFood,_that.lotId,_that.unitCode,_that.basis,_that.duration,_that.startDate,_that.endDate,_that.tagResolution,_that.submission);case _:
  return null;

}
}

}

/// @nodoc


class _RegisterFeedingState extends RegisterFeedingState {
  const _RegisterFeedingState({this.preparation = const ResultState<FeedingFormData>.initial(), this.establishmentId = '', final  List<FeedingAnimal> animals = const <FeedingAnimal>[], final  List<Food> foods = const <Food>[], final  List<FeedingLot> lots = const <FeedingLot>[], this.type = FeedingType.supplement, this.foodId, this.newFood, this.lotId, this.unitCode = 'kg', this.basis = FeedingQuantityBasis.perAnimalDay, this.duration = FeedingDuration.oneDay, this.startDate, this.endDate, this.tagResolution = const ResultState<FeedingAnimal>.initial(), this.submission = const ResultState<int>.initial()}): _animals = animals,_foods = foods,_lots = lots,super._();
  

@override@JsonKey() final  ResultState<FeedingFormData> preparation;
@override@JsonKey() final  String establishmentId;
 final  List<FeedingAnimal> _animals;
@override@JsonKey() List<FeedingAnimal> get animals {
  if (_animals is EqualUnmodifiableListView) return _animals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_animals);
}

 final  List<Food> _foods;
@override@JsonKey() List<Food> get foods {
  if (_foods is EqualUnmodifiableListView) return _foods;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_foods);
}

 final  List<FeedingLot> _lots;
@override@JsonKey() List<FeedingLot> get lots {
  if (_lots is EqualUnmodifiableListView) return _lots;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lots);
}

@override@JsonKey() final  FeedingType type;
@override final  String? foodId;
@override final  NewFoodInput? newFood;
@override final  String? lotId;
@override@JsonKey() final  String unitCode;
@override@JsonKey() final  FeedingQuantityBasis basis;
@override@JsonKey() final  FeedingDuration duration;
@override final  DateTime? startDate;
@override final  DateTime? endDate;
@override@JsonKey() final  ResultState<FeedingAnimal> tagResolution;
@override@JsonKey() final  ResultState<int> submission;

/// Create a copy of RegisterFeedingState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterFeedingStateCopyWith<_RegisterFeedingState> get copyWith => __$RegisterFeedingStateCopyWithImpl<_RegisterFeedingState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterFeedingState&&(identical(other.preparation, preparation) || other.preparation == preparation)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&const DeepCollectionEquality().equals(other._animals, _animals)&&const DeepCollectionEquality().equals(other._foods, _foods)&&const DeepCollectionEquality().equals(other._lots, _lots)&&(identical(other.type, type) || other.type == type)&&(identical(other.foodId, foodId) || other.foodId == foodId)&&(identical(other.newFood, newFood) || other.newFood == newFood)&&(identical(other.lotId, lotId) || other.lotId == lotId)&&(identical(other.unitCode, unitCode) || other.unitCode == unitCode)&&(identical(other.basis, basis) || other.basis == basis)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.tagResolution, tagResolution) || other.tagResolution == tagResolution)&&(identical(other.submission, submission) || other.submission == submission));
}


@override
int get hashCode => Object.hash(runtimeType,preparation,establishmentId,const DeepCollectionEquality().hash(_animals),const DeepCollectionEquality().hash(_foods),const DeepCollectionEquality().hash(_lots),type,foodId,newFood,lotId,unitCode,basis,duration,startDate,endDate,tagResolution,submission);

@override
String toString() {
  return 'RegisterFeedingState(preparation: $preparation, establishmentId: $establishmentId, animals: $animals, foods: $foods, lots: $lots, type: $type, foodId: $foodId, newFood: $newFood, lotId: $lotId, unitCode: $unitCode, basis: $basis, duration: $duration, startDate: $startDate, endDate: $endDate, tagResolution: $tagResolution, submission: $submission)';
}


}

/// @nodoc
abstract mixin class _$RegisterFeedingStateCopyWith<$Res> implements $RegisterFeedingStateCopyWith<$Res> {
  factory _$RegisterFeedingStateCopyWith(_RegisterFeedingState value, $Res Function(_RegisterFeedingState) _then) = __$RegisterFeedingStateCopyWithImpl;
@override @useResult
$Res call({
 ResultState<FeedingFormData> preparation, String establishmentId, List<FeedingAnimal> animals, List<Food> foods, List<FeedingLot> lots, FeedingType type, String? foodId, NewFoodInput? newFood, String? lotId, String unitCode, FeedingQuantityBasis basis, FeedingDuration duration, DateTime? startDate, DateTime? endDate, ResultState<FeedingAnimal> tagResolution, ResultState<int> submission
});


@override $ResultStateCopyWith<FeedingFormData, $Res> get preparation;@override $ResultStateCopyWith<FeedingAnimal, $Res> get tagResolution;@override $ResultStateCopyWith<int, $Res> get submission;

}
/// @nodoc
class __$RegisterFeedingStateCopyWithImpl<$Res>
    implements _$RegisterFeedingStateCopyWith<$Res> {
  __$RegisterFeedingStateCopyWithImpl(this._self, this._then);

  final _RegisterFeedingState _self;
  final $Res Function(_RegisterFeedingState) _then;

/// Create a copy of RegisterFeedingState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? preparation = null,Object? establishmentId = null,Object? animals = null,Object? foods = null,Object? lots = null,Object? type = null,Object? foodId = freezed,Object? newFood = freezed,Object? lotId = freezed,Object? unitCode = null,Object? basis = null,Object? duration = null,Object? startDate = freezed,Object? endDate = freezed,Object? tagResolution = null,Object? submission = null,}) {
  return _then(_RegisterFeedingState(
preparation: null == preparation ? _self.preparation : preparation // ignore: cast_nullable_to_non_nullable
as ResultState<FeedingFormData>,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,animals: null == animals ? _self._animals : animals // ignore: cast_nullable_to_non_nullable
as List<FeedingAnimal>,foods: null == foods ? _self._foods : foods // ignore: cast_nullable_to_non_nullable
as List<Food>,lots: null == lots ? _self._lots : lots // ignore: cast_nullable_to_non_nullable
as List<FeedingLot>,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FeedingType,foodId: freezed == foodId ? _self.foodId : foodId // ignore: cast_nullable_to_non_nullable
as String?,newFood: freezed == newFood ? _self.newFood : newFood // ignore: cast_nullable_to_non_nullable
as NewFoodInput?,lotId: freezed == lotId ? _self.lotId : lotId // ignore: cast_nullable_to_non_nullable
as String?,unitCode: null == unitCode ? _self.unitCode : unitCode // ignore: cast_nullable_to_non_nullable
as String,basis: null == basis ? _self.basis : basis // ignore: cast_nullable_to_non_nullable
as FeedingQuantityBasis,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as FeedingDuration,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,tagResolution: null == tagResolution ? _self.tagResolution : tagResolution // ignore: cast_nullable_to_non_nullable
as ResultState<FeedingAnimal>,submission: null == submission ? _self.submission : submission // ignore: cast_nullable_to_non_nullable
as ResultState<int>,
  ));
}

/// Create a copy of RegisterFeedingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<FeedingFormData, $Res> get preparation {
  
  return $ResultStateCopyWith<FeedingFormData, $Res>(_self.preparation, (value) {
    return _then(_self.copyWith(preparation: value));
  });
}/// Create a copy of RegisterFeedingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<FeedingAnimal, $Res> get tagResolution {
  
  return $ResultStateCopyWith<FeedingAnimal, $Res>(_self.tagResolution, (value) {
    return _then(_self.copyWith(tagResolution: value));
  });
}/// Create a copy of RegisterFeedingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<int, $Res> get submission {
  
  return $ResultStateCopyWith<int, $Res>(_self.submission, (value) {
    return _then(_self.copyWith(submission: value));
  });
}
}

// dart format on
