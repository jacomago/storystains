import 'package:flutter/foundation.dart';
import 'medium_model.dart';

import 'medium_service.dart';

/// State of loading mediums from api usually at top level for caching
class MediumsState extends ChangeNotifier {
  final MediumsService _service;

  List<Medium> _items = [];

  bool _isEmpty = false;
  bool _isFailed = false;
  bool _isLoading = false;

  /// count of mediums
  int get count => _items.length;

  /// all mediums possible
  List<Medium> get items => _items;

  /// if empty amount
  bool get isEmpty => _isEmpty;

  /// if failed to load
  bool get isFailed => _isFailed;

  /// if still loading
  bool get isLoading => _isLoading;

  /// item at index
  Medium item(int index) => _items[index];

  /// default mediums
  Medium get mediumDefault => _items.isEmpty ? Medium.mediumDefault : _items[0];

  /// load mediums
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
