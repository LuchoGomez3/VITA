// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'operating_expense_history_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OperatingExpenseHistoryState {

 OperatingExpenseFilters get filters; ResultState<OperatingExpenseHistory> get history; ResultState<OperatingExpenseExport> get export; List<OperatingExpenseCategory> get categories; bool get refreshing; String? get message;
/// Create a copy of OperatingExpenseHistoryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OperatingExpenseHistoryStateCopyWith<OperatingExpenseHistoryState> get copyWith => _$OperatingExpenseHistoryStateCopyWithImpl<OperatingExpenseHistoryState>(this as OperatingExpenseHistoryState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OperatingExpenseHistoryState&&(identical(other.filters, filters) || other.filters == filters)&&(identical(other.history, history) || other.history == history)&&(identical(other.export, export) || other.export == export)&&const DeepCollectionEquality().equals(other.categories, categories)&&(identical(other.refreshing, refreshing) || other.refreshing == refreshing)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,filters,history,export,const DeepCollectionEquality().hash(categories),refreshing,message);

@override
String toString() {
  return 'OperatingExpenseHistoryState(filters: $filters, history: $history, export: $export, categories: $categories, refreshing: $refreshing, message: $message)';
}


}

/// @nodoc
abstract mixin class $OperatingExpenseHistoryStateCopyWith<$Res>  {
  factory $OperatingExpenseHistoryStateCopyWith(OperatingExpenseHistoryState value, $Res Function(OperatingExpenseHistoryState) _then) = _$OperatingExpenseHistoryStateCopyWithImpl;
@useResult
$Res call({
 OperatingExpenseFilters filters, ResultState<OperatingExpenseHistory> history, ResultState<OperatingExpenseExport> export, List<OperatingExpenseCategory> categories, bool refreshing, String? message
});


$OperatingExpenseFiltersCopyWith<$Res> get filters;$ResultStateCopyWith<OperatingExpenseHistory, $Res> get history;$ResultStateCopyWith<OperatingExpenseExport, $Res> get export;

}
/// @nodoc
class _$OperatingExpenseHistoryStateCopyWithImpl<$Res>
    implements $OperatingExpenseHistoryStateCopyWith<$Res> {
  _$OperatingExpenseHistoryStateCopyWithImpl(this._self, this._then);

  final OperatingExpenseHistoryState _self;
  final $Res Function(OperatingExpenseHistoryState) _then;

/// Create a copy of OperatingExpenseHistoryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? filters = null,Object? history = null,Object? export = null,Object? categories = null,Object? refreshing = null,Object? message = freezed,}) {
  return _then(_self.copyWith(
filters: null == filters ? _self.filters : filters // ignore: cast_nullable_to_non_nullable
as OperatingExpenseFilters,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as ResultState<OperatingExpenseHistory>,export: null == export ? _self.export : export // ignore: cast_nullable_to_non_nullable
as ResultState<OperatingExpenseExport>,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<OperatingExpenseCategory>,refreshing: null == refreshing ? _self.refreshing : refreshing // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of OperatingExpenseHistoryState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OperatingExpenseFiltersCopyWith<$Res> get filters {
  
  return $OperatingExpenseFiltersCopyWith<$Res>(_self.filters, (value) {
    return _then(_self.copyWith(filters: value));
  });
}/// Create a copy of OperatingExpenseHistoryState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<OperatingExpenseHistory, $Res> get history {
  
  return $ResultStateCopyWith<OperatingExpenseHistory, $Res>(_self.history, (value) {
    return _then(_self.copyWith(history: value));
  });
}/// Create a copy of OperatingExpenseHistoryState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<OperatingExpenseExport, $Res> get export {
  
  return $ResultStateCopyWith<OperatingExpenseExport, $Res>(_self.export, (value) {
    return _then(_self.copyWith(export: value));
  });
}
}


