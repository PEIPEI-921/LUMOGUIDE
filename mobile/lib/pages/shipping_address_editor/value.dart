import 'package:get/get.dart';

enum AddressEditorType {
  add,
  edit,
}

extension AddressEditorTypeExtension on AddressEditorType {
  String get title {
    switch (this) {
      case AddressEditorType.add:
        return '新增地址'.tr;
      case AddressEditorType.edit:
        return '編輯地址'.tr;
    }
  }
}
