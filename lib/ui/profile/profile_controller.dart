import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kexie_app/service/user.dart';
import 'package:share_plus/share_plus.dart';

import '../sign_system/sign_controller.dart';

class ProfileController extends GetxController {

  SignController signController = Get.find();

  final shareText = "亲爱的科协成员，这是属于桂电三院科协的App。\n\n在上面能够完成签到打卡，能够查看签到记录以及签到时长排名。\n\n成为正式成员后你还能在独属科协的论坛里面发帖冲浪。\n\n上面还有一系列工具助你在学校在社团的生活更加便捷。\n\n快来下载试试吧。\n\n github地址：\n https://github.com/1zhangluo1/KexieAPP";
  
  void shareApp(BuildContext context) {
    Share.share(
        shareText,
    );
  }

  void showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '退出登录',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          content: Text(
            '您确定要退出登录吗？',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                '取消',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
            TextButton(
              onPressed: () {
                AppService().exitLogin();
                signController.isSign.value = false;
                Navigator.of(context).pop();
              },
              child: Text(
                '确定',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
          ],
        );
      },
    );
  }
}
