import 'package:flutter/foundation.dart';
import '../emotions/emotion_model.dart';
import '../review_emotion/review_emotion.dart';

/// Events on [ReviewEmotion] list
enum ReviewEmotionsEvent {
  /// editing an item
  edit,

  /// creating an item
  create,

  /// no event
  none,
}

/// State of list of [ReviewEmotion] on a review
class ReviewEmotionsState extends ChangeNotifier {
  List<ReviewEmotion> _items = [];

  bool _isEmpty = false;
  Emotion? _currentEmotion;
  int? _currentIndex;

  /// If editing or creating a new ReviewEmotion
  /// This value will be set to a new state.
  ReviewEmotionState? currentReviewEmotionState;

  /// count
  int get count => _items.length;

  /// all items loaded
  List<ReviewEmotion> get items => _items;

  /// if empty list
  bool get isEmpty => _isEmpty;

  /// current [Emotion]
  Emotion? get currentEmotion => _currentEmotion;

  /// item
  ReviewEmotion item(int index) => _items[index];

  /// load state
  ReviewEmotionsState(List<ReviewEmotion>? items) {
    _items = items ?? [];
  }

  /// Clear the current value
  void clear() {
    _items = [];
  }

  set items(List<ReviewEmotion> items) {
    _items = items;
    notifyListeners();
  }

  /// create an new [ReviewEmotion]
  Future<void> create(Emotion emotion) async {
    currentReviewEmotionState =
        ReviewEmotionState(ReviewEmotionService(), emotion: emotion);
    _currentEmotion = emotion;
    notifyListeners();
  }

  /// Edit a current [ReviewEmotion]
  Future<void> edit(
    int index,
    Emotion emotion,
    ReviewEmotion reviewEmotion,
  ) async {
    currentReviewEmotionState = ReviewEmotionState(
      ReviewEmotionService(),
      reviewEmotion: reviewEmotion,
      emotion: emotion,
    );
    _currentEmotion = emotion;
    _currentIndex = index;
    notifyListeners();
  }

  /// Cancel creating a new [ReviewEmotion]
  Future<void> cancelCreate() async {
    currentReviewEmotionState = null;
    _currentIndex = null;
    _currentEmotion = null;
    notifyListeners();
  }

  /// confirm creation of [ReviewEmotion]
  Future<void> confirmCreation(ReviewEmotion reviewEmotion) async {
    // In creation mode if currentIndex is null
    if (_currentIndex == null) {
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
    // if current index != null then editing a reviewEmotion
    if (_currentIndex != null) {
      _items.removeAt(_currentIndex!);
    }
    _items.sort(((a, b) => a.position.compareTo(b.position)));
    await cancelCreate();
  }

  @override
  void dispose() {
    _items = [];
    _isEmpty = false;
    _currentIndex = null;
    _currentEmotion = null;
    super.dispose();
  }
}
