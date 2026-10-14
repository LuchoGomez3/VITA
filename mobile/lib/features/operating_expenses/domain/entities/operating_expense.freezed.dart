// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'operating_expense.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OperatingExpenseCategory {

 String get value; String get label; OperatingExpenseType get type; bool get custom; String? get id;
/// Create a copy of OperatingExpenseCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OperatingExpenseCategoryCopyWith<OperatingExpenseCategory> get copyWith => _$OperatingExpenseCategoryCopyWithImpl<OperatingExpenseCategory>(this as OperatingExpenseCategory, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OperatingExpenseCategory&&(identical(other.value, value) || other.value == value)&&(identical(other.label, label) || other.label == label)&&(identical(other.type, type) || other.type == type)&&(identical(other.custom, custom) || other.custom == custom)&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,value,label,type,custom,id);

@override
String toString() {
  return 'OperatingExpenseCategory(value: $value, label: $label, type: $type, custom: $custom, id: $id)';
}


}

/// @nodoc
abstract mixin class $OperatingExpenseCategoryCopyWith<$Res>  {
  factory $OperatingExpenseCategoryCopyWith(OperatingExpenseCategory value, $Res Function(OperatingExpenseCategory) _then) = _$OperatingExpenseCategoryCopyWithImpl;
@useResult
$Res call({
 String value, String label, OperatingExpenseType type, bool custom, String? id
});




}
/// @nodoc
class _$OperatingExpenseCategoryCopyWithImpl<$Res>
    implements $OperatingExpenseCategoryCopyWith<$Res> {
  _$OperatingExpenseCategoryCopyWithImpl(this._self, this._then);

  final OperatingExpenseCategory _self;
  final $Res Function(OperatingExpenseCategory) _then;

/// Create a copy of OperatingExpenseCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? label = null,Object? type = null,Object? custom = null,Object? id = freezed,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as OperatingExpenseType,custom: null == custom ? _self.custom : custom // ignore: cast_nullable_to_non_nullable
as bool,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OperatingExpenseCategory].
extension OperatingExpenseCategoryPatterns on OperatingExpenseCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OperatingExpenseCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OperatingExpenseCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OperatingExpenseCategory value)  $default,){
final _that = this;
switch (_that) {
case _OperatingExpenseCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OperatingExpenseCategory value)?  $default,){
final _that = this;
switch (_that) {
case _OperatingExpenseCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String value,  String label,  OperatingExpenseType type,  bool custom,  String? id)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OperatingExpenseCategory() when $default != null:
return $default(_that.value,_that.label,_that.type,_that.custom,_that.id);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String value,  String label,  OperatingExpenseType type,  bool custom,  String? id)  $default,) {final _that = this;
switch (_that) {
case _OperatingExpenseCategory():
return $default(_that.value,_that.label,_that.type,_that.custom,_that.id);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String value,  String label,  OperatingExpenseType type,  bool custom,  String? id)?  $default,) {final _that = this;
switch (_that) {
case _OperatingExpenseCategory() when $default != null:
return $default(_that.value,_that.label,_that.type,_that.custom,_that.id);case _:
  return null;

}
}

}

/// @nodoc


class _OperatingExpenseCategory implements OperatingExpenseCategory {
  const _OperatingExpenseCategory({required this.value, required this.label, required this.type, this.custom = false, this.id});
  

@override final  String value;
@override final  String label;
@override final  OperatingExpenseType type;
@override@JsonKey() final  bool custom;
@override final  String? id;

/// Create a copy of OperatingExpenseCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OperatingExpenseCategoryCopyWith<_OperatingExpenseCategory> get copyWith => __$OperatingExpenseCategoryCopyWithImpl<_OperatingExpenseCategory>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OperatingExpenseCategory&&(identical(other.value, value) || other.value == value)&&(identical(other.label, label) || other.label == label)&&(identical(other.type, type) || other.type == type)&&(identical(other.custom, custom) || other.custom == custom)&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,value,label,type,custom,id);

@override
String toString() {
  return 'OperatingExpenseCategory(value: $value, label: $label, type: $type, custom: $custom, id: $id)';
}


}

