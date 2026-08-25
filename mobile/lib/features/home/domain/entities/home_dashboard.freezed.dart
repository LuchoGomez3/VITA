// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_dashboard.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HomeDashboard {

 int get activeAnimals; int get monthlyAdditions; int get monthlyRemovals; double get knownLiveWeightKg; int get animalsWithCurrentWeight; int get animalsWithDailyGain; List<CategoryInventoryMetric> get categories; List<LotWeightMetric> get lots; int get operatingExpensesCents; double? get averageDailyGainKg;
/// Create a copy of HomeDashboard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeDashboardCopyWith<HomeDashboard> get copyWith => _$HomeDashboardCopyWithImpl<HomeDashboard>(this as HomeDashboard, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeDashboard&&(identical(other.activeAnimals, activeAnimals) || other.activeAnimals == activeAnimals)&&(identical(other.monthlyAdditions, monthlyAdditions) || other.monthlyAdditions == monthlyAdditions)&&(identical(other.monthlyRemovals, monthlyRemovals) || other.monthlyRemovals == monthlyRemovals)&&(identical(other.knownLiveWeightKg, knownLiveWeightKg) || other.knownLiveWeightKg == knownLiveWeightKg)&&(identical(other.animalsWithCurrentWeight, animalsWithCurrentWeight) || other.animalsWithCurrentWeight == animalsWithCurrentWeight)&&(identical(other.animalsWithDailyGain, animalsWithDailyGain) || other.animalsWithDailyGain == animalsWithDailyGain)&&const DeepCollectionEquality().equals(other.categories, categories)&&const DeepCollectionEquality().equals(other.lots, lots)&&(identical(other.operatingExpensesCents, operatingExpensesCents) || other.operatingExpensesCents == operatingExpensesCents)&&(identical(other.averageDailyGainKg, averageDailyGainKg) || other.averageDailyGainKg == averageDailyGainKg));
}


@override
int get hashCode => Object.hash(runtimeType,activeAnimals,monthlyAdditions,monthlyRemovals,knownLiveWeightKg,animalsWithCurrentWeight,animalsWithDailyGain,const DeepCollectionEquality().hash(categories),const DeepCollectionEquality().hash(lots),operatingExpensesCents,averageDailyGainKg);

@override
String toString() {
  return 'HomeDashboard(activeAnimals: $activeAnimals, monthlyAdditions: $monthlyAdditions, monthlyRemovals: $monthlyRemovals, knownLiveWeightKg: $knownLiveWeightKg, animalsWithCurrentWeight: $animalsWithCurrentWeight, animalsWithDailyGain: $animalsWithDailyGain, categories: $categories, lots: $lots, operatingExpensesCents: $operatingExpensesCents, averageDailyGainKg: $averageDailyGainKg)';
}


}

