import 'package:storystains/common/data/network/rest_client.dart';
import 'package:storystains/common/utils/services.dart';

import '../../model/entity/emotion.dart';

class EmotionsService {
  Future<List<Emotion>?> fetch() async {
    try {
      //final res = await sl.get<RestClient>().getEmotions();
      final fullUrl =
          "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg'%3E%3Ccircle r='50' cx='50' cy='50' fill='tomato'/%3E%3Ccircle r='41' cx='47' cy='50' fill='orange'/%3E%3Ccircle r='33' cx='48' cy='53' fill='gold'/%3E%3Ccircle r='25' cx='49' cy='51' fill='yellowgreen'/%3E%3Ccircle r='17' cx='52' cy='50' fill='lightseagreen'/%3E%3Ccircle r='9' cx='55' cy='48' fill='teal'/%3E%3C/svg%3E";
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
