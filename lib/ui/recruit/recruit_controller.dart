import 'package:dio/dio.dart' as dios;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:kexie_app/internet/network.dart';
import 'package:kexie_app/models/recruitInfo/recruitInfo.dart';
import 'package:kexie_app/ui/recruit/update_dialog.dart';
import 'package:kexie_app/widgets/loading_view.dart';
import 'package:kexie_app/widgets/toast.dart';

class RecruitController extends GetxController {
  final GlobalKey formKey = GlobalKey();
  final nameController = TextEditingController();
  final studentIdController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final introduceController = TextEditingController();
  final reasonController = TextEditingController();
  final impressionController = TextEditingController();
  var isManager = '否';
  var learnDirection = '安卓开发';

  String? nameValidator(String name) {
    return name.isEmpty ? '姓名不能为空' : null;
  }

  String? emailValidator(String email) {
    return email.isEmpty ? '邮箱不能为空' : null;
  }

  String? idValidator(String id) {
    return id.isEmpty ? '学号不能为空' : null;
  }

  String? phoneValidator(String phone) {
    return phone.isEmpty ? '电话不能为空' : null;
  }

  String? introduceValidator(String introduce) {
    if (introduce.length < 50) {
      return '自我介绍字数不足';
    } else if (introduce.length > 500) {
      return '自我介绍字数过多';
    } else {
      return null;
    }
  }

  String? impressionValidator(String impression) {
    return impression.length > 500 ? '对科协印象字数过多' : null;
  }

  String? reasonValidator(String reason) {
    if (reason.length < 50) {
      return '自我介绍字数不足';
    } else if (reason.length > 500) {
      return '自我介绍字数过多';
    } else {
      return null;
    }
  }

  bool mapBool(String choose) {
    return choose == '是' ? true : false;
  }

  void uploadInfo(BuildContext context) async {
    try {
      dios.Dio dio = AppNetwork.get().appDio;
      dio.options.headers['Content-Type'] = 'application/json';
      RecruitInfo recruitInfo = RecruitInfo(
          name: nameController.text,
          email: emailController.text,
          studentId: studentIdController.text,
          phone: phoneController.text,
          learnDirection: learnDirection,
          isManger: mapBool(isManager),
          introduction: introduceController.text,
          reasonToSign: reasonController.text,
          impression: impressionController.text);
      dios.Response response =
          await dio.post('/recruit/upload_info', data: recruitInfo);
      LoadingView.show(context, text: '报名表上传中，请勿离开页面...');
      print(response.data);
      if (response.data['code'] == 200) {
        toastSuccess(message: response.data['msg']);
        LoadingView.hide(context);
      } else if (response.data['code'] == 201) {
        LoadingView.hide(context);
        showDialog(context: context, builder: (context) => UpdateDialog(),barrierDismissible: false);
      } else {
        toastFailure(message: response.data['msg']);
        LoadingView.hide(context);
      }
    } on Exception catch (e) {
      toastFailure(message: '上传失败', error: e.toString());
      LoadingView.hide(context);
    }
  }

  Future<bool> updateInfo() async {
    try {
      dios.Dio dio = AppNetwork.get().appDio;
      dio.options.headers['Content-Type'] = 'application/json';
      RecruitInfo recruitInfo = RecruitInfo(
          name: nameController.text,
          email: emailController.text,
          studentId: studentIdController.text,
          phone: phoneController.text,
          learnDirection: learnDirection,
          isManger: mapBool(isManager),
          introduction: introduceController.text,
          reasonToSign: reasonController.text,
          impression: impressionController.text);
      dios.Response response = await dio.post('/recruit/update_info', data: recruitInfo);
      print(response.data);
      if (response.data['code'] == 200) {
        toastSuccess(message: response.data['msg'],toastGravity: ToastGravity.CENTER);
        return true;
      } else {
        toastFailure(message: response.data['msg'],toastGravity: ToastGravity.CENTER);
        return false;
      }
    } on Exception catch (e) {
      toastFailure(message: '上传失败', error: e.toString(),toastGravity: ToastGravity.CENTER);
      return false;
    }
  }

}
