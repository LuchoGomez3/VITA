// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lot_editor_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LotEditorEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LotEditorEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LotEditorEvent()';
}


}

/// @nodoc
class $LotEditorEventCopyWith<$Res>  {
$LotEditorEventCopyWith(LotEditorEvent _, $Res Function(LotEditorEvent) __);
}


/// Adds pattern-matching-related methods to [LotEditorEvent].
extension LotEditorEventPatterns on LotEditorEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _VertexAdded value)?  vertexAdded,TResult Function( _VertexSelected value)?  vertexSelected,TResult Function( _VertexMoveStarted value)?  vertexMoveStarted,TResult Function( _VertexMoved value)?  vertexMoved,TResult Function( _SelectedVertexDeleted value)?  selectedVertexDeleted,TResult Function( _UndoRequested value)?  undoRequested,TResult Function( _RedoRequested value)?  redoRequested,TResult Function( _ClearRequested value)?  clearRequested,TResult Function( _BoundaryCloseRequested value)?  boundaryCloseRequested,TResult Function( _NameChanged value)?  nameChanged,TResult Function( _SaveRequested value)?  saveRequested,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VertexAdded() when vertexAdded != null:
return vertexAdded(_that);case _VertexSelected() when vertexSelected != null:
return vertexSelected(_that);case _VertexMoveStarted() when vertexMoveStarted != null:
return vertexMoveStarted(_that);case _VertexMoved() when vertexMoved != null:
return vertexMoved(_that);case _SelectedVertexDeleted() when selectedVertexDeleted != null:
return selectedVertexDeleted(_that);case _UndoRequested() when undoRequested != null:
return undoRequested(_that);case _RedoRequested() when redoRequested != null:
return redoRequested(_that);case _ClearRequested() when clearRequested != null:
return clearRequested(_that);case _BoundaryCloseRequested() when boundaryCloseRequested != null:
return boundaryCloseRequested(_that);case _NameChanged() when nameChanged != null:
return nameChanged(_that);case _SaveRequested() when saveRequested != null:
return saveRequested(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _VertexAdded value)  vertexAdded,required TResult Function( _VertexSelected value)  vertexSelected,required TResult Function( _VertexMoveStarted value)  vertexMoveStarted,required TResult Function( _VertexMoved value)  vertexMoved,required TResult Function( _SelectedVertexDeleted value)  selectedVertexDeleted,required TResult Function( _UndoRequested value)  undoRequested,required TResult Function( _RedoRequested value)  redoRequested,required TResult Function( _ClearRequested value)  clearRequested,required TResult Function( _BoundaryCloseRequested value)  boundaryCloseRequested,required TResult Function( _NameChanged value)  nameChanged,required TResult Function( _SaveRequested value)  saveRequested,}){
final _that = this;
switch (_that) {
case _VertexAdded():
return vertexAdded(_that);case _VertexSelected():
return vertexSelected(_that);case _VertexMoveStarted():
return vertexMoveStarted(_that);case _VertexMoved():
return vertexMoved(_that);case _SelectedVertexDeleted():
return selectedVertexDeleted(_that);case _UndoRequested():
return undoRequested(_that);case _RedoRequested():
return redoRequested(_that);case _ClearRequested():
return clearRequested(_that);case _BoundaryCloseRequested():
return boundaryCloseRequested(_that);case _NameChanged():
return nameChanged(_that);case _SaveRequested():
return saveRequested(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _VertexAdded value)?  vertexAdded,TResult? Function( _VertexSelected value)?  vertexSelected,TResult? Function( _VertexMoveStarted value)?  vertexMoveStarted,TResult? Function( _VertexMoved value)?  vertexMoved,TResult? Function( _SelectedVertexDeleted value)?  selectedVertexDeleted,TResult? Function( _UndoRequested value)?  undoRequested,TResult? Function( _RedoRequested value)?  redoRequested,TResult? Function( _ClearRequested value)?  clearRequested,TResult? Function( _BoundaryCloseRequested value)?  boundaryCloseRequested,TResult? Function( _NameChanged value)?  nameChanged,TResult? Function( _SaveRequested value)?  saveRequested,}){
final _that = this;
switch (_that) {
case _VertexAdded() when vertexAdded != null:
return vertexAdded(_that);case _VertexSelected() when vertexSelected != null:
return vertexSelected(_that);case _VertexMoveStarted() when vertexMoveStarted != null:
return vertexMoveStarted(_that);case _VertexMoved() when vertexMoved != null:
return vertexMoved(_that);case _SelectedVertexDeleted() when selectedVertexDeleted != null:
return selectedVertexDeleted(_that);case _UndoRequested() when undoRequested != null:
return undoRequested(_that);case _RedoRequested() when redoRequested != null:
return redoRequested(_that);case _ClearRequested() when clearRequested != null:
return clearRequested(_that);case _BoundaryCloseRequested() when boundaryCloseRequested != null:
return boundaryCloseRequested(_that);case _NameChanged() when nameChanged != null:
return nameChanged(_that);case _SaveRequested() when saveRequested != null:
return saveRequested(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( LocalPoint point)?  vertexAdded,TResult Function( int index)?  vertexSelected,TResult Function( int index)?  vertexMoveStarted,TResult Function( int index,  LocalPoint point)?  vertexMoved,TResult Function()?  selectedVertexDeleted,TResult Function()?  undoRequested,TResult Function()?  redoRequested,TResult Function()?  clearRequested,TResult Function()?  boundaryCloseRequested,TResult Function( String name)?  nameChanged,TResult Function()?  saveRequested,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VertexAdded() when vertexAdded != null:
return vertexAdded(_that.point);case _VertexSelected() when vertexSelected != null:
return vertexSelected(_that.index);case _VertexMoveStarted() when vertexMoveStarted != null:
return vertexMoveStarted(_that.index);case _VertexMoved() when vertexMoved != null:
return vertexMoved(_that.index,_that.point);case _SelectedVertexDeleted() when selectedVertexDeleted != null:
return selectedVertexDeleted();case _UndoRequested() when undoRequested != null:
return undoRequested();case _RedoRequested() when redoRequested != null:
return redoRequested();case _ClearRequested() when clearRequested != null:
return clearRequested();case _BoundaryCloseRequested() when boundaryCloseRequested != null:
return boundaryCloseRequested();case _NameChanged() when nameChanged != null:
return nameChanged(_that.name);case _SaveRequested() when saveRequested != null:
return saveRequested();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( LocalPoint point)  vertexAdded,required TResult Function( int index)  vertexSelected,required TResult Function( int index)  vertexMoveStarted,required TResult Function( int index,  LocalPoint point)  vertexMoved,required TResult Function()  selectedVertexDeleted,required TResult Function()  undoRequested,required TResult Function()  redoRequested,required TResult Function()  clearRequested,required TResult Function()  boundaryCloseRequested,required TResult Function( String name)  nameChanged,required TResult Function()  saveRequested,}) {final _that = this;
switch (_that) {
case _VertexAdded():
return vertexAdded(_that.point);case _VertexSelected():
return vertexSelected(_that.index);case _VertexMoveStarted():
return vertexMoveStarted(_that.index);case _VertexMoved():
return vertexMoved(_that.index,_that.point);case _SelectedVertexDeleted():
return selectedVertexDeleted();case _UndoRequested():
return undoRequested();case _RedoRequested():
return redoRequested();case _ClearRequested():
return clearRequested();case _BoundaryCloseRequested():
return boundaryCloseRequested();case _NameChanged():
return nameChanged(_that.name);case _SaveRequested():
return saveRequested();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( LocalPoint point)?  vertexAdded,TResult? Function( int index)?  vertexSelected,TResult? Function( int index)?  vertexMoveStarted,TResult? Function( int index,  LocalPoint point)?  vertexMoved,TResult? Function()?  selectedVertexDeleted,TResult? Function()?  undoRequested,TResult? Function()?  redoRequested,TResult? Function()?  clearRequested,TResult? Function()?  boundaryCloseRequested,TResult? Function( String name)?  nameChanged,TResult? Function()?  saveRequested,}) {final _that = this;
switch (_that) {
case _VertexAdded() when vertexAdded != null:
return vertexAdded(_that.point);case _VertexSelected() when vertexSelected != null:
return vertexSelected(_that.index);case _VertexMoveStarted() when vertexMoveStarted != null:
return vertexMoveStarted(_that.index);case _VertexMoved() when vertexMoved != null:
return vertexMoved(_that.index,_that.point);case _SelectedVertexDeleted() when selectedVertexDeleted != null:
return selectedVertexDeleted();case _UndoRequested() when undoRequested != null:
return undoRequested();case _RedoRequested() when redoRequested != null:
return redoRequested();case _ClearRequested() when clearRequested != null:
return clearRequested();case _BoundaryCloseRequested() when boundaryCloseRequested != null:
return boundaryCloseRequested();case _NameChanged() when nameChanged != null:
return nameChanged(_that.name);case _SaveRequested() when saveRequested != null:
return saveRequested();case _:
  return null;

}
}

}

