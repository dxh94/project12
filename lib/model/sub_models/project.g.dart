// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class ProjectModel extends _ProjectModel
    with RealmEntity, RealmObjectBase, RealmObject {
  ProjectModel(
    int id,
    double idCheck,
    String name,
    bool isCheckProject, {
    Iterable<Photos> photos = const [],
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'idCheck', idCheck);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'isCheckProject', isCheckProject);
    RealmObjectBase.set<RealmList<Photos>>(
        this, 'photos', RealmList<Photos>(photos));
  }

  ProjectModel._();

  @override
  int get id => RealmObjectBase.get<int>(this, 'id') as int;
  @override
  set id(int value) => RealmObjectBase.set(this, 'id', value);

  @override
  double get idCheck => RealmObjectBase.get<double>(this, 'idCheck') as double;
  @override
  set idCheck(double value) => RealmObjectBase.set(this, 'idCheck', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  RealmList<Photos> get photos =>
      RealmObjectBase.get<Photos>(this, 'photos') as RealmList<Photos>;
  @override
  set photos(covariant RealmList<Photos> value) =>
      throw RealmUnsupportedSetError();

  @override
  bool get isCheckProject =>
      RealmObjectBase.get<bool>(this, 'isCheckProject') as bool;
  @override
  set isCheckProject(bool value) =>
      RealmObjectBase.set(this, 'isCheckProject', value);

  @override
  Stream<RealmObjectChanges<ProjectModel>> get changes =>
      RealmObjectBase.getChanges<ProjectModel>(this);

  @override
  ProjectModel freeze() => RealmObjectBase.freezeObject<ProjectModel>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(ProjectModel._);
    return const SchemaObject(
        ObjectType.realmObject, ProjectModel, 'ProjectModel', [
      SchemaProperty('id', RealmPropertyType.int, primaryKey: true),
      SchemaProperty('idCheck', RealmPropertyType.double),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('photos', RealmPropertyType.object,
          linkTarget: 'Photos', collectionType: RealmCollectionType.list),
      SchemaProperty('isCheckProject', RealmPropertyType.bool),
    ]);
  }
}
