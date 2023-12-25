class Message {
  late final String msg;
  late final String toId;
  late final String read;
  late final String fromId;
  late final String send;
  late final Type type;

  Message(
      {required this.msg,
      required this.toId,
      required this.read,
      required this.type,
      required this.fromId,
      required this.send});

  Message.fromJson(Map<String, dynamic> json) {
    msg = json['msg'].toString();
    toId = json['toId'].toString();
    read = json['read'].toString();
    type = json['type'] == Type.image.name ? Type.image : Type.text;
    fromId = json['fromId'].toString();
    send = json['send'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['msg'] = msg;
    data['toId'] = toId;
    data['read'] = read;
    data['type'] = type.name;
    data['fromId'] = fromId;
    data['send'] = send;
    return data;
  }
}

enum Type { text, image }
