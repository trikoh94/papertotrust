import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ledger_provider.dart';

class LedgerImagePreview extends StatelessWidget {
  const LedgerImagePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LedgerProvider>(
      builder: (context, provider, child) {
        if (provider.selectedImage == null) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(provider.selectedImage!.path),
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ファイル名: ${provider.selectedImage!.path.split('/').last}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        );
      },
    );
  }
}
