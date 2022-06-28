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
    this.placeholders,
  });
  factory Message.fromJson(String source) =>
      Message.fromMap(json.decode(source) as JSON);

  factory Message.fromMap(Map<String, dynamic> map) {
    final key = map.keys.first;
    final child = map['@$key'] as JSON?;
    if (child == null) {
      throw ArgumentError('@$key not found');
    }
    final value = map[key] as String;

    final regex = RegExp(r'\{[a-zA-Z]+(\}|\,)');

    final placeholders = regex.allMatches(value);

    if (placeholders.length > 1 && value.contains('plural')) {
      placeholders.toList().removeRange(1, placeholders.length);
    }
    final hasPlaceholders = placeholders.isNotEmpty;

    return Message(
      key: key,
      value: value,
      description: child['description'] as String?,
      placeholders: hasPlaceholders
          ? {
              for (final placeholder in placeholders) '$placeholder': JSON,
            }
          : null,
    );
  }
  final String key;
  final String value;
  final String? description;
  final JSON? placeholders;

  Map<String, dynamic> toMap() {
    return {
      key: value,
      '@$key': {
        if (description != null) 'description': description,
        if (placeholders != null) 'placeholders': placeholders,
      },
    };
  }

  String toJson() => json.encode(toMap());
}
