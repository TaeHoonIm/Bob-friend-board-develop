String formatTimestamp(DateTime timestamp){
  DateTime now = DateTime.now();
  Duration diff = now.difference(timestamp);
  String stdDate = "";
  if (diff.inSeconds < 60) {
    stdDate = "${diff.inSeconds}초 전";
  } else if (diff.inSeconds > 60 && diff.inHours < 1) {
    stdDate = "${(diff.inSeconds / 60).floor()}분 전";
  } else if (diff.inHours < 24) {
    stdDate = "${diff.inHours}시간 전";
  } else if (diff.inDays < 30) {
    stdDate = "${diff.inDays}일 전";
  } else if (diff.inDays < 365) {
    stdDate = "${(diff.inDays / 30).floor()}달 전";
  } else {
    stdDate = "${(diff.inDays / 365).floor()}년 전";
  }
  return stdDate;
}