/// @nodoc
abstract mixin class _$OperatingExpenseCategoryCopyWith<$Res> implements $OperatingExpenseCategoryCopyWith<$Res> {
  factory _$OperatingExpenseCategoryCopyWith(_OperatingExpenseCategory value, $Res Function(_OperatingExpenseCategory) _then) = __$OperatingExpenseCategoryCopyWithImpl;
@override @useResult
$Res call({
 String value, String label, OperatingExpenseType type, bool custom, String? id
});




}
/// @nodoc
class __$OperatingExpenseCategoryCopyWithImpl<$Res>
    implements _$OperatingExpenseCategoryCopyWith<$Res> {
  __$OperatingExpenseCategoryCopyWithImpl(this._self, this._then);

  final _OperatingExpenseCategory _self;
  final $Res Function(_OperatingExpenseCategory) _then;

/// Create a copy of OperatingExpenseCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? label = null,Object? type = null,Object? custom = null,Object? id = freezed,}) {
  return _then(_OperatingExpenseCategory(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as OperatingExpenseType,custom: null == custom ? _self.custom : custom // ignore: cast_nullable_to_non_nullable
as bool,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$OperatingExpense {

 String get id; String get establishmentId; int get amountCents; OperatingExpenseType get type; String get category; String get supply; DateTime get date; DateTime get createdAt; DateTime get updatedAt; OperatingExpenseSyncStatus get syncStatus; String? get categoryLabel; String? get description; String? get receiptNumber; String? get loadedById; String? get loadedByName; String? get customCategoryId; String? get syncErrorCode;
/// Create a copy of OperatingExpense
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OperatingExpenseCopyWith<OperatingExpense> get copyWith => _$OperatingExpenseCopyWithImpl<OperatingExpense>(this as OperatingExpense, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OperatingExpense&&(identical(other.id, id) || other.id == id)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.amountCents, amountCents) || other.amountCents == amountCents)&&(identical(other.type, type) || other.type == type)&&(identical(other.category, category) || other.category == category)&&(identical(other.supply, supply) || other.supply == supply)&&(identical(other.date, date) || other.date == date)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.categoryLabel, categoryLabel) || other.categoryLabel == categoryLabel)&&(identical(other.description, description) || other.description == description)&&(identical(other.receiptNumber, receiptNumber) || other.receiptNumber == receiptNumber)&&(identical(other.loadedById, loadedById) || other.loadedById == loadedById)&&(identical(other.loadedByName, loadedByName) || other.loadedByName == loadedByName)&&(identical(other.customCategoryId, customCategoryId) || other.customCategoryId == customCategoryId)&&(identical(other.syncErrorCode, syncErrorCode) || other.syncErrorCode == syncErrorCode));
}


@override
int get hashCode => Object.hash(runtimeType,id,establishmentId,amountCents,type,category,supply,date,createdAt,updatedAt,syncStatus,categoryLabel,description,receiptNumber,loadedById,loadedByName,customCategoryId,syncErrorCode);

@override
String toString() {
  return 'OperatingExpense(id: $id, establishmentId: $establishmentId, amountCents: $amountCents, type: $type, category: $category, supply: $supply, date: $date, createdAt: $createdAt, updatedAt: $updatedAt, syncStatus: $syncStatus, categoryLabel: $categoryLabel, description: $description, receiptNumber: $receiptNumber, loadedById: $loadedById, loadedByName: $loadedByName, customCategoryId: $customCategoryId, syncErrorCode: $syncErrorCode)';
}


}

