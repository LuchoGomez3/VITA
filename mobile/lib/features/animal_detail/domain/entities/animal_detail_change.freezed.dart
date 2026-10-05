// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'animal_detail_change.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AnimalDetailChange {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnimalDetailChange);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AnimalDetailChange()';
}


}

/// @nodoc
class $AnimalDetailChangeCopyWith<$Res>  {
$AnimalDetailChangeCopyWith(AnimalDetailChange _, $Res Function(AnimalDetailChange) __);
}


/// Adds pattern-matching-related methods to [AnimalDetailChange].
extension AnimalDetailChangePatterns on AnimalDetailChange {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( RecordAnimalWeight value)?  weight,TResult Function( ChangeAnimalCategory value)?  category,TResult Function( ChangeAnimalReproduction value)?  reproduction,TResult Function( RecordAnimalDeath value)?  death,TResult Function( UndoAnimalDeath value)?  undoDeath,TResult Function( AddAnimalObservation value)?  observation,required TResult orElse(),}){
final _that = this;
switch (_that) {
case RecordAnimalWeight() when weight != null:
return weight(_that);case ChangeAnimalCategory() when category != null:
return category(_that);case ChangeAnimalReproduction() when reproduction != null:
return reproduction(_that);case RecordAnimalDeath() when death != null:
return death(_that);case UndoAnimalDeath() when undoDeath != null:
return undoDeath(_that);case AddAnimalObservation() when observation != null:
return observation(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( RecordAnimalWeight value)  weight,required TResult Function( ChangeAnimalCategory value)  category,required TResult Function( ChangeAnimalReproduction value)  reproduction,required TResult Function( RecordAnimalDeath value)  death,required TResult Function( UndoAnimalDeath value)  undoDeath,required TResult Function( AddAnimalObservation value)  observation,}){
final _that = this;
switch (_that) {
case RecordAnimalWeight():
return weight(_that);case ChangeAnimalCategory():
return category(_that);case ChangeAnimalReproduction():
return reproduction(_that);case RecordAnimalDeath():
return death(_that);case UndoAnimalDeath():
return undoDeath(_that);case AddAnimalObservation():
return observation(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( RecordAnimalWeight value)?  weight,TResult? Function( ChangeAnimalCategory value)?  category,TResult? Function( ChangeAnimalReproduction value)?  reproduction,TResult? Function( RecordAnimalDeath value)?  death,TResult? Function( UndoAnimalDeath value)?  undoDeath,TResult? Function( AddAnimalObservation value)?  observation,}){
final _that = this;
switch (_that) {
case RecordAnimalWeight() when weight != null:
return weight(_that);case ChangeAnimalCategory() when category != null:
return category(_that);case ChangeAnimalReproduction() when reproduction != null:
return reproduction(_that);case RecordAnimalDeath() when death != null:
return death(_that);case UndoAnimalDeath() when undoDeath != null:
return undoDeath(_that);case AddAnimalObservation() when observation != null:
return observation(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( double weightKg,  DateTime date)?  weight,TResult Function( String categoryId)?  category,TResult Function( AnimalReproductiveStatus? status)?  reproduction,TResult Function()?  death,TResult Function( AnimalStatus previousStatus,  DateTime deathUpdatedAt)?  undoDeath,TResult Function( String text,  DateTime date)?  observation,required TResult orElse(),}) {final _that = this;
switch (_that) {
case RecordAnimalWeight() when weight != null:
return weight(_that.weightKg,_that.date);case ChangeAnimalCategory() when category != null:
return category(_that.categoryId);case ChangeAnimalReproduction() when reproduction != null:
return reproduction(_that.status);case RecordAnimalDeath() when death != null:
return death();case UndoAnimalDeath() when undoDeath != null:
return undoDeath(_that.previousStatus,_that.deathUpdatedAt);case AddAnimalObservation() when observation != null:
return observation(_that.text,_that.date);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( double weightKg,  DateTime date)  weight,required TResult Function( String categoryId)  category,required TResult Function( AnimalReproductiveStatus? status)  reproduction,required TResult Function()  death,required TResult Function( AnimalStatus previousStatus,  DateTime deathUpdatedAt)  undoDeath,required TResult Function( String text,  DateTime date)  observation,}) {final _that = this;
switch (_that) {
case RecordAnimalWeight():
return weight(_that.weightKg,_that.date);case ChangeAnimalCategory():
return category(_that.categoryId);case ChangeAnimalReproduction():
return reproduction(_that.status);case RecordAnimalDeath():
return death();case UndoAnimalDeath():
return undoDeath(_that.previousStatus,_that.deathUpdatedAt);case AddAnimalObservation():
return observation(_that.text,_that.date);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( double weightKg,  DateTime date)?  weight,TResult? Function( String categoryId)?  category,TResult? Function( AnimalReproductiveStatus? status)?  reproduction,TResult? Function()?  death,TResult? Function( AnimalStatus previousStatus,  DateTime deathUpdatedAt)?  undoDeath,TResult? Function( String text,  DateTime date)?  observation,}) {final _that = this;
switch (_that) {
case RecordAnimalWeight() when weight != null:
return weight(_that.weightKg,_that.date);case ChangeAnimalCategory() when category != null:
return category(_that.categoryId);case ChangeAnimalReproduction() when reproduction != null:
return reproduction(_that.status);case RecordAnimalDeath() when death != null:
return death();case UndoAnimalDeath() when undoDeath != null:
return undoDeath(_that.previousStatus,_that.deathUpdatedAt);case AddAnimalObservation() when observation != null:
return observation(_that.text,_that.date);case _:
  return null;

}
}

}

/// @nodoc


class RecordAnimalWeight implements AnimalDetailChange {
  const RecordAnimalWeight({required this.weightKg, required this.date});
  

 final  double weightKg;
 final  DateTime date;

/// Create a copy of AnimalDetailChange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecordAnimalWeightCopyWith<RecordAnimalWeight> get copyWith => _$RecordAnimalWeightCopyWithImpl<RecordAnimalWeight>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecordAnimalWeight&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.date, date) || other.date == date));
}


@override
int get hashCode => Object.hash(runtimeType,weightKg,date);

@override
String toString() {
  return 'AnimalDetailChange.weight(weightKg: $weightKg, date: $date)';
}


}

/// @nodoc
abstract mixin class $RecordAnimalWeightCopyWith<$Res> implements $AnimalDetailChangeCopyWith<$Res> {
  factory $RecordAnimalWeightCopyWith(RecordAnimalWeight value, $Res Function(RecordAnimalWeight) _then) = _$RecordAnimalWeightCopyWithImpl;
@useResult
$Res call({
 double weightKg, DateTime date
});




}
/// @nodoc
class _$RecordAnimalWeightCopyWithImpl<$Res>
    implements $RecordAnimalWeightCopyWith<$Res> {
  _$RecordAnimalWeightCopyWithImpl(this._self, this._then);

  final RecordAnimalWeight _self;
  final $Res Function(RecordAnimalWeight) _then;

/// Create a copy of AnimalDetailChange
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? weightKg = null,Object? date = null,}) {
  return _then(RecordAnimalWeight(
weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc


class ChangeAnimalCategory implements AnimalDetailChange {
  const ChangeAnimalCategory({required this.categoryId});
  

 final  String categoryId;

/// Create a copy of AnimalDetailChange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangeAnimalCategoryCopyWith<ChangeAnimalCategory> get copyWith => _$ChangeAnimalCategoryCopyWithImpl<ChangeAnimalCategory>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangeAnimalCategory&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId));
}


@override
int get hashCode => Object.hash(runtimeType,categoryId);

@override
String toString() {
  return 'AnimalDetailChange.category(categoryId: $categoryId)';
}


}

/// @nodoc
abstract mixin class $ChangeAnimalCategoryCopyWith<$Res> implements $AnimalDetailChangeCopyWith<$Res> {
  factory $ChangeAnimalCategoryCopyWith(ChangeAnimalCategory value, $Res Function(ChangeAnimalCategory) _then) = _$ChangeAnimalCategoryCopyWithImpl;
@useResult
$Res call({
 String categoryId
});




}
/// @nodoc
class _$ChangeAnimalCategoryCopyWithImpl<$Res>
    implements $ChangeAnimalCategoryCopyWith<$Res> {
  _$ChangeAnimalCategoryCopyWithImpl(this._self, this._then);

  final ChangeAnimalCategory _self;
  final $Res Function(ChangeAnimalCategory) _then;

/// Create a copy of AnimalDetailChange
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? categoryId = null,}) {
  return _then(ChangeAnimalCategory(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ChangeAnimalReproduction implements AnimalDetailChange {
  const ChangeAnimalReproduction({required this.status});
  

 final  AnimalReproductiveStatus? status;

/// Create a copy of AnimalDetailChange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangeAnimalReproductionCopyWith<ChangeAnimalReproduction> get copyWith => _$ChangeAnimalReproductionCopyWithImpl<ChangeAnimalReproduction>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangeAnimalReproduction&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,status);

@override
String toString() {
  return 'AnimalDetailChange.reproduction(status: $status)';
}


}

/// @nodoc
abstract mixin class $ChangeAnimalReproductionCopyWith<$Res> implements $AnimalDetailChangeCopyWith<$Res> {
  factory $ChangeAnimalReproductionCopyWith(ChangeAnimalReproduction value, $Res Function(ChangeAnimalReproduction) _then) = _$ChangeAnimalReproductionCopyWithImpl;
@useResult
$Res call({
 AnimalReproductiveStatus? status
});




}
/// @nodoc
class _$ChangeAnimalReproductionCopyWithImpl<$Res>
    implements $ChangeAnimalReproductionCopyWith<$Res> {
  _$ChangeAnimalReproductionCopyWithImpl(this._self, this._then);

  final ChangeAnimalReproduction _self;
  final $Res Function(ChangeAnimalReproduction) _then;

/// Create a copy of AnimalDetailChange
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? status = freezed,}) {
  return _then(ChangeAnimalReproduction(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AnimalReproductiveStatus?,
  ));
}


}

/// @nodoc


class RecordAnimalDeath implements AnimalDetailChange {
  const RecordAnimalDeath();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecordAnimalDeath);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AnimalDetailChange.death()';
}


}




