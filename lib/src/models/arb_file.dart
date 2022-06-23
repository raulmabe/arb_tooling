import 'dart:convert';

typedef JSON = Map<String, dynamic>;

class ARBFile {
  const ARBFile({
    required this.locale,
    required this.messages,
  });

  factory ARBFile.fromJson(String source) =>
      ARBFile.fromMap(json.decode(source) as JSON);

  factory ARBFile.fromMap(Map<String, dynamic> map) {
    return ARBFile(
      locale: map['@@locale'] as String,
      messages: List<Message>.from([
        for (int i = 1; i < map.entries.length; i += 2)
          Message.fromMap(
            Map.fromEntries([
              map.entries.toList()[i],
              map.entries.toList()[i + 1],
            ]),
          ),
      ]),
    );
  }
  final String locale;
  final List<Message> messages;

  Map<String, dynamic> toMap() {
    return {
      '@@locale': locale,
      for (final msg in messages) ...msg.toMap(),
    };
  }

  String toJson() => json.encode(toMap());
}

class Message {
  const Message({
    required this.key,
    required this.value,
    this.description,
  });
  factory Message.fromJson(String source) =>
      Message.fromMap(json.decode(source) as JSON);

  factory Message.fromMap(Map<String, dynamic> map) {
    final key = map.keys.first;

    return Message(
      key: key,
      value: map[key] as String,
      description: (map['@$key'] as JSON)['description'] as String? ?? '',
    );
  }
  final String key;
  final String value;
  final String? description;

  Map<String, dynamic> toMap() {
    return {
      key: value,
      '@$key': {
        if (description != null) 'description': description,
      },
    };
  }

  String toJson() => json.encode(toMap());
}
