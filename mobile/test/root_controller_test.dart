import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:lumotrip/common/stores/user.dart';
import 'package:lumotrip/pages/root/controller.dart';

/// 轻量 fake：继承真实 [UserStore]，跳过真实初始化，暴露可断言的登录态与调用计数。
///
/// 说明：这里不用 mocktail 而用手写 fake，是因为 mocktail mock 一个 `GetxController`
/// 会把 `onStart`/`onDelete` 等生命周期字段一并 mock 成 null，`Get.put` 时
/// `_startController` 访问 `onStart` 直接抛 `Null is not a subtype of
/// InternalFinalCallback`。继承真实类的 fake 保留了 GetX 生命周期契约，是最稳妥的
/// 单例替换方式。
class FakeUserStore extends UserStore {
  FakeUserStore({required this.isLoginValue});

  final bool isLoginValue;
  int showLoginCalls = 0;

  @override
  // 有意跳过真实初始化：真实 onInit 会读 StorageService.to（测试未注册）并触发 getProfile 网络请求。
  // ignore: must_call_super
  void onInit() {}

  @override
  bool get isLogin => isLoginValue;

  @override
  Future<void> showLogin() async {
    showLoginCalls++;
  }
}

/// `RootController.handlePageChanged` 登录门禁分支测试。
///
/// 核心逻辑：tab 3（消息）/ tab 4（我的）需要登录，未登录时拦截并 `showLogin()`、
/// 不切换 tab；其余 tab 无需登录正常切换；同 tab 点击早退。
void main() {
  group('handlePageChanged 登录门禁', () {
    test('未登录点「消息」(3) → 拦截 showLogin，tabIndex 不变', () {
      final userStore = FakeUserStore(isLoginValue: false);
      Get.put<UserStore>(userStore);
      addTearDown(Get.reset);

      final c = RootController();
      c.handlePageChanged(3);

      expect(c.tabIndex.value, 0);
      expect(userStore.showLoginCalls, 1);
    });

    test('未登录点「我的」(4) → 拦截 showLogin，tabIndex 不变', () {
      final userStore = FakeUserStore(isLoginValue: false);
      Get.put<UserStore>(userStore);
      addTearDown(Get.reset);

      final c = RootController();
      c.handlePageChanged(4);

      expect(c.tabIndex.value, 0);
      expect(userStore.showLoginCalls, 1);
    });

    test('未登录点「城市」(1) 无需登录 → 正常切换，不触发 showLogin', () {
      final userStore = FakeUserStore(isLoginValue: false);
      Get.put<UserStore>(userStore);
      addTearDown(Get.reset);

      final c = RootController();
      c.handlePageChanged(1);

      expect(c.tabIndex.value, 1);
      expect(userStore.showLoginCalls, 0);
    });

    test('已登录点「城市」(1) → 正常切换', () {
      final userStore = FakeUserStore(isLoginValue: true);
      Get.put<UserStore>(userStore);
      addTearDown(Get.reset);

      final c = RootController();
      c.handlePageChanged(1);

      expect(c.tabIndex.value, 1);
    });

    test('同 tab 早退：已切到 1 再点 1 → 无变化', () {
      final userStore = FakeUserStore(isLoginValue: true);
      Get.put<UserStore>(userStore);
      addTearDown(Get.reset);

      final c = RootController();
      c.handlePageChanged(1);
      c.handlePageChanged(1);

      expect(c.tabIndex.value, 1);
    });
  });
}
