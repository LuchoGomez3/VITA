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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _DraftChanged value)?  draftChanged,TResult Function( _NextStepRequested value)?  nextStepRequested,TResult Function( _PreviousStepRequested value)?  previousStepRequested,TResult Function( _StepRequested value)?  stepRequested,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DraftChanged() when draftChanged != null:
return draftChanged(_that);case _NextStepRequested() when nextStepRequested != null:
return nextStepRequested(_that);case _PreviousStepRequested() when previousStepRequested != null:
return previousStepRequested(_that);case _StepRequested() when stepRequested != null:
return stepRequested(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _DraftChanged value)  draftChanged,required TResult Function( _NextStepRequested value)  nextStepRequested,required TResult Function( _PreviousStepRequested value)  previousStepRequested,required TResult Function( _StepRequested value)  stepRequested,}){
final _that = this;
switch (_that) {
case _DraftChanged():
return draftChanged(_that);case _NextStepRequested():
return nextStepRequested(_that);case _PreviousStepRequested():
return previousStepRequested(_that);case _StepRequested():
return stepRequested(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _DraftChanged value)?  draftChanged,TResult? Function( _NextStepRequested value)?  nextStepRequested,TResult? Function( _PreviousStepRequested value)?  previousStepRequested,TResult? Function( _StepRequested value)?  stepRequested,}){
final _that = this;
switch (_that) {
case _DraftChanged() when draftChanged != null:
return draftChanged(_that);case _NextStepRequested() when nextStepRequested != null:
return nextStepRequested(_that);case _PreviousStepRequested() when previousStepRequested != null:
return previousStepRequested(_that);case _StepRequested() when stepRequested != null:
return stepRequested(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( RegisterAnimalDraft draft)?  draftChanged,TResult Function()?  nextStepRequested,TResult Function()?  previousStepRequested,TResult Function( RegisterAnimalStep step)?  stepRequested,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DraftChanged() when draftChanged != null:
return draftChanged(_that.draft);case _NextStepRequested() when nextStepRequested != null:
return nextStepRequested();case _PreviousStepRequested() when previousStepRequested != null:
return previousStepRequested();case _StepRequested() when stepRequested != null:
return stepRequested(_that.step);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( RegisterAnimalDraft draft)  draftChanged,required TResult Function()  nextStepRequested,required TResult Function()  previousStepRequested,required TResult Function( RegisterAnimalStep step)  stepRequested,}) {final _that = this;
switch (_that) {
case _DraftChanged():
return draftChanged(_that.draft);case _NextStepRequested():
return nextStepRequested();case _PreviousStepRequested():
return previousStepRequested();case _StepRequested():
return stepRequested(_that.step);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( RegisterAnimalDraft draft)?  draftChanged,TResult? Function()?  nextStepRequested,TResult? Function()?  previousStepRequested,TResult? Function( RegisterAnimalStep step)?  stepRequested,}) {final _that = this;
switch (_that) {
case _DraftChanged() when draftChanged != null:
return draftChanged(_that.draft);case _NextStepRequested() when nextStepRequested != null:
return nextStepRequested();case _PreviousStepRequested() when previousStepRequested != null:
return previousStepRequested();case _StepRequested() when stepRequested != null:
return stepRequested(_that.step);case _:
  return null;

}
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
mixin _$RegisterAnimalDraft {

 String get rfid; String get visualTagSeries; String get visualTagNumber; int get earTagColorIndex; String get breed; String get sex; DateTime get birthDate; String get category; String get birthWeight; String? get motherId; String? get fatherId; String? get destinationId;
/// Create a copy of RegisterAnimalDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterAnimalDraftCopyWith<RegisterAnimalDraft> get copyWith => _$RegisterAnimalDraftCopyWithImpl<RegisterAnimalDraft>(this as RegisterAnimalDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterAnimalDraft&&(identical(other.rfid, rfid) || other.rfid == rfid)&&(identical(other.visualTagSeries, visualTagSeries) || other.visualTagSeries == visualTagSeries)&&(identical(other.visualTagNumber, visualTagNumber) || other.visualTagNumber == visualTagNumber)&&(identical(other.earTagColorIndex, earTagColorIndex) || other.earTagColorIndex == earTagColorIndex)&&(identical(other.breed, breed) || other.breed == breed)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.category, category) || other.category == category)&&(identical(other.birthWeight, birthWeight) || other.birthWeight == birthWeight)&&(identical(other.motherId, motherId) || other.motherId == motherId)&&(identical(other.fatherId, fatherId) || other.fatherId == fatherId)&&(identical(other.destinationId, destinationId) || other.destinationId == destinationId));
}


@override
int get hashCode => Object.hash(runtimeType,rfid,visualTagSeries,visualTagNumber,earTagColorIndex,breed,sex,birthDate,category,birthWeight,motherId,fatherId,destinationId);

@override
String toString() {
  return 'RegisterAnimalDraft(rfid: $rfid, visualTagSeries: $visualTagSeries, visualTagNumber: $visualTagNumber, earTagColorIndex: $earTagColorIndex, breed: $breed, sex: $sex, birthDate: $birthDate, category: $category, birthWeight: $birthWeight, motherId: $motherId, fatherId: $fatherId, destinationId: $destinationId)';
}


}

/// @nodoc
abstract mixin class $RegisterAnimalDraftCopyWith<$Res>  {
  factory $RegisterAnimalDraftCopyWith(RegisterAnimalDraft value, $Res Function(RegisterAnimalDraft) _then) = _$RegisterAnimalDraftCopyWithImpl;
@useResult
$Res call({
 String rfid, String visualTagSeries, String visualTagNumber, int earTagColorIndex, String breed, String sex, DateTime birthDate, String category, String birthWeight, String? motherId, String? fatherId, String? destinationId
});




}
/// @nodoc
class _$RegisterAnimalDraftCopyWithImpl<$Res>
    implements $RegisterAnimalDraftCopyWith<$Res> {
  _$RegisterAnimalDraftCopyWithImpl(this._self, this._then);

  final RegisterAnimalDraft _self;
  final $Res Function(RegisterAnimalDraft) _then;

/// Create a copy of RegisterAnimalDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rfid = null,Object? visualTagSeries = null,Object? visualTagNumber = null,Object? earTagColorIndex = null,Object? breed = null,Object? sex = null,Object? birthDate = null,Object? category = null,Object? birthWeight = null,Object? motherId = freezed,Object? fatherId = freezed,Object? destinationId = freezed,}) {
  return _then(_self.copyWith(
rfid: null == rfid ? _self.rfid : rfid // ignore: cast_nullable_to_non_nullable
as String,visualTagSeries: null == visualTagSeries ? _self.visualTagSeries : visualTagSeries // ignore: cast_nullable_to_non_nullable
as String,visualTagNumber: null == visualTagNumber ? _self.visualTagNumber : visualTagNumber // ignore: cast_nullable_to_non_nullable
as String,earTagColorIndex: null == earTagColorIndex ? _self.earTagColorIndex : earTagColorIndex // ignore: cast_nullable_to_non_nullable
as int,breed: null == breed ? _self.breed : breed // ignore: cast_nullable_to_non_nullable
as String,sex: null == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as String,birthDate: null == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as DateTime,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,birthWeight: null == birthWeight ? _self.birthWeight : birthWeight // ignore: cast_nullable_to_non_nullable
as String,motherId: freezed == motherId ? _self.motherId : motherId // ignore: cast_nullable_to_non_nullable
as String?,fatherId: freezed == fatherId ? _self.fatherId : fatherId // ignore: cast_nullable_to_non_nullable
as String?,destinationId: freezed == destinationId ? _self.destinationId : destinationId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String rfid,  String visualTagSeries,  String visualTagNumber,  int earTagColorIndex,  String breed,  String sex,  DateTime birthDate,  String category,  String birthWeight,  String? motherId,  String? fatherId,  String? destinationId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterAnimalDraft() when $default != null:
return $default(_that.rfid,_that.visualTagSeries,_that.visualTagNumber,_that.earTagColorIndex,_that.breed,_that.sex,_that.birthDate,_that.category,_that.birthWeight,_that.motherId,_that.fatherId,_that.destinationId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String rfid,  String visualTagSeries,  String visualTagNumber,  int earTagColorIndex,  String breed,  String sex,  DateTime birthDate,  String category,  String birthWeight,  String? motherId,  String? fatherId,  String? destinationId)  $default,) {final _that = this;
switch (_that) {
case _RegisterAnimalDraft():
return $default(_that.rfid,_that.visualTagSeries,_that.visualTagNumber,_that.earTagColorIndex,_that.breed,_that.sex,_that.birthDate,_that.category,_that.birthWeight,_that.motherId,_that.fatherId,_that.destinationId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String rfid,  String visualTagSeries,  String visualTagNumber,  int earTagColorIndex,  String breed,  String sex,  DateTime birthDate,  String category,  String birthWeight,  String? motherId,  String? fatherId,  String? destinationId)?  $default,) {final _that = this;
switch (_that) {
case _RegisterAnimalDraft() when $default != null:
return $default(_that.rfid,_that.visualTagSeries,_that.visualTagNumber,_that.earTagColorIndex,_that.breed,_that.sex,_that.birthDate,_that.category,_that.birthWeight,_that.motherId,_that.fatherId,_that.destinationId);case _:
  return null;

}
}

}

/// @nodoc


class _RegisterAnimalDraft implements RegisterAnimalDraft {
  const _RegisterAnimalDraft({required this.rfid, required this.visualTagSeries, required this.visualTagNumber, required this.earTagColorIndex, required this.breed, required this.sex, required this.birthDate, required this.category, required this.birthWeight, this.motherId, this.fatherId, this.destinationId});
  

@override final  String rfid;
@override final  String visualTagSeries;
@override final  String visualTagNumber;
@override final  int earTagColorIndex;
@override final  String breed;
@override final  String sex;
@override final  DateTime birthDate;
@override final  String category;
@override final  String birthWeight;
@override final  String? motherId;
@override final  String? fatherId;
@override final  String? destinationId;

/// Create a copy of RegisterAnimalDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterAnimalDraftCopyWith<_RegisterAnimalDraft> get copyWith => __$RegisterAnimalDraftCopyWithImpl<_RegisterAnimalDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterAnimalDraft&&(identical(other.rfid, rfid) || other.rfid == rfid)&&(identical(other.visualTagSeries, visualTagSeries) || other.visualTagSeries == visualTagSeries)&&(identical(other.visualTagNumber, visualTagNumber) || other.visualTagNumber == visualTagNumber)&&(identical(other.earTagColorIndex, earTagColorIndex) || other.earTagColorIndex == earTagColorIndex)&&(identical(other.breed, breed) || other.breed == breed)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.category, category) || other.category == category)&&(identical(other.birthWeight, birthWeight) || other.birthWeight == birthWeight)&&(identical(other.motherId, motherId) || other.motherId == motherId)&&(identical(other.fatherId, fatherId) || other.fatherId == fatherId)&&(identical(other.destinationId, destinationId) || other.destinationId == destinationId));
}


@override
int get hashCode => Object.hash(runtimeType,rfid,visualTagSeries,visualTagNumber,earTagColorIndex,breed,sex,birthDate,category,birthWeight,motherId,fatherId,destinationId);

@override
String toString() {
  return 'RegisterAnimalDraft(rfid: $rfid, visualTagSeries: $visualTagSeries, visualTagNumber: $visualTagNumber, earTagColorIndex: $earTagColorIndex, breed: $breed, sex: $sex, birthDate: $birthDate, category: $category, birthWeight: $birthWeight, motherId: $motherId, fatherId: $fatherId, destinationId: $destinationId)';
}


}

/// @nodoc
abstract mixin class _$RegisterAnimalDraftCopyWith<$Res> implements $RegisterAnimalDraftCopyWith<$Res> {
  factory _$RegisterAnimalDraftCopyWith(_RegisterAnimalDraft value, $Res Function(_RegisterAnimalDraft) _then) = __$RegisterAnimalDraftCopyWithImpl;
@override @useResult
$Res call({
 String rfid, String visualTagSeries, String visualTagNumber, int earTagColorIndex, String breed, String sex, DateTime birthDate, String category, String birthWeight, String? motherId, String? fatherId, String? destinationId
});




}
/// @nodoc
class __$RegisterAnimalDraftCopyWithImpl<$Res>
    implements _$RegisterAnimalDraftCopyWith<$Res> {
  __$RegisterAnimalDraftCopyWithImpl(this._self, this._then);

  final _RegisterAnimalDraft _self;
  final $Res Function(_RegisterAnimalDraft) _then;

/// Create a copy of RegisterAnimalDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rfid = null,Object? visualTagSeries = null,Object? visualTagNumber = null,Object? earTagColorIndex = null,Object? breed = null,Object? sex = null,Object? birthDate = null,Object? category = null,Object? birthWeight = null,Object? motherId = freezed,Object? fatherId = freezed,Object? destinationId = freezed,}) {
  return _then(_RegisterAnimalDraft(
rfid: null == rfid ? _self.rfid : rfid // ignore: cast_nullable_to_non_nullable
as String,visualTagSeries: null == visualTagSeries ? _self.visualTagSeries : visualTagSeries // ignore: cast_nullable_to_non_nullable
as String,visualTagNumber: null == visualTagNumber ? _self.visualTagNumber : visualTagNumber // ignore: cast_nullable_to_non_nullable
as String,earTagColorIndex: null == earTagColorIndex ? _self.earTagColorIndex : earTagColorIndex // ignore: cast_nullable_to_non_nullable
as int,breed: null == breed ? _self.breed : breed // ignore: cast_nullable_to_non_nullable
as String,sex: null == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as String,birthDate: null == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as DateTime,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,birthWeight: null == birthWeight ? _self.birthWeight : birthWeight // ignore: cast_nullable_to_non_nullable
as String,motherId: freezed == motherId ? _self.motherId : motherId // ignore: cast_nullable_to_non_nullable
as String?,fatherId: freezed == fatherId ? _self.fatherId : fatherId // ignore: cast_nullable_to_non_nullable
as String?,destinationId: freezed == destinationId ? _self.destinationId : destinationId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$RegisterAnimalState {

 RegisterAnimalStep get currentStep; RegisterAnimalDraft get draft;
/// Create a copy of RegisterAnimalState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterAnimalStateCopyWith<RegisterAnimalState> get copyWith => _$RegisterAnimalStateCopyWithImpl<RegisterAnimalState>(this as RegisterAnimalState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterAnimalState&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.draft, draft) || other.draft == draft));
}


@override
int get hashCode => Object.hash(runtimeType,currentStep,draft);

@override
String toString() {
  return 'RegisterAnimalState(currentStep: $currentStep, draft: $draft)';
}


}

/// @nodoc
abstract mixin class $RegisterAnimalStateCopyWith<$Res>  {
  factory $RegisterAnimalStateCopyWith(RegisterAnimalState value, $Res Function(RegisterAnimalState) _then) = _$RegisterAnimalStateCopyWithImpl;
@useResult
$Res call({
 RegisterAnimalStep currentStep, RegisterAnimalDraft draft
});


$RegisterAnimalDraftCopyWith<$Res> get draft;

}
/// @nodoc
class _$RegisterAnimalStateCopyWithImpl<$Res>
    implements $RegisterAnimalStateCopyWith<$Res> {
  _$RegisterAnimalStateCopyWithImpl(this._self, this._then);

  final RegisterAnimalState _self;
  final $Res Function(RegisterAnimalState) _then;

/// Create a copy of RegisterAnimalState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentStep = null,Object? draft = null,}) {
  return _then(_self.copyWith(
currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as RegisterAnimalStep,draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as RegisterAnimalDraft,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RegisterAnimalStep currentStep,  RegisterAnimalDraft draft)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterAnimalState() when $default != null:
return $default(_that.currentStep,_that.draft);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RegisterAnimalStep currentStep,  RegisterAnimalDraft draft)  $default,) {final _that = this;
switch (_that) {
case _RegisterAnimalState():
return $default(_that.currentStep,_that.draft);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RegisterAnimalStep currentStep,  RegisterAnimalDraft draft)?  $default,) {final _that = this;
switch (_that) {
case _RegisterAnimalState() when $default != null:
return $default(_that.currentStep,_that.draft);case _:
  return null;

}
}

}

/// @nodoc


class _RegisterAnimalState implements RegisterAnimalState {
  const _RegisterAnimalState({required this.currentStep, required this.draft});
  

@override final  RegisterAnimalStep currentStep;
@override final  RegisterAnimalDraft draft;

/// Create a copy of RegisterAnimalState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterAnimalStateCopyWith<_RegisterAnimalState> get copyWith => __$RegisterAnimalStateCopyWithImpl<_RegisterAnimalState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterAnimalState&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.draft, draft) || other.draft == draft));
}


@override
int get hashCode => Object.hash(runtimeType,currentStep,draft);

@override
String toString() {
  return 'RegisterAnimalState(currentStep: $currentStep, draft: $draft)';
}


}

/// @nodoc
abstract mixin class _$RegisterAnimalStateCopyWith<$Res> implements $RegisterAnimalStateCopyWith<$Res> {
  factory _$RegisterAnimalStateCopyWith(_RegisterAnimalState value, $Res Function(_RegisterAnimalState) _then) = __$RegisterAnimalStateCopyWithImpl;
@override @useResult
$Res call({
 RegisterAnimalStep currentStep, RegisterAnimalDraft draft
});


@override $RegisterAnimalDraftCopyWith<$Res> get draft;

}
/// @nodoc
class __$RegisterAnimalStateCopyWithImpl<$Res>
    implements _$RegisterAnimalStateCopyWith<$Res> {
  __$RegisterAnimalStateCopyWithImpl(this._self, this._then);

  final _RegisterAnimalState _self;
  final $Res Function(_RegisterAnimalState) _then;

/// Create a copy of RegisterAnimalState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentStep = null,Object? draft = null,}) {
  return _then(_RegisterAnimalState(
currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as RegisterAnimalStep,draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as RegisterAnimalDraft,
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
}
}

// dart format on
