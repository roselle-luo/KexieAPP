import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppNetwork {
  static const String kexieBaseUrl = "https://at.kexie.space";
  static const String appBaseUrl = 'http://jzhangluo.com:20051';

  late Dio kexieDio;
  late Dio appDio;

  // 私有构造函数
  AppNetwork._create() {
    kexieDio = setupKexieDio(Dio());
    appDio = setupAppDio(Dio(), '');
  }

  // 单例实例
  static final AppNetwork _instance = AppNetwork._create();

  // 工厂构造函数
  factory AppNetwork.get() {
    return _instance;
  }

  // 配置 kexieDio
  static Dio setupKexieDio(Dio dio) {
    dio.options = BaseOptions(
      baseUrl: kexieBaseUrl,
      followRedirects: false,
      validateStatus: (int? status) => status != null,
    );
    return dio;
  }

  // 配置 appDio
  static Dio setupAppDio(Dio dio, String token) {
    dio.options = BaseOptions(
      baseUrl: appBaseUrl,
      headers: {"token": token},
      followRedirects: false,
      validateStatus: (int? status) => status != null,
    );
    return dio;
  }

  // 初始化网络配置
  static Future<void> initNetwork() async {
    final pref = await SharedPreferences.getInstance();
    String token = pref.getString('token') ?? '';
    print(token);
    if (token.isNotEmpty) {
      // 更新 appDio 的配置
      _instance.appDio = setupAppDio(_instance.appDio, token);
    }
  }
}
