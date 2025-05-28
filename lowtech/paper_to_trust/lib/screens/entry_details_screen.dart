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
            if (entry.ocrText != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  entry.ocrText!,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
            ],
            _buildInfoSection('メモ', entry.note ?? 'メモなし'),
            const SizedBox(height: 16),
            _buildInfoSection('ステータス', entry.status),
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
