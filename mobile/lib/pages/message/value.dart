import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

enum MessageCategory {
  myComment,
  commentMe,
  myFollow,
  followMe,
  system,
}

extension MessageTabExtension on MessageCategory {
  String get title {
    switch (this) {
      case MessageCategory.myComment:
        return '我的評論'.tr;
      case MessageCategory.commentMe:
        return '評論我的'.tr;
      case MessageCategory.myFollow:
        return '我的關注'.tr;
      case MessageCategory.followMe:
        return '關注我的'.tr;
      case MessageCategory.system:
        return '系統消息'.tr;
    }
  }

  String get icon {
    switch (this) {
      case MessageCategory.myComment:
        return Assets.iconMsgMyComment;
      case MessageCategory.commentMe:
        return Assets.iconMsgCommentMe;
      case MessageCategory.myFollow:
        return Assets.iconMsgMyFollow;
      case MessageCategory.followMe:
        return Assets.iconMsgFollowMe;
      case MessageCategory.system:
        return Assets.iconMsgSystem;
    }
  }
}