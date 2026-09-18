// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_animal_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RegisterAnimalEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterAnimalEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RegisterAnimalEvent()';
}


}

/// @nodoc
class $RegisterAnimalEventCopyWith<$Res>  {
$RegisterAnimalEventCopyWith(RegisterAnimalEvent _, $Res Function(RegisterAnimalEvent) __);
}


/// Adds pattern-matching-related methods to [RegisterAnimalEvent].
extension RegisterAnimalEventPatterns on RegisterAnimalEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _ParentsRequested value)?  parentsRequested,TResult Function( _CategoriesRequested value)?  categoriesRequested,TResult Function( _EstablishmentsRequested value)?  establishmentsRequested,TResult Function( _EstablishmentSelected value)?  establishmentSelected,TResult Function( _DraftChanged value)?  draftChanged,TResult Function( _NextStepRequested value)?  nextStepRequested,TResult Function( _PreviousStepRequested value)?  previousStepRequested,TResult Function( _StepRequested value)?  stepRequested,TResult Function( _SubmitRequested value)?  submitRequested,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParentsRequested() when parentsRequested != null:
return parentsRequested(_that);case _CategoriesRequested() when categoriesRequested != null:
return categoriesRequested(_that);case _EstablishmentsRequested() when establishmentsRequested != null:
return establishmentsRequested(_that);case _EstablishmentSelected() when establishmentSelected != null:
return establishmentSelected(_that);case _DraftChanged() when draftChanged != null:
return draftChanged(_that);case _NextStepRequested() when nextStepRequested != null:
return nextStepRequested(_that);case _PreviousStepRequested() when previousStepRequested != null:
return previousStepRequested(_that);case _StepRequested() when stepRequested != null:
return stepRequested(_that);case _SubmitRequested() when submitRequested != null:
return submitRequested(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _ParentsRequested value)  parentsRequested,required TResult Function( _CategoriesRequested value)  categoriesRequested,required TResult Function( _EstablishmentsRequested value)  establishmentsRequested,required TResult Function( _EstablishmentSelected value)  establishmentSelected,required TResult Function( _DraftChanged value)  draftChanged,required TResult Function( _NextStepRequested value)  nextStepRequested,required TResult Function( _PreviousStepRequested value)  previousStepRequested,required TResult Function( _StepRequested value)  stepRequested,required TResult Function( _SubmitRequested value)  submitRequested,}){
final _that = this;
switch (_that) {
case _ParentsRequested():
return parentsRequested(_that);case _CategoriesRequested():
return categoriesRequested(_that);case _EstablishmentsRequested():
return establishmentsRequested(_that);case _EstablishmentSelected():
return establishmentSelected(_that);case _DraftChanged():
return draftChanged(_that);case _NextStepRequested():
return nextStepRequested(_that);case _PreviousStepRequested():
return previousStepRequested(_that);case _StepRequested():
return stepRequested(_that);case _SubmitRequested():
return submitRequested(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _ParentsRequested value)?  parentsRequested,TResult? Function( _CategoriesRequested value)?  categoriesRequested,TResult? Function( _EstablishmentsRequested value)?  establishmentsRequested,TResult? Function( _EstablishmentSelected value)?  establishmentSelected,TResult? Function( _DraftChanged value)?  draftChanged,TResult? Function( _NextStepRequested value)?  nextStepRequested,TResult? Function( _PreviousStepRequested value)?  previousStepRequested,TResult? Function( _StepRequested value)?  stepRequested,TResult? Function( _SubmitRequested value)?  submitRequested,}){
final _that = this;
switch (_that) {
case _ParentsRequested() when parentsRequested != null:
return parentsRequested(_that);case _CategoriesRequested() when categoriesRequested != null:
return categoriesRequested(_that);case _EstablishmentsRequested() when establishmentsRequested != null:
return establishmentsRequested(_that);case _EstablishmentSelected() when establishmentSelected != null:
return establishmentSelected(_that);case _DraftChanged() when draftChanged != null:
return draftChanged(_that);case _NextStepRequested() when nextStepRequested != null:
return nextStepRequested(_that);case _PreviousStepRequested() when previousStepRequested != null:
return previousStepRequested(_that);case _StepRequested() when stepRequested != null:
return stepRequested(_that);case _SubmitRequested() when submitRequested != null:
return submitRequested(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  parentsRequested,TResult Function()?  categoriesRequested,TResult Function()?  establishmentsRequested,TResult Function( String establishmentId)?  establishmentSelected,TResult Function( RegisterAnimalDraft draft)?  draftChanged,TResult Function()?  nextStepRequested,TResult Function()?  previousStepRequested,TResult Function( RegisterAnimalStep step)?  stepRequested,TResult Function()?  submitRequested,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParentsRequested() when parentsRequested != null:
return parentsRequested();case _CategoriesRequested() when categoriesRequested != null:
return categoriesRequested();case _EstablishmentsRequested() when establishmentsRequested != null:
return establishmentsRequested();case _EstablishmentSelected() when establishmentSelected != null:
return establishmentSelected(_that.establishmentId);case _DraftChanged() when draftChanged != null:
return draftChanged(_that.draft);case _NextStepRequested() when nextStepRequested != null:
return nextStepRequested();case _PreviousStepRequested() when previousStepRequested != null:
return previousStepRequested();case _StepRequested() when stepRequested != null:
return stepRequested(_that.step);case _SubmitRequested() when submitRequested != null:
return submitRequested();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  parentsRequested,required TResult Function()  categoriesRequested,required TResult Function()  establishmentsRequested,required TResult Function( String establishmentId)  establishmentSelected,required TResult Function( RegisterAnimalDraft draft)  draftChanged,required TResult Function()  nextStepRequested,required TResult Function()  previousStepRequested,required TResult Function( RegisterAnimalStep step)  stepRequested,required TResult Function()  submitRequested,}) {final _that = this;
switch (_that) {
case _ParentsRequested():
return parentsRequested();case _CategoriesRequested():
return categoriesRequested();case _EstablishmentsRequested():
return establishmentsRequested();case _EstablishmentSelected():
return establishmentSelected(_that.establishmentId);case _DraftChanged():
return draftChanged(_that.draft);case _NextStepRequested():
return nextStepRequested();case _PreviousStepRequested():
return previousStepRequested();case _StepRequested():
return stepRequested(_that.step);case _SubmitRequested():
return submitRequested();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  parentsRequested,TResult? Function()?  categoriesRequested,TResult? Function()?  establishmentsRequested,TResult? Function( String establishmentId)?  establishmentSelected,TResult? Function( RegisterAnimalDraft draft)?  draftChanged,TResult? Function()?  nextStepRequested,TResult? Function()?  previousStepRequested,TResult? Function( RegisterAnimalStep step)?  stepRequested,TResult? Function()?  submitRequested,}) {final _that = this;
switch (_that) {
case _ParentsRequested() when parentsRequested != null:
return parentsRequested();case _CategoriesRequested() when categoriesRequested != null:
return categoriesRequested();case _EstablishmentsRequested() when establishmentsRequested != null:
return establishmentsRequested();case _EstablishmentSelected() when establishmentSelected != null:
return establishmentSelected(_that.establishmentId);case _DraftChanged() when draftChanged != null:
return draftChanged(_that.draft);case _NextStepRequested() when nextStepRequested != null:
return nextStepRequested();case _PreviousStepRequested() when previousStepRequested != null:
return previousStepRequested();case _StepRequested() when stepRequested != null:
return stepRequested(_that.step);case _SubmitRequested() when submitRequested != null:
return submitRequested();case _:
  return null;

}
}

}

