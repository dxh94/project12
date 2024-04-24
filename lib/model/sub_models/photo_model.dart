import 'package:project12/model/sub_models/frame_model.dart';
import 'package:realm/realm.dart';

part 'photo_model.g.dart';

@RealmModel()
class $Photos {
  @PrimaryKey()
  late int id;
  late String media;
  late $Frame? frame;
}