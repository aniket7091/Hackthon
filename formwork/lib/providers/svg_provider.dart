import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/svg_model.dart';
import '../services/svg_service.dart';

class SvgProvider extends ChangeNotifier {
  final _service = SvgService();
  final _uuid = const Uuid();

  final List<SvgCard> _cards = [];
  List<SvgCard> get cards => List.unmodifiable(_cards);

  Future<void> addSvg(String filename, String svgContent) async {
    final card = SvgCard(
      id: _uuid.v4(),
      filename: filename,
      originalSvg: svgContent,
      isLoading: true,
    );
    _cards.insert(0, card);
    notifyListeners();

    try {
      final json = await _service.analyzeSvg(svgContent);
      card.result = SvgAnalysisResult.fromJson(json, svgContent);
      card.isLoading = false;
    } catch (e) {
      card.isLoading = false;
      card.error = e.toString();
    }
    notifyListeners();
  }

  void removeCard(String id) {
    _cards.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  void clearAll() {
    _cards.clear();
    notifyListeners();
  }
}
