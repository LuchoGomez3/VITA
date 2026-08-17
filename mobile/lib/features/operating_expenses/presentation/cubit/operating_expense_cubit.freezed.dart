// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'operating_expense_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OperatingExpenseState {

 OperatingExpenseType get type; DateTime get date; List<OperatingExpenseCategory> get categories; ResultState<void> get saveState; String? get selectedCategory; String? get selectedCustomCategoryId; OperatingExpense? get savedExpense; String? get errorMessage;
/// Create a copy of OperatingExpenseState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OperatingExpenseStateCopyWith<OperatingExpenseState> get copyWith => _$OperatingExpenseStateCopyWithImpl<OperatingExpenseState>(this as OperatingExpenseState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OperatingExpenseState&&(identical(other.type, type) || other.type == type)&&(identical(other.date, date) || other.date == date)&&const DeepCollectionEquality().equals(other.categories, categories)&&(identical(other.saveState, saveState) || other.saveState == saveState)&&(identical(other.selectedCategory, selectedCategory) || other.selectedCategory == selectedCategory)&&(identical(other.selectedCustomCategoryId, selectedCustomCategoryId) || other.selectedCustomCategoryId == selectedCustomCategoryId)&&(identical(other.savedExpense, savedExpense) || other.savedExpense == savedExpense)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,type,date,const DeepCollectionEquality().hash(categories),saveState,selectedCategory,selectedCustomCategoryId,savedExpense,errorMessage);

@override
String toString() {
  return 'OperatingExpenseState(type: $type, date: $date, categories: $categories, saveState: $saveState, selectedCategory: $selectedCategory, selectedCustomCategoryId: $selectedCustomCategoryId, savedExpense: $savedExpense, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $OperatingExpenseStateCopyWith<$Res>  {
  factory $OperatingExpenseStateCopyWith(OperatingExpenseState value, $Res Function(OperatingExpenseState) _then) = _$OperatingExpenseStateCopyWithImpl;
@useResult
$Res call({
 OperatingExpenseType type, DateTime date, List<OperatingExpenseCategory> categories, ResultState<void> saveState, String? selectedCategory, String? selectedCustomCategoryId, OperatingExpense? savedExpense, String? errorMessage
});


$ResultStateCopyWith<void, $Res> get saveState;$OperatingExpenseCopyWith<$Res>? get savedExpense;

}
/// @nodoc
class _$OperatingExpenseStateCopyWithImpl<$Res>
    implements $OperatingExpenseStateCopyWith<$Res> {
  _$OperatingExpenseStateCopyWithImpl(this._self, this._then);

  final OperatingExpenseState _self;
  final $Res Function(OperatingExpenseState) _then;

/// Create a copy of OperatingExpenseState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? date = null,Object? categories = null,Object? saveState = null,Object? selectedCategory = freezed,Object? selectedCustomCategoryId = freezed,Object? savedExpense = freezed,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as OperatingExpenseType,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<OperatingExpenseCategory>,saveState: null == saveState ? _self.saveState : saveState // ignore: cast_nullable_to_non_nullable
as ResultState<void>,selectedCategory: freezed == selectedCategory ? _self.selectedCategory : selectedCategory // ignore: cast_nullable_to_non_nullable
as String?,selectedCustomCategoryId: freezed == selectedCustomCategoryId ? _self.selectedCustomCategoryId : selectedCustomCategoryId // ignore: cast_nullable_to_non_nullable
as String?,savedExpense: freezed == savedExpense ? _self.savedExpense : savedExpense // ignore: cast_nullable_to_non_nullable
as OperatingExpense?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of OperatingExpenseState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<void, $Res> get saveState {
  
  return $ResultStateCopyWith<void, $Res>(_self.saveState, (value) {
    return _then(_self.copyWith(saveState: value));
  });
}/// Create a copy of OperatingExpenseState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OperatingExpenseCopyWith<$Res>? get savedExpense {
    if (_self.savedExpense == null) {
    return null;
  }

  return $OperatingExpenseCopyWith<$Res>(_self.savedExpense!, (value) {
    return _then(_self.copyWith(savedExpense: value));
  });
}
}


