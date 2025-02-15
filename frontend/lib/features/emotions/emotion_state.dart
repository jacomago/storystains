import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'emotion_model.dart';

import 'emotion_service.dart';

/// State of loading emotions from api usually at top level for caching
class EmotionsState extends ChangeNotifier {
  final EmotionsService _service;

  List<Emotion> _items = [];

  bool _isEmpty = false;
  bool _isFailed = false;
  bool _isLoading = false;

  /// count of emotions
  int get count => _items.length;

  /// emotions
  List<Emotion> get items => _items;

  /// if empty list
  bool get isEmpty => _isEmpty;

  /// if failed to fetch api
  bool get isFailed => _isFailed;

  /// if still loading from api
  bool get isLoading => _isLoading;

  /// pick and item
  Emotion item(int index) => _items[index];

  /// default emotion
  Emotion get emotionDefault => _items.isEmpty
      ? const Emotion(
          description: '',
          name: 'Default',
          iconUrl: '',
          joy: 0,
          sadness: 0,
          anger: 0,
          disgust: 0,
          surprise: 0,
          fear: 0,
        )
      : _items[0];

  /// begin load and create state
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

    notifyListeners();
    _stopLoading();
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