/// Adds pattern-matching-related methods to [OperatingExpenseHistoryState].
extension OperatingExpenseHistoryStatePatterns on OperatingExpenseHistoryState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OperatingExpenseHistoryState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OperatingExpenseHistoryState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OperatingExpenseHistoryState value)  $default,){
final _that = this;
switch (_that) {
case _OperatingExpenseHistoryState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OperatingExpenseHistoryState value)?  $default,){
final _that = this;
switch (_that) {
case _OperatingExpenseHistoryState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( OperatingExpenseFilters filters,  ResultState<OperatingExpenseHistory> history,  ResultState<OperatingExpenseExport> export,  List<OperatingExpenseCategory> categories,  bool refreshing,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OperatingExpenseHistoryState() when $default != null:
return $default(_that.filters,_that.history,_that.export,_that.categories,_that.refreshing,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( OperatingExpenseFilters filters,  ResultState<OperatingExpenseHistory> history,  ResultState<OperatingExpenseExport> export,  List<OperatingExpenseCategory> categories,  bool refreshing,  String? message)  $default,) {final _that = this;
switch (_that) {
case _OperatingExpenseHistoryState():
return $default(_that.filters,_that.history,_that.export,_that.categories,_that.refreshing,_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( OperatingExpenseFilters filters,  ResultState<OperatingExpenseHistory> history,  ResultState<OperatingExpenseExport> export,  List<OperatingExpenseCategory> categories,  bool refreshing,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _OperatingExpenseHistoryState() when $default != null:
return $default(_that.filters,_that.history,_that.export,_that.categories,_that.refreshing,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _OperatingExpenseHistoryState implements OperatingExpenseHistoryState {
  const _OperatingExpenseHistoryState({required this.filters, this.history = const ResultState<OperatingExpenseHistory>.initial(), this.export = const ResultState<OperatingExpenseExport>.initial(), final  List<OperatingExpenseCategory> categories = const <OperatingExpenseCategory>[], this.refreshing = false, this.message}): _categories = categories;
  

@override final  OperatingExpenseFilters filters;
@override@JsonKey() final  ResultState<OperatingExpenseHistory> history;
@override@JsonKey() final  ResultState<OperatingExpenseExport> export;
 final  List<OperatingExpenseCategory> _categories;
@override@JsonKey() List<OperatingExpenseCategory> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

@override@JsonKey() final  bool refreshing;
@override final  String? message;

/// Create a copy of OperatingExpenseHistoryState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OperatingExpenseHistoryStateCopyWith<_OperatingExpenseHistoryState> get copyWith => __$OperatingExpenseHistoryStateCopyWithImpl<_OperatingExpenseHistoryState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OperatingExpenseHistoryState&&(identical(other.filters, filters) || other.filters == filters)&&(identical(other.history, history) || other.history == history)&&(identical(other.export, export) || other.export == export)&&const DeepCollectionEquality().equals(other._categories, _categories)&&(identical(other.refreshing, refreshing) || other.refreshing == refreshing)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,filters,history,export,const DeepCollectionEquality().hash(_categories),refreshing,message);

@override
String toString() {
  return 'OperatingExpenseHistoryState(filters: $filters, history: $history, export: $export, categories: $categories, refreshing: $refreshing, message: $message)';
}


}

/// @nodoc
abstract mixin class _$OperatingExpenseHistoryStateCopyWith<$Res> implements $OperatingExpenseHistoryStateCopyWith<$Res> {
  factory _$OperatingExpenseHistoryStateCopyWith(_OperatingExpenseHistoryState value, $Res Function(_OperatingExpenseHistoryState) _then) = __$OperatingExpenseHistoryStateCopyWithImpl;
@override @useResult
$Res call({
 OperatingExpenseFilters filters, ResultState<OperatingExpenseHistory> history, ResultState<OperatingExpenseExport> export, List<OperatingExpenseCategory> categories, bool refreshing, String? message
});


@override $OperatingExpenseFiltersCopyWith<$Res> get filters;@override $ResultStateCopyWith<OperatingExpenseHistory, $Res> get history;@override $ResultStateCopyWith<OperatingExpenseExport, $Res> get export;

}
/// @nodoc
class __$OperatingExpenseHistoryStateCopyWithImpl<$Res>
    implements _$OperatingExpenseHistoryStateCopyWith<$Res> {
  __$OperatingExpenseHistoryStateCopyWithImpl(this._self, this._then);

  final _OperatingExpenseHistoryState _self;
  final $Res Function(_OperatingExpenseHistoryState) _then;

/// Create a copy of OperatingExpenseHistoryState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? filters = null,Object? history = null,Object? export = null,Object? categories = null,Object? refreshing = null,Object? message = freezed,}) {
  return _then(_OperatingExpenseHistoryState(
filters: null == filters ? _self.filters : filters // ignore: cast_nullable_to_non_nullable
as OperatingExpenseFilters,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as ResultState<OperatingExpenseHistory>,export: null == export ? _self.export : export // ignore: cast_nullable_to_non_nullable
as ResultState<OperatingExpenseExport>,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<OperatingExpenseCategory>,refreshing: null == refreshing ? _self.refreshing : refreshing // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of OperatingExpenseHistoryState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OperatingExpenseFiltersCopyWith<$Res> get filters {
  
  return $OperatingExpenseFiltersCopyWith<$Res>(_self.filters, (value) {
    return _then(_self.copyWith(filters: value));
  });
}/// Create a copy of OperatingExpenseHistoryState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<OperatingExpenseHistory, $Res> get history {
  
  return $ResultStateCopyWith<OperatingExpenseHistory, $Res>(_self.history, (value) {
    return _then(_self.copyWith(history: value));
  });
}/// Create a copy of OperatingExpenseHistoryState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<OperatingExpenseExport, $Res> get export {
  
  return $ResultStateCopyWith<OperatingExpenseExport, $Res>(_self.export, (value) {
    return _then(_self.copyWith(export: value));
  });
}
}

// dart format on
