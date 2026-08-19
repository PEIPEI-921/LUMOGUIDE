import 'package:easy_refresh/easy_refresh.dart';

class CustomHeader extends CupertinoHeader {
  const CustomHeader()
      : super(
          position: IndicatorPosition.above,
          triggerOffset: 30,
          // backgroundColor: AppColors.backgroundGray,
          // foregroundColor: Colors.white,
        );
}

class CustomFooter extends CupertinoFooter {
  const CustomFooter()
      : super(position: IndicatorPosition.above
            // infiniteOffset: null,
            // backgroundColor: Colors.white,
            // foregroundColor: AppColors.primary,
            );
}