/// @nodoc


class _ParentsRequested implements RegisterAnimalEvent {
  const _ParentsRequested();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParentsRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RegisterAnimalEvent.parentsRequested()';
}


}




/// @nodoc


class _CategoriesRequested implements RegisterAnimalEvent {
  const _CategoriesRequested();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoriesRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RegisterAnimalEvent.categoriesRequested()';
}


}




/// @nodoc


class _EstablishmentsRequested implements RegisterAnimalEvent {
  const _EstablishmentsRequested();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EstablishmentsRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RegisterAnimalEvent.establishmentsRequested()';
}


}




/// @nodoc


class _EstablishmentSelected implements RegisterAnimalEvent {
  const _EstablishmentSelected(this.establishmentId);
  

 final  String establishmentId;

/// Create a copy of RegisterAnimalEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EstablishmentSelectedCopyWith<_EstablishmentSelected> get copyWith => __$EstablishmentSelectedCopyWithImpl<_EstablishmentSelected>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EstablishmentSelected&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId));
}


@override
int get hashCode => Object.hash(runtimeType,establishmentId);

@override
String toString() {
  return 'RegisterAnimalEvent.establishmentSelected(establishmentId: $establishmentId)';
}


}

/// @nodoc
abstract mixin class _$EstablishmentSelectedCopyWith<$Res> implements $RegisterAnimalEventCopyWith<$Res> {
  factory _$EstablishmentSelectedCopyWith(_EstablishmentSelected value, $Res Function(_EstablishmentSelected) _then) = __$EstablishmentSelectedCopyWithImpl;
@useResult
$Res call({
 String establishmentId
});




}
/// @nodoc
class __$EstablishmentSelectedCopyWithImpl<$Res>
    implements _$EstablishmentSelectedCopyWith<$Res> {
  __$EstablishmentSelectedCopyWithImpl(this._self, this._then);

  final _EstablishmentSelected _self;
  final $Res Function(_EstablishmentSelected) _then;

/// Create a copy of RegisterAnimalEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? establishmentId = null,}) {
  return _then(_EstablishmentSelected(
null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _DraftChanged implements RegisterAnimalEvent {
  const _DraftChanged(this.draft);
  

 final  RegisterAnimalDraft draft;

/// Create a copy of RegisterAnimalEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DraftChangedCopyWith<_DraftChanged> get copyWith => __$DraftChangedCopyWithImpl<_DraftChanged>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DraftChanged&&(identical(other.draft, draft) || other.draft == draft));
}


@override
int get hashCode => Object.hash(runtimeType,draft);

@override
String toString() {
  return 'RegisterAnimalEvent.draftChanged(draft: $draft)';
}


}

/// @nodoc
abstract mixin class _$DraftChangedCopyWith<$Res> implements $RegisterAnimalEventCopyWith<$Res> {
  factory _$DraftChangedCopyWith(_DraftChanged value, $Res Function(_DraftChanged) _then) = __$DraftChangedCopyWithImpl;
@useResult
$Res call({
 RegisterAnimalDraft draft
});


$RegisterAnimalDraftCopyWith<$Res> get draft;

}
/// @nodoc
class __$DraftChangedCopyWithImpl<$Res>
    implements _$DraftChangedCopyWith<$Res> {
  __$DraftChangedCopyWithImpl(this._self, this._then);

  final _DraftChanged _self;
  final $Res Function(_DraftChanged) _then;

/// Create a copy of RegisterAnimalEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? draft = null,}) {
  return _then(_DraftChanged(
null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as RegisterAnimalDraft,
  ));
}

/// Create a copy of RegisterAnimalEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RegisterAnimalDraftCopyWith<$Res> get draft {
  
  return $RegisterAnimalDraftCopyWith<$Res>(_self.draft, (value) {
    return _then(_self.copyWith(draft: value));
  });
}
}

