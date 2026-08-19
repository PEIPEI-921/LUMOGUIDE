/// 應用內二維碼：統一前綴 + 格式類型 + 內容，用於生成與識別。
/// 格式：{prefix}{type}:{payload}，例如 LUMOTRIP:GROUP:groupID
/// 擴展：新增類型時在 [typeXxx]、[AppQRCodeType]、[_typeFromString]、[buildXxx] 中補齊。
class AppQRCode {
  AppQRCode._();

  static const String prefix = 'LUMOTRIP:';

  static const String typeGroup = 'GROUP';
  static const String typeUser = 'USER';

  static String buildGroup(String groupID) =>
      '$prefix$typeGroup:${groupID.trim()}';

  static String buildUser(String userID) =>
      '$prefix$typeUser:${userID.trim()}';

  static AppQRCodePayload? parse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith(prefix)) {
      final after = trimmed.substring(prefix.length);
      final colon = after.indexOf(':');
      final typeStr = colon >= 0 ? after.substring(0, colon) : after;
      final payload =
          colon >= 0 && colon < after.length - 1
              ? after.substring(colon + 1).trim()
              : (colon < 0 ? '' : '');
      final t = _typeFromString(typeStr);
      if (t == AppQRCodeType.unknown) return null;
      return AppQRCodePayload(type: t, payload: payload);
    }
    return AppQRCodePayload(type: AppQRCodeType.group, payload: trimmed);
  }

  static AppQRCodeType _typeFromString(String s) {
    switch (s.toUpperCase()) {
      case typeGroup:
        return AppQRCodeType.group;
      case typeUser:
        return AppQRCodeType.user;
      default:
        return AppQRCodeType.unknown;
    }
  }
}

enum AppQRCodeType {
  group,
  user,
  unknown,
}

class AppQRCodePayload {
  const AppQRCodePayload({
    required this.type,
    required this.payload,
    this.extra,
  });

  final AppQRCodeType type;
  final String payload;
  final Map<String, String>? extra;

  bool get isGroup => type == AppQRCodeType.group;
  bool get isUser => type == AppQRCodeType.user;
}
