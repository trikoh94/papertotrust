import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  late final CloudinaryPublic _cloudinary;
  late final String _uploadPreset;

  CloudinaryService() {
    print('=== CloudinaryService 초기화 시작 ===');
    print('dotenv.env.length: ${dotenv.env.length}');

    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
    final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];

    print('Raw cloudName: "$cloudName"');
    print('Raw uploadPreset: "$uploadPreset"');
    print('cloudName.runtimeType: ${cloudName.runtimeType}');
    print('cloudName?.isEmpty: ${cloudName?.isEmpty}');

    // 모든 환경변수 출력
    print('All dotenv keys: ${dotenv.env.keys.toList()}');
    dotenv.env.forEach((key, value) {
      print('  $key = "$value"');
    });

    if (cloudName == null || cloudName.isEmpty) {
      print('❌ CLOUDINARY_CLOUD_NAME이 비어있음!');
      throw Exception('CLOUDINARY_CLOUD_NAME is required in .env file');
    }

    if (uploadPreset == null || uploadPreset.isEmpty) {
      print('❌ CLOUDINARY_UPLOAD_PRESET이 비어있음!');
      throw Exception('CLOUDINARY_UPLOAD_PRESET is required in .env file');
    }

    print(
        '✅ CloudinaryPublic 초기화: cloudName="$cloudName", uploadPreset="$uploadPreset"');

    _cloudinary = CloudinaryPublic(
      cloudName,
      uploadPreset,
      cache: false,
    );
    _uploadPreset = uploadPreset;

    print('=== CloudinaryService 초기화 완료 ===');
  }

  Future<String> uploadImage(File file, {String? note}) async {
    try {
      print('=== Cloudinary 파일 업로드 시작 ===');
      print('파일 경로: ${file.path}');
      print('노트: $note');

      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          resourceType: CloudinaryResourceType.Image,
      // folder: 'ledger_images', // 일단 주석 처리
          tags: note != null ? ['note: $note'] : null,
        ),
        uploadPreset: _uploadPreset,
      );

      print('업로드 성공: ${response.secureUrl}');

      if (response.secureUrl.isEmpty) {
        throw Exception('Upload failed: No secure URL returned');
      }

      return response.secureUrl;
    } on CloudinaryException catch (e) {
      print('Cloudinary 에러: ${e.message}');
      print('Cloudinary 에러 코드: ${e.statusCode}');
      throw Exception('Cloudinary error: ${e.message}');
    } catch (e) {
      print('일반 에러: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<String> uploadWebImage(String imageUrl, {String? note}) async {
    try {
      if (imageUrl.isEmpty) {
        throw Exception('Image URL cannot be empty');
      }

      print('=== Cloudinary 웹 이미지 업로드 시작 ===');
      print('이미지 URL: $imageUrl');
      print('노트: $note');

      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromUrl(
          imageUrl,
          resourceType: CloudinaryResourceType.Image,
          // folder 파라미터 임시 제거 (프리셋 설정과 충돌 가능성)
          // folder: 'ledger_images',
          tags: note != null ? ['note: $note'] : null,
        ),
      );

      print('업로드 성공: ${response.secureUrl}');

      if (response.secureUrl.isEmpty) {
        throw Exception('Upload failed: No secure URL returned');
      }

      return response.secureUrl;
    } on CloudinaryException catch (e) {
      print('Cloudinary 에러: ${e.message}');
      print('Cloudinary 에러 코드: ${e.statusCode}');
      throw Exception('Cloudinary error: ${e.message}');
    } catch (e) {
      print('일반 에러: $e');
      throw Exception('Failed to upload web image: $e');
    }
  }

  // 업로드 진행상황을 추적하고 싶다면
  Future<String> uploadImageWithProgress(
    File file, {
    String? note,
    Function(int sent, int total)? onProgress,
  }) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'ledger_images',
          tags: note != null ? ['note: $note'] : null,
        ),
        uploadPreset: _uploadPreset,
        onProgress: onProgress,
      );

      return response.secureUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}
