import 'package:dio/dio.dart';

import '../../common/data/network/rest_client.dart';
import '../../common/utils/service_locator.dart';
import 'emotion_model.dart';

/// Wrapper around [RestClient] methods on a [Emotion]
class EmotionsService {
  /// Wrapper around [RestClient.getEmotions]
  Future<List<Emotion>?> fetch() async {
    try {
      final res = await ServiceLocator.sl.get<RestClient>().getEmotions();

      return res.emotions;
    } on DioException catch (_) {
      return null;
    }
  }
}
