import 'package:dio/dio.dart';

import '../../common/constant/app_config.dart';
import '../../common/data/network/rest_client.dart';
import '../../common/utils/service_locator.dart';
import '../review/review_model.dart';

class ReviewsService {
  Future<List<Review>?> fetch({String query = '', int offset = 0}) async {
    try {
      final res = await sl
          .get<RestClient>()
          .getReviews(limit: AppConfig.defaultLimit, offset: offset);

      return res.reviews;
    } on DioError catch (_) {
      return null;
    }
  }
}