/// @nodoc


class _NextStepRequested implements RegisterAnimalEvent {
  const _NextStepRequested();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NextStepRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RegisterAnimalEvent.nextStepRequested()';
}


}




/// @nodoc


class _PreviousStepRequested implements RegisterAnimalEvent {
  const _PreviousStepRequested();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PreviousStepRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RegisterAnimalEvent.previousStepRequested()';
}


}




/// @nodoc


class _StepRequested implements RegisterAnimalEvent {
  const _StepRequested(this.step);
  

 final  RegisterAnimalStep step;

/// Create a copy of RegisterAnimalEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StepRequestedCopyWith<_StepRequested> get copyWith => __$StepRequestedCopyWithImpl<_StepRequested>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StepRequested&&(identical(other.step, step) || other.step == step));
}


@override
int get hashCode => Object.hash(runtimeType,step);

@override
String toString() {
  return 'RegisterAnimalEvent.stepRequested(step: $step)';
}


}

/// @nodoc
abstract mixin class _$StepRequestedCopyWith<$Res> implements $RegisterAnimalEventCopyWith<$Res> {
  factory _$StepRequestedCopyWith(_StepRequested value, $Res Function(_StepRequested) _then) = __$StepRequestedCopyWithImpl;
@useResult
$Res call({
 RegisterAnimalStep step
});




}
/// @nodoc
class __$StepRequestedCopyWithImpl<$Res>
    implements _$StepRequestedCopyWith<$Res> {
  __$StepRequestedCopyWithImpl(this._self, this._then);

  final _StepRequested _self;
  final $Res Function(_StepRequested) _then;

/// Create a copy of RegisterAnimalEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? step = null,}) {
  return _then(_StepRequested(
null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as RegisterAnimalStep,
  ));
}


}

/// @nodoc


class _SubmitRequested implements RegisterAnimalEvent {
  const _SubmitRequested();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubmitRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RegisterAnimalEvent.submitRequested()';
}


}




/// @nodoc
mixin _$RegisterAnimalDraft {

 String get rfid; String get visualTagSeries; String get visualTagNumber; String get breed; String get sex; DateTime get birthDate; String get birthWeight; String? get categoryId; String? get categoryName; String? get establishmentId; String? get establishmentName; AnimalParent? get mother; AnimalParent? get father; String? get destinationId;
/// Create a copy of RegisterAnimalDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterAnimalDraftCopyWith<RegisterAnimalDraft> get copyWith => _$RegisterAnimalDraftCopyWithImpl<RegisterAnimalDraft>(this as RegisterAnimalDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterAnimalDraft&&(identical(other.rfid, rfid) || other.rfid == rfid)&&(identical(other.visualTagSeries, visualTagSeries) || other.visualTagSeries == visualTagSeries)&&(identical(other.visualTagNumber, visualTagNumber) || other.visualTagNumber == visualTagNumber)&&(identical(other.breed, breed) || other.breed == breed)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.birthWeight, birthWeight) || other.birthWeight == birthWeight)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.establishmentName, establishmentName) || other.establishmentName == establishmentName)&&(identical(other.mother, mother) || other.mother == mother)&&(identical(other.father, father) || other.father == father)&&(identical(other.destinationId, destinationId) || other.destinationId == destinationId));
}


@override
int get hashCode => Object.hash(runtimeType,rfid,visualTagSeries,visualTagNumber,breed,sex,birthDate,birthWeight,categoryId,categoryName,establishmentId,establishmentName,mother,father,destinationId);

@override
String toString() {
  return 'RegisterAnimalDraft(rfid: $rfid, visualTagSeries: $visualTagSeries, visualTagNumber: $visualTagNumber, breed: $breed, sex: $sex, birthDate: $birthDate, birthWeight: $birthWeight, categoryId: $categoryId, categoryName: $categoryName, establishmentId: $establishmentId, establishmentName: $establishmentName, mother: $mother, father: $father, destinationId: $destinationId)';
}


}

