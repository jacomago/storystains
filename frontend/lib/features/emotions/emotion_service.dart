import 'package:storystains/common/data/network/rest_client.dart';
import 'package:storystains/common/utils/services.dart';
import 'package:storystains/model/resp/emotions_resp.dart';

import '../../model/entity/emotion.dart';

class EmotionsService {
  Future<List<Emotion>?> fetch() async {
    try {
      final res = await sl.get<RestClient>().getEmotions();

      if (res is EmotionsResp) {
        final data = res.emotions;

        return data;
      }
    } catch (e) {
      return null;
    }

    return null;
  }
}
