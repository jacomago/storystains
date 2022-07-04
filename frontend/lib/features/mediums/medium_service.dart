import 'package:dio/dio.dart';

import '../../common/data/network/rest_client.dart';
import '../../common/utils/service_locator.dart';
import 'medium_model.dart';

class MediumsService {
  Future<List<Medium>?> fetch() async {
    try {
      final res = await sl.get<RestClient>().getMediums();

      return res.mediums;
    } on DioError catch (_) {
      return null;
    }
  }
}
