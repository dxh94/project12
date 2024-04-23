import 'package:project12/model/sub_models/frame_model.dart';

class FrameTemp {
  late int id;
  late double x;
  late double y;
  late double width;
  late double height;
  late double scale;
  late double rotation;
  FrameTemp({
    required this.height,
    required this.id,
    required this.rotation,
    required this.scale,
    required this.width,
    required this.x,
    required this.y,
  });
  Frame convertFrameTempToFrameModel() {
    return Frame(id, x, y, width, height, scale, rotation);
  }

  static FrameTemp convertFrameModelToFrameTemp(Frame frame) {
    return FrameTemp(
        height: frame.height,
        id: frame.id,
        rotation: frame.rotation,
        scale: frame.scale,
        width: frame.width,
        x: frame.x,
        y: frame.y);
  }
}