/// @nodoc
abstract mixin class $RegisterAnimalDraftCopyWith<$Res>  {
  factory $RegisterAnimalDraftCopyWith(RegisterAnimalDraft value, $Res Function(RegisterAnimalDraft) _then) = _$RegisterAnimalDraftCopyWithImpl;
@useResult
$Res call({
 String rfid, String visualTagSeries, String visualTagNumber, String breed, String sex, DateTime birthDate, String birthWeight, String? categoryId, String? categoryName, String? establishmentId, String? establishmentName, AnimalParent? mother, AnimalParent? father, String? destinationId
});


$AnimalParentCopyWith<$Res>? get mother;$AnimalParentCopyWith<$Res>? get father;

}
/// @nodoc
class _$RegisterAnimalDraftCopyWithImpl<$Res>
    implements $RegisterAnimalDraftCopyWith<$Res> {
  _$RegisterAnimalDraftCopyWithImpl(this._self, this._then);

  final RegisterAnimalDraft _self;
  final $Res Function(RegisterAnimalDraft) _then;

/// Create a copy of RegisterAnimalDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rfid = null,Object? visualTagSeries = null,Object? visualTagNumber = null,Object? breed = null,Object? sex = null,Object? birthDate = null,Object? birthWeight = null,Object? categoryId = freezed,Object? categoryName = freezed,Object? establishmentId = freezed,Object? establishmentName = freezed,Object? mother = freezed,Object? father = freezed,Object? destinationId = freezed,}) {
  return _then(_self.copyWith(
rfid: null == rfid ? _self.rfid : rfid // ignore: cast_nullable_to_non_nullable
as String,visualTagSeries: null == visualTagSeries ? _self.visualTagSeries : visualTagSeries // ignore: cast_nullable_to_non_nullable
as String,visualTagNumber: null == visualTagNumber ? _self.visualTagNumber : visualTagNumber // ignore: cast_nullable_to_non_nullable
as String,breed: null == breed ? _self.breed : breed // ignore: cast_nullable_to_non_nullable
as String,sex: null == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as String,birthDate: null == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as DateTime,birthWeight: null == birthWeight ? _self.birthWeight : birthWeight // ignore: cast_nullable_to_non_nullable
as String,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,establishmentId: freezed == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String?,establishmentName: freezed == establishmentName ? _self.establishmentName : establishmentName // ignore: cast_nullable_to_non_nullable
as String?,mother: freezed == mother ? _self.mother : mother // ignore: cast_nullable_to_non_nullable
as AnimalParent?,father: freezed == father ? _self.father : father // ignore: cast_nullable_to_non_nullable
as AnimalParent?,destinationId: freezed == destinationId ? _self.destinationId : destinationId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of RegisterAnimalDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnimalParentCopyWith<$Res>? get mother {
    if (_self.mother == null) {
    return null;
  }

  return $AnimalParentCopyWith<$Res>(_self.mother!, (value) {
    return _then(_self.copyWith(mother: value));
  });
}/// Create a copy of RegisterAnimalDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnimalParentCopyWith<$Res>? get father {
    if (_self.father == null) {
    return null;
  }

  return $AnimalParentCopyWith<$Res>(_self.father!, (value) {
    return _then(_self.copyWith(father: value));
  });
}
}


/// Adds pattern-matching-related methods to [RegisterAnimalDraft].
extension RegisterAnimalDraftPatterns on RegisterAnimalDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisterAnimalDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisterAnimalDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisterAnimalDraft value)  $default,){
final _that = this;
switch (_that) {
case _RegisterAnimalDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisterAnimalDraft value)?  $default,){
final _that = this;
switch (_that) {
case _RegisterAnimalDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String rfid,  String visualTagSeries,  String visualTagNumber,  String breed,  String sex,  DateTime birthDate,  String birthWeight,  String? categoryId,  String? categoryName,  String? establishmentId,  String? establishmentName,  AnimalParent? mother,  AnimalParent? father,  String? destinationId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterAnimalDraft() when $default != null:
return $default(_that.rfid,_that.visualTagSeries,_that.visualTagNumber,_that.breed,_that.sex,_that.birthDate,_that.birthWeight,_that.categoryId,_that.categoryName,_that.establishmentId,_that.establishmentName,_that.mother,_that.father,_that.destinationId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String rfid,  String visualTagSeries,  String visualTagNumber,  String breed,  String sex,  DateTime birthDate,  String birthWeight,  String? categoryId,  String? categoryName,  String? establishmentId,  String? establishmentName,  AnimalParent? mother,  AnimalParent? father,  String? destinationId)  $default,) {final _that = this;
switch (_that) {
case _RegisterAnimalDraft():
return $default(_that.rfid,_that.visualTagSeries,_that.visualTagNumber,_that.breed,_that.sex,_that.birthDate,_that.birthWeight,_that.categoryId,_that.categoryName,_that.establishmentId,_that.establishmentName,_that.mother,_that.father,_that.destinationId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String rfid,  String visualTagSeries,  String visualTagNumber,  String breed,  String sex,  DateTime birthDate,  String birthWeight,  String? categoryId,  String? categoryName,  String? establishmentId,  String? establishmentName,  AnimalParent? mother,  AnimalParent? father,  String? destinationId)?  $default,) {final _that = this;
switch (_that) {
case _RegisterAnimalDraft() when $default != null:
return $default(_that.rfid,_that.visualTagSeries,_that.visualTagNumber,_that.breed,_that.sex,_that.birthDate,_that.birthWeight,_that.categoryId,_that.categoryName,_that.establishmentId,_that.establishmentName,_that.mother,_that.father,_that.destinationId);case _:
  return null;

}
}

}

/// @nodoc


class _RegisterAnimalDraft implements RegisterAnimalDraft {
  const _RegisterAnimalDraft({required this.rfid, required this.visualTagSeries, required this.visualTagNumber, required this.breed, required this.sex, required this.birthDate, required this.birthWeight, this.categoryId, this.categoryName, this.establishmentId, this.establishmentName, this.mother, this.father, this.destinationId});
  

@override final  String rfid;
@override final  String visualTagSeries;
@override final  String visualTagNumber;
@override final  String breed;
@override final  String sex;
@override final  DateTime birthDate;
@override final  String birthWeight;
@override final  String? categoryId;
@override final  String? categoryName;
@override final  String? establishmentId;
@override final  String? establishmentName;
@override final  AnimalParent? mother;
@override final  AnimalParent? father;
@override final  String? destinationId;

/// Create a copy of RegisterAnimalDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterAnimalDraftCopyWith<_RegisterAnimalDraft> get copyWith => __$RegisterAnimalDraftCopyWithImpl<_RegisterAnimalDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterAnimalDraft&&(identical(other.rfid, rfid) || other.rfid == rfid)&&(identical(other.visualTagSeries, visualTagSeries) || other.visualTagSeries == visualTagSeries)&&(identical(other.visualTagNumber, visualTagNumber) || other.visualTagNumber == visualTagNumber)&&(identical(other.breed, breed) || other.breed == breed)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.birthWeight, birthWeight) || other.birthWeight == birthWeight)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.establishmentName, establishmentName) || other.establishmentName == establishmentName)&&(identical(other.mother, mother) || other.mother == mother)&&(identical(other.father, father) || other.father == father)&&(identical(other.destinationId, destinationId) || other.destinationId == destinationId));
}


@override
int get hashCode => Object.hash(runtimeType,rfid,visualTagSeries,visualTagNumber,breed,sex,birthDate,birthWeight,categoryId,categoryName,establishmentId,establishmentName,mother,father,destinationId);

@override
String toString() {
  return 'RegisterAnimalDraft(rfid: $rfid, visualTagSeries: $visualTagSeries, visualTagNumber: $visualTagNumber, breed: $breed, sex: $sex, birthDate: $birthDate, birthWeight: $birthWeight, categoryId: $categoryId, categoryName: $categoryName, establishmentId: $establishmentId, establishmentName: $establishmentName, mother: $mother, father: $father, destinationId: $destinationId)';
}


}

