import 'package:dio/dio.dart';
import 'package:universal_html/html.dart' as html;

class CloudinaryWebService {
  final String cloudName;
  final String uploadPreset;
  final String folder;

  CloudinaryWebService({
    required this.cloudName,
    required this.uploadPreset,
    this.folder = 'ledger_images',
  });

  Future<String> uploadHtmlFile(html.File file) async {
    final dio = Dio();
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;
    final bytes = reader.result as List<int>;

    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: file.name),
      'upload_preset': uploadPreset,
      'folder': folder,
    });

    final response = await dio.post(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      data: formData,
    );

    if (response.statusCode == 200) {
      return response.data['secure_url'];
    } else {
      throw Exception('Cloudinary upload failed: \\${response.data}');
    }
  }
}
