import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'index.dart';
import '../../pages/index.dart';

class AppPages {
  static const INITIAL = AppRoutes.WELCOME;
  static final RouteObserver<Route> observer = RouteObservers();
  static List<String> history = [];

  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.CHAT,
      page: () => const ChatPage(),
    ),
    GetPage(
      name: AppRoutes.SELECT_MEMBERS,
      page: () => const SelectMembersPage(),
    ),
    GetPage(
      name: AppRoutes.MY_GROUPS,
      page: () => const MyGroupsPage(),
    ),
    GetPage(
      name: AppRoutes.GROUP_PROFILE,
      page: () => const GroupProfilePage(),
    ),
    GetPage(
      name: AppRoutes.GROUP_QR,
      page: () => const GroupQRPage(),
    ),
    GetPage(
      name: AppRoutes.SCAN,
      page: () => const ScanPage(),
    ),
    GetPage(
      name: AppRoutes.PHOTO_VIEW,
      page: () => const PhotoViewPage(),
    ),
    GetPage(
      name: AppRoutes.USER_AVATAR,
      page: () => const UserAvatarPage(),
    ),
    GetPage(
      name: AppRoutes.REJECT_RESERVATION,
      page: () => const RejectReservationPage(),
    ),
    GetPage(
      name: AppRoutes.SEARCH,
      page: () => const SearchPage(),
    ),
    GetPage(
      name: AppRoutes.COMPANY_INFO,
      page: () => const CompanyInfoPage(),
    ),
    GetPage(
      name: AppRoutes.CITY_STRATEGY,
      page: () => const CityStrategyPage(),
    ),
    GetPage(
      name: AppRoutes.MEMBER_CENTER,
      page: () => const MemberCenterPage(),
    ),
    GetPage(
      name: AppRoutes.MY_PUBLISH_CITY,
      page: () => const MyPublishCityPage(),
    ),
    GetPage(
      name: AppRoutes.GUIDE_CHANGE_CITY,
      page: () => const GuideChangeCityPage(),
    ),
    GetPage(
      name: AppRoutes.PUBLISH_CITY,
      page: () => const PublishCityPage(),
    ),
    GetPage(
      name: AppRoutes.MERCHANT_BOOKING_DETAIL,
      page: () => const MerchantBookingDetailPage(),
    ),
    GetPage(
      name: AppRoutes.GUIDE_BOOKING_DETAIL,
      page: () => const GuideBookingDetailPage(),
    ),
    GetPage(
      name: AppRoutes.USER_BOOKING_MERCHANT_INFO,
      page: () => const UserBookingMerchantInfoPage(),
    ),
    GetPage(
      name: AppRoutes.USER_BOOKING_GUIDE_INFO,
      page: () => const UserBookingGuideInfoPage(),
    ),
    GetPage(
      name: AppRoutes.MERCHANT_BOOKING_MANAGER,
      page: () => const MerchantBookingManagerPage(),
    ),
    GetPage(
      name: AppRoutes.GUIDE_BOOKING_MANAGER,
      page: () => const GuideBookingManagerPage(),
    ),
    GetPage(
      name: AppRoutes.USER_BOOKING_MANAGER,
      page: () => const UserBookingManagerPage(),
    ),
    GetPage(
      name: AppRoutes.BOOKING_MERCHANT,
      page: () => const BookingMerchantPage(),
    ),
    GetPage(
      name: AppRoutes.BOOKING_GUIDE,
      page: () => const BookingGuidePage(),
    ),
    GetPage(
      name: AppRoutes.MERCHANT_MANAGEMENT,
      page: () => const MerchantManagementPage(),
    ),
    GetPage(
      name: AppRoutes.MERCHANT_EDITOR,
      page: () => const MerchantEditorPage(),
    ),
    GetPage(
      name: AppRoutes.PUBLISH_ACTIVITY,
      page: () => const PublishActivityPage(),
    ),
    GetPage(
      name: AppRoutes.PUBLISH_FACILITY,
      page: () => const PublishFacilityPage(),
    ),
    GetPage(
      name: AppRoutes.PUBLISH_TRANSPORTATION,
      page: () => const PublishTransportationPage(),
    ),
    GetPage(
      name: AppRoutes.PUBLISH_INFORMATION,
      page: () => const PublishInformationPage(),
    ),
    GetPage(
      name: AppRoutes.PUBLISH_ATTRACTION,
      page: () => const PublishAttractionPage(),
    ),
    GetPage(
      name: AppRoutes.MY_PUBLISH,
      page: () => const MyPublishPage(),
    ),
    GetPage(
      name: AppRoutes.SHIPPING_ADDRESS_EDITOR,
      page: () => const ShippingAddressEditorPage(),
    ),
    GetPage(
      name: AppRoutes.SHIPPING_ADDRESS,
      page: () => const ShippingAddressPage(),
    ),
    GetPage(
      name: AppRoutes.INTEGRAL_EXCHANGE_ORDER,
      page: () => const IntegralExchangeOrderPage(),
    ),
    GetPage(
      name: AppRoutes.INTEGRAL_EXCHANGE_RECORD,
      page: () => const IntegralExchangeRecordPage(),
    ),
    GetPage(
      name: AppRoutes.INTEGRAL_EXCHANGE_RESULT,
      page: () => const IntegralExchangeResultPage(),
    ),
    GetPage(
      name: AppRoutes.INTEGRAL_GOODS_EXCHANGE,
      page: () => const IntegralGoodsExchangePage(),
    ),
    GetPage(
      name: AppRoutes.INTEGRAL_GOODS_DETAIL,
      page: () => const IntegralGoodsDetailPage(),
    ),
    GetPage(
      name: AppRoutes.WEB,
      page: () => const WebPage(),
    ),
    GetPage(
      name: AppRoutes.EVALUATE_LIST,
      page: () => const EvaluateListPage(),
    ),
    GetPage(
      name: AppRoutes.INVITE,
      page: () => const InvitePage(),
    ),
    GetPage(
      name: AppRoutes.MERCHANT_ENTRY,
      page: () => const MerchantEntryPage(),
    ),
    GetPage(
      name: AppRoutes.GUIDE_CERTIFICATION,
      page: () => const GuideCertificationPage(),
    ),
    GetPage(
      name: AppRoutes.WELCOME,
      page: () => const WelcomePage(),
    ),
    GetPage(
      name: AppRoutes.INTEGRAL_MALL,
      page: () => const IntegralMallPage(),
    ),
    GetPage(
      name: AppRoutes.MY_INTEGRAL,
      page: () => const MyIntegralPage(),
    ),
    GetPage(
      name: AppRoutes.MODIFY_PASSWORD,
      page: () => const ModifyPasswordPage(),
    ),
    GetPage(
      name: AppRoutes.CONTACT_US,
      page: () => const ContactUsPage(),
    ),
    GetPage(
      name: AppRoutes.FEEDBACK,
      page: () => const FeedbackPage(),
    ),
    GetPage(
      name: AppRoutes.NICKNAME,
      page: () => const NicknamePage(),
    ),
    GetPage(
      name: AppRoutes.JOURNEY,
      page: () => const JourneyPage(),
    ),
    GetPage(
      name: AppRoutes.JOURNEY_DETAIL,
      page: () => const JourneyDetailPage(),
    ),
    GetPage(
      name: AppRoutes.JOURNEY_EDITOR,
      page: () => const JourneyEditorPage(),
    ),
    GetPage(
      name: AppRoutes.RESERVATION,
      page: () => const ReservationPage(),
    ),
    GetPage(
      name: AppRoutes.EVALUATION,
      page: () => const EvaluationPage(),
    ),
    GetPage(
      name: AppRoutes.COMMON_DETAIL,
      page: () => const CommonDetailPage(),
    ),
    GetPage(
      name: AppRoutes.GUIDE_DETAIL,
      page: () => const GuideDetailPage(),
    ),
    GetPage(
      name: AppRoutes.CITY_DETAIL,
      page: () => const CityDetailPage(),
    ),
    GetPage(
      name: AppRoutes.COMMENT,
      page: () => const CommentPage(),
    ),
    GetPage(
      name: AppRoutes.FOLLOW,
      page: () => const FollowPage(),
    ),
    GetPage(
      name: AppRoutes.MESSAGE_SYSTEM,
      page: () => const MessageSystemPage(),
    ),
    GetPage(
      name: AppRoutes.MODIFY_PHONE,
      page: () => const ModifyPhonePage(),
    ),
    GetPage(
      name: AppRoutes.SETTING,
      page: () => const SettingPage(),
    ),
    GetPage(
      name: AppRoutes.PROFILE,
      page: () => const ProfilePage(),
    ),
    GetPage(
      name: AppRoutes.NEWS_DETAIL,
      page: () => const NewsDetailPage(),
    ),
    GetPage(
      name: AppRoutes.PASSWORD_INPUT,
      page: () => const PasswordInputPage(),
    ),
    GetPage(
      name: AppRoutes.VERIFY_CODE,
      page: () => const VerifyCodePage(),
    ),
    GetPage(
      name: AppRoutes.FORGET_PASSWORD,
      page: () => const ForgetPasswordPage(),
    ),
    GetPage(
      name: AppRoutes.REGISTER,
      page: () => const RegisterPage(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginPage(),
    ),
    GetPage(
      name: AppRoutes.MINE,
      page: () => const MinePage(),
    ),
    GetPage(
      name: AppRoutes.MESSAGE,
      page: () => const MessagePage(),
    ),
    GetPage(
      name: AppRoutes.NEWS,
      page: () => const NewsPage(),
    ),
    GetPage(
      name: AppRoutes.CITY,
      page: () => const CityPage(),
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => const HomePage(),
    ),
    GetPage(
      name: AppRoutes.ROOT,
      page: () => const RootPage(),
    ),
  ];
}
