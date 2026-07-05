import 'package:get/get.dart';
import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String formatTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return '剛剛'.tr;
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分鐘前'.tr;
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小時前'.tr;
    } else if (difference.inDays < 2) {
      return '昨天'.tr;
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前'.tr;
    } else if (difference.inDays < 14) {
      return '上週'.tr;
    } else if (difference.inDays < 30) {
      final weeksAgo = (difference.inDays / 7).floor();
      return '$weeksAgo週前'.tr;
    } else if (difference.inDays < 60) {
      return '上個月'.tr;
    } else if (difference.inDays < 365) {
      if (now.year == year) {
        return DateFormat.MMMd().format(this);
      } else {
        return DateFormat.yMMMd().format(this);
      }
    } else {
      return DateFormat.yMMMd().format(this);
    }
  }

  String hmsFormat() {
    return DateFormat('HH:mm:ss').format(this);
  }
}
