import 'package:storystains/common/constant/app_config.dart';
import 'package:storystains/common/data/network/rest_client.dart';
import 'package:storystains/common/utils/service_locator.dart';
import 'package:storystains/features/review/review_model.dart';

class ReviewsService {
  Future<List<Review>?> fetch({String query = "", int offset = 0}) async {
    try {
      final res = await sl
          .get<RestClient>()
          .getReviews(limit: AppConfig.defaultLimit, offset: offset);

      return res.reviews;
    } catch (e) {
      return null;
    }
  }
}