/// @nodoc


class _VertexAdded implements LotEditorEvent {
  const _VertexAdded(this.point);
  

 final  LocalPoint point;

/// Create a copy of LotEditorEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VertexAddedCopyWith<_VertexAdded> get copyWith => __$VertexAddedCopyWithImpl<_VertexAdded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VertexAdded&&(identical(other.point, point) || other.point == point));
}


@override
int get hashCode => Object.hash(runtimeType,point);

@override
String toString() {
  return 'LotEditorEvent.vertexAdded(point: $point)';
}


}

/// @nodoc
abstract mixin class _$VertexAddedCopyWith<$Res> implements $LotEditorEventCopyWith<$Res> {
  factory _$VertexAddedCopyWith(_VertexAdded value, $Res Function(_VertexAdded) _then) = __$VertexAddedCopyWithImpl;
@useResult
$Res call({
 LocalPoint point
});


$LocalPointCopyWith<$Res> get point;

}
/// @nodoc
class __$VertexAddedCopyWithImpl<$Res>
    implements _$VertexAddedCopyWith<$Res> {
  __$VertexAddedCopyWithImpl(this._self, this._then);

  final _VertexAdded _self;
  final $Res Function(_VertexAdded) _then;

/// Create a copy of LotEditorEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? point = null,}) {
  return _then(_VertexAdded(
null == point ? _self.point : point // ignore: cast_nullable_to_non_nullable
as LocalPoint,
  ));
}