/// @nodoc
abstract mixin class $OperatingExpenseCopyWith<$Res>  {
  factory $OperatingExpenseCopyWith(OperatingExpense value, $Res Function(OperatingExpense) _then) = _$OperatingExpenseCopyWithImpl;
@useResult
$Res call({
 String id, String establishmentId, int amountCents, OperatingExpenseType type, String category, String supply, DateTime date, DateTime createdAt, DateTime updatedAt, OperatingExpenseSyncStatus syncStatus, String? categoryLabel, String? description, String? receiptNumber, String? loadedById, String? loadedByName, String? customCategoryId, String? syncErrorCode
});




}
/// @nodoc
class _$OperatingExpenseCopyWithImpl<$Res>
    implements $OperatingExpenseCopyWith<$Res> {
  _$OperatingExpenseCopyWithImpl(this._self, this._then);

  final OperatingExpense _self;
  final $Res Function(OperatingExpense) _then;

/// Create a copy of OperatingExpense
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? establishmentId = null,Object? amountCents = null,Object? type = null,Object? category = null,Object? supply = null,Object? date = null,Object? createdAt = null,Object? updatedAt = null,Object? syncStatus = null,Object? categoryLabel = freezed,Object? description = freezed,Object? receiptNumber = freezed,Object? loadedById = freezed,Object? loadedByName = freezed,Object? customCategoryId = freezed,Object? syncErrorCode = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,amountCents: null == amountCents ? _self.amountCents : amountCents // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as OperatingExpenseType,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,supply: null == supply ? _self.supply : supply // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as OperatingExpenseSyncStatus,categoryLabel: freezed == categoryLabel ? _self.categoryLabel : categoryLabel // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,receiptNumber: freezed == receiptNumber ? _self.receiptNumber : receiptNumber // ignore: cast_nullable_to_non_nullable
as String?,loadedById: freezed == loadedById ? _self.loadedById : loadedById // ignore: cast_nullable_to_non_nullable
as String?,loadedByName: freezed == loadedByName ? _self.loadedByName : loadedByName // ignore: cast_nullable_to_non_nullable
as String?,customCategoryId: freezed == customCategoryId ? _self.customCategoryId : customCategoryId // ignore: cast_nullable_to_non_nullable
as String?,syncErrorCode: freezed == syncErrorCode ? _self.syncErrorCode : syncErrorCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OperatingExpense].
extension OperatingExpensePatterns on OperatingExpense {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OperatingExpense value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OperatingExpense() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OperatingExpense value)  $default,){
final _that = this;
switch (_that) {
case _OperatingExpense():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OperatingExpense value)?  $default,){
final _that = this;
switch (_that) {
case _OperatingExpense() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String establishmentId,  int amountCents,  OperatingExpenseType type,  String category,  String supply,  DateTime date,  DateTime createdAt,  DateTime updatedAt,  OperatingExpenseSyncStatus syncStatus,  String? categoryLabel,  String? description,  String? receiptNumber,  String? loadedById,  String? loadedByName,  String? customCategoryId,  String? syncErrorCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OperatingExpense() when $default != null:
return $default(_that.id,_that.establishmentId,_that.amountCents,_that.type,_that.category,_that.supply,_that.date,_that.createdAt,_that.updatedAt,_that.syncStatus,_that.categoryLabel,_that.description,_that.receiptNumber,_that.loadedById,_that.loadedByName,_that.customCategoryId,_that.syncErrorCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String establishmentId,  int amountCents,  OperatingExpenseType type,  String category,  String supply,  DateTime date,  DateTime createdAt,  DateTime updatedAt,  OperatingExpenseSyncStatus syncStatus,  String? categoryLabel,  String? description,  String? receiptNumber,  String? loadedById,  String? loadedByName,  String? customCategoryId,  String? syncErrorCode)  $default,) {final _that = this;
switch (_that) {
case _OperatingExpense():
return $default(_that.id,_that.establishmentId,_that.amountCents,_that.type,_that.category,_that.supply,_that.date,_that.createdAt,_that.updatedAt,_that.syncStatus,_that.categoryLabel,_that.description,_that.receiptNumber,_that.loadedById,_that.loadedByName,_that.customCategoryId,_that.syncErrorCode);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String establishmentId,  int amountCents,  OperatingExpenseType type,  String category,  String supply,  DateTime date,  DateTime createdAt,  DateTime updatedAt,  OperatingExpenseSyncStatus syncStatus,  String? categoryLabel,  String? description,  String? receiptNumber,  String? loadedById,  String? loadedByName,  String? customCategoryId,  String? syncErrorCode)?  $default,) {final _that = this;
switch (_that) {
case _OperatingExpense() when $default != null:
return $default(_that.id,_that.establishmentId,_that.amountCents,_that.type,_that.category,_that.supply,_that.date,_that.createdAt,_that.updatedAt,_that.syncStatus,_that.categoryLabel,_that.description,_that.receiptNumber,_that.loadedById,_that.loadedByName,_that.customCategoryId,_that.syncErrorCode);case _:
  return null;

}
}

}

/// @nodoc


