/// 选择成员页用途：建群选人 / 群内添加成员
enum SelectMembersPurpose {
  /// 创建群聊时选择成员
  createGroup,

  /// 群详情内添加成员（需传入 groupID，且排除已在群内的用户）
  addToGroup,
}
