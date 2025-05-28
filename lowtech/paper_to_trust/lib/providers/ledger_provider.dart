import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../services/cloudinary_service.dart';
import '../services/ocr_service.dart';
import '../services/camera_service.dart';
import '../services/ocr_web_service.dart';
import '../services/ocr_parser_jp.dart';
import '../models/ledger_entry.dart';
import '../services/cloudinary_web_service.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LedgerProvider with ChangeNotifier {
  final CloudinaryService _cloudinaryService = CloudinaryService();

  final CameraService _cameraService = CameraService();

  List<LedgerEntry> _entries = [];
  XFile? _selectedImage;
  String? _note;
  bool _isUploading = false;
  bool _isProcessing = false;
  String? _lastResponse;
  String? _ocrText;
  Map<String, dynamic>? _ledgerData;
  String? _parsedResult;

  List<LedgerEntry> get entries => _entries;
  XFile? get selectedImage => _selectedImage;
  String? get note => _note;
  bool get isUploading => _isUploading;
  bool get isProcessing => _isProcessing;
  String? get lastResponse => _lastResponse;
  String? get ocrText => _ocrText;
  Map<String, dynamic>? get ledgerData => _ledgerData;
  String? get parsedResult => _parsedResult;

  Future<void> loadEntries() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('ledgers')
          .orderBy('createdAt', descending: true)
          .get();
      _entries =
          snapshot.docs.map((doc) => LedgerEntry.fromJson(doc.data())).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading entries: $e');
      rethrow;
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final image = await _cameraService.pickImage(source);
      if (image != null) {
        _selectedImage = image;
        _ocrText = null;
        _ledgerData = null;
        notifyListeners();
      }
    } catch (e) {
      _lastResponse = '画像の選択に失敗しました: $e';
      notifyListeners();
    }
  }

  void setNote(String value) {
    _note = value;
    notifyListeners();
  }

  void clearImage() {
    _selectedImage = null;
    _note = null;
    _lastResponse = null;
    _ocrText = null;
    _ledgerData = null;
    notifyListeners();
  }

  Future<void> processImage() async {
    if (_selectedImage == null) return;

    try {
      _isProcessing = true;
      _lastResponse = null;
      notifyListeners();

      String uploadedUrl;
      if (kIsWeb) {
        final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
        final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';
        if (cloudName.isEmpty || uploadPreset.isEmpty) {
          throw Exception('Cloudinary 환경변수가 비어있습니다');
        }
        final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
        uploadInput.click();
        await uploadInput.onChange.first;
        if (uploadInput.files == null || uploadInput.files!.isEmpty) {
          throw Exception('웹 파일 객체를 찾을 수 없습니다');
        }
        final file = uploadInput.files!.first;
        final cloudinaryWeb = CloudinaryWebService(
          cloudName: cloudName,
          uploadPreset: uploadPreset,
        );
        uploadedUrl = await cloudinaryWeb.uploadHtmlFile(file);
      } else {
        final file = File(_selectedImage!.path);
        uploadedUrl = await _cloudinaryService.uploadImage(
          file,
          note: _note,
        );
      }
      _ocrText = await recognizeTextWeb(uploadedUrl, lang: 'jpn');
      final ledger = parseLedgerTextJp(_ocrText!);
      _parsedResult = ledger.toString();
      await saveLedgerToFirestore(ledger, uploadedUrl, _ocrText!);
      _lastResponse = '画像の処理と保存が完了しました';
      await loadEntries();
    } catch (e) {
      _lastResponse = '処理に失敗しました: $e';
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> saveLedgerToFirestore(
      LedgerDataJp ledger, String imageUrl, String ocrText) async {
    await FirebaseFirestore.instance.collection('ledgers').add({
      'imageUrl': imageUrl,
      'date': ledger.date?.toIso8601String(),
      'income': ledger.income,
      'expense': ledger.expense,
      'balance': ledger.balance,
      'memo': ledger.memo,
      'ocrText': ocrText,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
