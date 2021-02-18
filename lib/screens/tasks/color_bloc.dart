import 'dart:async';

enum ColorCircleEvent { visible, invisible }

class ColorCircleBloc {
  StreamController<ColorCircleEvent> _eventColorCircleController =
  StreamController<ColorCircleEvent>.broadcast();
  StreamSink<ColorCircleEvent> get eventColorCircleSink =>
      _eventColorCircleController.sink;

  StreamController<bool> _boolController = StreamController<bool>.broadcast();
  StreamSink<bool> get _boolStateSink => _boolController.sink;
  Stream<bool> get colorCircleStream => _boolController.stream;

  dispose() {
    _eventColorCircleController.close();
    _boolController.close();
  }

  void _mapEventToBool(ColorCircleEvent event) {
    if (event == ColorCircleEvent.visible) {
      _boolStateSink.add(true);
    }
    if (event == ColorCircleEvent.invisible) {
      _boolStateSink.add(false);
    }
  }

  ColorCircleBloc() {
    _eventColorCircleController.stream.listen(_mapEventToBool);
  }
}
