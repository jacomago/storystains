import 'package:flutter/foundation.dart';
import 'package:storystains/model/entity/emotion.dart';
import 'package:storystains/model/entity/review_emotion.dart';

class ReviewEmotionsState extends ChangeNotifier {
  List<ReviewEmotion> _items = [];

  bool _isEmpty = false;
  bool _isNewItem = false;
  Emotion? _newEmotion;

  int get count => _items.length;
  List<ReviewEmotion> get items => _items;

  bool get newItem => _isNewItem;
  bool get isEmpty => _isEmpty;

  get newEmotion => _newEmotion;

  ReviewEmotion item(int index) => _items[index];

  ReviewEmotionsState(List<ReviewEmotion> items) {
    _items = items;
  }

  Future create(Emotion emotion) async {
    _isNewItem = true;
    _newEmotion = emotion;
    notifyListeners();
  }

  Future cancelCreate() async {
    _isNewItem = false;
    _newEmotion = null;
    notifyListeners();
  }

  Future confirmCreation(ReviewEmotion reviewEmotion) async {
    _items.add(reviewEmotion);
    _items.sort(((a, b) => a.position.compareTo(b.position)));
    await cancelCreate();
  }

  @override
  void dispose() {
    _items = [];
    _isEmpty = false;
    _isNewItem = false;
    _newEmotion = null;
    super.dispose();
  }
}
