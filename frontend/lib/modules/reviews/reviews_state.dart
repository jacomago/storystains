import 'package:flutter/foundation.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:storystains/config/config.dart';

import 'package:storystains/models/review.dart';
import 'package:storystains/modules/reviews/reviews.dart';

class ReviewsState extends ChangeNotifier {
  final ReviewsService _service;

  int _offset = 0;
  List<Review> _items = [];

  bool _isEmpty = false;
  bool _isFailed = false;
  bool _isLoading = false;
  bool _hasReachedMax = false;

  int get offset => _offset;
  int get count => _items.length;
  List<Review> get items => _items;

  bool get isEmpty => _isEmpty;
  bool get isFailed => _isFailed;
  bool get isLoading => _isLoading;
  bool get hasReachedMax => _hasReachedMax;

  bool get isFirstPage => _offset == 1;
  bool get isLoadingFirst => _isLoading && isFirstPage;
  bool get isLoadingMore => _isLoading && _offset > 1;

  Review item(int index) => _items[index];

  ItemScrollController itemScrollController = ItemScrollController();
  ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  ReviewsState(this._service) {
    _init();
    _trigger();
  }

  Future<void> _init() async {
    _startLoading();

    final items = await _service.fetch(default_limit, 0);

    if (items == null) {
      _isFailed = true;
    } else if (items.isEmpty) {
      _isEmpty = true;
    } else {
      _offset = default_limit;
      _items = [...items];
    }

    notifyListeners();
    _stopLoading();
  }

  Future<void> refresh([int? limit]) async {
    _startLoading();

    final items = await _service.fetch(default_limit, 1);

    if (items != null && items.isNotEmpty) {
      _offset = 2 * default_limit;
      _items = [...items];
    }

    notifyListeners();
    _stopLoading();
  }

  Future<void> fetch() async {
    if (!_isLoading) {
      _startLoading();

      final items = await _service.fetch(default_limit, _offset);

      if (items != null) {
        if (items.isEmpty) {
          _isEmpty = false;
          _isFailed = false;
          _hasReachedMax = true;
        } else {
          _offset = _offset + default_limit;
          _items = [..._items, ...items];

          _isEmpty = false;
          _isFailed = false;
          _hasReachedMax = false;
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
    _offset = 1;
    _items = [];
    _isEmpty = false;
    _isFailed = false;
    _isLoading = false;
    super.dispose();
  }
}
