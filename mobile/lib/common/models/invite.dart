import '../extensions/map.dart';

class Invite {
  String? inviteesNickname;
  String? inviteesAvatar;
  String? createdAt;

  Invite({
    this.inviteesNickname,
    this.inviteesAvatar,
    this.createdAt,
  });

  factory Invite.fromJson(Map<String, dynamic> json) {
    return Invite(
      inviteesNickname: json.safeString('invitees_nickname'),
      inviteesAvatar: json.safeString('invitees_avatar'),
      createdAt: json.safeString('created_at'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invitees_nickname': inviteesNickname,
      'invitees_avatar': inviteesAvatar,
      'created_at': createdAt,
    };
  }
}
