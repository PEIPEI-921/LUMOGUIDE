import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../apis/provider.dart';
import '../apis/urls.dart';
import '../values/colors.dart';
import '../values/font.dart';

class ShareQrcodeDialog extends StatefulWidget {
  final String type;
  final int id;

  const ShareQrcodeDialog({super.key, required this.type, required this.id});

  @override
  State<ShareQrcodeDialog> createState() => _ShareQrcodeDialogState();
}

class _ShareQrcodeDialogState extends State<ShareQrcodeDialog> {
  List<int>? _qrcodeBytes;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadQrcode();
  }

  Future<void> _loadQrcode() async {
    try {
      final response = await ApiProvider().getBytes(
        ApiUrl.shareQrcode,
        parameters: {'type': widget.type, 'id': widget.id},
      );
      if (response != null && response.statusCode == 200) {
        setState(() {
          _qrcodeBytes = response.data as List<int>?;
          _loading = false;
        });
      } else {
        setState(() {
          _error = '加載失敗';
          _loading = false;
        });
      }
    } catch (_) {
      setState(() {
        _error = '加載失敗';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.w)),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '分享',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            SizedBox(height: 16.w),
            if (_loading)
              SizedBox(
                width: 200.w,
                height: 200.w,
                child: const Center(child: CircularProgressIndicator()),
              )
            else if (_qrcodeBytes != null)
              Image.memory(
                _qrcodeBytes as Uint8List,
                width: 200.w,
                height: 200.w,
                fit: BoxFit.contain,
              )
            else
              Text(
                _error ?? '加載失敗',
                style: TextStyle(color: AppColors.assistantText, fontSize: 14.sp),
              ),
            SizedBox(height: 12.w),
            Text(
              '掃碼查看內容',
              style: TextStyle(
                color: AppColors.assistantText,
                fontSize: AppFontSize.xs,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
