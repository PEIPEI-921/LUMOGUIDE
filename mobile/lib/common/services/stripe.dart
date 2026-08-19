import 'dart:developer';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

// 支付状态枚举
enum PaymentStatus { success, failed, cancelled, processing, timeout }

// 支付错误类型
enum PaymentErrorType {
  networkError,
  paymentMethodInvalid,
  paymentCancelled,
  paymentTimeout,
  systemError,
  unknown,
}

// 支付结果类
class PaymentResult {
  final PaymentStatus status;
  final String? message;
  final PaymentErrorType? errorType;

  PaymentResult({required this.status, this.message, this.errorType});

  bool get isSuccess => status == PaymentStatus.success;
  bool get isFailed => status == PaymentStatus.failed;
  bool get isCancelled => status == PaymentStatus.cancelled;
}

const String stripePublishableKey = 'pk_live_51RkgWL058lDhaDhlmzyCTYR6DGnbTDCQhyAU5OKqDZtvwuFmq7MizQ0xUR1f4jo6ssfSWrx3ngPV2VDOwf4E28KS00GTJNHInk';

class StripeService extends GetxService with ApiMixin {
  static StripeService get to => Get.find();

  Future<StripeService> init() async {

    return this;
  }

  Future<PaymentResult> createPaymentSheet(
    String clientSecret, {
    required String orderSn,
  }) async {
    try {
      final stripeKey = ConfigService.to.systemConfig.stripeKey;
      if (stripeKey != null) {
        Stripe.publishableKey = stripeKey;
      }  else {
        Stripe.publishableKey = stripePublishableKey;
      }
      await Stripe.instance.presentPaymentSheet();

      final result = await _verifyPaymentResult(clientSecret);
      if (!result.isSuccess) {
        return result;
      }
      final orderResult = await _verifyOrderSn(orderSn);
      return orderResult;
    } catch (e) {
      log(e.toString());
      final errorResult = PaymentResult(
        status: PaymentStatus.failed,
        message: _getErrorMessage(e),
        errorType: _getErrorType(e),
      );
      return errorResult;
    }
  }

  Future<PaymentResult> _verifyPaymentResult(String clientSecret) async {
    try {
      final paymentIntent = await Stripe.instance.retrievePaymentIntent(
        clientSecret,
      );

      switch (paymentIntent.status) {
        case PaymentIntentsStatus.Succeeded:
          return PaymentResult(
            status: PaymentStatus.success,
            message: '支付成功'.tr,
          );
        case PaymentIntentsStatus.RequiresPaymentMethod:
          return PaymentResult(
            status: PaymentStatus.failed,
            message: '支付方式無效'.tr,
            errorType: PaymentErrorType.paymentMethodInvalid,
          );
        case PaymentIntentsStatus.Processing:
          return await _handleProcessingPayment(clientSecret);
        default:
          return PaymentResult(
            status: PaymentStatus.failed,
            message: '支付失敗'.tr,
            errorType: PaymentErrorType.unknown,
          );
      }
    } catch (e) {
      log(e.toString());
      return PaymentResult(
        status: PaymentStatus.failed,
        message: _getErrorMessage(e),
        errorType: _getErrorType(e),
      );
    }
  }

  Future<PaymentResult> _verifyOrderSn(String orderSn) async {
    Loading.show();
    final res = await get(
      ApiUrl.vipPayStatus,
      parameters: {'order_sn': orderSn},
    );
    Loading.dismiss();
    if (!res.isSuccess) {
      return PaymentResult(status: PaymentStatus.failed, message: res.message);
    }
    final status = res.dataJson['pay_status'] as int? ?? 0;
    if (status == 1) {
      return PaymentResult(status: PaymentStatus.success, message: '訂閱成功'.tr);
    } else {
      return PaymentResult(status: PaymentStatus.failed, message: '訂閱失敗'.tr);
    }
  }

  Future<PaymentResult> _handleProcessingPayment(String clientSecret) async {
    await Future.delayed(const Duration(seconds: 2));
    try {
      final updatedIntent = await Stripe.instance.retrievePaymentIntent(
        clientSecret,
      );

      if (updatedIntent.status == PaymentIntentsStatus.Succeeded) {
        return PaymentResult(status: PaymentStatus.success, message: '支付成功'.tr);
      } else {
        return PaymentResult(
          status: PaymentStatus.failed,
          message: '支付超時'.tr,
          errorType: PaymentErrorType.paymentTimeout,
        );
      }
    } catch (e) {
      log(e.toString());
      return PaymentResult(
        status: PaymentStatus.failed,
        message: _getErrorMessage(e),
        errorType: _getErrorType(e),
      );
    }
  }

  // 获取错误信息
  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('network') ||
        error.toString().contains('Network')) {
      return '網絡錯誤，請檢查網絡連接'.tr;
    } else if (error.toString().contains('cancelled') ||
        error.toString().contains('canceled')) {
      return '支付被取消'.tr;
    } else if (error.toString().contains('timeout')) {
      return '支付超時'.tr;
    } else {
      return error.toString().isNotEmpty ? error.toString() : '支付系統錯誤'.tr;
    }
  }

  // 获取错误类型
  PaymentErrorType _getErrorType(dynamic error) {
    if (error.toString().contains('network') ||
        error.toString().contains('Network')) {
      return PaymentErrorType.networkError;
    } else if (error.toString().contains('cancelled') ||
        error.toString().contains('canceled')) {
      return PaymentErrorType.paymentCancelled;
    } else if (error.toString().contains('timeout')) {
      return PaymentErrorType.paymentTimeout;
    } else {
      return PaymentErrorType.systemError;
    }
  }
}
