import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:lumotrip/common/index.dart';

class UserAvatarController extends GetxController
    with ApiMixin, UserStoreMixin {
  final _avatarUrl = Rx<String>('');

  @override
  void onInit() {
    super.onInit();
    _avatarUrl.value =
        (Get.arguments as Map<String, dynamic>?)?['avatarUrl'] as String? ?? '';
  }

  String get avatarUrl => _avatarUrl.value;

  /// 保存图片到相册（优先用缓存，无缓存时由 cache 内部下载后读取再保存）
  Future<void> saveImage() async {
    if (avatarUrl.isEmpty) {
      Loading.error('保存失败'.tr);
      return;
    }
    Loading.show();
    try {
      final file = await DefaultCacheManager().getSingleFile(avatarUrl);
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        Loading.dismiss();
        Loading.error('保存失败'.tr);
        return;
      }
      final result = await ImageGallerySaverPlus.saveImage(bytes);
      Loading.dismiss();
      if (result['isSuccess'] == true) {
        Loading.success('已保存到相册'.tr);
      } else {
        Loading.error('保存失败'.tr);
      }
    } catch (e) {
      Loading.dismiss();
      Loading.error('保存失败'.tr);
    }
  }

  /// 从相簿选择并更换头像（直接打开相簿，不弹 sheet）
  Future<void> selectFromGallery() async {
    final path = await ImagePickerUtil.selectImageFromGallery(Get.context!);
    if (path.isEmpty) return;
    _uploadAndUpdateAvatar(path);
  }

  /// 从相机拍照并更换头像（直接打开相机，不弹 sheet）
  Future<void> selectFromCamera() async {
    final path = await ImagePickerUtil.selectImageFromCamera(Get.context!);
    if (path.isEmpty) return;
    _uploadAndUpdateAvatar(path);
  }

  Future<void> _uploadAndUpdateAvatar(String path) async {
    Loading.show();
    final url = await ConfigService.to.uploadFile(path);
    if (url.isEmpty) {
      Loading.dismiss();
      AlertUtils.error('圖片上傳失敗'.tr);
      return;
    }
    final res = await UserStore.to.modifyProfile({'avatar': url});
    Loading.dismiss();
    if (!res) {
      AlertUtils.error('修改失敗'.tr);
    } else {
      _avatarUrl.value = url;
    }
  }
}