/// @nodoc
abstract mixin class _$RegisterAnimalDraftCopyWith<$Res> implements $RegisterAnimalDraftCopyWith<$Res> {
  factory _$RegisterAnimalDraftCopyWith(_RegisterAnimalDraft value, $Res Function(_RegisterAnimalDraft) _then) = __$RegisterAnimalDraftCopyWithImpl;
@override @useResult
$Res call({
 String rfid, String visualTagSeries, String visualTagNumber, String breed, String sex, DateTime birthDate, String birthWeight, String? categoryId, String? categoryName, String? establishmentId, String? establishmentName, AnimalParent? mother, AnimalParent? father, String? destinationId
});


@override $AnimalParentCopyWith<$Res>? get mother;@override $AnimalParentCopyWith<$Res>? get father;

}
/// @nodoc
class __$RegisterAnimalDraftCopyWithImpl<$Res>
    implements _$RegisterAnimalDraftCopyWith<$Res> {
  __$RegisterAnimalDraftCopyWithImpl(this._self, this._then);

  final _RegisterAnimalDraft _self;
  final $Res Function(_RegisterAnimalDraft) _then;

/// Create a copy of RegisterAnimalDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rfid = null,Object? visualTagSeries = null,Object? visualTagNumber = null,Object? breed = null,Object? sex = null,Object? birthDate = null,Object? birthWeight = null,Object? categoryId = freezed,Object? categoryName = freezed,Object? establishmentId = freezed,Object? establishmentName = freezed,Object? mother = freezed,Object? father = freezed,Object? destinationId = freezed,}) {
  return _then(_RegisterAnimalDraft(
rfid: null == rfid ? _self.rfid : rfid // ignore: cast_nullable_to_non_nullable
as String,visualTagSeries: null == visualTagSeries ? _self.visualTagSeries : visualTagSeries // ignore: cast_nullable_to_non_nullable
as String,visualTagNumber: null == visualTagNumber ? _self.visualTagNumber : visualTagNumber // ignore: cast_nullable_to_non_nullable
as String,breed: null == breed ? _self.breed : breed // ignore: cast_nullable_to_non_nullable
as String,sex: null == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as String,birthDate: null == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as DateTime,birthWeight: null == birthWeight ? _self.birthWeight : birthWeight // ignore: cast_nullable_to_non_nullable
as String,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,establishmentId: freezed == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String?,establishmentName: freezed == establishmentName ? _self.establishmentName : establishmentName // ignore: cast_nullable_to_non_nullable
as String?,mother: freezed == mother ? _self.mother : mother // ignore: cast_nullable_to_non_nullable
as AnimalParent?,father: freezed == father ? _self.father : father // ignore: cast_nullable_to_non_nullable
as AnimalParent?,destinationId: freezed == destinationId ? _self.destinationId : destinationId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of RegisterAnimalDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnimalParentCopyWith<$Res>? get mother {
    if (_self.mother == null) {
    return null;
  }

  return $AnimalParentCopyWith<$Res>(_self.mother!, (value) {
    return _then(_self.copyWith(mother: value));
  });
}/// Create a copy of RegisterAnimalDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnimalParentCopyWith<$Res>? get father {
    if (_self.father == null) {
    return null;
  }

  return $AnimalParentCopyWith<$Res>(_self.father!, (value) {
    return _then(_self.copyWith(father: value));
  });
}
}

/// @nodoc
mixin _$RegisterAnimalState {

 RegisterAnimalStep get currentStep; RegisterAnimalDraft get draft; ResultState<List<AnimalRegistrationEstablishment>> get establishmentsState; ResultState<List<AnimalRegistrationDestination>> get destinationsState; ResultState<List<AnimalCategory>> get categoriesState; ResultState<List<AnimalParent>> get parentsState; ResultState<RegisteredAnimal> get submitResult;
/// Create a copy of RegisterAnimalState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterAnimalStateCopyWith<RegisterAnimalState> get copyWith => _$RegisterAnimalStateCopyWithImpl<RegisterAnimalState>(this as RegisterAnimalState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterAnimalState&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.draft, draft) || other.draft == draft)&&(identical(other.establishmentsState, establishmentsState) || other.establishmentsState == establishmentsState)&&(identical(other.destinationsState, destinationsState) || other.destinationsState == destinationsState)&&(identical(other.categoriesState, categoriesState) || other.categoriesState == categoriesState)&&(identical(other.parentsState, parentsState) || other.parentsState == parentsState)&&(identical(other.submitResult, submitResult) || other.submitResult == submitResult));
}


@override
int get hashCode => Object.hash(runtimeType,currentStep,draft,establishmentsState,destinationsState,categoriesState,parentsState,submitResult);

@override
String toString() {
  return 'RegisterAnimalState(currentStep: $currentStep, draft: $draft, establishmentsState: $establishmentsState, destinationsState: $destinationsState, categoriesState: $categoriesState, parentsState: $parentsState, submitResult: $submitResult)';
}


}