/// @nodoc
abstract mixin class $HomeDashboardCopyWith<$Res>  {
  factory $HomeDashboardCopyWith(HomeDashboard value, $Res Function(HomeDashboard) _then) = _$HomeDashboardCopyWithImpl;
@useResult
$Res call({
 int activeAnimals, int monthlyAdditions, int monthlyRemovals, double knownLiveWeightKg, int animalsWithCurrentWeight, int animalsWithDailyGain, List<CategoryInventoryMetric> categories, List<LotWeightMetric> lots, int operatingExpensesCents, double? averageDailyGainKg
});




}
/// @nodoc
class _$HomeDashboardCopyWithImpl<$Res>
    implements $HomeDashboardCopyWith<$Res> {
  _$HomeDashboardCopyWithImpl(this._self, this._then);

  final HomeDashboard _self;
  final $Res Function(HomeDashboard) _then;

/// Create a copy of HomeDashboard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? activeAnimals = null,Object? monthlyAdditions = null,Object? monthlyRemovals = null,Object? knownLiveWeightKg = null,Object? animalsWithCurrentWeight = null,Object? animalsWithDailyGain = null,Object? categories = null,Object? lots = null,Object? operatingExpensesCents = null,Object? averageDailyGainKg = freezed,}) {
  return _then(_self.copyWith(
activeAnimals: null == activeAnimals ? _self.activeAnimals : activeAnimals // ignore: cast_nullable_to_non_nullable
as int,monthlyAdditions: null == monthlyAdditions ? _self.monthlyAdditions : monthlyAdditions // ignore: cast_nullable_to_non_nullable
as int,monthlyRemovals: null == monthlyRemovals ? _self.monthlyRemovals : monthlyRemovals // ignore: cast_nullable_to_non_nullable
as int,knownLiveWeightKg: null == knownLiveWeightKg ? _self.knownLiveWeightKg : knownLiveWeightKg // ignore: cast_nullable_to_non_nullable
as double,animalsWithCurrentWeight: null == animalsWithCurrentWeight ? _self.animalsWithCurrentWeight : animalsWithCurrentWeight // ignore: cast_nullable_to_non_nullable
as int,animalsWithDailyGain: null == animalsWithDailyGain ? _self.animalsWithDailyGain : animalsWithDailyGain // ignore: cast_nullable_to_non_nullable
as int,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<CategoryInventoryMetric>,lots: null == lots ? _self.lots : lots // ignore: cast_nullable_to_non_nullable
as List<LotWeightMetric>,operatingExpensesCents: null == operatingExpensesCents ? _self.operatingExpensesCents : operatingExpensesCents // ignore: cast_nullable_to_non_nullable
as int,averageDailyGainKg: freezed == averageDailyGainKg ? _self.averageDailyGainKg : averageDailyGainKg // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeDashboard].
extension HomeDashboardPatterns on HomeDashboard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeDashboard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeDashboard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeDashboard value)  $default,){
final _that = this;
switch (_that) {
case _HomeDashboard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeDashboard value)?  $default,){
final _that = this;
switch (_that) {
case _HomeDashboard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int activeAnimals,  int monthlyAdditions,  int monthlyRemovals,  double knownLiveWeightKg,  int animalsWithCurrentWeight,  int animalsWithDailyGain,  List<CategoryInventoryMetric> categories,  List<LotWeightMetric> lots,  int operatingExpensesCents,  double? averageDailyGainKg)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeDashboard() when $default != null:
return $default(_that.activeAnimals,_that.monthlyAdditions,_that.monthlyRemovals,_that.knownLiveWeightKg,_that.animalsWithCurrentWeight,_that.animalsWithDailyGain,_that.categories,_that.lots,_that.operatingExpensesCents,_that.averageDailyGainKg);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int activeAnimals,  int monthlyAdditions,  int monthlyRemovals,  double knownLiveWeightKg,  int animalsWithCurrentWeight,  int animalsWithDailyGain,  List<CategoryInventoryMetric> categories,  List<LotWeightMetric> lots,  int operatingExpensesCents,  double? averageDailyGainKg)  $default,) {final _that = this;
switch (_that) {
case _HomeDashboard():
return $default(_that.activeAnimals,_that.monthlyAdditions,_that.monthlyRemovals,_that.knownLiveWeightKg,_that.animalsWithCurrentWeight,_that.animalsWithDailyGain,_that.categories,_that.lots,_that.operatingExpensesCents,_that.averageDailyGainKg);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int activeAnimals,  int monthlyAdditions,  int monthlyRemovals,  double knownLiveWeightKg,  int animalsWithCurrentWeight,  int animalsWithDailyGain,  List<CategoryInventoryMetric> categories,  List<LotWeightMetric> lots,  int operatingExpensesCents,  double? averageDailyGainKg)?  $default,) {final _that = this;
switch (_that) {
case _HomeDashboard() when $default != null:
return $default(_that.activeAnimals,_that.monthlyAdditions,_that.monthlyRemovals,_that.knownLiveWeightKg,_that.animalsWithCurrentWeight,_that.animalsWithDailyGain,_that.categories,_that.lots,_that.operatingExpensesCents,_that.averageDailyGainKg);case _:
  return null;

}
}

}

/// @nodoc


class _HomeDashboard implements HomeDashboard {
  const _HomeDashboard({required this.activeAnimals, required this.monthlyAdditions, required this.monthlyRemovals, required this.knownLiveWeightKg, required this.animalsWithCurrentWeight, required this.animalsWithDailyGain, required final  List<CategoryInventoryMetric> categories, required final  List<LotWeightMetric> lots, this.operatingExpensesCents = 0, this.averageDailyGainKg}): _categories = categories,_lots = lots;
  

@override final  int activeAnimals;
@override final  int monthlyAdditions;
@override final  int monthlyRemovals;
@override final  double knownLiveWeightKg;
@override final  int animalsWithCurrentWeight;
@override final  int animalsWithDailyGain;
 final  List<CategoryInventoryMetric> _categories;
@override List<CategoryInventoryMetric> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

