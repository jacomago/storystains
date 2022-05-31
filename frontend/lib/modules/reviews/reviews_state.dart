import 'package:flutter/foundation.dart';

import 'package:frontend/modules/reviews/reviews.dart';

class ReviewsState extends ChangeNotifier {

  final ReviewsService _service;

  ReviewsState(this._service);

}