/// @nodoc
abstract mixin class $RegisterAnimalStateCopyWith<$Res>  {
  factory $RegisterAnimalStateCopyWith(RegisterAnimalState value, $Res Function(RegisterAnimalState) _then) = _$RegisterAnimalStateCopyWithImpl;
@useResult
$Res call({
 RegisterAnimalStep currentStep, RegisterAnimalDraft draft, ResultState<List<AnimalRegistrationEstablishment>> establishmentsState, ResultState<List<AnimalRegistrationDestination>> destinationsState, ResultState<List<AnimalCategory>> categoriesState, ResultState<List<AnimalParent>> parentsState, ResultState<RegisteredAnimal> submitResult
});


$RegisterAnimalDraftCopyWith<$Res> get draft;$ResultStateCopyWith<List<AnimalRegistrationEstablishment>, $Res> get establishmentsState;$ResultStateCopyWith<List<AnimalRegistrationDestination>, $Res> get destinationsState;$ResultStateCopyWith<List<AnimalCategory>, $Res> get categoriesState;$ResultStateCopyWith<List<AnimalParent>, $Res> get parentsState;$ResultStateCopyWith<RegisteredAnimal, $Res> get submitResult;

}
/// @nodoc
class _$RegisterAnimalStateCopyWithImpl<$Res>
    implements $RegisterAnimalStateCopyWith<$Res> {
  _$RegisterAnimalStateCopyWithImpl(this._self, this._then);

  final RegisterAnimalState _self;
  final $Res Function(RegisterAnimalState) _then;

/// Create a copy of RegisterAnimalState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentStep = null,Object? draft = null,Object? establishmentsState = null,Object? destinationsState = null,Object? categoriesState = null,Object? parentsState = null,Object? submitResult = null,}) {
  return _then(_self.copyWith(
currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as RegisterAnimalStep,draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as RegisterAnimalDraft,establishmentsState: null == establishmentsState ? _self.establishmentsState : establishmentsState // ignore: cast_nullable_to_non_nullable
as ResultState<List<AnimalRegistrationEstablishment>>,destinationsState: null == destinationsState ? _self.destinationsState : destinationsState // ignore: cast_nullable_to_non_nullable
as ResultState<List<AnimalRegistrationDestination>>,categoriesState: null == categoriesState ? _self.categoriesState : categoriesState // ignore: cast_nullable_to_non_nullable
as ResultState<List<AnimalCategory>>,parentsState: null == parentsState ? _self.parentsState : parentsState // ignore: cast_nullable_to_non_nullable
as ResultState<List<AnimalParent>>,submitResult: null == submitResult ? _self.submitResult : submitResult // ignore: cast_nullable_to_non_nullable
as ResultState<RegisteredAnimal>,
  ));
}
/// Create a copy of RegisterAnimalState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RegisterAnimalDraftCopyWith<$Res> get draft {
  
  return $RegisterAnimalDraftCopyWith<$Res>(_self.draft, (value) {
    return _then(_self.copyWith(draft: value));
  });
}/// Create a copy of RegisterAnimalState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<List<AnimalRegistrationEstablishment>, $Res> get establishmentsState {
  
  return $ResultStateCopyWith<List<AnimalRegistrationEstablishment>, $Res>(_self.establishmentsState, (value) {
    return _then(_self.copyWith(establishmentsState: value));
  });
}/// Create a copy of RegisterAnimalState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<List<AnimalRegistrationDestination>, $Res> get destinationsState {
  
  return $ResultStateCopyWith<List<AnimalRegistrationDestination>, $Res>(_self.destinationsState, (value) {
    return _then(_self.copyWith(destinationsState: value));
  });
}/// Create a copy of RegisterAnimalState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<List<AnimalCategory>, $Res> get categoriesState {
  
  return $ResultStateCopyWith<List<AnimalCategory>, $Res>(_self.categoriesState, (value) {
    return _then(_self.copyWith(categoriesState: value));
  });
}/// Create a copy of RegisterAnimalState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<List<AnimalParent>, $Res> get parentsState {
  
  return $ResultStateCopyWith<List<AnimalParent>, $Res>(_self.parentsState, (value) {
    return _then(_self.copyWith(parentsState: value));
  });
}/// Create a copy of RegisterAnimalState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<RegisteredAnimal, $Res> get submitResult {
  
  return $ResultStateCopyWith<RegisteredAnimal, $Res>(_self.submitResult, (value) {
    return _then(_self.copyWith(submitResult: value));
  });
}
}


