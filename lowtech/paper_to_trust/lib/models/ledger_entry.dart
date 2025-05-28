class LedgerEntry {
  final String id;
  final String? note;
  final DateTime createdAt;
  final String status;
  final String? ocrText;
  final String? reviewNote;

  LedgerEntry({
    required this.id,
    this.note,
    required this.createdAt,
    required this.status,
    this.ocrText,
    this.reviewNote,
  });

  factory LedgerEntry.fromJson(Map<String, dynamic> json) {
    return LedgerEntry(
      id: json['id'] as String,
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
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'ocrText': ocrText,
      'reviewNote': reviewNote,
    };
  }

  LedgerEntry copyWith({
    String? id,
    String? note,
    DateTime? createdAt,
    String? status,
    String? ocrText,
    String? reviewNote,
  }) {
    return LedgerEntry(
      id: id ?? this.id,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      ocrText: ocrText ?? this.ocrText,
      reviewNote: reviewNote ?? this.reviewNote,
    );
  }
}
