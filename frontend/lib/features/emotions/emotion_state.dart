import 'package:flutter/foundation.dart';
import 'package:storystains/model/entity/emotion.dart';

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

  Future<void> refresh([String? query]) async {
    _startLoading();

    final items = await _service.fetch();

    if (items != null && items.isNotEmpty) {
      _items = [...items];
      _isFailed = false;
      _isEmpty = false;
    }

    notifyListeners();
    _stopLoading();
  }

  Future<void> fetch() async {
    if (!_isLoading) {
      _startLoading();

      final items = await _service.fetch();

      if (items != null) {
        if (items.isEmpty) {
          _isEmpty = false;
          _isFailed = false;
        } else {
          _items = [..._items, ...items];

          _isEmpty = false;
          _isFailed = false;
        }
      }

      notifyListeners();
      _stopLoading();
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