/// Adds pattern-matching-related methods to [RegisterAnimalState].
extension RegisterAnimalStatePatterns on RegisterAnimalState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisterAnimalState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisterAnimalState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisterAnimalState value)  $default,){
final _that = this;
switch (_that) {
case _RegisterAnimalState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisterAnimalState value)?  $default,){
final _that = this;
switch (_that) {
case _RegisterAnimalState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RegisterAnimalStep currentStep,  RegisterAnimalDraft draft,  ResultState<List<AnimalRegistrationEstablishment>> establishmentsState,  ResultState<List<AnimalRegistrationDestination>> destinationsState,  ResultState<List<AnimalCategory>> categoriesState,  ResultState<List<AnimalParent>> parentsState,  ResultState<RegisteredAnimal> submitResult)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterAnimalState() when $default != null:
return $default(_that.currentStep,_that.draft,_that.establishmentsState,_that.destinationsState,_that.categoriesState,_that.parentsState,_that.submitResult);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RegisterAnimalStep currentStep,  RegisterAnimalDraft draft,  ResultState<List<AnimalRegistrationEstablishment>> establishmentsState,  ResultState<List<AnimalRegistrationDestination>> destinationsState,  ResultState<List<AnimalCategory>> categoriesState,  ResultState<List<AnimalParent>> parentsState,  ResultState<RegisteredAnimal> submitResult)  $default,) {final _that = this;
switch (_that) {
case _RegisterAnimalState():
return $default(_that.currentStep,_that.draft,_that.establishmentsState,_that.destinationsState,_that.categoriesState,_that.parentsState,_that.submitResult);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RegisterAnimalStep currentStep,  RegisterAnimalDraft draft,  ResultState<List<AnimalRegistrationEstablishment>> establishmentsState,  ResultState<List<AnimalRegistrationDestination>> destinationsState,  ResultState<List<AnimalCategory>> categoriesState,  ResultState<List<AnimalParent>> parentsState,  ResultState<RegisteredAnimal> submitResult)?  $default,) {final _that = this;
switch (_that) {
case _RegisterAnimalState() when $default != null:
return $default(_that.currentStep,_that.draft,_that.establishmentsState,_that.destinationsState,_that.categoriesState,_that.parentsState,_that.submitResult);case _:
  return null;

}
}

}

/// @nodoc


class _RegisterAnimalState extends RegisterAnimalState {
  const _RegisterAnimalState({required this.currentStep, required this.draft, this.establishmentsState = const ResultState<List<AnimalRegistrationEstablishment>>.initial(), this.destinationsState = const ResultState<List<AnimalRegistrationDestination>>.initial(), this.categoriesState = const ResultState<List<AnimalCategory>>.initial(), this.parentsState = const ResultState<List<AnimalParent>>.initial(), this.submitResult = const ResultState<RegisteredAnimal>.initial()}): super._();
  

@override final  RegisterAnimalStep currentStep;
@override final  RegisterAnimalDraft draft;
@override@JsonKey() final  ResultState<List<AnimalRegistrationEstablishment>> establishmentsState;
@override@JsonKey() final  ResultState<List<AnimalRegistrationDestination>> destinationsState;
@override@JsonKey() final  ResultState<List<AnimalCategory>> categoriesState;
@override@JsonKey() final  ResultState<List<AnimalParent>> parentsState;
@override@JsonKey() final  ResultState<RegisteredAnimal> submitResult;

/// Create a copy of RegisterAnimalState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterAnimalStateCopyWith<_RegisterAnimalState> get copyWith => __$RegisterAnimalStateCopyWithImpl<_RegisterAnimalState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterAnimalState&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.draft, draft) || other.draft == draft)&&(identical(other.establishmentsState, establishmentsState) || other.establishmentsState == establishmentsState)&&(identical(other.destinationsState, destinationsState) || other.destinationsState == destinationsState)&&(identical(other.categoriesState, categoriesState) || other.categoriesState == categoriesState)&&(identical(other.parentsState, parentsState) || other.parentsState == parentsState)&&(identical(other.submitResult, submitResult) || other.submitResult == submitResult));
}


