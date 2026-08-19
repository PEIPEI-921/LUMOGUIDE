import 'package:flutter/material.dart';
import 'package:lumotrip/common/index.dart';
import 'index.dart';

extension CityDetailTabExtension on CityDetailTab {
  Widget get page {
    switch (this) {
      case CityDetailTab.overview:
        return const CityDetailOverviewWidget();
      case CityDetailTab.guide:
        return const CityDetailGuideWidget();
      case CityDetailTab.scenic:
        return const CityDetailScenicWidget();
      case CityDetailTab.restaurant:
        return const RestaurantTabPage();
      case CityDetailTab.mall:
        return const CityDetailShoppingWidget();
      case CityDetailTab.hotel:
        return const CityDetailHotelWidget();
      case CityDetailTab.traffic:
        return const CityDetailTrafficWidget();
      case CityDetailTab.facility:
        return const CityDetailFacilityWidget();
      case CityDetailTab.activity:
        return const CityDetailActivityWidget();
      case CityDetailTab.ticket:
        return const CityDetailTicketWidget();
      case CityDetailTab.all:
        return const SizedBox.shrink();
    }
  }
}
