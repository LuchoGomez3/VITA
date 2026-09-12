// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'operating_expense_history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OperatingExpenseFilters {

 OperatingExpensePeriod get period; DateTime? get from; DateTime? get to; OperatingExpenseType? get type; String? get category;
/// Create a copy of OperatingExpenseFilters
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OperatingExpenseFiltersCopyWith<OperatingExpenseFilters> get copyWith => _$OperatingExpenseFiltersCopyWithImpl<OperatingExpenseFilters>(this as OperatingExpenseFilters, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OperatingExpenseFilters&&(identical(other.period, period) || other.period == period)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.type, type) || other.type == type)&&(identical(other.category, category) || other.category == category));
}


@override
int get hashCode => Object.hash(runtimeType,period,from,to,type,category);

@override
String toString() {
  return 'OperatingExpenseFilters(period: $period, from: $from, to: $to, type: $type, category: $category)';
}


}

/// @nodoc
abstract mixin class $OperatingExpenseFiltersCopyWith<$Res>  {
  factory $OperatingExpenseFiltersCopyWith(OperatingExpenseFilters value, $Res Function(OperatingExpenseFilters) _then) = _$OperatingExpenseFiltersCopyWithImpl;
@useResult
$Res call({
 OperatingExpensePeriod period, DateTime? from, DateTime? to, OperatingExpenseType? type, String? category
});




}
/// @nodoc
class _$OperatingExpenseFiltersCopyWithImpl<$Res>
    implements $OperatingExpenseFiltersCopyWith<$Res> {
  _$OperatingExpenseFiltersCopyWithImpl(this._self, this._then);

  final OperatingExpenseFilters _self;
  final $Res Function(OperatingExpenseFilters) _then;

/// Create a copy of OperatingExpenseFilters
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? period = null,Object? from = freezed,Object? to = freezed,Object? type = freezed,Object? category = freezed,}) {
  return _then(_self.copyWith(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as OperatingExpensePeriod,from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime?,to: freezed == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as OperatingExpenseType?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OperatingExpenseFilters].
extension OperatingExpenseFiltersPatterns on OperatingExpenseFilters {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OperatingExpenseFilters value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OperatingExpenseFilters() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OperatingExpenseFilters value)  $default,){
final _that = this;
switch (_that) {
case _OperatingExpenseFilters():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OperatingExpenseFilters value)?  $default,){
final _that = this;
switch (_that) {
case _OperatingExpenseFilters() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( OperatingExpensePeriod period,  DateTime? from,  DateTime? to,  OperatingExpenseType? type,  String? category)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OperatingExpenseFilters() when $default != null:
return $default(_that.period,_that.from,_that.to,_that.type,_that.category);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( OperatingExpensePeriod period,  DateTime? from,  DateTime? to,  OperatingExpenseType? type,  String? category)  $default,) {final _that = this;
switch (_that) {
case _OperatingExpenseFilters():
return $default(_that.period,_that.from,_that.to,_that.type,_that.category);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( OperatingExpensePeriod period,  DateTime? from,  DateTime? to,  OperatingExpenseType? type,  String? category)?  $default,) {final _that = this;
switch (_that) {
case _OperatingExpenseFilters() when $default != null:
return $default(_that.period,_that.from,_that.to,_that.type,_that.category);case _:
  return null;

}
}

}

/// @nodoc


class _OperatingExpenseFilters extends OperatingExpenseFilters {
  const _OperatingExpenseFilters({required this.period, this.from, this.to, this.type, this.category}): super._();
  

@override final  OperatingExpensePeriod period;
@override final  DateTime? from;
@override final  DateTime? to;
@override final  OperatingExpenseType? type;
@override final  String? category;

/// Create a copy of OperatingExpenseFilters
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OperatingExpenseFiltersCopyWith<_OperatingExpenseFilters> get copyWith => __$OperatingExpenseFiltersCopyWithImpl<_OperatingExpenseFilters>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OperatingExpenseFilters&&(identical(other.period, period) || other.period == period)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.type, type) || other.type == type)&&(identical(other.category, category) || other.category == category));
}


@override
int get hashCode => Object.hash(runtimeType,period,from,to,type,category);

@override
String toString() {
  return 'OperatingExpenseFilters(period: $period, from: $from, to: $to, type: $type, category: $category)';
}


}