@override
int get hashCode => Object.hash(runtimeType,currentStep,draft,establishmentsState,destinationsState,categoriesState,parentsState,submitResult);

@override
String toString() {
  return 'RegisterAnimalState(currentStep: $currentStep, draft: $draft, establishmentsState: $establishmentsState, destinationsState: $destinationsState, categoriesState: $categoriesState, parentsState: $parentsState, submitResult: $submitResult)';
}


}

/// @nodoc
abstract mixin class _$RegisterAnimalStateCopyWith<$Res> implements $RegisterAnimalStateCopyWith<$Res> {
  factory _$RegisterAnimalStateCopyWith(_RegisterAnimalState value, $Res Function(_RegisterAnimalState) _then) = __$RegisterAnimalStateCopyWithImpl;
@override @useResult
$Res call({
 RegisterAnimalStep currentStep, RegisterAnimalDraft draft, ResultState<List<AnimalRegistrationEstablishment>> establishmentsState, ResultState<List<AnimalRegistrationDestination>> destinationsState, ResultState<List<AnimalCategory>> categoriesState, ResultState<List<AnimalParent>> parentsState, ResultState<RegisteredAnimal> submitResult
});


@override $RegisterAnimalDraftCopyWith<$Res> get draft;@override $ResultStateCopyWith<List<AnimalRegistrationEstablishment>, $Res> get establishmentsState;@override $ResultStateCopyWith<List<AnimalRegistrationDestination>, $Res> get destinationsState;@override $ResultStateCopyWith<List<AnimalCategory>, $Res> get categoriesState;@override $ResultStateCopyWith<List<AnimalParent>, $Res> get parentsState;@override $ResultStateCopyWith<RegisteredAnimal, $Res> get submitResult;

}
/// @nodoc
class __$RegisterAnimalStateCopyWithImpl<$Res>
    implements _$RegisterAnimalStateCopyWith<$Res> {
  __$RegisterAnimalStateCopyWithImpl(this._self, this._then);

  final _RegisterAnimalState _self;
  final $Res Function(_RegisterAnimalState) _then;

/// Create a copy of RegisterAnimalState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentStep = null,Object? draft = null,Object? establishmentsState = null,Object? destinationsState = null,Object? categoriesState = null,Object? parentsState = null,Object? submitResult = null,}) {
  return _then(_RegisterAnimalState(
currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as RegisterAnimalStep,draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as RegisterAnimalDraft,establishmentsState: null == establishmentsState ? _self.establishmentsState : establishmentsState // ignore: cast_nullable_to_non_nullable
as ResultState<List<AnimalRegistrationEstablishment>>,destinationsState: null == destinationsState ? _self.destinationsState : destinationsState // ignore: cast_nullable_to_non_nullable
as ResultState<List<AnimalRegistrationDestination>>,categoriesState: null == categoriesState ? _self.categoriesState : categoriesState // ignore: cast_nullable_to_non_nullable
as ResultState<List<AnimalCategory>>,parentsState: null == parentsState ? _self.parentsState : parentsState // ignore: cast_nullable_to_non_nullable
as ResultState<List<AnimalParent>>,submitResult: null == submitResult ? _self.submitResult : submitResult // ignore: cast_nullable_to_non_nullable
as ResultState<RegisteredAnimal>,
  ));
}

/// Create a copy of RegisterAnimalState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RegisterAnimalDraftCopyWith<$Res> get draft {
  
  return $RegisterAnimalDraftCopyWith<$Res>(_self.draft, (value) {
    return _then(_self.copyWith(draft: value));
  });
}/// Create a copy of RegisterAnimalState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<List<AnimalRegistrationEstablishment>, $Res> get establishmentsState {
  
  return $ResultStateCopyWith<List<AnimalRegistrationEstablishment>, $Res>(_self.establishmentsState, (value) {
    return _then(_self.copyWith(establishmentsState: value));
  });
}/// Create a copy of RegisterAnimalState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<List<AnimalRegistrationDestination>, $Res> get destinationsState {
  
  return $ResultStateCopyWith<List<AnimalRegistrationDestination>, $Res>(_self.destinationsState, (value) {
    return _then(_self.copyWith(destinationsState: value));
  });
}/// Create a copy of RegisterAnimalState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<List<AnimalCategory>, $Res> get categoriesState {
  
  return $ResultStateCopyWith<List<AnimalCategory>, $Res>(_self.categoriesState, (value) {
    return _then(_self.copyWith(categoriesState: value));
  });
}/// Create a copy of RegisterAnimalState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<List<AnimalParent>, $Res> get parentsState {
  
  return $ResultStateCopyWith<List<AnimalParent>, $Res>(_self.parentsState, (value) {
    return _then(_self.copyWith(parentsState: value));
  });
}/// Create a copy of RegisterAnimalState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<RegisteredAnimal, $Res> get submitResult {
  
  return $ResultStateCopyWith<RegisteredAnimal, $Res>(_self.submitResult, (value) {
    return _then(_self.copyWith(submitResult: value));
  });
}
}

// dart format on
