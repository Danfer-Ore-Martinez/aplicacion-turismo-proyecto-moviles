import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/itinerario_model.dart';

// Persistencia local de itinerarios con SharedPreferences.
class ItinerarioLocalService {
  static const String _key = 'itinerarios_local';

  Future<List<Itinerario>> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final lista = json.decode(raw) as List<dynamic>;
      return lista
          .map((e) => Itinerario.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> guardar(List<Itinerario> itinerarios) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = json.encode(itinerarios.map((e) => e.toJson()).toList());
    await prefs.setString(_key, raw);
  }

  Future<void> borrarTodo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
