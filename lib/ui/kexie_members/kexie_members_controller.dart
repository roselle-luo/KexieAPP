import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kexie_app/internet/network.dart';
import 'package:kexie_app/models/kexie_members/kexie_members.dart';
import 'package:kexie_app/widgets/toast.dart';

class KexieMembersController extends GetxController {

  Rx<KexieMembers> kexieMembers = KexieMembers(code: 1, result: false, msg: '', data: []).obs;
  late Future members;
  RxList<Data> filterMembers = <Data>[].obs;
  TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    members = getMembers();
    searchController.addListener( () {
      filterMembers.value = kexieMembers.value.data.where((member) => member.name.contains(searchController.text.trim())).toList();
    });
  }

  Future getMembers() async {
    try {
      final dio = AppNetwork.get().appDio;
      final response = await dio.get('/tools/kexie_members');
      if (response.data['code'] == 200) {
        kexieMembers.value = KexieMembers.fromJson(response.data);
        kexieMembers.value.data = kexieMembers.value.data.reversed.toList();
        filterMembers.value = kexieMembers.value.data;
      } else {
        toastFailure(message: response.data['msg']);
      }
    } on Exception catch (e) {
      toastFailure(message: e.toString());
    }
  }
}