 final  List<LotWeightMetric> _lots;
@override List<LotWeightMetric> get lots {
  if (_lots is EqualUnmodifiableListView) return _lots;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lots);
}

@override@JsonKey() final  int operatingExpensesCents;
@override final  double? averageDailyGainKg;

/// Create a copy of HomeDashboard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeDashboardCopyWith<_HomeDashboard> get copyWith => __$HomeDashboardCopyWithImpl<_HomeDashboard>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeDashboard&&(identical(other.activeAnimals, activeAnimals) || other.activeAnimals == activeAnimals)&&(identical(other.monthlyAdditions, monthlyAdditions) || other.monthlyAdditions == monthlyAdditions)&&(identical(other.monthlyRemovals, monthlyRemovals) || other.monthlyRemovals == monthlyRemovals)&&(identical(other.knownLiveWeightKg, knownLiveWeightKg) || other.knownLiveWeightKg == knownLiveWeightKg)&&(identical(other.animalsWithCurrentWeight, animalsWithCurrentWeight) || other.animalsWithCurrentWeight == animalsWithCurrentWeight)&&(identical(other.animalsWithDailyGain, animalsWithDailyGain) || other.animalsWithDailyGain == animalsWithDailyGain)&&const DeepCollectionEquality().equals(other._categories, _categories)&&const DeepCollectionEquality().equals(other._lots, _lots)&&(identical(other.operatingExpensesCents, operatingExpensesCents) || other.operatingExpensesCents == operatingExpensesCents)&&(identical(other.averageDailyGainKg, averageDailyGainKg) || other.averageDailyGainKg == averageDailyGainKg));
}


@override
int get hashCode => Object.hash(runtimeType,activeAnimals,monthlyAdditions,monthlyRemovals,knownLiveWeightKg,animalsWithCurrentWeight,animalsWithDailyGain,const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_lots),operatingExpensesCents,averageDailyGainKg);

@override
String toString() {
  return 'HomeDashboard(activeAnimals: $activeAnimals, monthlyAdditions: $monthlyAdditions, monthlyRemovals: $monthlyRemovals, knownLiveWeightKg: $knownLiveWeightKg, animalsWithCurrentWeight: $animalsWithCurrentWeight, animalsWithDailyGain: $animalsWithDailyGain, categories: $categories, lots: $lots, operatingExpensesCents: $operatingExpensesCents, averageDailyGainKg: $averageDailyGainKg)';
}


}