/// @nodoc


class UndoAnimalDeath implements AnimalDetailChange {
  const UndoAnimalDeath({required this.previousStatus, required this.deathUpdatedAt});
  

 final  AnimalStatus previousStatus;
 final  DateTime deathUpdatedAt;

/// Create a copy of AnimalDetailChange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UndoAnimalDeathCopyWith<UndoAnimalDeath> get copyWith => _$UndoAnimalDeathCopyWithImpl<UndoAnimalDeath>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UndoAnimalDeath&&(identical(other.previousStatus, previousStatus) || other.previousStatus == previousStatus)&&(identical(other.deathUpdatedAt, deathUpdatedAt) || other.deathUpdatedAt == deathUpdatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,previousStatus,deathUpdatedAt);

@override
String toString() {
  return 'AnimalDetailChange.undoDeath(previousStatus: $previousStatus, deathUpdatedAt: $deathUpdatedAt)';
}


}

/// @nodoc
abstract mixin class $UndoAnimalDeathCopyWith<$Res> implements $AnimalDetailChangeCopyWith<$Res> {
  factory $UndoAnimalDeathCopyWith(UndoAnimalDeath value, $Res Function(UndoAnimalDeath) _then) = _$UndoAnimalDeathCopyWithImpl;
@useResult
$Res call({
 AnimalStatus previousStatus, DateTime deathUpdatedAt
});




}
/// @nodoc
class _$UndoAnimalDeathCopyWithImpl<$Res>
    implements $UndoAnimalDeathCopyWith<$Res> {
  _$UndoAnimalDeathCopyWithImpl(this._self, this._then);

  final UndoAnimalDeath _self;
  final $Res Function(UndoAnimalDeath) _then;

/// Create a copy of AnimalDetailChange
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? previousStatus = null,Object? deathUpdatedAt = null,}) {
  return _then(UndoAnimalDeath(
previousStatus: null == previousStatus ? _self.previousStatus : previousStatus // ignore: cast_nullable_to_non_nullable
as AnimalStatus,deathUpdatedAt: null == deathUpdatedAt ? _self.deathUpdatedAt : deathUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc


class AddAnimalObservation implements AnimalDetailChange {
  const AddAnimalObservation({required this.text, required this.date});
  

 final  String text;
 final  DateTime date;

/// Create a copy of AnimalDetailChange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddAnimalObservationCopyWith<AddAnimalObservation> get copyWith => _$AddAnimalObservationCopyWithImpl<AddAnimalObservation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddAnimalObservation&&(identical(other.text, text) || other.text == text)&&(identical(other.date, date) || other.date == date));
}


@override
int get hashCode => Object.hash(runtimeType,text,date);

@override
String toString() {
  return 'AnimalDetailChange.observation(text: $text, date: $date)';
}


}

/// @nodoc
abstract mixin class $AddAnimalObservationCopyWith<$Res> implements $AnimalDetailChangeCopyWith<$Res> {
  factory $AddAnimalObservationCopyWith(AddAnimalObservation value, $Res Function(AddAnimalObservation) _then) = _$AddAnimalObservationCopyWithImpl;
@useResult
$Res call({
 String text, DateTime date
});




}
/// @nodoc
class _$AddAnimalObservationCopyWithImpl<$Res>
    implements $AddAnimalObservationCopyWith<$Res> {
  _$AddAnimalObservationCopyWithImpl(this._self, this._then);

  final AddAnimalObservation _self;
  final $Res Function(AddAnimalObservation) _then;

/// Create a copy of AnimalDetailChange
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? text = null,Object? date = null,}) {
  return _then(AddAnimalObservation(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
