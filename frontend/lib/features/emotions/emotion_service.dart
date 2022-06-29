import 'package:storystains/common/data/network/rest_client.dart';
import 'package:storystains/common/utils/service_locator.dart';
import 'package:storystains/features/emotions/emotion_model.dart';

class EmotionsService {
  Future<List<Emotion>?> fetch() async {
    try {
      final res = await sl.get<RestClient>().getEmotions();

      return res.emotions;
    } catch (e) {
      return null;
    }
  }
}
