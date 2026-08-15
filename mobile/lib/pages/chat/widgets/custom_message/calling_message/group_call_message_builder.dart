import 'package:flutter/cupertino.dart';
import 'package:tencent_cloud_chat_uikit/ui/widgets/link_preview/common/utils.dart';

import 'calling_message_data_provider.dart';

class GroupCallMessageItem extends StatefulWidget {
  final CallingMessageDataProvider callingMessageDataProvider;

  const GroupCallMessageItem({
    super.key,
    required this.callingMessageDataProvider,
  });

  @override
  State<StatefulWidget> createState() => _GroupCallMessageItemState();
}

class _GroupCallMessageItemState extends State<GroupCallMessageItem> {

  @override
  void initState() {
    super.initState();
  }
  
  Widget wrapMessageTips(Widget child) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 10), child: child);
  }

  @override
  Widget build(BuildContext context) {
    return !widget.callingMessageDataProvider.excludeFromHistory ? wrapMessageTips(Text(
      widget.callingMessageDataProvider.content,
      style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: LinkUtils.hexToColor("888888")),
      textAlign: TextAlign.center,
      softWrap: true,
    )) : const SizedBox();
  }
}