/// Create a copy of LotEditorEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalPointCopyWith<$Res> get point {
  
  return $LocalPointCopyWith<$Res>(_self.point, (value) {
    return _then(_self.copyWith(point: value));
  });
}
}

/// @nodoc


class _VertexSelected implements LotEditorEvent {
  const _VertexSelected(this.index);
  

 final  int index;

/// Create a copy of LotEditorEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VertexSelectedCopyWith<_VertexSelected> get copyWith => __$VertexSelectedCopyWithImpl<_VertexSelected>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VertexSelected&&(identical(other.index, index) || other.index == index));
}


@override
int get hashCode => Object.hash(runtimeType,index);

@override
String toString() {
  return 'LotEditorEvent.vertexSelected(index: $index)';
}


}

/// @nodoc
abstract mixin class _$VertexSelectedCopyWith<$Res> implements $LotEditorEventCopyWith<$Res> {
  factory _$VertexSelectedCopyWith(_VertexSelected value, $Res Function(_VertexSelected) _then) = __$VertexSelectedCopyWithImpl;
@useResult
$Res call({
 int index
});




}
/// @nodoc
class __$VertexSelectedCopyWithImpl<$Res>
    implements _$VertexSelectedCopyWith<$Res> {
  __$VertexSelectedCopyWithImpl(this._self, this._then);

  final _VertexSelected _self;
  final $Res Function(_VertexSelected) _then;

/// Create a copy of LotEditorEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? index = null,}) {
  return _then(_VertexSelected(
null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _VertexMoveStarted implements LotEditorEvent {
  const _VertexMoveStarted(this.index);
  

 final  int index;

/// Create a copy of LotEditorEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VertexMoveStartedCopyWith<_VertexMoveStarted> get copyWith => __$VertexMoveStartedCopyWithImpl<_VertexMoveStarted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VertexMoveStarted&&(identical(other.index, index) || other.index == index));
}


@override
int get hashCode => Object.hash(runtimeType,index);

@override
String toString() {
  return 'LotEditorEvent.vertexMoveStarted(index: $index)';
}


}

/// @nodoc
abstract mixin class _$VertexMoveStartedCopyWith<$Res> implements $LotEditorEventCopyWith<$Res> {
  factory _$VertexMoveStartedCopyWith(_VertexMoveStarted value, $Res Function(_VertexMoveStarted) _then) = __$VertexMoveStartedCopyWithImpl;
@useResult
$Res call({
 int index
});




}
/// @nodoc
class __$VertexMoveStartedCopyWithImpl<$Res>
    implements _$VertexMoveStartedCopyWith<$Res> {
  __$VertexMoveStartedCopyWithImpl(this._self, this._then);

  final _VertexMoveStarted _self;
  final $Res Function(_VertexMoveStarted) _then;

/// Create a copy of LotEditorEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? index = null,}) {
  return _then(_VertexMoveStarted(
null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _VertexMoved implements LotEditorEvent {
  const _VertexMoved(this.index, this.point);
  

 final  int index;
 final  LocalPoint point;

/// Create a copy of LotEditorEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VertexMovedCopyWith<_VertexMoved> get copyWith => __$VertexMovedCopyWithImpl<_VertexMoved>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VertexMoved&&(identical(other.index, index) || other.index == index)&&(identical(other.point, point) || other.point == point));
}


@override
int get hashCode => Object.hash(runtimeType,index,point);

@override
String toString() {
  return 'LotEditorEvent.vertexMoved(index: $index, point: $point)';
}


}

/// @nodoc
abstract mixin class _$VertexMovedCopyWith<$Res> implements $LotEditorEventCopyWith<$Res> {
  factory _$VertexMovedCopyWith(_VertexMoved value, $Res Function(_VertexMoved) _then) = __$VertexMovedCopyWithImpl;
@useResult
$Res call({
 int index, LocalPoint point
});


$LocalPointCopyWith<$Res> get point;

}
/// @nodoc
class __$VertexMovedCopyWithImpl<$Res>
    implements _$VertexMovedCopyWith<$Res> {
  __$VertexMovedCopyWithImpl(this._self, this._then);

  final _VertexMoved _self;
  final $Res Function(_VertexMoved) _then;

/// Create a copy of LotEditorEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? index = null,Object? point = null,}) {
  return _then(_VertexMoved(
null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,null == point ? _self.point : point // ignore: cast_nullable_to_non_nullable
as LocalPoint,
  ));
}

/// Create a copy of LotEditorEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalPointCopyWith<$Res> get point {
  
  return $LocalPointCopyWith<$Res>(_self.point, (value) {
    return _then(_self.copyWith(point: value));
  });
}
}

/// @nodoc


class _SelectedVertexDeleted implements LotEditorEvent {
  const _SelectedVertexDeleted();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SelectedVertexDeleted);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LotEditorEvent.selectedVertexDeleted()';
}


}




