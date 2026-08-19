import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../values/assets.dart';

/// 分享卡片共用浮水印組件
///
/// 以網格排列品牌圖標，均勻覆蓋卡片，
/// 透明度極低，不影響內容瀏覽，視覺清晰美觀。
class ShareWatermark extends StatelessWidget {
  const ShareWatermark({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(4, (row) {
            return Padding(
              padding: EdgeInsets.only(bottom: row < 3 ? 70.w : 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (col) {
                  final index = row * 3 + col;
                  final rotate = (index % 3 == 0)
                      ? -0.12
                      : (index % 3 == 1) ? 0.0 : 0.12;
                  return Padding(
                    padding: EdgeInsets.only(right: col < 2 ? 70.w : 0),
                    child: Transform.rotate(
                      angle: rotate,
                      child: Opacity(
                        opacity: 0.07,
                        child: Image.asset(
                          Assets.iconWatermark,
                          width: 36.w,
                          height: 36.w,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }
}
