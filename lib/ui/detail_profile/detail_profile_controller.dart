import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart' as dios;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kexie_app/internet/network.dart';
import 'package:kexie_app/service/user.dart';
import 'package:kexie_app/widgets/image_view.dart';
import 'package:kexie_app/widgets/loading_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';

import '../../global/global.dart';
import '../../widgets/toast.dart';

class DetailProfileController extends GetxController {
  final imagePicker = ImagePicker();
  var image = Rxn<XFile>();

  readAvatar(String url) {
    Get.to(
        ImageView(
          backgroundColor: Colors.black,
          imgUrl: "http://47.76.139.24:9000$url",
        ),
        transition: Transition.cupertino);
  }

  changeAvatar(BuildContext context) async {
    image.value = await imagePicker.pickImage(source: ImageSource.gallery);
    dios.FormData toChangeAvatar = dios.FormData();
    toChangeAvatar.files.add(MapEntry(
      'avatar',
      await dios.MultipartFile.fromFile(image.value!.path,
          filename: image.value!.name),
    ));
    dios.Dio dio = AppNetwork.get().appDio;
    LoadingView.show(context, text: '正在更换中，请稍候');
    try {
      final response = await dio.post(
        '/account/set_avatar',
        data: toChangeAvatar,
      );
      if (response.data['code'] == 200) {
        toastSuccess(message: response.data['msg']);
        AppService().initUserInfor();
      } else {
        toastFailure(error: '保存失败', message: response.data['msg']);
      }
    } on Exception catch (e) {
      toastFailure(error: e, message: '保存失败');
    } finally {
      LoadingView.hide(context);
    }
  }

  saveNetworkImage(BuildContext context) async {
    if (GetPlatform.isDesktop) {
      toastFailure(message: '保存失败', error: "暂不支持非移动端"); // todo
      return;
    }

    bool isGranted;
    if (Platform.isAndroid) {
      final sdkInt = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
      isGranted = await (sdkInt > 33 ? Permission.photos : Permission.storage)
          .request()
          .isGranted;
    } else {
      isGranted = await Permission.photosAddOnly.request().isGranted;
    }

    if (isGranted) {
      String picturesPath =
          "${DateTime.now().millisecondsSinceEpoch}-${Global.user.value.name}.jpg";
      LoadingView.show(context, text: '保存中，请勿离开此页面...');
      try {
        final response = await dios.Dio().get(
          'http://47.76.139.24:9000${Global.user.value.avatar}',
          options: dios.Options(responseType: dios.ResponseType.bytes),
        );
        final result = await SaverGallery.saveImage(
          Uint8List.fromList(response.data),
          quality: 100,
          name: picturesPath,
          androidRelativePath: "Pictures/KexieApp",
          androidExistNotSave: false,
        );
        if (result.isSuccess) {
          toastSuccess(message: '保存成功');
        } else {
          toastFailure(message: '保存失败', error: result.errorMessage);
        }
      } on Exception catch (e) {
        toastFailure(message:'保存失败',error: e.toString());
      } finally {
        LoadingView.hide(context); // Ensure this is always called
      }
    } else {
      toastFailure(message: '保存失败', error: "权限不允许");
      // Ensure LoadingView.hide(context) is called in this case as well
    }
  }
}
