import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../common/index.dart';
import 'controller.dart';

class PhotoViewPage extends StatelessWidget {
  const PhotoViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PhotoViewPageController());
    return IScaffold(
      backgroundColor: Colors.black,
      backgroundImage: null,
      appBar: IAppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Obx(
        () => Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: _buildItem,
              itemCount: controller.pictures.length,
              loadingBuilder: (context, error) =>
                  const Center(child: CircularProgressIndicator()),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              pageController: PageController(initialPage: controller.index),
              onPageChanged: controller.onPageChanged,
              scrollDirection: Axis.horizontal,
            ),
            Container(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "${controller.index + 1}/${controller.pictures.length}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17.0,
                  decoration: null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    final controller = Get.find<PhotoViewPageController>();
    final String picture = controller.pictures[index];
    return PhotoViewGalleryPageOptions(
      imageProvider: NetworkImage(picture),
      initialScale: PhotoViewComputedScale.contained,
      minScale: PhotoViewComputedScale.contained * (0.5 + index / 10),
      maxScale: PhotoViewComputedScale.covered * 4.1,
      heroAttributes: PhotoViewHeroAttributes(tag: picture),
    );
  }
}
