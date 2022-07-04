import 'package:flutter/foundation.dart';
import '../emotions/emotion_model.dart';
import '../review_emotion/review_emotion_model.dart';

/// State of list of [ReviewEmotion] on a review
class ReviewEmotionsState extends ChangeNotifier {
  List<ReviewEmotion> _items = [];

  bool _isEmpty = false;
  bool _isNewItem = false;
  bool _isEditItem = false;
  Emotion? _currentEmotion;
  int? _currentIndex;

  /// count
  int get count => _items.length;

  /// all items loaded
  List<ReviewEmotion> get items => _items;

  /// if a new item
  bool get newItem => _isNewItem;

  /// if editing an item
  bool get editItem => _isEditItem;

  /// current edited item
  ReviewEmotion? get currentReviewEmotion =>
      _isEditItem ? _items[_currentIndex!] : null;

  /// if empty list
  bool get isEmpty => _isEmpty;

  /// current [Emotion]
  Emotion? get currentEmotion => _currentEmotion;

  /// item
  ReviewEmotion item(int index) => _items[index];

  /// load state
  ReviewEmotionsState(List<ReviewEmotion> items) {
    _items = items;
  }

  /// create an new [ReviewEmotion]
  Future<void> create(Emotion emotion) async {
    _isNewItem = true;
    _currentEmotion = emotion;
    notifyListeners();
  }

  /// Edit a current [ReviewEmotion]
  Future<void> edit(int index, Emotion emotion) async {
    _isEditItem = true;
    _currentEmotion = emotion;
    _currentIndex = index;
    notifyListeners();
  }

  /// Cancel creating a new [ReviewEmotion]
  Future<void> cancelCreate() async {
    _isNewItem = false;
    _isEditItem = false;
    _currentIndex = null;
    _currentEmotion = null;
    notifyListeners();
  }

  /// confirm creation of [ReviewEmotion]
  Future<void> confirmCreation(ReviewEmotion reviewEmotion) async {
    if (_isNewItem) {
      _items.add(reviewEmotion);
    } else {
      _items[_currentIndex!] = reviewEmotion;
    }
    _items.sort(((a, b) => a.position.compareTo(b.position)));
    await cancelCreate();
  }

  /// confirm editing a [ReviewEmotion]
  Future<void> confirmEdit(ReviewEmotion reviewEmotion) async {
    _items.sort(((a, b) => a.position.compareTo(b.position)));
    await cancelCreate();
  }

  /// Confirm deletion of a [ReviewEmotion] from list
  Future<void> confirmDelete() async {
    if (!_isNewItem) {
      _items.removeAt(_currentIndex!);
    }
    _items.sort(((a, b) => a.position.compareTo(b.position)));
    await cancelCreate();
  }

  @override
  void dispose() {
    _items = [];
    _isEmpty = false;
    _isNewItem = false;
    _currentEmotion = null;
    super.dispose();
  }
}
