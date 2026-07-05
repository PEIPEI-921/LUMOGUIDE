import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class MessageLists {
  int evaluateMyCount;
  int followMyCount;
  int systemCount;
  MessageListsContent? followMessage;
  MessageListsContent? evaluateMessage;
  MessageListsContent? reserveMessage;
  MessageListsContent? myReserveMessage;

  MessageLists({
    this.evaluateMyCount = 0,
    this.followMyCount = 0,
    this.systemCount = 0,
    this.followMessage,
    this.evaluateMessage,
    this.reserveMessage,
    this.myReserveMessage,
  });

  factory MessageLists.fromJson(Map<String, dynamic> json) {
    return MessageLists(
      evaluateMyCount: json.safeInt('evaluate_my_count') ?? 0,
      followMyCount: json.safeInt('follow_my_count') ?? 0,
      systemCount: json.safeInt('system_count') ?? 0,
      followMessage: json.safeObject(
        'follow_message',
        MessageListsContent.fromJson,
      ),
      evaluateMessage: json.safeObject(
        'evaluate_message',
        MessageListsContent.fromJson,
      ),
      reserveMessage: json.safeObject(
        'reserve_message',
        MessageListsContent.fromJson,
      ),
      myReserveMessage: json.safeObject(
        'my_reserve_message',
        MessageListsContent.fromJson,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'evaluate_my_count': evaluateMyCount,
      'follow_my_count': followMyCount,
      'system_count': systemCount,
      'follow_message': followMessage?.toJson(),
      'evaluate_message': evaluateMessage?.toJson(),
      'reserve_message': reserveMessage?.toJson(),
      'my_reserve_message': myReserveMessage?.toJson(),
    };
  }
}

class MessageListsContent {
  String? text;
  String? time;

  String? get formatTime {
    if (time == null) return null;
    final date = DateTime.tryParse(time ?? '');
    if (date == null) return null;
    return date.formatTimeAgo();
  }

  MessageListsContent({this.text, this.time});

  factory MessageListsContent.fromJson(Map<String, dynamic> json) {
    return MessageListsContent(
      text: json.safeString('text'),
      time: json.safeString('time'),
    );
  }

  Map<String, dynamic> toJson() {
    return {'text': text, 'time': time};
  }
}

enum MessageTopFixed { follow, evaluate, reserve, myReserve, chat }

extension MessageTopFixedExtension on MessageTopFixed {
  String get title {
    switch (this) {
      case MessageTopFixed.follow:
        return '關注信息'.tr;
      case MessageTopFixed.evaluate:
        return '評論信息'.tr;
      case MessageTopFixed.reserve:
        return '預定信息'.tr;
      case MessageTopFixed.myReserve:
        return '預定信息'.tr;
      case MessageTopFixed.chat:
        return '聊天'.tr;
    }
  }

  String get icon {
    switch (this) {
      case MessageTopFixed.follow:
        return Assets.iconMsgFollow;
      case MessageTopFixed.evaluate:
        return Assets.iconMsgComment;
      case MessageTopFixed.reserve:
        return Assets.iconMsgReserve;
      case MessageTopFixed.myReserve:
        return Assets.iconMsgReserve;
      case MessageTopFixed.chat:
        return Assets.iconMsgFollow;
    }
  }
}

class MessageTopFixedModel {
  String? text;
  String? time;
  MessageTopFixed? topFixed;
  dynamic conversation;

  MessageTopFixedModel({
    this.text,
    this.time,
    this.topFixed,
    this.conversation,
  });
}

class MessageSystemModel {
  String? title;
  String? content;
  String? time;
  String? desc;
  String? contentType;
  int? contentId;
  int? cityId;
  int? cityContentType;

  String? get formatDate {
    if (time == null) return null;
    final date = DateTime.tryParse(time ?? '');
    if (date == null) return null;
    return date.formatTimeAgo();
  }

  MessageSystemModel({
    this.title,
    this.content,
    this.time,
    this.desc,
    this.contentType,
    this.contentId,
    this.cityId,
    this.cityContentType,
  });

  bool get hasLinkedContent {
    final id = contentId;
    if (id == null || id <= 0) return false;
    final t = (contentType ?? '').trim();
    return t == 'city' || t == 'city_content';
  }

  void openLinkedContent() {
    final id = contentId;
    if (id == null || id <= 0) return;
    switch ((contentType ?? '').trim()) {
      case 'city':
        Get.toNamed(AppRoutes.CITY_DETAIL, arguments: {'id': id});
        return;
      case 'city_content':
        final cid = cityId ?? 0;
        final tid = cityContentType ?? 0;
        if (cid <= 0 || tid <= 0) {
          Loading.toast('暫無詳情'.tr);
          return;
        }
        Get.toNamed(
          AppRoutes.COMMON_DETAIL,
          arguments: {'id': id, 'city_id': cid, 'type_id': tid},
        );
        return;
    }
  }

  factory MessageSystemModel.fromJson(Map<String, dynamic> json) {
    return MessageSystemModel(
      title: json.safeString('title'),
      content: json.safeString('content'),
      time: json.safeString('time'),
      desc: json.safeString('desc'),
      contentType: json.safeString('content_type'),
      contentId: json.safeInt('content_id'),
      cityId: json.safeInt('city_id'),
      cityContentType: json.safeInt('city_content_type'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'time': time,
      'desc': desc,
      'content_type': contentType,
      'content_id': contentId,
      'city_id': cityId,
      'city_content_type': cityContentType,
    };
  }
}
