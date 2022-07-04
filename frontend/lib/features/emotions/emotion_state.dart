import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../common/constant/app_config.dart';
import 'emotion_model.dart';

import 'emotion_service.dart';

class EmotionsState extends ChangeNotifier {
  final EmotionsService _service;

  List<Emotion> _items = [];

  bool _isEmpty = false;
  bool _isFailed = false;
  bool _isLoading = false;

  int get count => _items.length;
  List<Emotion> get items => _items;

  bool get isEmpty => _isEmpty;
  bool get isFailed => _isFailed;
  bool get isLoading => _isLoading;

  Emotion item(int index) => _items[index];

  Emotion get emotionDefault => _items.isEmpty
      ? const Emotion(description: '', name: 'Default', iconUrl: '')
      : _items[0];

  EmotionsState(this._service) {
    _init();
  }

  Future<void> _init() async {
    _startLoading();

    final items = await _service.fetch();

    if (items == null) {
      _isFailed = true;
    } else if (items.isEmpty) {
      _isEmpty = true;
    } else {
      _items = [...items];
    }

    await _precache();

    notifyListeners();
    _stopLoading();
  }

  Future<void> _precache() async {
    for (var e in _items) {
      await precachePicture(
        NetworkPicture(
          SvgPicture.svgByteDecoderBuilder,
          e.iconFullUrl(),
        ),
        null,
      );
    }
  }

  void _startLoading() {
    _isLoading = true;
    notifyListeners();
  }

  void _stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _items = [];
    _isEmpty = false;
    _isFailed = false;
    _isLoading = false;
    super.dispose();
  }
}