class _OperatingExpense implements OperatingExpense {
  const _OperatingExpense({required this.id, required this.establishmentId, required this.amountCents, required this.type, required this.category, required this.supply, required this.date, required this.createdAt, required this.updatedAt, required this.syncStatus, this.categoryLabel, this.description, this.receiptNumber, this.loadedById, this.loadedByName, this.customCategoryId, this.syncErrorCode});
  

@override final  String id;
@override final  String establishmentId;
@override final  int amountCents;
@override final  OperatingExpenseType type;
@override final  String category;
@override final  String supply;
@override final  DateTime date;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  OperatingExpenseSyncStatus syncStatus;
@override final  String? categoryLabel;
@override final  String? description;
@override final  String? receiptNumber;
@override final  String? loadedById;
@override final  String? loadedByName;
@override final  String? customCategoryId;
@override final  String? syncErrorCode;

/// Create a copy of OperatingExpense
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OperatingExpenseCopyWith<_OperatingExpense> get copyWith => __$OperatingExpenseCopyWithImpl<_OperatingExpense>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OperatingExpense&&(identical(other.id, id) || other.id == id)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.amountCents, amountCents) || other.amountCents == amountCents)&&(identical(other.type, type) || other.type == type)&&(identical(other.category, category) || other.category == category)&&(identical(other.supply, supply) || other.supply == supply)&&(identical(other.date, date) || other.date == date)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.categoryLabel, categoryLabel) || other.categoryLabel == categoryLabel)&&(identical(other.description, description) || other.description == description)&&(identical(other.receiptNumber, receiptNumber) || other.receiptNumber == receiptNumber)&&(identical(other.loadedById, loadedById) || other.loadedById == loadedById)&&(identical(other.loadedByName, loadedByName) || other.loadedByName == loadedByName)&&(identical(other.customCategoryId, customCategoryId) || other.customCategoryId == customCategoryId)&&(identical(other.syncErrorCode, syncErrorCode) || other.syncErrorCode == syncErrorCode));
}


@override
int get hashCode => Object.hash(runtimeType,id,establishmentId,amountCents,type,category,supply,date,createdAt,updatedAt,syncStatus,categoryLabel,description,receiptNumber,loadedById,loadedByName,customCategoryId,syncErrorCode);

@override
String toString() {
  return 'OperatingExpense(id: $id, establishmentId: $establishmentId, amountCents: $amountCents, type: $type, category: $category, supply: $supply, date: $date, createdAt: $createdAt, updatedAt: $updatedAt, syncStatus: $syncStatus, categoryLabel: $categoryLabel, description: $description, receiptNumber: $receiptNumber, loadedById: $loadedById, loadedByName: $loadedByName, customCategoryId: $customCategoryId, syncErrorCode: $syncErrorCode)';
}


}

/// @nodoc
abstract mixin class _$OperatingExpenseCopyWith<$Res> implements $OperatingExpenseCopyWith<$Res> {
  factory _$OperatingExpenseCopyWith(_OperatingExpense value, $Res Function(_OperatingExpense) _then) = __$OperatingExpenseCopyWithImpl;
@override @useResult
$Res call({
 String id, String establishmentId, int amountCents, OperatingExpenseType type, String category, String supply, DateTime date, DateTime createdAt, DateTime updatedAt, OperatingExpenseSyncStatus syncStatus, String? categoryLabel, String? description, String? receiptNumber, String? loadedById, String? loadedByName, String? customCategoryId, String? syncErrorCode
});




}
/// @nodoc
class __$OperatingExpenseCopyWithImpl<$Res>
    implements _$OperatingExpenseCopyWith<$Res> {
  __$OperatingExpenseCopyWithImpl(this._self, this._then);

  final _OperatingExpense _self;
  final $Res Function(_OperatingExpense) _then;

/// Create a copy of OperatingExpense
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? establishmentId = null,Object? amountCents = null,Object? type = null,Object? category = null,Object? supply = null,Object? date = null,Object? createdAt = null,Object? updatedAt = null,Object? syncStatus = null,Object? categoryLabel = freezed,Object? description = freezed,Object? receiptNumber = freezed,Object? loadedById = freezed,Object? loadedByName = freezed,Object? customCategoryId = freezed,Object? syncErrorCode = freezed,}) {
  return _then(_OperatingExpense(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,amountCents: null == amountCents ? _self.amountCents : amountCents // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as OperatingExpenseType,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,supply: null == supply ? _self.supply : supply // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as OperatingExpenseSyncStatus,categoryLabel: freezed == categoryLabel ? _self.categoryLabel : categoryLabel // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,receiptNumber: freezed == receiptNumber ? _self.receiptNumber : receiptNumber // ignore: cast_nullable_to_non_nullable
as String?,loadedById: freezed == loadedById ? _self.loadedById : loadedById // ignore: cast_nullable_to_non_nullable
as String?,loadedByName: freezed == loadedByName ? _self.loadedByName : loadedByName // ignore: cast_nullable_to_non_nullable
as String?,customCategoryId: freezed == customCategoryId ? _self.customCategoryId : customCategoryId // ignore: cast_nullable_to_non_nullable
as String?,syncErrorCode: freezed == syncErrorCode ? _self.syncErrorCode : syncErrorCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
