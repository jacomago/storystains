import 'package:dio/dio.dart';

import '../../common/data/network/rest_client.dart';
import '../../common/utils/service_locator.dart';
import 'emotion_model.dart';

class EmotionsService {
  Future<List<Emotion>?> fetch() async {
    try {
      final res = await sl.get<RestClient>().getEmotions();

      return res.emotions;
    } on DioError catch (_) {
      return null;
    }
  }
}
