import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

abstract class CacheStore {
  Future<void> write(String key, dynamic json);
  dynamic read(String key);
  Future<void> clear();
}

/// Cache JSON persistant basé sur Hive (une box de String).
class HiveCacheStore implements CacheStore {
  HiveCacheStore(this._box);
  final Box<String> _box;

  @override
  Future<void> write(String key, dynamic json) => _box.put(key, jsonEncode(json));

  @override
  dynamic read(String key) {
    final v = _box.get(key);
    return v == null ? null : jsonDecode(v);
  }

  @override
  Future<void> clear() => _box.clear();
}
