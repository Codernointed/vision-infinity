import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final audioCacheProvider = Provider((ref) => AudioCacheService());

class AudioCacheService {
  final Map<String, Uint8List> _cache = {};

  void cacheAudio(String text, Uint8List audioData) {
    _cache[text] = audioData;
  }

  Uint8List? getAudio(String text) {
    return _cache[text];
  }

  bool hasAudio(String text) {
    return _cache.containsKey(text);
  }
}
