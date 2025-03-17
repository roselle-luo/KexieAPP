import 'package:dio/dio.dart' as dios;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:kexie_app/internet/network.dart';
import 'package:kexie_app/global/global.dart';
import 'package:kexie_app/models/onlineUsers/onlineUsers.dart';
import 'package:kexie_app/widgets/toast.dart';

class SignController extends GetxController{
  var isSign = false.obs;
  var startTime = ''.obs;
  var totalTime = ''.obs;
  var singleTotalTime = ''.obs;
  var week = 1.obs;
  var peopleNums = 0.obs;
  RxList<Data> onlineUsers = <Data>[].obs;
  RxList<Data> filterOnlineUsers = <Data>[].obs;

  sign() async {
    dios.Dio dio = AppNetwork.get().kexieDio;
    try {
      dios.Response response = await dio.post('/api/user/signIn',data: {'userId': Global.user.value.studentId});
      if (response.data['code'] == 0) {
        toastSuccess(message: '签到成功');
        isSign.value = true;
        week.value = response.data['data']['week'];
        await getOnline();
      } else {
        if (response.data['code'] == -201) {
          await getUserStatus();
        }
        toastFailure(message: '签到失败',error: response.data['msg']);
      }
    } on Exception catch (e) {
      toastFailure(message: '签到失败',error: e.toString());
    }
  }

  signOut() async {
    dios.Dio dio = AppNetwork.get().kexieDio;
    try {
      dios.Response response = await dio.post('/api/user/signOut',data: {'userId': Global.user.value.studentId});
      if (response.data['code'] == 0) {
        toastSuccess(message: '签退成功');
        totalTime.value = response.data['data']['totalTime'];
        isSign.value = false;
      } else {
        toastFailure(message: '签退失败',error: response.data['msg']);
      }
    } on Exception catch (e) {
      toastFailure(message: '签退失败',error: e.toString());
    }
  }

  getUserStatus() async {
    dios.Dio dio = AppNetwork.get().kexieDio;
    try {
      dios.Response response = await dio.get('/api/record/online/${Global.user.value.studentId}');
      if (response.data['code'] == 0) {
        if(response.data['data']['status'] == 0) {
          isSign.value = false;
        } else if (response.data['data']['status'] == 1) {
          isSign.value = true;
          print(response.data['data']['week']);
          week.value = response.data['data']['week'];
          await getOnline();
        }
      } else {
        toastFailure(message: '获取状态失败',error: response.data['msg']);
      }
    } on Exception catch (e) {
      toastFailure(message: '获取状态失败',error: e.toString());
    }
  }

  getOnline() async {
    dios.Dio dio = AppNetwork.get().kexieDio;
    try {
      dios.Response response = await dio.get('/api/record/online');
      if (response.data['code'] == 0) {
        OnlineUsers onlineUsers = OnlineUsers.fromJson(response.data);
        peopleNums.value = onlineUsers.data.length;
        this.onlineUsers.clear();
        this.onlineUsers.addAll(onlineUsers.data);
        filterOnlineUsers.value = this.onlineUsers;
        if (kDebugMode){
          this.onlineUsers.forEach((u) => print(u.userName));
        }
      } else {
        toastFailure(error: '获取在线用户失败');
      }
    } on Exception catch (e) {
      toastFailure(message: '获取在线用户失败',error: e.toString());
    }
  }

  complaintUser(int targetId) async {
    dios.Dio dio = AppNetwork.get().kexieDio;
    try {
      dios.Response response = await dio.post('/api/user/complaint',data: {'operatorUserId': Global.user.value.studentId,'targetUserId': targetId});
      if (response.data['code'] == 0) {
        toastSuccess(message: '举报成功');
        await getUserStatus();
        await getOnline();
      } else {
        toastFailure(message: '举报失败',error: response.data['msg']);
      }
    } on Exception catch (e) {
      toastFailure(message: '举报失败',error: e.toString());
    }
  }

  @override
  void onInit() async {
    super.onInit();
    await getUserStatus();
  }

}