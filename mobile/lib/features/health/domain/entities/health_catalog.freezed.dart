// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health_catalog.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HealthPractice {

 String get id; String get name; HealthPracticeKind get kind; List<String> get productIds;
/// Create a copy of HealthPractice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthPracticeCopyWith<HealthPractice> get copyWith => _$HealthPracticeCopyWithImpl<HealthPractice>(this as HealthPractice, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthPractice&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.kind, kind) || other.kind == kind)&&const DeepCollectionEquality().equals(other.productIds, productIds));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,kind,const DeepCollectionEquality().hash(productIds));

@override
String toString() {
  return 'HealthPractice(id: $id, name: $name, kind: $kind, productIds: $productIds)';
}


}

/// @nodoc
abstract mixin class $HealthPracticeCopyWith<$Res>  {
  factory $HealthPracticeCopyWith(HealthPractice value, $Res Function(HealthPractice) _then) = _$HealthPracticeCopyWithImpl;
@useResult
$Res call({
 String id, String name, HealthPracticeKind kind, List<String> productIds
});




}
/// @nodoc
class _$HealthPracticeCopyWithImpl<$Res>
    implements $HealthPracticeCopyWith<$Res> {
  _$HealthPracticeCopyWithImpl(this._self, this._then);

  final HealthPractice _self;
  final $Res Function(HealthPractice) _then;

/// Create a copy of HealthPractice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? kind = null,Object? productIds = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as HealthPracticeKind,productIds: null == productIds ? _self.productIds : productIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [HealthPractice].
extension HealthPracticePatterns on HealthPractice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthPractice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthPractice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthPractice value)  $default,){
final _that = this;
switch (_that) {
case _HealthPractice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthPractice value)?  $default,){
final _that = this;
switch (_that) {
case _HealthPractice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  HealthPracticeKind kind,  List<String> productIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthPractice() when $default != null:
return $default(_that.id,_that.name,_that.kind,_that.productIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  HealthPracticeKind kind,  List<String> productIds)  $default,) {final _that = this;
switch (_that) {
case _HealthPractice():
return $default(_that.id,_that.name,_that.kind,_that.productIds);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  HealthPracticeKind kind,  List<String> productIds)?  $default,) {final _that = this;
switch (_that) {
case _HealthPractice() when $default != null:
return $default(_that.id,_that.name,_that.kind,_that.productIds);case _:
  return null;

}
}

}

/// @nodoc


class _HealthPractice implements HealthPractice {
  const _HealthPractice({required this.id, required this.name, required this.kind, final  List<String> productIds = const []}): _productIds = productIds;
  

@override final  String id;
@override final  String name;
@override final  HealthPracticeKind kind;
 final  List<String> _productIds;
@override@JsonKey() List<String> get productIds {
  if (_productIds is EqualUnmodifiableListView) return _productIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_productIds);
}


/// Create a copy of HealthPractice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthPracticeCopyWith<_HealthPractice> get copyWith => __$HealthPracticeCopyWithImpl<_HealthPractice>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthPractice&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.kind, kind) || other.kind == kind)&&const DeepCollectionEquality().equals(other._productIds, _productIds));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,kind,const DeepCollectionEquality().hash(_productIds));

@override
String toString() {
  return 'HealthPractice(id: $id, name: $name, kind: $kind, productIds: $productIds)';
}


}

