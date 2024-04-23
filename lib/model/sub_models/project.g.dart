import 'package:project12/model/sub_models/photo_model.dart';
import 'package:realm/realm.dart';

part "project.g.dart";

@RealmModel()
class _ProjectModel {
  @PrimaryKey()
  late int id;
  late double idCheck;
  late String name;
  late List<$Photos> photos;
  late bool isCheckProject;
}