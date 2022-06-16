import 'package:storystains/common/constant/app_config.dart';
import 'package:storystains/common/data/network/rest_client.dart';
import 'package:storystains/common/utils/services.dart';

import '../../model/entity/emotion.dart';

class EmotionsService {
  Future<List<Emotion>?> fetch() async {
    try {
      //final res = await sl.get<RestClient>().getEmotions();
      final fullUrl = "$AppConfig.baseUrl/assets/amaze.svg";
      return [
        Emotion(name: "Joy", iconUrl: fullUrl, description: "stuff"),
        Emotion(name: "Anger", iconUrl: fullUrl, description: "stuff"),
        Emotion(name: "Hope", iconUrl: fullUrl, description: "stuff"),
        Emotion(name: "Blah", iconUrl: fullUrl, description: "stuff"),
        Emotion(name: "d", iconUrl: fullUrl, description: "stuff"),
        Emotion(name: "Jody", iconUrl: fullUrl, description: "stuff"),
        Emotion(name: "Jody", iconUrl: fullUrl, description: "stuff"),
        Emotion(name: "Joly", iconUrl: fullUrl, description: "stuff"),
        Emotion(name: "Jojy", iconUrl: fullUrl, description: "stuff"),
        Emotion(name: "Joyy", iconUrl: fullUrl, description: "stuff"),
        Emotion(name: "Joy", iconUrl: fullUrl, description: "stuff"),
        Emotion(name: "Joy", iconUrl: fullUrl, description: "stuff"),
        Emotion(name: "Joy", iconUrl: fullUrl, description: "stuff"),
        Emotion(name: "Joy", iconUrl: fullUrl, description: "stuff"),
        Emotion(name: "Joy", iconUrl: fullUrl, description: "stuff"),
        Emotion(name: "Joy", iconUrl: fullUrl, description: "stuff"),
        Emotion(name: "Joy", iconUrl: fullUrl, description: "stuff"),
        Emotion(name: "Joy", iconUrl: fullUrl, description: "stuff"),
      ];

      //return res.emotions;
    } catch (e) {
      return null;
    }
  }
}
