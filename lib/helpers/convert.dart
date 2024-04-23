import 'package:project12/helpers/random_number.dart';
import 'package:project12/model/sub_models/frame_model.dart';
import 'package:project12/model/sub_models/photo_model.dart';
import 'package:project12/model/sub_models/project.dart';
class FlutterConvert {
  Photos convertJsonToPhotos(Map<String, dynamic> json) {
    dynamic url = json['url'];
    dynamic frame =
        json['frame'] != null ? convertJsonToFrame(json['frame']) : null;
    return Photos(randomInt(), url, frame: frame);
  }

  Frame convertJsonToFrame(Map<String, dynamic> json) {
    double x = (json['x']).toDouble();
    double y = (json['y']).toDouble();
    double width = (json['width']).toDouble();
    double height = (json['height']).toDouble();
    return Frame(randomInt(), x, y, width, height, 1.0, 0.0);
  }

  ProjectModel convertJsonToProjectModel(Map<String, dynamic> json) {
    dynamic name = json['name'];
    dynamic id = json['id'];
    List<Photos> photos = <Photos>[];
    if (json['photos'] != null) {
      json['photos'].forEach((v) {
        photos.add(convertJsonToPhotos(v));
      });
    }
    return ProjectModel(
      id,
      randomDouble(),
      name,
      false,
      photos: photos,
    );
  }
}