/// @nodoc
abstract mixin class _$HomeDashboardCopyWith<$Res> implements $HomeDashboardCopyWith<$Res> {
  factory _$HomeDashboardCopyWith(_HomeDashboard value, $Res Function(_HomeDashboard) _then) = __$HomeDashboardCopyWithImpl;
@override @useResult
$Res call({
 int activeAnimals, int monthlyAdditions, int monthlyRemovals, double knownLiveWeightKg, int animalsWithCurrentWeight, int animalsWithDailyGain, List<CategoryInventoryMetric> categories, List<LotWeightMetric> lots, int operatingExpensesCents, double? averageDailyGainKg
});




}
/// @nodoc
class __$HomeDashboardCopyWithImpl<$Res>
    implements _$HomeDashboardCopyWith<$Res> {
  __$HomeDashboardCopyWithImpl(this._self, this._then);

  final _HomeDashboard _self;
  final $Res Function(_HomeDashboard) _then;

/// Create a copy of HomeDashboard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? activeAnimals = null,Object? monthlyAdditions = null,Object? monthlyRemovals = null,Object? knownLiveWeightKg = null,Object? animalsWithCurrentWeight = null,Object? animalsWithDailyGain = null,Object? categories = null,Object? lots = null,Object? operatingExpensesCents = null,Object? averageDailyGainKg = freezed,}) {
  return _then(_HomeDashboard(
activeAnimals: null == activeAnimals ? _self.activeAnimals : activeAnimals // ignore: cast_nullable_to_non_nullable
as int,monthlyAdditions: null == monthlyAdditions ? _self.monthlyAdditions : monthlyAdditions // ignore: cast_nullable_to_non_nullable
as int,monthlyRemovals: null == monthlyRemovals ? _self.monthlyRemovals : monthlyRemovals // ignore: cast_nullable_to_non_nullable
as int,knownLiveWeightKg: null == knownLiveWeightKg ? _self.knownLiveWeightKg : knownLiveWeightKg // ignore: cast_nullable_to_non_nullable
as double,animalsWithCurrentWeight: null == animalsWithCurrentWeight ? _self.animalsWithCurrentWeight : animalsWithCurrentWeight // ignore: cast_nullable_to_non_nullable
as int,animalsWithDailyGain: null == animalsWithDailyGain ? _self.animalsWithDailyGain : animalsWithDailyGain // ignore: cast_nullable_to_non_nullable
as int,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<CategoryInventoryMetric>,lots: null == lots ? _self._lots : lots // ignore: cast_nullable_to_non_nullable
as List<LotWeightMetric>,operatingExpensesCents: null == operatingExpensesCents ? _self.operatingExpensesCents : operatingExpensesCents // ignore: cast_nullable_to_non_nullable
as int,averageDailyGainKg: freezed == averageDailyGainKg ? _self.averageDailyGainKg : averageDailyGainKg // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

/// @nodoc
mixin _$CategoryInventoryMetric {

 String? get name; int get animals; double get percentage;
/// Create a copy of CategoryInventoryMetric
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryInventoryMetricCopyWith<CategoryInventoryMetric> get copyWith => _$CategoryInventoryMetricCopyWithImpl<CategoryInventoryMetric>(this as CategoryInventoryMetric, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryInventoryMetric&&(identical(other.name, name) || other.name == name)&&(identical(other.animals, animals) || other.animals == animals)&&(identical(other.percentage, percentage) || other.percentage == percentage));
}


@override
int get hashCode => Object.hash(runtimeType,name,animals,percentage);

@override
String toString() {
  return 'CategoryInventoryMetric(name: $name, animals: $animals, percentage: $percentage)';
}


}

/// @nodoc
abstract mixin class $CategoryInventoryMetricCopyWith<$Res>  {
  factory $CategoryInventoryMetricCopyWith(CategoryInventoryMetric value, $Res Function(CategoryInventoryMetric) _then) = _$CategoryInventoryMetricCopyWithImpl;
@useResult
$Res call({
 String? name, int animals, double percentage
});




}
/// @nodoc
class _$CategoryInventoryMetricCopyWithImpl<$Res>
    implements $CategoryInventoryMetricCopyWith<$Res> {
  _$CategoryInventoryMetricCopyWithImpl(this._self, this._then);

  final CategoryInventoryMetric _self;
  final $Res Function(CategoryInventoryMetric) _then;

/// Create a copy of CategoryInventoryMetric
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? animals = null,Object? percentage = null,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,animals: null == animals ? _self.animals : animals // ignore: cast_nullable_to_non_nullable
as int,percentage: null == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [CategoryInventoryMetric].
extension CategoryInventoryMetricPatterns on CategoryInventoryMetric {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryInventoryMetric value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryInventoryMetric() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryInventoryMetric value)  $default,){
final _that = this;
switch (_that) {
case _CategoryInventoryMetric():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryInventoryMetric value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryInventoryMetric() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  int animals,  double percentage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryInventoryMetric() when $default != null:
return $default(_that.name,_that.animals,_that.percentage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  int animals,  double percentage)  $default,) {final _that = this;
switch (_that) {
case _CategoryInventoryMetric():
return $default(_that.name,_that.animals,_that.percentage);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  int animals,  double percentage)?  $default,) {final _that = this;
switch (_that) {
case _CategoryInventoryMetric() when $default != null:
return $default(_that.name,_that.animals,_that.percentage);case _:
  return null;

}
}

}

/// @nodoc


class _CategoryInventoryMetric implements CategoryInventoryMetric {
  const _CategoryInventoryMetric({required this.name, required this.animals, required this.percentage});
  

@override final  String? name;
@override final  int animals;
@override final  double percentage;

/// Create a copy of CategoryInventoryMetric
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryInventoryMetricCopyWith<_CategoryInventoryMetric> get copyWith => __$CategoryInventoryMetricCopyWithImpl<_CategoryInventoryMetric>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryInventoryMetric&&(identical(other.name, name) || other.name == name)&&(identical(other.animals, animals) || other.animals == animals)&&(identical(other.percentage, percentage) || other.percentage == percentage));
}


@override
int get hashCode => Object.hash(runtimeType,name,animals,percentage);

@override
String toString() {
  return 'CategoryInventoryMetric(name: $name, animals: $animals, percentage: $percentage)';
}


}

