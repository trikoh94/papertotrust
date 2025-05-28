import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../providers/ledger_provider.dart';
import '../widgets/loading_screen.dart';

class CaptureScreen extends StatelessWidget {
  const CaptureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('撮影'),
        centerTitle: true,
      ),
      body: Consumer<LedgerProvider>(
        builder: (context, provider, child) {
          if (provider.isProcessing) {
            return const LoadingScreen(
              message: '画像を処理中です...',
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (provider.selectedImage != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: kIsWeb
                        ? Image.network(
                            provider.selectedImage!.path,
                            height: 300,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 300,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(Icons.error),
                                ),
                              );
                            },
                          )
                        : Image.file(
                            File(provider.selectedImage!.path),
                            height: 300,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 300,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(Icons.error),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'メモ',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onChanged: provider.setNote,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: provider.processImage,
                    child: const Text('処理開始'),
                  ),
                  if (provider.ocrText != null) ...[
                    const SizedBox(height: 16),
                    Text('OCR結果:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(provider.ocrText!),
                  ],
                  if (provider.parsedResult != null) ...[
                    const SizedBox(height: 16),
                    Text('パース結果:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(provider.parsedResult!),
                  ],
                ] else ...[
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () => provider.pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('カメラで撮影'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => provider.pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('ギャラリーから選択'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                  const Spacer(),
                ],
                if (provider.lastResponse != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    provider.lastResponse!,
                    style: TextStyle(
                      color: provider.lastResponse!.contains('失敗')
                          ? Colors.red
                          : Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
