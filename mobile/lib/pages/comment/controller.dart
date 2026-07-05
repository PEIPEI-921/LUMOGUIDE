import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class CommentController extends GetxController with RefreshableMixin, ApiMixin {
  var isMyComment = false;
  String get title => isMyComment ? '我的評論'.tr : '評論我的'.tr;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      isMyComment = Get.arguments['isMyComment'] ?? false;
    }
    initRefresh();
    fetchData();
    Loading.show();
  }

  @override
  Future<void> fetchData() async {
    isMyComment ? await _fetchMyComment() : await _fetchCommentMe();
    Loading.dismiss();
  }

  onTapMyComment(Comment item) {
    if (item.contentType == 1) {
      /// 店铺
      Get.toNamed(
        AppRoutes.COMMON_DETAIL,
        arguments: {
          'id': item.contentId,
          'city_id': item.contentInfo?.cityId,
          'type_id': item.contentInfo?.typeId,
        },
      );
    } else if (item.contentType == 2) {
      /// 资讯
      Get.toNamed(AppRoutes.NEWS_DETAIL, arguments: {'id': item.contentId});
    }
  }

  onTapCommentMe(Comment item) {
    if (item.contentType == 1) {
      /// 店铺
      Get.toNamed(
        AppRoutes.COMMON_DETAIL,
        arguments: {
          'id': item.contentId,
          'city_id': item.contentInfo?.cityId,
          'type_id': item.contentInfo?.typeId,
        },
      );
    } else if (item.contentType == 2) {
      /// 资讯
      Get.toNamed(AppRoutes.NEWS_DETAIL, arguments: {'id': item.contentId});
    }
  }
}

extension on CommentController {
  _fetchMyComment() async {
    final res = await get(
      ApiUrl.messageMyEvaluate,
      parameters: {'page': page, 'limit': limit},
    );
    if (!res.isSuccess) {
      endLoad([]);
      return;
    }
    final data = res.dataJson['list'] as List<dynamic>;
    final list = data.map((e) => Comment.fromJson(e)).toList();
    endLoad(list);
  }

  _fetchCommentMe() async {
    final res = await get(
      ApiUrl.messageEvaluateMe,
      parameters: {'page': page, 'limit': limit},
    );
    if (!res.isSuccess) {
      endLoad([]);
      return;
    }
    final data = res.dataJson['list'] as List<dynamic>;
    final list = data.map((e) => Comment.fromJson(e)).toList();
    endLoad(list);
  }
}
