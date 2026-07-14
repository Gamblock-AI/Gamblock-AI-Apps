/// A reflection/journal entry. The backend stores the text AES-256 encrypted
/// (PRD §4); the client only sees/plaintext via the API response.
class ReflectionEntry {
  final String id;
  final String text;
  final String mood;
  final DateTime createdAt;

  const ReflectionEntry({
    required this.id,
    required this.text,
    required this.mood,
    required this.createdAt,
  });

  factory ReflectionEntry.fromJson(Map<String, dynamic> json) {
    return ReflectionEntry(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      mood: json['mood']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
