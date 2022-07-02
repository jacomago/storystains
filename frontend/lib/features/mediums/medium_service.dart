import 'package:storystains/common/data/network/rest_client.dart';
import 'package:storystains/common/utils/service_locator.dart';
import 'package:storystains/features/mediums/medium_model.dart';

class MediumsService {
  Future<List<Medium>?> fetch() async {
    try {
      final res = await sl.get<RestClient>().getMediums();

      return res.mediums;
    } catch (e) {
      return null;
    }
  }
}
