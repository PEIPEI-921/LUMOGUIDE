import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:tencent_cloud_chat_uikit/tencent_cloud_chat_uikit.dart';
import 'package:tencent_cloud_chat_uikit/ui/utils/message.dart';
import 'package:tencent_cloud_chat_uikit/business_logic/separate_models/tui_chat_separate_view_model.dart';
import 'package:tencent_cloud_chat_uikit/business_logic/view_models/tui_chat_global_model.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/custom_message/custom_message_element.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatController());
    return TIMUIKitChat(
      customAppBar: IAppBar(
        title: controller.conversation.showName,
        actions: [
          if (controller.conversation.type == 2)
            IconButton(
              onPressed: () {
                controller.onMore();
              },
              icon: const Icon(Icons.more_horiz),
            ).paddingOnly(right: 10),
        ],
      ),
      conversation: controller.conversation,
      conversationID: controller.conversationID,
      config: const TIMUIKitChatConfig(isShowReadingStatus: false),
      messageItemBuilder: MessageItemBuilder(
        messageRowBuilder:
            (
              message,
              messageWidget,
              onScrollToIndex,
              isNeedShowJumpStatus,
              clearJumpStatus,
              onScrollToIndexBegin,
            ) {
              if (MessageUtils.isGroupCallingMessage(message)) {
                return messageWidget;
              }
              if (MessageUtils.getCustomGroupCreatedOrDismissedString(
                message,
              ).isNotEmpty) {
                return messageWidget;
              }
              return null;
            },
        customMessageItemBuilder: (message, isShowJump, clearJump) {
          return CustomMessageElem(
            message: message,
            isShowJump: isShowJump,
            clearJump: clearJump,
          );
        },
      ),
      onTapAvatar: controller.onTapAvatar,
      morePanelConfig: MorePanelConfig(
        showFilePickAction: false,
        showGalleryPickAction: false,
        showCameraAction: false,
        showWebImagePickAction: false,
        showWebVideoPickAction: false,
        showVoiceCall: false,
        showVideoCall: false,
        extraAction: [
          MorePanelItem(
            id: "custom_photo",
            title: "照片".tr,
            icon: Container(
              height: 64,
              width: 64,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              child: const Icon(
                Icons.photo_library,
                size: 32,
                color: Colors.black54,
              ),
            ),
            onTap: (c) {
              _handleCustomPhotoSelection(c, controller);
            },
          ),
        ],
      ),
    );
  }

  void _handleCustomPhotoSelection(
    BuildContext context,
    ChatController controller,
  ) async {
    final imagePath = await ImagePickerUtil.selectImageFromGallery(
      context,
      canEdit: false,
    );
    if (!context.mounted) return;
    if (imagePath.isEmpty) return;

    final model = Provider.of<TUIChatSeparateViewModel>(context, listen: false);
    final convID = controller.conversationID ?? '';
    if (convID.isEmpty) return;

    final convType = controller.conversation.type == 1
        ? ConvType.c2c
        : ConvType.group;

    MessageUtils.handleMessageError(
      model.sendImageMessage(
        imagePath: imagePath,
        convID: convID,
        convType: convType,
      ),
      context,
    );
  }
}
