class LedgerEntry {
  final String id;
  final String imageUrl;
  final String? note;
  final DateTime createdAt;
  final String status;
  final String? ocrText;
  final String? reviewNote;

  LedgerEntry({
    required this.id,
    required this.imageUrl,
    this.note,
    required this.createdAt,
    required this.status,
    this.ocrText,
    this.reviewNote,
  });

  factory LedgerEntry.fromJson(Map<String, dynamic> json) {
    return LedgerEntry(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: json['status'] as String,
      ocrText: json['ocrText'] as String?,
      reviewNote: json['reviewNote'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'ocrText': ocrText,
      'reviewNote': reviewNote,
    };
  }

  LedgerEntry copyWith({
    String? id,
    String? imageUrl,
    String? note,
    DateTime? createdAt,
    String? status,
    String? ocrText,
    String? reviewNote,
  }) {
    return LedgerEntry(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      ocrText: ocrText ?? this.ocrText,
      reviewNote: reviewNote ?? this.reviewNote,
    );
  }
}
