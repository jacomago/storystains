import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../common/constant/app_config.dart';
import '../review/review_model.dart';

import 'reviews_service.dart';

class ReviewsState extends ChangeNotifier {
  final ReviewsService _service;

  int _offset = 0;
  String _query = '';
  List<Review> _items = [];

  bool _isEmpty = false;
  bool _isFailed = false;
  bool _isLoading = false;
  bool _hasReachedMax = false;

  int get offset => _offset;
  int get count => _items.length;
  String get query => _query;
  List<Review> get items => _items;

  bool get isEmpty => _isEmpty;
  bool get isFailed => _isFailed;
  bool get isLoading => _isLoading;
  bool get hasReachedMax => _hasReachedMax;

  bool get isFirstPage => _offset == 0;
  bool get isLoadingFirst => _isLoading && isFirstPage;
  bool get isLoadingMore => _isLoading && _offset > 0;

  Review item(int index) => _items[index];

  ItemScrollController itemScrollController = ItemScrollController();
  ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  ReviewsState(this._service) {
    _init();
    _trigger();
  }

  Future<void> _init() async {
    _startLoading();

    try {
      final items = await _service.fetch();
      if (items == null) {
        _isFailed = true;
      } else if (items.isEmpty) {
        _isEmpty = true;
      } else {
        _offset = AppConfig.defaultLimit;
        _query = '';
        _items = [...items];
      }
    } on DioError catch (_) {
      _isFailed = true;
    }

    notifyListeners();
    _stopLoading();
  }

  Future<void> refresh([String? query]) async {
    _startLoading();

    try {
      final items = await _service.fetch();

      if (items != null && items.isNotEmpty) {
        _offset = AppConfig.defaultLimit;
        _query = query ?? '';
        _items = [...items];
        _isFailed = false;
        _isEmpty = false;
      }
    } on DioError catch (_) {
      _isFailed = true;
    }

    notifyListeners();
    _stopLoading();
  }

  Future<void> fetch() async {
    if (!_isLoading) {
      _startLoading();

      try {
        final items = await _service.fetch(query: _query, offset: _offset);

        if (items != null) {
          if (items.isEmpty) {
            _isEmpty = false;
            _isFailed = false;
            _hasReachedMax = true;
          } else {
            _offset = _offset + AppConfig.defaultLimit;
            _items = [..._items, ...items];

            _isEmpty = false;
            _isFailed = false;
            _hasReachedMax = false;
          }
        }
      } on DioError catch (_) {
        _isFailed = true;
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

  void _trigger() {
    itemPositionsListener.itemPositions.addListener(() {
      final pos = itemPositionsListener.itemPositions.value;
      final lastIndex = count - 1;

      final isAtBottom = pos.isNotEmpty && pos.last.index == lastIndex;
      final isLoadMore = isAtBottom && !isLoading && !hasReachedMax;

      // load data from the next offset
      if (isLoadMore) {
        fetch();
      }
    });
  }

  @override
  void dispose() {
    _offset = 0;
    _items = [];
    _isEmpty = false;
    _isFailed = false;
    _isLoading = false;
    super.dispose();
  }
}
