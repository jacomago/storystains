import 'package:flutter/foundation.dart';
import '../emotions/emotion_model.dart';
import '../review_emotion/review_emotion_model.dart';

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

  /// count
  int get count => _items.length;

  /// all items loaded
  List<ReviewEmotion> get items => _items;

  /// current edited item
  ReviewEmotion? get currentReviewEmotion =>
      editing.value == ReviewEmotionsEvent.edit ? _items[_currentIndex!] : null;

  /// if empty list
  bool get isEmpty => _isEmpty;

  /// current [Emotion]
  Emotion? get currentEmotion => _currentEmotion;

  /// If editing a review emotion
  late ValueNotifier<ReviewEmotionsEvent> editing;

  /// item
  ReviewEmotion item(int index) => _items[index];

  /// load state
  ReviewEmotionsState(List<ReviewEmotion>? items) {
    _items = items ?? [];
    editing = ValueNotifier<ReviewEmotionsEvent>(ReviewEmotionsEvent.none);
  }

  /// Clear the current value
  void clear() {
    _items = [];
  }

  /// create an new [ReviewEmotion]
  Future<void> create(Emotion emotion) async {
    editing.value = ReviewEmotionsEvent.create;
    editing.notifyListeners();
    _currentEmotion = emotion;
    notifyListeners();
  }

  /// Edit a current [ReviewEmotion]
  Future<void> edit(int index, Emotion emotion) async {
    editing.value = ReviewEmotionsEvent.edit;
    editing.notifyListeners();
    _currentEmotion = emotion;
    _currentIndex = index;
    notifyListeners();
  }

  /// Cancel creating a new [ReviewEmotion]
  Future<void> cancelCreate() async {
    editing.value = ReviewEmotionsEvent.none;
    editing.notifyListeners();
    _currentIndex = null;
    _currentEmotion = null;
    notifyListeners();
  }

  /// confirm creation of [ReviewEmotion]
  Future<void> confirmCreation(ReviewEmotion reviewEmotion) async {
    if (editing.value == ReviewEmotionsEvent.create) {
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
    if (!(editing.value == ReviewEmotionsEvent.create)) {
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
