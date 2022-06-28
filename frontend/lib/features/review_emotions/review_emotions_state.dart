import 'package:flutter/foundation.dart';
import 'package:storystains/features/emotions/emotion_model.dart';
import 'package:storystains/features/review_emotion/review_emotion_model.dart';

class ReviewEmotionsState extends ChangeNotifier {
  List<ReviewEmotion> _items = [];

  bool _isEmpty = false;
  bool _isNewItem = false;
  bool _isEditItem = false;
  Emotion? _currentEmotion;
  int? _currentIndex;

  int get count => _items.length;
  List<ReviewEmotion> get items => _items;

  bool get newItem => _isNewItem;
  bool get editItem => _isEditItem;
  ReviewEmotion? get currentReviewEmotion =>
      _isEditItem ? _items[_currentIndex!] : null;
  bool get isEmpty => _isEmpty;

  get currentEmotion => _currentEmotion;

  ReviewEmotion item(int index) => _items[index];

  ReviewEmotionsState(List<ReviewEmotion> items) {
    _items = items;
  }

  Future create(Emotion emotion) async {
    _isNewItem = true;
    _currentEmotion = emotion;
    notifyListeners();
  }

  Future edit(int index, Emotion emotion) async {
    _isEditItem = true;
    _currentEmotion = emotion;
    _currentIndex = index;
    notifyListeners();
  }

  Future cancelCreate() async {
    _isNewItem = false;
    _isEditItem = false;
    _currentIndex = null;
    _currentEmotion = null;
    notifyListeners();
  }

  Future confirmCreation(ReviewEmotion reviewEmotion) async {
    if (_isNewItem) {
      _items.add(reviewEmotion);
    } else {
      _items[_currentIndex!] = reviewEmotion;
    }
    _items.sort(((a, b) => a.position.compareTo(b.position)));
    await cancelCreate();
  }

  Future confirmEdit(ReviewEmotion reviewEmotion) async {
    _items.sort(((a, b) => a.position.compareTo(b.position)));
    await cancelCreate();
  }

  Future confirmDelete() async {
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