/// @nodoc
abstract mixin class _$CategoryInventoryMetricCopyWith<$Res> implements $CategoryInventoryMetricCopyWith<$Res> {
  factory _$CategoryInventoryMetricCopyWith(_CategoryInventoryMetric value, $Res Function(_CategoryInventoryMetric) _then) = __$CategoryInventoryMetricCopyWithImpl;
@override @useResult
$Res call({
 String? name, int animals, double percentage
});




}
/// @nodoc
class __$CategoryInventoryMetricCopyWithImpl<$Res>
    implements _$CategoryInventoryMetricCopyWith<$Res> {
  __$CategoryInventoryMetricCopyWithImpl(this._self, this._then);

  final _CategoryInventoryMetric _self;
  final $Res Function(_CategoryInventoryMetric) _then;

/// Create a copy of CategoryInventoryMetric
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? animals = null,Object? percentage = null,}) {
  return _then(_CategoryInventoryMetric(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,animals: null == animals ? _self.animals : animals // ignore: cast_nullable_to_non_nullable
as int,percentage: null == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$LotWeightMetric {

 String? get name; int get animals; int get animalsWithWeight; double get averageWeightKg; double get weightStandardDeviationKg;
/// Create a copy of LotWeightMetric
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LotWeightMetricCopyWith<LotWeightMetric> get copyWith => _$LotWeightMetricCopyWithImpl<LotWeightMetric>(this as LotWeightMetric, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LotWeightMetric&&(identical(other.name, name) || other.name == name)&&(identical(other.animals, animals) || other.animals == animals)&&(identical(other.animalsWithWeight, animalsWithWeight) || other.animalsWithWeight == animalsWithWeight)&&(identical(other.averageWeightKg, averageWeightKg) || other.averageWeightKg == averageWeightKg)&&(identical(other.weightStandardDeviationKg, weightStandardDeviationKg) || other.weightStandardDeviationKg == weightStandardDeviationKg));
}


@override
int get hashCode => Object.hash(runtimeType,name,animals,animalsWithWeight,averageWeightKg,weightStandardDeviationKg);

@override
String toString() {
  return 'LotWeightMetric(name: $name, animals: $animals, animalsWithWeight: $animalsWithWeight, averageWeightKg: $averageWeightKg, weightStandardDeviationKg: $weightStandardDeviationKg)';
}


}

/// @nodoc
abstract mixin class $LotWeightMetricCopyWith<$Res>  {
  factory $LotWeightMetricCopyWith(LotWeightMetric value, $Res Function(LotWeightMetric) _then) = _$LotWeightMetricCopyWithImpl;
@useResult
$Res call({
 String? name, int animals, int animalsWithWeight, double averageWeightKg, double weightStandardDeviationKg
});




}
/// @nodoc
class _$LotWeightMetricCopyWithImpl<$Res>
    implements $LotWeightMetricCopyWith<$Res> {
  _$LotWeightMetricCopyWithImpl(this._self, this._then);

  final LotWeightMetric _self;
  final $Res Function(LotWeightMetric) _then;

/// Create a copy of LotWeightMetric
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? animals = null,Object? animalsWithWeight = null,Object? averageWeightKg = null,Object? weightStandardDeviationKg = null,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,animals: null == animals ? _self.animals : animals // ignore: cast_nullable_to_non_nullable
as int,animalsWithWeight: null == animalsWithWeight ? _self.animalsWithWeight : animalsWithWeight // ignore: cast_nullable_to_non_nullable
as int,averageWeightKg: null == averageWeightKg ? _self.averageWeightKg : averageWeightKg // ignore: cast_nullable_to_non_nullable
as double,weightStandardDeviationKg: null == weightStandardDeviationKg ? _self.weightStandardDeviationKg : weightStandardDeviationKg // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [LotWeightMetric].
extension LotWeightMetricPatterns on LotWeightMetric {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LotWeightMetric value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LotWeightMetric() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LotWeightMetric value)  $default,){
final _that = this;
switch (_that) {
case _LotWeightMetric():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LotWeightMetric value)?  $default,){
final _that = this;
switch (_that) {
case _LotWeightMetric() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  int animals,  int animalsWithWeight,  double averageWeightKg,  double weightStandardDeviationKg)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LotWeightMetric() when $default != null:
return $default(_that.name,_that.animals,_that.animalsWithWeight,_that.averageWeightKg,_that.weightStandardDeviationKg);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  int animals,  int animalsWithWeight,  double averageWeightKg,  double weightStandardDeviationKg)  $default,) {final _that = this;
switch (_that) {
case _LotWeightMetric():
return $default(_that.name,_that.animals,_that.animalsWithWeight,_that.averageWeightKg,_that.weightStandardDeviationKg);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  int animals,  int animalsWithWeight,  double averageWeightKg,  double weightStandardDeviationKg)?  $default,) {final _that = this;
switch (_that) {
case _LotWeightMetric() when $default != null:
return $default(_that.name,_that.animals,_that.animalsWithWeight,_that.averageWeightKg,_that.weightStandardDeviationKg);case _:
  return null;

}
}

}