/// @nodoc
abstract mixin class _$HealthPracticeCopyWith<$Res> implements $HealthPracticeCopyWith<$Res> {
  factory _$HealthPracticeCopyWith(_HealthPractice value, $Res Function(_HealthPractice) _then) = __$HealthPracticeCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, HealthPracticeKind kind, List<String> productIds
});




}
/// @nodoc
class __$HealthPracticeCopyWithImpl<$Res>
    implements _$HealthPracticeCopyWith<$Res> {
  __$HealthPracticeCopyWithImpl(this._self, this._then);

  final _HealthPractice _self;
  final $Res Function(_HealthPractice) _then;

/// Create a copy of HealthPractice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? kind = null,Object? productIds = null,}) {
  return _then(_HealthPractice(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as HealthPracticeKind,productIds: null == productIds ? _self._productIds : productIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc
mixin _$HealthProduct {

 String get id; String get name;
/// Create a copy of HealthProduct
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthProductCopyWith<HealthProduct> get copyWith => _$HealthProductCopyWithImpl<HealthProduct>(this as HealthProduct, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthProduct&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'HealthProduct(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $HealthProductCopyWith<$Res>  {
  factory $HealthProductCopyWith(HealthProduct value, $Res Function(HealthProduct) _then) = _$HealthProductCopyWithImpl;
@useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class _$HealthProductCopyWithImpl<$Res>
    implements $HealthProductCopyWith<$Res> {
  _$HealthProductCopyWithImpl(this._self, this._then);

  final HealthProduct _self;
  final $Res Function(HealthProduct) _then;

/// Create a copy of HealthProduct
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [HealthProduct].
extension HealthProductPatterns on HealthProduct {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthProduct value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthProduct() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthProduct value)  $default,){
final _that = this;
switch (_that) {
case _HealthProduct():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthProduct value)?  $default,){
final _that = this;
switch (_that) {
case _HealthProduct() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthProduct() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name)  $default,) {final _that = this;
switch (_that) {
case _HealthProduct():
return $default(_that.id,_that.name);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _HealthProduct() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc


class _HealthProduct implements HealthProduct {
  const _HealthProduct({required this.id, required this.name});
  

@override final  String id;
@override final  String name;

/// Create a copy of HealthProduct
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthProductCopyWith<_HealthProduct> get copyWith => __$HealthProductCopyWithImpl<_HealthProduct>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthProduct&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'HealthProduct(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$HealthProductCopyWith<$Res> implements $HealthProductCopyWith<$Res> {
  factory _$HealthProductCopyWith(_HealthProduct value, $Res Function(_HealthProduct) _then) = __$HealthProductCopyWithImpl;
@override @useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class __$HealthProductCopyWithImpl<$Res>
    implements _$HealthProductCopyWith<$Res> {
  __$HealthProductCopyWithImpl(this._self, this._then);

  final _HealthProduct _self;
  final $Res Function(_HealthProduct) _then;

/// Create a copy of HealthProduct
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_HealthProduct(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$HealthCatalog {

 String get establishmentId; List<HealthPractice> get practices; List<HealthProduct> get products;
/// Create a copy of HealthCatalog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthCatalogCopyWith<HealthCatalog> get copyWith => _$HealthCatalogCopyWithImpl<HealthCatalog>(this as HealthCatalog, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthCatalog&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&const DeepCollectionEquality().equals(other.practices, practices)&&const DeepCollectionEquality().equals(other.products, products));
}


@override
int get hashCode => Object.hash(runtimeType,establishmentId,const DeepCollectionEquality().hash(practices),const DeepCollectionEquality().hash(products));

@override
String toString() {
  return 'HealthCatalog(establishmentId: $establishmentId, practices: $practices, products: $products)';
}


}

/// @nodoc
abstract mixin class $HealthCatalogCopyWith<$Res>  {
  factory $HealthCatalogCopyWith(HealthCatalog value, $Res Function(HealthCatalog) _then) = _$HealthCatalogCopyWithImpl;
@useResult
$Res call({
 String establishmentId, List<HealthPractice> practices, List<HealthProduct> products
});




}
/// @nodoc
class _$HealthCatalogCopyWithImpl<$Res>
    implements $HealthCatalogCopyWith<$Res> {
  _$HealthCatalogCopyWithImpl(this._self, this._then);

  final HealthCatalog _self;
  final $Res Function(HealthCatalog) _then;

/// Create a copy of HealthCatalog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? establishmentId = null,Object? practices = null,Object? products = null,}) {
  return _then(_self.copyWith(
establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,practices: null == practices ? _self.practices : practices // ignore: cast_nullable_to_non_nullable
as List<HealthPractice>,products: null == products ? _self.products : products // ignore: cast_nullable_to_non_nullable
as List<HealthProduct>,
  ));
}

}


/// Adds pattern-matching-related methods to [HealthCatalog].
extension HealthCatalogPatterns on HealthCatalog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthCatalog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthCatalog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthCatalog value)  $default,){
final _that = this;
switch (_that) {
case _HealthCatalog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthCatalog value)?  $default,){
final _that = this;
switch (_that) {
case _HealthCatalog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String establishmentId,  List<HealthPractice> practices,  List<HealthProduct> products)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthCatalog() when $default != null:
return $default(_that.establishmentId,_that.practices,_that.products);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String establishmentId,  List<HealthPractice> practices,  List<HealthProduct> products)  $default,) {final _that = this;
switch (_that) {
case _HealthCatalog():
return $default(_that.establishmentId,_that.practices,_that.products);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String establishmentId,  List<HealthPractice> practices,  List<HealthProduct> products)?  $default,) {final _that = this;
switch (_that) {
case _HealthCatalog() when $default != null:
return $default(_that.establishmentId,_that.practices,_that.products);case _:
  return null;

}
}

}

/// @nodoc


class _HealthCatalog implements HealthCatalog {
  const _HealthCatalog({required this.establishmentId, required final  List<HealthPractice> practices, required final  List<HealthProduct> products}): _practices = practices,_products = products;
  

@override final  String establishmentId;
 final  List<HealthPractice> _practices;
@override List<HealthPractice> get practices {
  if (_practices is EqualUnmodifiableListView) return _practices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_practices);
}

 final  List<HealthProduct> _products;
@override List<HealthProduct> get products {
  if (_products is EqualUnmodifiableListView) return _products;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_products);
}


/// Create a copy of HealthCatalog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthCatalogCopyWith<_HealthCatalog> get copyWith => __$HealthCatalogCopyWithImpl<_HealthCatalog>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthCatalog&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&const DeepCollectionEquality().equals(other._practices, _practices)&&const DeepCollectionEquality().equals(other._products, _products));
}


@override
int get hashCode => Object.hash(runtimeType,establishmentId,const DeepCollectionEquality().hash(_practices),const DeepCollectionEquality().hash(_products));

@override
String toString() {
  return 'HealthCatalog(establishmentId: $establishmentId, practices: $practices, products: $products)';
}


}

/// @nodoc
abstract mixin class _$HealthCatalogCopyWith<$Res> implements $HealthCatalogCopyWith<$Res> {
  factory _$HealthCatalogCopyWith(_HealthCatalog value, $Res Function(_HealthCatalog) _then) = __$HealthCatalogCopyWithImpl;
@override @useResult
$Res call({
 String establishmentId, List<HealthPractice> practices, List<HealthProduct> products
});




}
/// @nodoc
class __$HealthCatalogCopyWithImpl<$Res>
    implements _$HealthCatalogCopyWith<$Res> {
  __$HealthCatalogCopyWithImpl(this._self, this._then);

  final _HealthCatalog _self;
  final $Res Function(_HealthCatalog) _then;

/// Create a copy of HealthCatalog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? establishmentId = null,Object? practices = null,Object? products = null,}) {
  return _then(_HealthCatalog(
establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,practices: null == practices ? _self._practices : practices // ignore: cast_nullable_to_non_nullable
as List<HealthPractice>,products: null == products ? _self._products : products // ignore: cast_nullable_to_non_nullable
as List<HealthProduct>,
  ));
}


}

// dart format on
