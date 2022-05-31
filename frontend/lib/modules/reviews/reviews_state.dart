import 'package:flutter/foundation.dart';

import 'reviews_service.dart';

class ReviewsState extends ChangeNotifier {

  final ReviewsService _service;

  ReviewsState(this._service);

}