/// @nodoc


class _LotWeightMetric implements LotWeightMetric {
  const _LotWeightMetric({required this.name, required this.animals, required this.animalsWithWeight, required this.averageWeightKg, required this.weightStandardDeviationKg});
  

@override final  String? name;
@override final  int animals;
@override final  int animalsWithWeight;
@override final  double averageWeightKg;
@override final  double weightStandardDeviationKg;

/// Create a copy of LotWeightMetric
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LotWeightMetricCopyWith<_LotWeightMetric> get copyWith => __$LotWeightMetricCopyWithImpl<_LotWeightMetric>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LotWeightMetric&&(identical(other.name, name) || other.name == name)&&(identical(other.animals, animals) || other.animals == animals)&&(identical(other.animalsWithWeight, animalsWithWeight) || other.animalsWithWeight == animalsWithWeight)&&(identical(other.averageWeightKg, averageWeightKg) || other.averageWeightKg == averageWeightKg)&&(identical(other.weightStandardDeviationKg, weightStandardDeviationKg) || other.weightStandardDeviationKg == weightStandardDeviationKg));
}


@override
int get hashCode => Object.hash(runtimeType,name,animals,animalsWithWeight,averageWeightKg,weightStandardDeviationKg);

@override
String toString() {
  return 'LotWeightMetric(name: $name, animals: $animals, animalsWithWeight: $animalsWithWeight, averageWeightKg: $averageWeightKg, weightStandardDeviationKg: $weightStandardDeviationKg)';
}


}

/// @nodoc
abstract mixin class _$LotWeightMetricCopyWith<$Res> implements $LotWeightMetricCopyWith<$Res> {
  factory _$LotWeightMetricCopyWith(_LotWeightMetric value, $Res Function(_LotWeightMetric) _then) = __$LotWeightMetricCopyWithImpl;
@override @useResult
$Res call({
 String? name, int animals, int animalsWithWeight, double averageWeightKg, double weightStandardDeviationKg
});




}
/// @nodoc
class __$LotWeightMetricCopyWithImpl<$Res>
    implements _$LotWeightMetricCopyWith<$Res> {
  __$LotWeightMetricCopyWithImpl(this._self, this._then);

  final _LotWeightMetric _self;
  final $Res Function(_LotWeightMetric) _then;

/// Create a copy of LotWeightMetric
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? animals = null,Object? animalsWithWeight = null,Object? averageWeightKg = null,Object? weightStandardDeviationKg = null,}) {
  return _then(_LotWeightMetric(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,animals: null == animals ? _self.animals : animals // ignore: cast_nullable_to_non_nullable
as int,animalsWithWeight: null == animalsWithWeight ? _self.animalsWithWeight : animalsWithWeight // ignore: cast_nullable_to_non_nullable
as int,averageWeightKg: null == averageWeightKg ? _self.averageWeightKg : averageWeightKg // ignore: cast_nullable_to_non_nullable
as double,weightStandardDeviationKg: null == weightStandardDeviationKg ? _self.weightStandardDeviationKg : weightStandardDeviationKg // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
