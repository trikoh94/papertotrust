import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../services/camera_service.dart';
import '../services/ocr_parser_jp.dart';
import '../models/ledger_entry.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LedgerProvider with ChangeNotifier {
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

  static const String apiUrl = String.fromEnvironment('OCR_API_URL');

  Future<String> uploadImageForOCR(XFile imageFile) async {
    debugPrint('OCR_API_URL: $apiUrl');
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

    if (kIsWeb) {
      // 웹에서는 bytes로 읽어서 업로드
      final bytes = await imageFile.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: imageFile.name,
        ),
      );
    } else {
      // 모바일/데스크탑에서는 fromPath 사용
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    debugPrint('Mistral OCR API status: ${response.statusCode}');
    debugPrint('Mistral OCR API response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint('Decoded response: $data');
      if (data['result'] != null) {
        return data['result'].toString();
      } else {
        throw Exception('Unexpected null value in OCR result');
      }
    } else {
      throw Exception('Failed to get OCR result');
    }
  }

  Future<void> processImage() async {
    if (_selectedImage == null) return;

    try {
      _isProcessing = true;
      _lastResponse = null;
      notifyListeners();

      _ocrText = await uploadImageForOCR(_selectedImage!);
      final ledger = parseLedgerTextJp(_ocrText!);
      _parsedResult = ledger.toString();
      await saveLedgerToFirestore(ledger, _ocrText!);
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
      LedgerDataJp ledger, String ocrText) async {
    await FirebaseFirestore.instance.collection('ledgers').add({
      'ocrText': ocrText,
      'date': ledger.date?.toIso8601String(),
      'income': ledger.income,
      'expense': ledger.expense,
      'balance': ledger.balance,
      'memo': ledger.memo,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