/// @nodoc
abstract mixin class _$OperatingExpenseFiltersCopyWith<$Res> implements $OperatingExpenseFiltersCopyWith<$Res> {
  factory _$OperatingExpenseFiltersCopyWith(_OperatingExpenseFilters value, $Res Function(_OperatingExpenseFilters) _then) = __$OperatingExpenseFiltersCopyWithImpl;
@override @useResult
$Res call({
 OperatingExpensePeriod period, DateTime? from, DateTime? to, OperatingExpenseType? type, String? category
});




}
/// @nodoc
class __$OperatingExpenseFiltersCopyWithImpl<$Res>
    implements _$OperatingExpenseFiltersCopyWith<$Res> {
  __$OperatingExpenseFiltersCopyWithImpl(this._self, this._then);

  final _OperatingExpenseFilters _self;
  final $Res Function(_OperatingExpenseFilters) _then;

/// Create a copy of OperatingExpenseFilters
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? period = null,Object? from = freezed,Object? to = freezed,Object? type = freezed,Object? category = freezed,}) {
  return _then(_OperatingExpenseFilters(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as OperatingExpensePeriod,from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime?,to: freezed == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as OperatingExpenseType?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$OperatingExpenseHistory {

 List<OperatingExpense> get expenses; int get totalCents; bool get cachedWithoutConnection; int get pendingCount; bool get totalIncludesPending;
/// Create a copy of OperatingExpenseHistory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OperatingExpenseHistoryCopyWith<OperatingExpenseHistory> get copyWith => _$OperatingExpenseHistoryCopyWithImpl<OperatingExpenseHistory>(this as OperatingExpenseHistory, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OperatingExpenseHistory&&const DeepCollectionEquality().equals(other.expenses, expenses)&&(identical(other.totalCents, totalCents) || other.totalCents == totalCents)&&(identical(other.cachedWithoutConnection, cachedWithoutConnection) || other.cachedWithoutConnection == cachedWithoutConnection)&&(identical(other.pendingCount, pendingCount) || other.pendingCount == pendingCount)&&(identical(other.totalIncludesPending, totalIncludesPending) || other.totalIncludesPending == totalIncludesPending));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(expenses),totalCents,cachedWithoutConnection,pendingCount,totalIncludesPending);

@override
String toString() {
  return 'OperatingExpenseHistory(expenses: $expenses, totalCents: $totalCents, cachedWithoutConnection: $cachedWithoutConnection, pendingCount: $pendingCount, totalIncludesPending: $totalIncludesPending)';
}


}

/// @nodoc
abstract mixin class $OperatingExpenseHistoryCopyWith<$Res>  {
  factory $OperatingExpenseHistoryCopyWith(OperatingExpenseHistory value, $Res Function(OperatingExpenseHistory) _then) = _$OperatingExpenseHistoryCopyWithImpl;
@useResult
$Res call({
 List<OperatingExpense> expenses, int totalCents, bool cachedWithoutConnection, int pendingCount, bool totalIncludesPending
});




}
/// @nodoc
class _$OperatingExpenseHistoryCopyWithImpl<$Res>
    implements $OperatingExpenseHistoryCopyWith<$Res> {
  _$OperatingExpenseHistoryCopyWithImpl(this._self, this._then);

  final OperatingExpenseHistory _self;
  final $Res Function(OperatingExpenseHistory) _then;

/// Create a copy of OperatingExpenseHistory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? expenses = null,Object? totalCents = null,Object? cachedWithoutConnection = null,Object? pendingCount = null,Object? totalIncludesPending = null,}) {
  return _then(_self.copyWith(
expenses: null == expenses ? _self.expenses : expenses // ignore: cast_nullable_to_non_nullable
as List<OperatingExpense>,totalCents: null == totalCents ? _self.totalCents : totalCents // ignore: cast_nullable_to_non_nullable
as int,cachedWithoutConnection: null == cachedWithoutConnection ? _self.cachedWithoutConnection : cachedWithoutConnection // ignore: cast_nullable_to_non_nullable
as bool,pendingCount: null == pendingCount ? _self.pendingCount : pendingCount // ignore: cast_nullable_to_non_nullable
as int,totalIncludesPending: null == totalIncludesPending ? _self.totalIncludesPending : totalIncludesPending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [OperatingExpenseHistory].
extension OperatingExpenseHistoryPatterns on OperatingExpenseHistory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OperatingExpenseHistory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OperatingExpenseHistory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OperatingExpenseHistory value)  $default,){
final _that = this;
switch (_that) {
case _OperatingExpenseHistory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OperatingExpenseHistory value)?  $default,){
final _that = this;
switch (_that) {
case _OperatingExpenseHistory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<OperatingExpense> expenses,  int totalCents,  bool cachedWithoutConnection,  int pendingCount,  bool totalIncludesPending)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OperatingExpenseHistory() when $default != null:
return $default(_that.expenses,_that.totalCents,_that.cachedWithoutConnection,_that.pendingCount,_that.totalIncludesPending);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<OperatingExpense> expenses,  int totalCents,  bool cachedWithoutConnection,  int pendingCount,  bool totalIncludesPending)  $default,) {final _that = this;
switch (_that) {
case _OperatingExpenseHistory():
return $default(_that.expenses,_that.totalCents,_that.cachedWithoutConnection,_that.pendingCount,_that.totalIncludesPending);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<OperatingExpense> expenses,  int totalCents,  bool cachedWithoutConnection,  int pendingCount,  bool totalIncludesPending)?  $default,) {final _that = this;
switch (_that) {
case _OperatingExpenseHistory() when $default != null:
return $default(_that.expenses,_that.totalCents,_that.cachedWithoutConnection,_that.pendingCount,_that.totalIncludesPending);case _:
  return null;

}
}

}

/// @nodoc


class _OperatingExpenseHistory implements OperatingExpenseHistory {
  const _OperatingExpenseHistory({required final  List<OperatingExpense> expenses, required this.totalCents, required this.cachedWithoutConnection, this.pendingCount = 0, this.totalIncludesPending = false}): _expenses = expenses;
  

 final  List<OperatingExpense> _expenses;
@override List<OperatingExpense> get expenses {
  if (_expenses is EqualUnmodifiableListView) return _expenses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_expenses);
}

@override final  int totalCents;
@override final  bool cachedWithoutConnection;
@override@JsonKey() final  int pendingCount;
@override@JsonKey() final  bool totalIncludesPending;

/// Create a copy of OperatingExpenseHistory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OperatingExpenseHistoryCopyWith<_OperatingExpenseHistory> get copyWith => __$OperatingExpenseHistoryCopyWithImpl<_OperatingExpenseHistory>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OperatingExpenseHistory&&const DeepCollectionEquality().equals(other._expenses, _expenses)&&(identical(other.totalCents, totalCents) || other.totalCents == totalCents)&&(identical(other.cachedWithoutConnection, cachedWithoutConnection) || other.cachedWithoutConnection == cachedWithoutConnection)&&(identical(other.pendingCount, pendingCount) || other.pendingCount == pendingCount)&&(identical(other.totalIncludesPending, totalIncludesPending) || other.totalIncludesPending == totalIncludesPending));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_expenses),totalCents,cachedWithoutConnection,pendingCount,totalIncludesPending);

@override
String toString() {
  return 'OperatingExpenseHistory(expenses: $expenses, totalCents: $totalCents, cachedWithoutConnection: $cachedWithoutConnection, pendingCount: $pendingCount, totalIncludesPending: $totalIncludesPending)';
}


}

/// @nodoc
abstract mixin class _$OperatingExpenseHistoryCopyWith<$Res> implements $OperatingExpenseHistoryCopyWith<$Res> {
  factory _$OperatingExpenseHistoryCopyWith(_OperatingExpenseHistory value, $Res Function(_OperatingExpenseHistory) _then) = __$OperatingExpenseHistoryCopyWithImpl;
@override @useResult
$Res call({
 List<OperatingExpense> expenses, int totalCents, bool cachedWithoutConnection, int pendingCount, bool totalIncludesPending
});




}
/// @nodoc
class __$OperatingExpenseHistoryCopyWithImpl<$Res>
    implements _$OperatingExpenseHistoryCopyWith<$Res> {
  __$OperatingExpenseHistoryCopyWithImpl(this._self, this._then);

  final _OperatingExpenseHistory _self;
  final $Res Function(_OperatingExpenseHistory) _then;

/// Create a copy of OperatingExpenseHistory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? expenses = null,Object? totalCents = null,Object? cachedWithoutConnection = null,Object? pendingCount = null,Object? totalIncludesPending = null,}) {
  return _then(_OperatingExpenseHistory(
expenses: null == expenses ? _self._expenses : expenses // ignore: cast_nullable_to_non_nullable
as List<OperatingExpense>,totalCents: null == totalCents ? _self.totalCents : totalCents // ignore: cast_nullable_to_non_nullable
as int,cachedWithoutConnection: null == cachedWithoutConnection ? _self.cachedWithoutConnection : cachedWithoutConnection // ignore: cast_nullable_to_non_nullable
as bool,pendingCount: null == pendingCount ? _self.pendingCount : pendingCount // ignore: cast_nullable_to_non_nullable
as int,totalIncludesPending: null == totalIncludesPending ? _self.totalIncludesPending : totalIncludesPending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$OperatingExpenseExport {

 Uint8List get bytes; String get filename; String get mediaType;
/// Create a copy of OperatingExpenseExport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OperatingExpenseExportCopyWith<OperatingExpenseExport> get copyWith => _$OperatingExpenseExportCopyWithImpl<OperatingExpenseExport>(this as OperatingExpenseExport, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OperatingExpenseExport&&const DeepCollectionEquality().equals(other.bytes, bytes)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(bytes),filename,mediaType);

@override
String toString() {
  return 'OperatingExpenseExport(bytes: $bytes, filename: $filename, mediaType: $mediaType)';
}


}

/// @nodoc
abstract mixin class $OperatingExpenseExportCopyWith<$Res>  {
  factory $OperatingExpenseExportCopyWith(OperatingExpenseExport value, $Res Function(OperatingExpenseExport) _then) = _$OperatingExpenseExportCopyWithImpl;
@useResult
$Res call({
 Uint8List bytes, String filename, String mediaType
});




}
/// @nodoc
class _$OperatingExpenseExportCopyWithImpl<$Res>
    implements $OperatingExpenseExportCopyWith<$Res> {
  _$OperatingExpenseExportCopyWithImpl(this._self, this._then);

  final OperatingExpenseExport _self;
  final $Res Function(OperatingExpenseExport) _then;

/// Create a copy of OperatingExpenseExport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bytes = null,Object? filename = null,Object? mediaType = null,}) {
  return _then(_self.copyWith(
bytes: null == bytes ? _self.bytes : bytes // ignore: cast_nullable_to_non_nullable
as Uint8List,filename: null == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [OperatingExpenseExport].
extension OperatingExpenseExportPatterns on OperatingExpenseExport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OperatingExpenseExport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OperatingExpenseExport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OperatingExpenseExport value)  $default,){
final _that = this;
switch (_that) {
case _OperatingExpenseExport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OperatingExpenseExport value)?  $default,){
final _that = this;
switch (_that) {
case _OperatingExpenseExport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Uint8List bytes,  String filename,  String mediaType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OperatingExpenseExport() when $default != null:
return $default(_that.bytes,_that.filename,_that.mediaType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Uint8List bytes,  String filename,  String mediaType)  $default,) {final _that = this;
switch (_that) {
case _OperatingExpenseExport():
return $default(_that.bytes,_that.filename,_that.mediaType);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Uint8List bytes,  String filename,  String mediaType)?  $default,) {final _that = this;
switch (_that) {
case _OperatingExpenseExport() when $default != null:
return $default(_that.bytes,_that.filename,_that.mediaType);case _:
  return null;

}
}

}

/// @nodoc


class _OperatingExpenseExport implements OperatingExpenseExport {
  const _OperatingExpenseExport({required this.bytes, required this.filename, required this.mediaType});
  

@override final  Uint8List bytes;
@override final  String filename;
@override final  String mediaType;

/// Create a copy of OperatingExpenseExport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OperatingExpenseExportCopyWith<_OperatingExpenseExport> get copyWith => __$OperatingExpenseExportCopyWithImpl<_OperatingExpenseExport>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OperatingExpenseExport&&const DeepCollectionEquality().equals(other.bytes, bytes)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(bytes),filename,mediaType);

@override
String toString() {
  return 'OperatingExpenseExport(bytes: $bytes, filename: $filename, mediaType: $mediaType)';
}


}

/// @nodoc
abstract mixin class _$OperatingExpenseExportCopyWith<$Res> implements $OperatingExpenseExportCopyWith<$Res> {
  factory _$OperatingExpenseExportCopyWith(_OperatingExpenseExport value, $Res Function(_OperatingExpenseExport) _then) = __$OperatingExpenseExportCopyWithImpl;
@override @useResult
$Res call({
 Uint8List bytes, String filename, String mediaType
});




}
/// @nodoc
class __$OperatingExpenseExportCopyWithImpl<$Res>
    implements _$OperatingExpenseExportCopyWith<$Res> {
  __$OperatingExpenseExportCopyWithImpl(this._self, this._then);

  final _OperatingExpenseExport _self;
  final $Res Function(_OperatingExpenseExport) _then;

/// Create a copy of OperatingExpenseExport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bytes = null,Object? filename = null,Object? mediaType = null,}) {
  return _then(_OperatingExpenseExport(
bytes: null == bytes ? _self.bytes : bytes // ignore: cast_nullable_to_non_nullable
as Uint8List,filename: null == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
