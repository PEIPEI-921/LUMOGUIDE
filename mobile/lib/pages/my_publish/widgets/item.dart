// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:lumotrip/common/index.dart';

// class PublishItem extends StatelessWidget {
//   const PublishItem({super.key, required this.item});
//   final Map<String, dynamic> item;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(12.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8.w),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(6.w),
//                 child: Image.network(
//                   item['image'],
//                   width: 80.w,
//                   height: 80.w,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) {
//                     return Container(
//                       width: 80.w,
//                       height: 80.w,
//                       color: AppColors.backgroundBlue,
//                       child: Icon(
//                         Icons.image,
//                         color: AppColors.assistantText,
//                         size: 24.w,
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               12.w.horizontalSpace,
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       '發佈時間: ${item['publishTime']}',
//                       style: TextStyle(
//                         color: AppColors.assistantText,
//                         fontSize: 12.sp,
//                       ),
//                     ),
//                     8.w.verticalSpace,
//                     Text(
//                       item['title'],
//                       style: TextStyle(
//                         color: AppColors.primaryText,
//                         fontSize: 16.sp,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     8.w.verticalSpace,
//                     Text(
//                       '開放時間: ${item['openingHours']}',
//                       style: TextStyle(
//                         color: AppColors.secondaryText,
//                         fontSize: 12.sp,
//                       ),
//                     ),
//                     4.w.verticalSpace,
//                     Text(
//                       '地址: ${item['address']}',
//                       style: TextStyle(
//                         color: AppColors.secondaryText,
//                         fontSize: 12.sp,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     if (item['rejectionReason'] != null) ...[
//                       4.w.verticalSpace,
//                       Text(
//                         '駁回原因: ${item['rejectionReason']}',
//                         style: TextStyle(
//                           color: AppColors.red,
//                           fontSize: 12.sp,
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//               _StatusTag(status: item['status']),
//             ],
//           ),
//           12.w.verticalSpace,
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               Expanded(
//                 child: OutlinedButton.icon(
//                   onPressed: () {
//                     // 编辑功能
//                   },
//                   icon: Icon(
//                     Icons.edit,
//                     size: 16.w,
//                     color: AppColors.primary,
//                   ),
//                   label: Text(
//                     '編輯'.tr,
//                     style: TextStyle(
//                       color: AppColors.primary,
//                       fontSize: 12.sp,
//                     ),
//                   ),
//                   style: OutlinedButton.styleFrom(
//                     padding: EdgeInsets.symmetric(vertical: 8.w),
//                     side: const BorderSide(color: AppColors.primary),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(4.w),
//                     ),
//                   ),
//                 ),
//               ),
//               8.w.horizontalSpace,
//               Expanded(
//                 child: OutlinedButton.icon(
//                   onPressed: () {
//                     // 删除功能
//                   },
//                   icon: Icon(
//                     Icons.delete,
//                     size: 16.w,
//                     color: AppColors.red,
//                   ),
//                   label: Text(
//                     '刪除'.tr,
//                     style: TextStyle(
//                       color: AppColors.red,
//                       fontSize: 12.sp,
//                     ),
//                   ),
//                   style: OutlinedButton.styleFrom(
//                     padding: EdgeInsets.symmetric(vertical: 8.w),
//                     side: const BorderSide(color: AppColors.red),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(4.w),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _StatusTag extends StatelessWidget {
//   const _StatusTag({required this.status});
//   final String status;

//   @override
//   Widget build(BuildContext context) {
//     Color backgroundColor;
//     Color textColor;
//     String text;

//     switch (status) {
//       case 'reviewing':
//         backgroundColor = const Color(0xFFE6E6FA);
//         textColor = const Color(0xFF9370DB);
//         text = '審核中';
//         break;
//       case 'approved':
//         backgroundColor = const Color(0xFFE8F5E8);
//         textColor = const Color(0xFF4CAF50);
//         text = '審核通過';
//         break;
//       case 'rejected':
//         backgroundColor = const Color(0xFFFFEBEE);
//         textColor = const Color(0xFFF44336);
//         text = '審核駁回';
//         break;
//       default:
//         backgroundColor = AppColors.assistantText.withOpacity(0.1);
//         textColor = AppColors.assistantText;
//         text = '未知';
//     }

//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(12.w),
//       ),
//       child: Text(
//         text.tr,
//         style: TextStyle(
//           color: textColor,
//           fontSize: 10.sp,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//     );
//   }
// }
