import 'package:flutter/material.dart';
import '../models/ledger_entry.dart';

class EntryDetailsScreen extends StatelessWidget {
  final LedgerEntry entry;

  const EntryDetailsScreen({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('記録の詳細'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                entry.imageUrl,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 300,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.error,
                      size: 48,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoSection('メモ', entry.note ?? 'メモなし'),
            const SizedBox(height: 16),
            _buildInfoSection('ステータス', entry.status),
            if (entry.ocrText != null) ...[
              const SizedBox(height: 16),
              _buildInfoSection('OCRテキスト', entry.ocrText!),
            ],
            if (entry.reviewNote != null) ...[
              const SizedBox(height: 16),
              _buildInfoSection('確認メモ', entry.reviewNote!),
            ],
            const SizedBox(height: 16),
            _buildInfoSection(
              '作成日時',
              '${entry.createdAt.year}/${entry.createdAt.month}/${entry.createdAt.day} ${entry.createdAt.hour}:${entry.createdAt.minute}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
