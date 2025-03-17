import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:kexie_app/internet/network.dart';
import 'package:kexie_app/global/global.dart';
import 'package:kexie_app/service/user.dart';
import 'package:kexie_app/widgets/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login{
  static Future<void> login({required String name,required String studentId,required BuildContext context}) async {
    final dio = AppNetwork.get().appDio;
    FormData formData = FormData.fromMap({
      'name': name,
      'student_id': studentId,
    });
    try {
      final Response response = await dio.post('/account/login',data: formData);
      if (response.data['code'] == 200) {
        String token = response.data['data'];
        final pref = await SharedPreferences.getInstance();
        await pref.setString('token', token);
        await AppNetwork.initNetwork();
        AppService().initUserInfor();
        Global.isLogin.value = true;
        toastSuccess(message: '登录成功');
        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.of(context).pop();
      } else {
        toastFailure(message: '登录失败' ,error: response.data['msg']);
        if (kDebugMode) {
          print(response.data);
        }
      }
    } on Exception catch (e) {
      toastFailure(error: '登录失败：',message: e.toString());
    }
  }

}