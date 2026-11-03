// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'livestock_sale_saved_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LivestockSaleSavedDraft {

 String get establishmentId; DateTime get operationDate; LivestockSaleBuyerType get buyerType; String get buyerName; bool get isCompany; String get buyerLastName; String get dteNumber; LivestockSaleType get saleType; String get bulkTotalAmount; String get totalWeight; String get pricePerKg; LivestockSalePaymentCondition get paymentCondition; LivestockSalePaymentMethod get paymentMethod; String get amountToCollect; DateTime get paymentDate; String get observations; String get paymentObservations; List<String> get selectedRfidTagNumbers; LivestockSaleDraftStep get currentStep; DateTime get updatedAt;
/// Create a copy of LivestockSaleSavedDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LivestockSaleSavedDraftCopyWith<LivestockSaleSavedDraft> get copyWith => _$LivestockSaleSavedDraftCopyWithImpl<LivestockSaleSavedDraft>(this as LivestockSaleSavedDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LivestockSaleSavedDraft&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.operationDate, operationDate) || other.operationDate == operationDate)&&(identical(other.buyerType, buyerType) || other.buyerType == buyerType)&&(identical(other.buyerName, buyerName) || other.buyerName == buyerName)&&(identical(other.isCompany, isCompany) || other.isCompany == isCompany)&&(identical(other.buyerLastName, buyerLastName) || other.buyerLastName == buyerLastName)&&(identical(other.dteNumber, dteNumber) || other.dteNumber == dteNumber)&&(identical(other.saleType, saleType) || other.saleType == saleType)&&(identical(other.bulkTotalAmount, bulkTotalAmount) || other.bulkTotalAmount == bulkTotalAmount)&&(identical(other.totalWeight, totalWeight) || other.totalWeight == totalWeight)&&(identical(other.pricePerKg, pricePerKg) || other.pricePerKg == pricePerKg)&&(identical(other.paymentCondition, paymentCondition) || other.paymentCondition == paymentCondition)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.amountToCollect, amountToCollect) || other.amountToCollect == amountToCollect)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate)&&(identical(other.observations, observations) || other.observations == observations)&&(identical(other.paymentObservations, paymentObservations) || other.paymentObservations == paymentObservations)&&const DeepCollectionEquality().equals(other.selectedRfidTagNumbers, selectedRfidTagNumbers)&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,establishmentId,operationDate,buyerType,buyerName,isCompany,buyerLastName,dteNumber,saleType,bulkTotalAmount,totalWeight,pricePerKg,paymentCondition,paymentMethod,amountToCollect,paymentDate,observations,paymentObservations,const DeepCollectionEquality().hash(selectedRfidTagNumbers),currentStep,updatedAt]);

