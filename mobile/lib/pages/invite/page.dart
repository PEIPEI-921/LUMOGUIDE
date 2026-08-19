import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'widgets/code.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/list.dart';
import 'widgets/tip.dart';
import 'widgets/share_card.dart';
import 'widgets/guide_invite_share_card.dart';
import 'widgets/company_invite_share_card.dart';

class InvitePage extends StatelessWidget {
  const InvitePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InviteController());
    return IScaffold(
      backgroundImage: const AssetImage(Assets.bgInvite),
      backgroundImageFit: BoxFit.cover,
      appBar: IAppBar(
        title: '我的邀請'.tr,
        titleStyle: const TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          systemNavigationBarColor: Colors.white,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
        actions: [
          Icon(
            Icons.share,
            size: 20.w,
            color: Colors.white,
          )
              .padding(all: 12.w)
              .gestures(
                onTap: () => controller.shareInviteCard(),
                behavior: HitTestBehavior.opaque,
              ),
        ],
      ),
      body: Stack(
        children: [
          const Column(
        children: [
          InviteCodeWidget(),
          InviteListWidget(),
          InviteTipWidget(),
        ],
      ).scrollable().safeArea(),
          Positioned(
            left: 0,
            top: 0,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.01,
                child: SizedBox(
                  width: 375.w,
                  child: UserStore.to.profile.isEnterprise
                      ? CompanyInviteShareCardWidget(
                          repaintKey: controller.shareCardKey,
                        )
                      : UserStore.to.profile.isGuide
                      ? GuideInviteShareCardWidget(
                          repaintKey: controller.shareCardKey,
                        )
                      : InviteShareCardWidget(
                          repaintKey: controller.shareCardKey,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