/// Adds pattern-matching-related methods to [OperatingExpenseState].
extension OperatingExpenseStatePatterns on OperatingExpenseState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OperatingExpenseState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OperatingExpenseState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OperatingExpenseState value)  $default,){
final _that = this;
switch (_that) {
case _OperatingExpenseState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OperatingExpenseState value)?  $default,){
final _that = this;
switch (_that) {
case _OperatingExpenseState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( OperatingExpenseType type,  DateTime date,  List<OperatingExpenseCategory> categories,  ResultState<void> saveState,  String? selectedCategory,  String? selectedCustomCategoryId,  OperatingExpense? savedExpense,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OperatingExpenseState() when $default != null:
return $default(_that.type,_that.date,_that.categories,_that.saveState,_that.selectedCategory,_that.selectedCustomCategoryId,_that.savedExpense,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( OperatingExpenseType type,  DateTime date,  List<OperatingExpenseCategory> categories,  ResultState<void> saveState,  String? selectedCategory,  String? selectedCustomCategoryId,  OperatingExpense? savedExpense,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _OperatingExpenseState():
return $default(_that.type,_that.date,_that.categories,_that.saveState,_that.selectedCategory,_that.selectedCustomCategoryId,_that.savedExpense,_that.errorMessage);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( OperatingExpenseType type,  DateTime date,  List<OperatingExpenseCategory> categories,  ResultState<void> saveState,  String? selectedCategory,  String? selectedCustomCategoryId,  OperatingExpense? savedExpense,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _OperatingExpenseState() when $default != null:
return $default(_that.type,_that.date,_that.categories,_that.saveState,_that.selectedCategory,_that.selectedCustomCategoryId,_that.savedExpense,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _OperatingExpenseState implements OperatingExpenseState {
  const _OperatingExpenseState({required this.type, required this.date, final  List<OperatingExpenseCategory> categories = const <OperatingExpenseCategory>[], this.saveState = const ResultState<void>.initial(), this.selectedCategory, this.selectedCustomCategoryId, this.savedExpense, this.errorMessage}): _categories = categories;
  

@override final  OperatingExpenseType type;
@override final  DateTime date;
 final  List<OperatingExpenseCategory> _categories;
@override@JsonKey() List<OperatingExpenseCategory> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

@override@JsonKey() final  ResultState<void> saveState;
@override final  String? selectedCategory;
@override final  String? selectedCustomCategoryId;
@override final  OperatingExpense? savedExpense;
@override final  String? errorMessage;

/// Create a copy of OperatingExpenseState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OperatingExpenseStateCopyWith<_OperatingExpenseState> get copyWith => __$OperatingExpenseStateCopyWithImpl<_OperatingExpenseState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OperatingExpenseState&&(identical(other.type, type) || other.type == type)&&(identical(other.date, date) || other.date == date)&&const DeepCollectionEquality().equals(other._categories, _categories)&&(identical(other.saveState, saveState) || other.saveState == saveState)&&(identical(other.selectedCategory, selectedCategory) || other.selectedCategory == selectedCategory)&&(identical(other.selectedCustomCategoryId, selectedCustomCategoryId) || other.selectedCustomCategoryId == selectedCustomCategoryId)&&(identical(other.savedExpense, savedExpense) || other.savedExpense == savedExpense)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,type,date,const DeepCollectionEquality().hash(_categories),saveState,selectedCategory,selectedCustomCategoryId,savedExpense,errorMessage);

@override
String toString() {
  return 'OperatingExpenseState(type: $type, date: $date, categories: $categories, saveState: $saveState, selectedCategory: $selectedCategory, selectedCustomCategoryId: $selectedCustomCategoryId, savedExpense: $savedExpense, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$OperatingExpenseStateCopyWith<$Res> implements $OperatingExpenseStateCopyWith<$Res> {
  factory _$OperatingExpenseStateCopyWith(_OperatingExpenseState value, $Res Function(_OperatingExpenseState) _then) = __$OperatingExpenseStateCopyWithImpl;
@override @useResult
$Res call({
 OperatingExpenseType type, DateTime date, List<OperatingExpenseCategory> categories, ResultState<void> saveState, String? selectedCategory, String? selectedCustomCategoryId, OperatingExpense? savedExpense, String? errorMessage
});


@override $ResultStateCopyWith<void, $Res> get saveState;@override $OperatingExpenseCopyWith<$Res>? get savedExpense;

}
/// @nodoc
class __$OperatingExpenseStateCopyWithImpl<$Res>
    implements _$OperatingExpenseStateCopyWith<$Res> {
  __$OperatingExpenseStateCopyWithImpl(this._self, this._then);

  final _OperatingExpenseState _self;
  final $Res Function(_OperatingExpenseState) _then;

/// Create a copy of OperatingExpenseState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? date = null,Object? categories = null,Object? saveState = null,Object? selectedCategory = freezed,Object? selectedCustomCategoryId = freezed,Object? savedExpense = freezed,Object? errorMessage = freezed,}) {
  return _then(_OperatingExpenseState(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as OperatingExpenseType,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<OperatingExpenseCategory>,saveState: null == saveState ? _self.saveState : saveState // ignore: cast_nullable_to_non_nullable
as ResultState<void>,selectedCategory: freezed == selectedCategory ? _self.selectedCategory : selectedCategory // ignore: cast_nullable_to_non_nullable
as String?,selectedCustomCategoryId: freezed == selectedCustomCategoryId ? _self.selectedCustomCategoryId : selectedCustomCategoryId // ignore: cast_nullable_to_non_nullable
as String?,savedExpense: freezed == savedExpense ? _self.savedExpense : savedExpense // ignore: cast_nullable_to_non_nullable
as OperatingExpense?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of OperatingExpenseState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<void, $Res> get saveState {
  
  return $ResultStateCopyWith<void, $Res>(_self.saveState, (value) {
    return _then(_self.copyWith(saveState: value));
  });
}/// Create a copy of OperatingExpenseState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OperatingExpenseCopyWith<$Res>? get savedExpense {
    if (_self.savedExpense == null) {
    return null;
  }

  return $OperatingExpenseCopyWith<$Res>(_self.savedExpense!, (value) {
    return _then(_self.copyWith(savedExpense: value));
  });
}
}

// dart format on