@override
String toString() {
  return 'LivestockSaleSavedDraft(establishmentId: $establishmentId, operationDate: $operationDate, buyerType: $buyerType, buyerName: $buyerName, isCompany: $isCompany, buyerLastName: $buyerLastName, dteNumber: $dteNumber, saleType: $saleType, bulkTotalAmount: $bulkTotalAmount, totalWeight: $totalWeight, pricePerKg: $pricePerKg, paymentCondition: $paymentCondition, paymentMethod: $paymentMethod, amountToCollect: $amountToCollect, paymentDate: $paymentDate, observations: $observations, paymentObservations: $paymentObservations, selectedRfidTagNumbers: $selectedRfidTagNumbers, currentStep: $currentStep, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $LivestockSaleSavedDraftCopyWith<$Res>  {
  factory $LivestockSaleSavedDraftCopyWith(LivestockSaleSavedDraft value, $Res Function(LivestockSaleSavedDraft) _then) = _$LivestockSaleSavedDraftCopyWithImpl;
@useResult
$Res call({
 String establishmentId, DateTime operationDate, LivestockSaleBuyerType buyerType, String buyerName, bool isCompany, String buyerLastName, String dteNumber, LivestockSaleType saleType, String bulkTotalAmount, String totalWeight, String pricePerKg, LivestockSalePaymentCondition paymentCondition, LivestockSalePaymentMethod paymentMethod, String amountToCollect, DateTime paymentDate, String observations, String paymentObservations, List<String> selectedRfidTagNumbers, LivestockSaleDraftStep currentStep, DateTime updatedAt
});




}
/// @nodoc
class _$LivestockSaleSavedDraftCopyWithImpl<$Res>
    implements $LivestockSaleSavedDraftCopyWith<$Res> {
  _$LivestockSaleSavedDraftCopyWithImpl(this._self, this._then);

  final LivestockSaleSavedDraft _self;
  final $Res Function(LivestockSaleSavedDraft) _then;

/// Create a copy of LivestockSaleSavedDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? establishmentId = null,Object? operationDate = null,Object? buyerType = null,Object? buyerName = null,Object? isCompany = null,Object? buyerLastName = null,Object? dteNumber = null,Object? saleType = null,Object? bulkTotalAmount = null,Object? totalWeight = null,Object? pricePerKg = null,Object? paymentCondition = null,Object? paymentMethod = null,Object? amountToCollect = null,Object? paymentDate = null,Object? observations = null,Object? paymentObservations = null,Object? selectedRfidTagNumbers = null,Object? currentStep = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,operationDate: null == operationDate ? _self.operationDate : operationDate // ignore: cast_nullable_to_non_nullable
as DateTime,buyerType: null == buyerType ? _self.buyerType : buyerType // ignore: cast_nullable_to_non_nullable
as LivestockSaleBuyerType,buyerName: null == buyerName ? _self.buyerName : buyerName // ignore: cast_nullable_to_non_nullable
as String,isCompany: null == isCompany ? _self.isCompany : isCompany // ignore: cast_nullable_to_non_nullable
as bool,buyerLastName: null == buyerLastName ? _self.buyerLastName : buyerLastName // ignore: cast_nullable_to_non_nullable
as String,dteNumber: null == dteNumber ? _self.dteNumber : dteNumber // ignore: cast_nullable_to_non_nullable
as String,saleType: null == saleType ? _self.saleType : saleType // ignore: cast_nullable_to_non_nullable
as LivestockSaleType,bulkTotalAmount: null == bulkTotalAmount ? _self.bulkTotalAmount : bulkTotalAmount // ignore: cast_nullable_to_non_nullable
as String,totalWeight: null == totalWeight ? _self.totalWeight : totalWeight // ignore: cast_nullable_to_non_nullable
as String,pricePerKg: null == pricePerKg ? _self.pricePerKg : pricePerKg // ignore: cast_nullable_to_non_nullable
as String,paymentCondition: null == paymentCondition ? _self.paymentCondition : paymentCondition // ignore: cast_nullable_to_non_nullable
as LivestockSalePaymentCondition,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as LivestockSalePaymentMethod,amountToCollect: null == amountToCollect ? _self.amountToCollect : amountToCollect // ignore: cast_nullable_to_non_nullable
as String,paymentDate: null == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as DateTime,observations: null == observations ? _self.observations : observations // ignore: cast_nullable_to_non_nullable
as String,paymentObservations: null == paymentObservations ? _self.paymentObservations : paymentObservations // ignore: cast_nullable_to_non_nullable
as String,selectedRfidTagNumbers: null == selectedRfidTagNumbers ? _self.selectedRfidTagNumbers : selectedRfidTagNumbers // ignore: cast_nullable_to_non_nullable
as List<String>,currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as LivestockSaleDraftStep,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [LivestockSaleSavedDraft].
extension LivestockSaleSavedDraftPatterns on LivestockSaleSavedDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LivestockSaleSavedDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LivestockSaleSavedDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LivestockSaleSavedDraft value)  $default,){
final _that = this;
switch (_that) {
case _LivestockSaleSavedDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LivestockSaleSavedDraft value)?  $default,){
final _that = this;
switch (_that) {
case _LivestockSaleSavedDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String establishmentId,  DateTime operationDate,  LivestockSaleBuyerType buyerType,  String buyerName,  bool isCompany,  String buyerLastName,  String dteNumber,  LivestockSaleType saleType,  String bulkTotalAmount,  String totalWeight,  String pricePerKg,  LivestockSalePaymentCondition paymentCondition,  LivestockSalePaymentMethod paymentMethod,  String amountToCollect,  DateTime paymentDate,  String observations,  String paymentObservations,  List<String> selectedRfidTagNumbers,  LivestockSaleDraftStep currentStep,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LivestockSaleSavedDraft() when $default != null:
return $default(_that.establishmentId,_that.operationDate,_that.buyerType,_that.buyerName,_that.isCompany,_that.buyerLastName,_that.dteNumber,_that.saleType,_that.bulkTotalAmount,_that.totalWeight,_that.pricePerKg,_that.paymentCondition,_that.paymentMethod,_that.amountToCollect,_that.paymentDate,_that.observations,_that.paymentObservations,_that.selectedRfidTagNumbers,_that.currentStep,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String establishmentId,  DateTime operationDate,  LivestockSaleBuyerType buyerType,  String buyerName,  bool isCompany,  String buyerLastName,  String dteNumber,  LivestockSaleType saleType,  String bulkTotalAmount,  String totalWeight,  String pricePerKg,  LivestockSalePaymentCondition paymentCondition,  LivestockSalePaymentMethod paymentMethod,  String amountToCollect,  DateTime paymentDate,  String observations,  String paymentObservations,  List<String> selectedRfidTagNumbers,  LivestockSaleDraftStep currentStep,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _LivestockSaleSavedDraft():
return $default(_that.establishmentId,_that.operationDate,_that.buyerType,_that.buyerName,_that.isCompany,_that.buyerLastName,_that.dteNumber,_that.saleType,_that.bulkTotalAmount,_that.totalWeight,_that.pricePerKg,_that.paymentCondition,_that.paymentMethod,_that.amountToCollect,_that.paymentDate,_that.observations,_that.paymentObservations,_that.selectedRfidTagNumbers,_that.currentStep,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String establishmentId,  DateTime operationDate,  LivestockSaleBuyerType buyerType,  String buyerName,  bool isCompany,  String buyerLastName,  String dteNumber,  LivestockSaleType saleType,  String bulkTotalAmount,  String totalWeight,  String pricePerKg,  LivestockSalePaymentCondition paymentCondition,  LivestockSalePaymentMethod paymentMethod,  String amountToCollect,  DateTime paymentDate,  String observations,  String paymentObservations,  List<String> selectedRfidTagNumbers,  LivestockSaleDraftStep currentStep,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _LivestockSaleSavedDraft() when $default != null:
return $default(_that.establishmentId,_that.operationDate,_that.buyerType,_that.buyerName,_that.isCompany,_that.buyerLastName,_that.dteNumber,_that.saleType,_that.bulkTotalAmount,_that.totalWeight,_that.pricePerKg,_that.paymentCondition,_that.paymentMethod,_that.amountToCollect,_that.paymentDate,_that.observations,_that.paymentObservations,_that.selectedRfidTagNumbers,_that.currentStep,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _LivestockSaleSavedDraft implements LivestockSaleSavedDraft {
  const _LivestockSaleSavedDraft({required this.establishmentId, required this.operationDate, required this.buyerType, required this.buyerName, required this.isCompany, required this.buyerLastName, required this.dteNumber, required this.saleType, required this.bulkTotalAmount, required this.totalWeight, required this.pricePerKg, required this.paymentCondition, required this.paymentMethod, required this.amountToCollect, required this.paymentDate, required this.observations, required this.paymentObservations, required final  List<String> selectedRfidTagNumbers, required this.currentStep, required this.updatedAt}): _selectedRfidTagNumbers = selectedRfidTagNumbers;
  

@override final  String establishmentId;
@override final  DateTime operationDate;
@override final  LivestockSaleBuyerType buyerType;
@override final  String buyerName;
@override final  bool isCompany;
@override final  String buyerLastName;
@override final  String dteNumber;
@override final  LivestockSaleType saleType;
@override final  String bulkTotalAmount;
@override final  String totalWeight;
@override final  String pricePerKg;
@override final  LivestockSalePaymentCondition paymentCondition;
@override final  LivestockSalePaymentMethod paymentMethod;
@override final  String amountToCollect;
@override final  DateTime paymentDate;
@override final  String observations;
@override final  String paymentObservations;
 final  List<String> _selectedRfidTagNumbers;
@override List<String> get selectedRfidTagNumbers {
  if (_selectedRfidTagNumbers is EqualUnmodifiableListView) return _selectedRfidTagNumbers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedRfidTagNumbers);
}

@override final  LivestockSaleDraftStep currentStep;
@override final  DateTime updatedAt;

/// Create a copy of LivestockSaleSavedDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LivestockSaleSavedDraftCopyWith<_LivestockSaleSavedDraft> get copyWith => __$LivestockSaleSavedDraftCopyWithImpl<_LivestockSaleSavedDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LivestockSaleSavedDraft&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.operationDate, operationDate) || other.operationDate == operationDate)&&(identical(other.buyerType, buyerType) || other.buyerType == buyerType)&&(identical(other.buyerName, buyerName) || other.buyerName == buyerName)&&(identical(other.isCompany, isCompany) || other.isCompany == isCompany)&&(identical(other.buyerLastName, buyerLastName) || other.buyerLastName == buyerLastName)&&(identical(other.dteNumber, dteNumber) || other.dteNumber == dteNumber)&&(identical(other.saleType, saleType) || other.saleType == saleType)&&(identical(other.bulkTotalAmount, bulkTotalAmount) || other.bulkTotalAmount == bulkTotalAmount)&&(identical(other.totalWeight, totalWeight) || other.totalWeight == totalWeight)&&(identical(other.pricePerKg, pricePerKg) || other.pricePerKg == pricePerKg)&&(identical(other.paymentCondition, paymentCondition) || other.paymentCondition == paymentCondition)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.amountToCollect, amountToCollect) || other.amountToCollect == amountToCollect)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate)&&(identical(other.observations, observations) || other.observations == observations)&&(identical(other.paymentObservations, paymentObservations) || other.paymentObservations == paymentObservations)&&const DeepCollectionEquality().equals(other._selectedRfidTagNumbers, _selectedRfidTagNumbers)&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,establishmentId,operationDate,buyerType,buyerName,isCompany,buyerLastName,dteNumber,saleType,bulkTotalAmount,totalWeight,pricePerKg,paymentCondition,paymentMethod,amountToCollect,paymentDate,observations,paymentObservations,const DeepCollectionEquality().hash(_selectedRfidTagNumbers),currentStep,updatedAt]);

@override
String toString() {
  return 'LivestockSaleSavedDraft(establishmentId: $establishmentId, operationDate: $operationDate, buyerType: $buyerType, buyerName: $buyerName, isCompany: $isCompany, buyerLastName: $buyerLastName, dteNumber: $dteNumber, saleType: $saleType, bulkTotalAmount: $bulkTotalAmount, totalWeight: $totalWeight, pricePerKg: $pricePerKg, paymentCondition: $paymentCondition, paymentMethod: $paymentMethod, amountToCollect: $amountToCollect, paymentDate: $paymentDate, observations: $observations, paymentObservations: $paymentObservations, selectedRfidTagNumbers: $selectedRfidTagNumbers, currentStep: $currentStep, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$LivestockSaleSavedDraftCopyWith<$Res> implements $LivestockSaleSavedDraftCopyWith<$Res> {
  factory _$LivestockSaleSavedDraftCopyWith(_LivestockSaleSavedDraft value, $Res Function(_LivestockSaleSavedDraft) _then) = __$LivestockSaleSavedDraftCopyWithImpl;
@override @useResult
$Res call({
 String establishmentId, DateTime operationDate, LivestockSaleBuyerType buyerType, String buyerName, bool isCompany, String buyerLastName, String dteNumber, LivestockSaleType saleType, String bulkTotalAmount, String totalWeight, String pricePerKg, LivestockSalePaymentCondition paymentCondition, LivestockSalePaymentMethod paymentMethod, String amountToCollect, DateTime paymentDate, String observations, String paymentObservations, List<String> selectedRfidTagNumbers, LivestockSaleDraftStep currentStep, DateTime updatedAt
});




}
/// @nodoc
class __$LivestockSaleSavedDraftCopyWithImpl<$Res>
    implements _$LivestockSaleSavedDraftCopyWith<$Res> {
  __$LivestockSaleSavedDraftCopyWithImpl(this._self, this._then);

  final _LivestockSaleSavedDraft _self;
  final $Res Function(_LivestockSaleSavedDraft) _then;

/// Create a copy of LivestockSaleSavedDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? establishmentId = null,Object? operationDate = null,Object? buyerType = null,Object? buyerName = null,Object? isCompany = null,Object? buyerLastName = null,Object? dteNumber = null,Object? saleType = null,Object? bulkTotalAmount = null,Object? totalWeight = null,Object? pricePerKg = null,Object? paymentCondition = null,Object? paymentMethod = null,Object? amountToCollect = null,Object? paymentDate = null,Object? observations = null,Object? paymentObservations = null,Object? selectedRfidTagNumbers = null,Object? currentStep = null,Object? updatedAt = null,}) {
  return _then(_LivestockSaleSavedDraft(
establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,operationDate: null == operationDate ? _self.operationDate : operationDate // ignore: cast_nullable_to_non_nullable
as DateTime,buyerType: null == buyerType ? _self.buyerType : buyerType // ignore: cast_nullable_to_non_nullable
as LivestockSaleBuyerType,buyerName: null == buyerName ? _self.buyerName : buyerName // ignore: cast_nullable_to_non_nullable
as String,isCompany: null == isCompany ? _self.isCompany : isCompany // ignore: cast_nullable_to_non_nullable
as bool,buyerLastName: null == buyerLastName ? _self.buyerLastName : buyerLastName // ignore: cast_nullable_to_non_nullable
as String,dteNumber: null == dteNumber ? _self.dteNumber : dteNumber // ignore: cast_nullable_to_non_nullable
as String,saleType: null == saleType ? _self.saleType : saleType // ignore: cast_nullable_to_non_nullable
as LivestockSaleType,bulkTotalAmount: null == bulkTotalAmount ? _self.bulkTotalAmount : bulkTotalAmount // ignore: cast_nullable_to_non_nullable
as String,totalWeight: null == totalWeight ? _self.totalWeight : totalWeight // ignore: cast_nullable_to_non_nullable
as String,pricePerKg: null == pricePerKg ? _self.pricePerKg : pricePerKg // ignore: cast_nullable_to_non_nullable
as String,paymentCondition: null == paymentCondition ? _self.paymentCondition : paymentCondition // ignore: cast_nullable_to_non_nullable
as LivestockSalePaymentCondition,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as LivestockSalePaymentMethod,amountToCollect: null == amountToCollect ? _self.amountToCollect : amountToCollect // ignore: cast_nullable_to_non_nullable
as String,paymentDate: null == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as DateTime,observations: null == observations ? _self.observations : observations // ignore: cast_nullable_to_non_nullable
as String,paymentObservations: null == paymentObservations ? _self.paymentObservations : paymentObservations // ignore: cast_nullable_to_non_nullable
as String,selectedRfidTagNumbers: null == selectedRfidTagNumbers ? _self._selectedRfidTagNumbers : selectedRfidTagNumbers // ignore: cast_nullable_to_non_nullable
as List<String>,currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as LivestockSaleDraftStep,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
