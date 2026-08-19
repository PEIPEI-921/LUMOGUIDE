import 'package:get/get.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation.dart';
import 'package:flutter/material.dart';
import 'package:lumotrip/common/index.dart';

class ChatController extends GetxController with ApiMixin, UserStoreMixin {
  late V2TimConversation conversation;

  String? get conversationID =>
      conversation.type == 1 ? conversation.userID : conversation.groupID;

  final _memberInfo = Rxn<MemberInfo>();
  MemberInfo? get memberInfo => _memberInfo.value;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is! Map) {
      Get.back();
      return;
    }
    final args = Get.arguments as Map;
    conversation = args["conversation"];
    if (conversation.type != 2) {
      fetchMemberInfo();
    }
  }

  onMore() async {
    if (conversation.type == 2) {
      await Get.toNamed(
        AppRoutes.GROUP_PROFILE,
        arguments: {'groupID': conversation.groupID},
      );
      conversation =
          await TIMStore.to.getConversation(conversationID!) ?? conversation;
    } else {
      // if (userInfo.isUnLimited) {
      //   Get.toNamed(AppRoutes.USER_PROFILE, arguments: {
      //     'userID': conversation.userID,
      //   });
      //   return;
      // }
      // Get.toNamed(AppRoutes.PROFILE, arguments: conversation.userID);
    }
  }

  onTapAvatar(String userID, TapDownDetails tapDetails) {
    if (userInfo.number == userID) return;
    if (memberInfo?.identity == 2) {
      final previousRoute = Get.previousRoute;
      if (previousRoute == AppRoutes.GUIDE_DETAIL) {
        Get.back();
        return;
      }
      Get.toNamed(
        AppRoutes.GUIDE_DETAIL,
        arguments: {'id': memberInfo?.guideId},
      );
    } else if (memberInfo?.identity == 3) {
      Get.toNamed(
        AppRoutes.COMPANY_INFO,
        arguments: {'id': memberInfo?.companyId},
      );
    }
  }

  fetchMemberInfo() async {
    final res = await get(
      ApiUrl.memberInfo,
      parameters: {'user_number': conversation.userID},
    );
    if (!res.isSuccess) {
      return;
    }

    _memberInfo.value = MemberInfo.fromJson(res.dataJson);
  }
}
