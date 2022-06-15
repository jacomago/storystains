import 'package:get_it/get_it.dart';
import 'package:storystains/common/data/network/dio_manager.dart';
import 'package:storystains/common/data/network/rest_client.dart';

// Service Locator
final sl = GetIt.instance;

class Lasting {
  void setup() {
    final dioManager = DioManager();
    sl.registerSingleton<DioManager>(dioManager);
    sl.registerSingleton<RestClient>(RestClient(dioManager.dio));
  }
}
