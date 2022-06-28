import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:storystains/common/constant/app_config.dart';
import 'package:storystains/features/emotions/emotion_model.dart';

import 'emotion_service.dart';

class EmotionsState extends ChangeNotifier {
  final EmotionsService _service;

  late Future _initFuture;

  List<Emotion> _items = [];

  bool _isEmpty = false;
  bool _isFailed = false;
  bool _isLoading = false;

  int get count => _items.length;
  List<Emotion> get items => _items;

  bool get isEmpty => _isEmpty;
  bool get isFailed => _isFailed;
  bool get isLoading => _isLoading;

  Future get initDone => _initFuture;
  Emotion item(int index) => _items[index];

  Emotion get emotionDefault => _items.isEmpty
      ? Emotion(description: '', name: "Default", iconUrl: "")
      : _items[0];

  EmotionsState(this._service) {
    _initFuture = _init();
  }

  Future _init() async {
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

  static String iconFullUrl(Emotion emotion) =>
      '${AppConfig.imagesBaseUrl}${emotion.iconUrl}';

  Future<void> _precache() async {
    for (Emotion e in _items) {
      await precachePicture(
        NetworkPicture(
          SvgPicture.svgByteDecoderBuilder,
          iconFullUrl(e),
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
