import 'package:realm/realm.dart';

part 'frame_model.g.dart';

@RealmModel()
class $Frame {
  @PrimaryKey()
  late int id;
  late double x;
  late double y;
  late double width;
  late double height;
  late double scale;
  late double rotation;
}