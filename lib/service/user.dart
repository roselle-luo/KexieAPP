import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kexie_app/internet/network.dart';
import 'package:kexie_app/global/global.dart';
import 'package:kexie_app/widgets/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_infor/user_infor.dart';

class AppService {
  Future<void> initUserInfor() async {
    final Dio dio = AppNetwork.get().appDio;
    if (kDebugMode) {
      if (kDebugMode) {
        print(dio.options.headers);
      }
    }
    try {
      final response = await dio.get('/account/get_user');
      final UserInfor user;
      if (response.statusCode == 200) {
        user = UserInfor.fromJson(response.data['data']);
        Global.user.value = user;
        if (kDebugMode) {
          print(user.toString());
        }
      } else {
        if (kDebugMode) {
          print("初始化失败${response.data}");
        }
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print("初始化失败$e");
      }
    }
  }

  Future exitLogin() async {
    final pref = await SharedPreferences.getInstance();
    pref.setString('token','');
    Global.isLogin.value = false;
    Global.user.value = UserInfor(iD: -1, createdAt: '', updatedAt: '', name: '', avatar: '', email: '', studentId: '', department: '', learnDirection: '', location: '', grade: '', permission: 10);
    toastSuccess(message: '退出成功');
  }

  AppService._create();

  static final AppService _instance = AppService._create();

  factory AppService() {
    return _instance;
  }

}
