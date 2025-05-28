import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:universal_html/html.dart' as html;
import 'package:path/path.dart' as path;

class CameraService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImage(ImageSource source) async {
    try {
      if (kIsWeb) {
        // 웹 플랫폼
        if (source == ImageSource.camera) {
          // 웹에서는 카메라 스트림을 직접 처리
          final input = html.FileUploadInputElement()..accept = 'image/*';
          input.setAttribute('capture', 'camera');
          input.click();

          await input.onChange.first;
          if (input.files?.isNotEmpty ?? false) {
            final file = input.files!.first;
            final reader = html.FileReader();
            reader.readAsArrayBuffer(file);
            await reader.onLoad.first;

            final bytes = reader.result as List<int>;
            final blob = html.Blob([bytes]);
            final url = html.Url.createObjectUrlFromBlob(blob);

            return XFile(url, name: file.name);
          }
        } else {
          // 갤러리 선택
          final input = html.FileUploadInputElement()..accept = 'image/*';
          input.click();

          await input.onChange.first;
          if (input.files?.isNotEmpty ?? false) {
            final file = input.files!.first;
            final reader = html.FileReader();
            reader.readAsArrayBuffer(file);
            await reader.onLoad.first;

            final bytes = reader.result as List<int>;
            final blob = html.Blob([bytes]);
            final url = html.Url.createObjectUrlFromBlob(blob);

            return XFile(url, name: file.name);
          }
        }
      } else {
        // 모바일 플랫폼
        final image = await _picker.pickImage(
          source: source,
          maxWidth: 1800,
          maxHeight: 1800,
          imageQuality: 85,
        );
        return image;
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
    return null;
  }

  Future<File?> getImageFile(XFile image) async {
    if (kIsWeb) {
      // 웹에서는 Blob URL을 사용
      return null;
    } else {
      // 모바일에서는 실제 파일 반환
      return File(image.path);
    }
  }

  Future<String> getImageUrl(XFile image) async {
    if (kIsWeb) {
      // 웹에서는 Blob URL 반환
      return image.path;
    } else {
      // 모바일에서는 파일 경로 반환
      return image.path;
    }
  }
}
