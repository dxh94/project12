// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'frame_model.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class Frame extends $Frame with RealmEntity, RealmObjectBase, RealmObject {
  Frame(
    int id,
    double x,
    double y,
    double width,
    double height,
    double scale,
    double rotation,
  ) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'x', x);
    RealmObjectBase.set(this, 'y', y);
    RealmObjectBase.set(this, 'width', width);
    RealmObjectBase.set(this, 'height', height);
    RealmObjectBase.set(this, 'scale', scale);
    RealmObjectBase.set(this, 'rotation', rotation);
  }

  Frame._();

  @override
  int get id => RealmObjectBase.get<int>(this, 'id') as int;
  @override
  set id(int value) => RealmObjectBase.set(this, 'id', value);

  @override
  double get x => RealmObjectBase.get<double>(this, 'x') as double;
  @override
  set x(double value) => RealmObjectBase.set(this, 'x', value);

  @override
  double get y => RealmObjectBase.get<double>(this, 'y') as double;
  @override
  set y(double value) => RealmObjectBase.set(this, 'y', value);

  @override
  double get width => RealmObjectBase.get<double>(this, 'width') as double;
  @override
  set width(double value) => RealmObjectBase.set(this, 'width', value);

  @override
  double get height => RealmObjectBase.get<double>(this, 'height') as double;
  @override
  set height(double value) => RealmObjectBase.set(this, 'height', value);

  @override
  double get scale => RealmObjectBase.get<double>(this, 'scale') as double;
  @override
  set scale(double value) => RealmObjectBase.set(this, 'scale', value);

  @override
  double get rotation =>
      RealmObjectBase.get<double>(this, 'rotation') as double;
  @override
  set rotation(double value) => RealmObjectBase.set(this, 'rotation', value);

  @override
  Stream<RealmObjectChanges<Frame>> get changes =>
      RealmObjectBase.getChanges<Frame>(this);

  @override
  Frame freeze() => RealmObjectBase.freezeObject<Frame>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Frame._);
    return const SchemaObject(ObjectType.realmObject, Frame, 'Frame', [
      SchemaProperty('id', RealmPropertyType.int, primaryKey: true),
      SchemaProperty('x', RealmPropertyType.double),
      SchemaProperty('y', RealmPropertyType.double),
      SchemaProperty('width', RealmPropertyType.double),
      SchemaProperty('height', RealmPropertyType.double),
      SchemaProperty('scale', RealmPropertyType.double),
      SchemaProperty('rotation', RealmPropertyType.double),
    ]);
  }
}
