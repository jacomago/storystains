import 'package:dio/dio.dart';

import '../../common/data/network/rest_client.dart';
import '../../common/utils/service_locator.dart';
import 'medium_model.dart';

/// Wrapper around [RestClient] methods on a [Medium]
class MediumsService {
  /// Wrapper around [RestClient.getMediums]
  Future<List<Medium>?> fetch() async {
    try {
      final res = await ServiceLocator.sl.get<RestClient>().getMediums();

      return res.mediums;
    } on DioError catch (_) {
      return null;
    }
  }
}
