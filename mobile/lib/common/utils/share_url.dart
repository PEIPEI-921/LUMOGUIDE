import '../stores/user.dart';

/// 構建內容分享的 QR 碼 URL
///
/// 格式: https://lumoguide.com/share?c={inviteCode}&t={type}&i={id}
///
/// 使用 https:// 而非自定義 scheme，因為手機相機/掃碼器只識別 http/https 鏈接。
///
/// 掃描後的行為依賴於平台配置：
/// - iOS (Universal Links): 已安裝 App → 直接打開 App；未安裝 → Safari 打開 share.html
/// - Android (App Links): 已安裝 App → 直接打開 App；未安裝 → 瀏覽器打開 share.html
/// - 服務端 share.html 負責：檢測 OS + 中國 IP，分流 App Store / Google Play / APK 下載
String buildContentShareUrl(String type, int id) {
  final code = UserStore.to.profile.inviterCode ?? '';
  return 'https://lumoguide.com/share?c=$code&t=$type&i=$id';
}