/// @nodoc


class _UndoRequested implements LotEditorEvent {
  const _UndoRequested();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UndoRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LotEditorEvent.undoRequested()';
}


}




/// @nodoc


class _RedoRequested implements LotEditorEvent {
  const _RedoRequested();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RedoRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LotEditorEvent.redoRequested()';
}


}




/// @nodoc


class _ClearRequested implements LotEditorEvent {
  const _ClearRequested();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClearRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LotEditorEvent.clearRequested()';
}


}




/// @nodoc


class _BoundaryCloseRequested implements LotEditorEvent {
  const _BoundaryCloseRequested();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BoundaryCloseRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LotEditorEvent.boundaryCloseRequested()';
}


}




/// @nodoc


class _NameChanged implements LotEditorEvent {
  const _NameChanged(this.name);
  

 final  String name;

/// Create a copy of LotEditorEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NameChangedCopyWith<_NameChanged> get copyWith => __$NameChangedCopyWithImpl<_NameChanged>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NameChanged&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,name);

@override
String toString() {
  return 'LotEditorEvent.nameChanged(name: $name)';
}


}

/// @nodoc
abstract mixin class _$NameChangedCopyWith<$Res> implements $LotEditorEventCopyWith<$Res> {
  factory _$NameChangedCopyWith(_NameChanged value, $Res Function(_NameChanged) _then) = __$NameChangedCopyWithImpl;
@useResult
$Res call({
 String name
});




}
/// @nodoc
class __$NameChangedCopyWithImpl<$Res>
    implements _$NameChangedCopyWith<$Res> {
  __$NameChangedCopyWithImpl(this._self, this._then);

  final _NameChanged _self;
  final $Res Function(_NameChanged) _then;

/// Create a copy of LotEditorEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? name = null,}) {
  return _then(_NameChanged(
null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _SaveRequested implements LotEditorEvent {
  const _SaveRequested();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SaveRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LotEditorEvent.saveRequested()';
}


}




/// @nodoc
mixin _$LotEditorState {

 LotDraft get draft; LotBoundaryValidation get validation; List<List<LocalPoint>> get undoStack; List<List<LocalPoint>> get redoStack; bool get isClosed; bool get showValidationErrors; int? get selectedVertexIndex; List<Lot> get existingLots; bool get isSaving; Lot? get savedLot; String? get errorMessage;
/// Create a copy of LotEditorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LotEditorStateCopyWith<LotEditorState> get copyWith => _$LotEditorStateCopyWithImpl<LotEditorState>(this as LotEditorState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LotEditorState&&(identical(other.draft, draft) || other.draft == draft)&&(identical(other.validation, validation) || other.validation == validation)&&const DeepCollectionEquality().equals(other.undoStack, undoStack)&&const DeepCollectionEquality().equals(other.redoStack, redoStack)&&(identical(other.isClosed, isClosed) || other.isClosed == isClosed)&&(identical(other.showValidationErrors, showValidationErrors) || other.showValidationErrors == showValidationErrors)&&(identical(other.selectedVertexIndex, selectedVertexIndex) || other.selectedVertexIndex == selectedVertexIndex)&&const DeepCollectionEquality().equals(other.existingLots, existingLots)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.savedLot, savedLot) || other.savedLot == savedLot)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,draft,validation,const DeepCollectionEquality().hash(undoStack),const DeepCollectionEquality().hash(redoStack),isClosed,showValidationErrors,selectedVertexIndex,const DeepCollectionEquality().hash(existingLots),isSaving,savedLot,errorMessage);

@override
String toString() {
  return 'LotEditorState(draft: $draft, validation: $validation, undoStack: $undoStack, redoStack: $redoStack, isClosed: $isClosed, showValidationErrors: $showValidationErrors, selectedVertexIndex: $selectedVertexIndex, existingLots: $existingLots, isSaving: $isSaving, savedLot: $savedLot, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $LotEditorStateCopyWith<$Res>  {
  factory $LotEditorStateCopyWith(LotEditorState value, $Res Function(LotEditorState) _then) = _$LotEditorStateCopyWithImpl;
@useResult
$Res call({
 LotDraft draft, LotBoundaryValidation validation, List<List<LocalPoint>> undoStack, List<List<LocalPoint>> redoStack, bool isClosed, bool showValidationErrors, int? selectedVertexIndex, List<Lot> existingLots, bool isSaving, Lot? savedLot, String? errorMessage
});


$LotDraftCopyWith<$Res> get draft;$LotBoundaryValidationCopyWith<$Res> get validation;$LotCopyWith<$Res>? get savedLot;

}
/// @nodoc
class _$LotEditorStateCopyWithImpl<$Res>
    implements $LotEditorStateCopyWith<$Res> {
  _$LotEditorStateCopyWithImpl(this._self, this._then);

  final LotEditorState _self;
  final $Res Function(LotEditorState) _then;

/// Create a copy of LotEditorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? draft = null,Object? validation = null,Object? undoStack = null,Object? redoStack = null,Object? isClosed = null,Object? showValidationErrors = null,Object? selectedVertexIndex = freezed,Object? existingLots = null,Object? isSaving = null,Object? savedLot = freezed,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as LotDraft,validation: null == validation ? _self.validation : validation // ignore: cast_nullable_to_non_nullable
as LotBoundaryValidation,undoStack: null == undoStack ? _self.undoStack : undoStack // ignore: cast_nullable_to_non_nullable
as List<List<LocalPoint>>,redoStack: null == redoStack ? _self.redoStack : redoStack // ignore: cast_nullable_to_non_nullable
as List<List<LocalPoint>>,isClosed: null == isClosed ? _self.isClosed : isClosed // ignore: cast_nullable_to_non_nullable
as bool,showValidationErrors: null == showValidationErrors ? _self.showValidationErrors : showValidationErrors // ignore: cast_nullable_to_non_nullable
as bool,selectedVertexIndex: freezed == selectedVertexIndex ? _self.selectedVertexIndex : selectedVertexIndex // ignore: cast_nullable_to_non_nullable
as int?,existingLots: null == existingLots ? _self.existingLots : existingLots // ignore: cast_nullable_to_non_nullable
as List<Lot>,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,savedLot: freezed == savedLot ? _self.savedLot : savedLot // ignore: cast_nullable_to_non_nullable
as Lot?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of LotEditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LotDraftCopyWith<$Res> get draft {
  
  return $LotDraftCopyWith<$Res>(_self.draft, (value) {
    return _then(_self.copyWith(draft: value));
  });
}/// Create a copy of LotEditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LotBoundaryValidationCopyWith<$Res> get validation {
  
  return $LotBoundaryValidationCopyWith<$Res>(_self.validation, (value) {
    return _then(_self.copyWith(validation: value));
  });
}/// Create a copy of LotEditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LotCopyWith<$Res>? get savedLot {
    if (_self.savedLot == null) {
    return null;
  }

  return $LotCopyWith<$Res>(_self.savedLot!, (value) {
    return _then(_self.copyWith(savedLot: value));
  });
}
}


/// Adds pattern-matching-related methods to [LotEditorState].
extension LotEditorStatePatterns on LotEditorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LotEditorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LotEditorState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LotEditorState value)  $default,){
final _that = this;
switch (_that) {
case _LotEditorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LotEditorState value)?  $default,){
final _that = this;
switch (_that) {
case _LotEditorState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LotDraft draft,  LotBoundaryValidation validation,  List<List<LocalPoint>> undoStack,  List<List<LocalPoint>> redoStack,  bool isClosed,  bool showValidationErrors,  int? selectedVertexIndex,  List<Lot> existingLots,  bool isSaving,  Lot? savedLot,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LotEditorState() when $default != null:
return $default(_that.draft,_that.validation,_that.undoStack,_that.redoStack,_that.isClosed,_that.showValidationErrors,_that.selectedVertexIndex,_that.existingLots,_that.isSaving,_that.savedLot,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LotDraft draft,  LotBoundaryValidation validation,  List<List<LocalPoint>> undoStack,  List<List<LocalPoint>> redoStack,  bool isClosed,  bool showValidationErrors,  int? selectedVertexIndex,  List<Lot> existingLots,  bool isSaving,  Lot? savedLot,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _LotEditorState():
return $default(_that.draft,_that.validation,_that.undoStack,_that.redoStack,_that.isClosed,_that.showValidationErrors,_that.selectedVertexIndex,_that.existingLots,_that.isSaving,_that.savedLot,_that.errorMessage);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LotDraft draft,  LotBoundaryValidation validation,  List<List<LocalPoint>> undoStack,  List<List<LocalPoint>> redoStack,  bool isClosed,  bool showValidationErrors,  int? selectedVertexIndex,  List<Lot> existingLots,  bool isSaving,  Lot? savedLot,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _LotEditorState() when $default != null:
return $default(_that.draft,_that.validation,_that.undoStack,_that.redoStack,_that.isClosed,_that.showValidationErrors,_that.selectedVertexIndex,_that.existingLots,_that.isSaving,_that.savedLot,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _LotEditorState extends LotEditorState {
  const _LotEditorState({required this.draft, required this.validation, final  List<List<LocalPoint>> undoStack = const <List<LocalPoint>>[], final  List<List<LocalPoint>> redoStack = const <List<LocalPoint>>[], this.isClosed = false, this.showValidationErrors = false, this.selectedVertexIndex, final  List<Lot> existingLots = const <Lot>[], this.isSaving = false, this.savedLot, this.errorMessage}): _undoStack = undoStack,_redoStack = redoStack,_existingLots = existingLots,super._();
  

@override final  LotDraft draft;
@override final  LotBoundaryValidation validation;
 final  List<List<LocalPoint>> _undoStack;
@override@JsonKey() List<List<LocalPoint>> get undoStack {
  if (_undoStack is EqualUnmodifiableListView) return _undoStack;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_undoStack);
}

 final  List<List<LocalPoint>> _redoStack;
@override@JsonKey() List<List<LocalPoint>> get redoStack {
  if (_redoStack is EqualUnmodifiableListView) return _redoStack;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_redoStack);
}

@override@JsonKey() final  bool isClosed;
@override@JsonKey() final  bool showValidationErrors;
@override final  int? selectedVertexIndex;
 final  List<Lot> _existingLots;
@override@JsonKey() List<Lot> get existingLots {
  if (_existingLots is EqualUnmodifiableListView) return _existingLots;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_existingLots);
}

@override@JsonKey() final  bool isSaving;
@override final  Lot? savedLot;
@override final  String? errorMessage;

/// Create a copy of LotEditorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LotEditorStateCopyWith<_LotEditorState> get copyWith => __$LotEditorStateCopyWithImpl<_LotEditorState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LotEditorState&&(identical(other.draft, draft) || other.draft == draft)&&(identical(other.validation, validation) || other.validation == validation)&&const DeepCollectionEquality().equals(other._undoStack, _undoStack)&&const DeepCollectionEquality().equals(other._redoStack, _redoStack)&&(identical(other.isClosed, isClosed) || other.isClosed == isClosed)&&(identical(other.showValidationErrors, showValidationErrors) || other.showValidationErrors == showValidationErrors)&&(identical(other.selectedVertexIndex, selectedVertexIndex) || other.selectedVertexIndex == selectedVertexIndex)&&const DeepCollectionEquality().equals(other._existingLots, _existingLots)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.savedLot, savedLot) || other.savedLot == savedLot)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,draft,validation,const DeepCollectionEquality().hash(_undoStack),const DeepCollectionEquality().hash(_redoStack),isClosed,showValidationErrors,selectedVertexIndex,const DeepCollectionEquality().hash(_existingLots),isSaving,savedLot,errorMessage);

@override
String toString() {
  return 'LotEditorState(draft: $draft, validation: $validation, undoStack: $undoStack, redoStack: $redoStack, isClosed: $isClosed, showValidationErrors: $showValidationErrors, selectedVertexIndex: $selectedVertexIndex, existingLots: $existingLots, isSaving: $isSaving, savedLot: $savedLot, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$LotEditorStateCopyWith<$Res> implements $LotEditorStateCopyWith<$Res> {
  factory _$LotEditorStateCopyWith(_LotEditorState value, $Res Function(_LotEditorState) _then) = __$LotEditorStateCopyWithImpl;
@override @useResult
$Res call({
 LotDraft draft, LotBoundaryValidation validation, List<List<LocalPoint>> undoStack, List<List<LocalPoint>> redoStack, bool isClosed, bool showValidationErrors, int? selectedVertexIndex, List<Lot> existingLots, bool isSaving, Lot? savedLot, String? errorMessage
});


@override $LotDraftCopyWith<$Res> get draft;@override $LotBoundaryValidationCopyWith<$Res> get validation;@override $LotCopyWith<$Res>? get savedLot;

}
/// @nodoc
class __$LotEditorStateCopyWithImpl<$Res>
    implements _$LotEditorStateCopyWith<$Res> {
  __$LotEditorStateCopyWithImpl(this._self, this._then);

  final _LotEditorState _self;
  final $Res Function(_LotEditorState) _then;

/// Create a copy of LotEditorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? draft = null,Object? validation = null,Object? undoStack = null,Object? redoStack = null,Object? isClosed = null,Object? showValidationErrors = null,Object? selectedVertexIndex = freezed,Object? existingLots = null,Object? isSaving = null,Object? savedLot = freezed,Object? errorMessage = freezed,}) {
  return _then(_LotEditorState(
draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as LotDraft,validation: null == validation ? _self.validation : validation // ignore: cast_nullable_to_non_nullable
as LotBoundaryValidation,undoStack: null == undoStack ? _self._undoStack : undoStack // ignore: cast_nullable_to_non_nullable
as List<List<LocalPoint>>,redoStack: null == redoStack ? _self._redoStack : redoStack // ignore: cast_nullable_to_non_nullable
as List<List<LocalPoint>>,isClosed: null == isClosed ? _self.isClosed : isClosed // ignore: cast_nullable_to_non_nullable
as bool,showValidationErrors: null == showValidationErrors ? _self.showValidationErrors : showValidationErrors // ignore: cast_nullable_to_non_nullable
as bool,selectedVertexIndex: freezed == selectedVertexIndex ? _self.selectedVertexIndex : selectedVertexIndex // ignore: cast_nullable_to_non_nullable
as int?,existingLots: null == existingLots ? _self._existingLots : existingLots // ignore: cast_nullable_to_non_nullable
as List<Lot>,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,savedLot: freezed == savedLot ? _self.savedLot : savedLot // ignore: cast_nullable_to_non_nullable
as Lot?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of LotEditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LotDraftCopyWith<$Res> get draft {
  
  return $LotDraftCopyWith<$Res>(_self.draft, (value) {
    return _then(_self.copyWith(draft: value));
  });
}/// Create a copy of LotEditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LotBoundaryValidationCopyWith<$Res> get validation {
  
  return $LotBoundaryValidationCopyWith<$Res>(_self.validation, (value) {
    return _then(_self.copyWith(validation: value));
  });
}/// Create a copy of LotEditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LotCopyWith<$Res>? get savedLot {
    if (_self.savedLot == null) {
    return null;
  }

  return $LotCopyWith<$Res>(_self.savedLot!, (value) {
    return _then(_self.copyWith(savedLot: value));
  });
}
}

// dart format on
