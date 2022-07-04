import 'package:flutter/foundation.dart';
import 'medium_model.dart';

import 'medium_service.dart';

class MediumsState extends ChangeNotifier {
  final MediumsService _service;

  List<Medium> _items = [];

  bool _isEmpty = false;
  bool _isFailed = false;
  bool _isLoading = false;

  int get count => _items.length;
  List<Medium> get items => _items;

  bool get isEmpty => _isEmpty;
  bool get isFailed => _isFailed;
  bool get isLoading => _isLoading;

  Medium item(int index) => _items[index];

  Medium get mediumDefault => _items.isEmpty ? Medium.mediumDefault : _items[0];

  MediumsState(this._service) {
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
