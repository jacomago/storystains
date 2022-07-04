import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../common/constant/app_config.dart';
import '../review/review_model.dart';

import 'reviews_service.dart';

/// State for a [Review]s and covers intractions with the Api
class ReviewsState extends ChangeNotifier {
  final ReviewsService _service;

  int _offset = 0;
  String _query = '';
  List<Review> _items = [];

  bool _isEmpty = false;
  bool _isFailed = false;
  bool _isLoading = false;
  bool _hasReachedMax = false;

  /// Current offset sending to api
  int get offset => _offset;

  /// Count of items
  int get count => _items.length;

  /// Query to pass to list
  String get query => _query;

  /// the current items
  List<Review> get items => _items;

  /// If list is empty
  bool get isEmpty => _isEmpty;

  /// If getting list failed
  bool get isFailed => _isFailed;

  /// If loading from the api
  bool get isLoading => _isLoading;

  /// If has reache dthe amx [Review]s from the api
  bool get hasReachedMax => _hasReachedMax;

  /// If on the first page
  bool get isFirstPage => _offset == 0;

  /// If loading the first selection of results
  bool get isLoadingFirst => _isLoading && isFirstPage;

  /// If still loading more items
  bool get isLoadingMore => _isLoading && _offset > 0;

  /// Get an item from the list
  Review item(int index) => _items[index];

  /// Scroll controller
  ItemScrollController itemScrollController = ItemScrollController();

  /// Position in the list controller
  ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  /// State for a [Review]s and covers intractions with the Api
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

  /// Refresh the list
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

  /// Fetch more data from the api
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
