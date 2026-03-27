import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/design_model.dart';
import '../models/validation_model.dart';
import '../services/design_service.dart';
import '../services/validation_service.dart';
import '../services/autofix_service.dart';
import '../services/ai_service.dart';
import '../services/report_service.dart';
import '../core/network/api_client.dart';

enum DesignLoadState { idle, loading, success, error }

class DesignProvider extends ChangeNotifier {
  final _designService = DesignService();
  final _validationService = ValidationService();
  final _autofixService = AutofixService();
  final _aiService = AiService();
  final _reportService = ReportService();

  // State
  Map<String, dynamic>? _rawDesignJson;
  DesignUploadResponse? _uploadedDesign;
  ValidationResult? _validationResult;
  AutofixResult? _autofixResult;
  AiSuggestionData? _aiSuggestion;
  ValidationIssue? _selectedIssue;
  Uint8List? _reportBytes;

  DesignLoadState _uploadState = DesignLoadState.idle;
  DesignLoadState _validateState = DesignLoadState.idle;
  DesignLoadState _autofixState = DesignLoadState.idle;
  DesignLoadState _aiState = DesignLoadState.idle;
  DesignLoadState _reportState = DesignLoadState.idle;
  String? _errorMessage;

  // Getters
  Map<String, dynamic>? get rawDesignJson => _rawDesignJson;
  DesignUploadResponse? get uploadedDesign => _uploadedDesign;
  ValidationResult? get validationResult => _validationResult;
  AutofixResult? get autofixResult => _autofixResult;
  AiSuggestionData? get aiSuggestion => _aiSuggestion;
  ValidationIssue? get selectedIssue => _selectedIssue;
  Uint8List? get reportBytes => _reportBytes;
  DesignLoadState get uploadState => _uploadState;
  DesignLoadState get validateState => _validateState;
  DesignLoadState get autofixState => _autofixState;
  DesignLoadState get aiState => _aiState;
  DesignLoadState get reportState => _reportState;
  String? get errorMessage => _errorMessage;
  bool get hasDesign => _rawDesignJson != null;
  bool get hasValidation => _validationResult != null;

  // Returns the active shape list (from autofix if available, else upload)
  List<DesignShape> get activeShapes {
    if (_autofixResult != null) {
      return (_autofixResult!.shapes)
          .map((s) => DesignShape.fromJson(s as Map<String, dynamic>))
          .toList();
    }
    return _uploadedDesign?.shapes ?? [];
  }

  // Returns issues with status if autofix ran, else validation issues
  List<ValidationIssue> get activeIssues {
    if (_autofixResult != null) return _autofixResult!.issuesWithStatus;
    return _validationResult?.issues ?? [];
  }

  void setDesignJson(String jsonString) {
    try {
      _rawDesignJson = jsonDecode(jsonString) as Map<String, dynamic>;
      _validationResult = null;
      _autofixResult = null;
      _aiSuggestion = null;
      _uploadedDesign = null;
      _uploadState = DesignLoadState.idle;
      _validateState = DesignLoadState.idle;
      _autofixState = DesignLoadState.idle;
      notifyListeners();
    } catch (_) {
      _errorMessage = 'Invalid JSON format.';
      notifyListeners();
    }
  }

  void selectIssue(ValidationIssue issue) {
    _selectedIssue = issue;
    _aiSuggestion = null;
    notifyListeners();
  }

  Future<void> upload() async {
    if (_rawDesignJson == null) return;
    _uploadState = DesignLoadState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _uploadedDesign = await _designService.uploadDesign(_rawDesignJson!);
      _uploadState = DesignLoadState.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _uploadState = DesignLoadState.error;
    } catch (e) {
      _errorMessage = e.toString();
      _uploadState = DesignLoadState.error;
    }
    notifyListeners();
  }

  Future<void> validate() async {
    if (_rawDesignJson == null) return;
    _validateState = DesignLoadState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _validationResult = await _validationService.validate(_rawDesignJson!);
      _validateState = DesignLoadState.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _validateState = DesignLoadState.error;
    } catch (e) {
      _errorMessage = e.toString();
      _validateState = DesignLoadState.error;
    }
    notifyListeners();
  }

  Future<void> autofix() async {
    if (_rawDesignJson == null) return;
    _autofixState = DesignLoadState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _autofixResult = await _autofixService.autofix(_rawDesignJson!);
      _autofixState = DesignLoadState.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _autofixState = DesignLoadState.error;
    } catch (e) {
      _errorMessage = e.toString();
      _autofixState = DesignLoadState.error;
    }
    notifyListeners();
  }

  Future<void> getAiSuggestion() async {
    if (_selectedIssue == null) return;
    _aiState = DesignLoadState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _aiSuggestion = await _aiService.getSuggestion(_selectedIssue!);
      _aiState = DesignLoadState.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _aiState = DesignLoadState.error;
    } catch (e) {
      _errorMessage = e.toString();
      _aiState = DesignLoadState.error;
    }
    notifyListeners();
  }

  Future<Uint8List?> generateReport() async {
    if (_rawDesignJson == null) return null;
    _reportState = DesignLoadState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _reportBytes = await _reportService.generateReport(_rawDesignJson!);
      _reportState = DesignLoadState.success;
      notifyListeners();
      return _reportBytes;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _reportState = DesignLoadState.error;
      notifyListeners();
      return null;
    } catch (e) {
      _errorMessage = e.toString();
      _reportState = DesignLoadState.error;
      notifyListeners();
      return null;
    }
  }

  void reset() {
    _rawDesignJson = null;
    _uploadedDesign = null;
    _validationResult = null;
    _autofixResult = null;
    _aiSuggestion = null;
    _selectedIssue = null;
    _reportBytes = null;
    _uploadState = DesignLoadState.idle;
    _validateState = DesignLoadState.idle;
    _autofixState = DesignLoadState.idle;
    _aiState = DesignLoadState.idle;
    _reportState = DesignLoadState.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
