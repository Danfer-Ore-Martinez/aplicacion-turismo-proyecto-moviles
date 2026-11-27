import 'dart:convert';

import 'package:flutter/foundation.dart' hide Category;
import 'package:http/http.dart' as http;

import '../models/destination_model.dart';
import '../models/category_model.dart';

/// Servicio de comunicación con la API REST del backend
///
/// URL base:
///   - Emulador Android:  http://10.0.2.2:8000
///   - Flutter Web / iOS: http://localhost:8000
///   - Dispositivo físico: http://<IP-de-tu-PC>:8000
class ApiService {
  ApiService._();

  // URL base del backend
  static const String _baseUrl = 'http://192.168.1.80:8000';

  // Tiempo máximo de espera para cada petición HTTP
  static const Duration _timeout = Duration(seconds: 3);

  // ============================================================
  //  Datos de respaldo (fallback) cuando la API no está disponible
  // ============================================================

  static const List<Map<String, dynamic>> _fallbackCategorias = [
    {
      'id_categoria': 1,
      'nombre': 'Natural',
      'descripcion': 'Destinos de naturaleza y paisajes',
    },
    {
      'id_categoria': 2,
      'nombre': 'Cultural',
      'descripcion': 'Destinos culturales e históricos',
    },
    {
      'id_categoria': 3,
      'nombre': 'Religioso',
      'descripcion': 'Destinos de carácter religioso',
    },
    {
      'id_categoria': 4,
      'nombre': 'Aventura',
      'descripcion': 'Destinos para deportes extremos y aventura',
    },
    {
      'id_categoria': 5,
      'nombre': 'Enoturismo',
      'descripcion': 'Destinos relacionados con vinos y piscos',
    },
  ];

  static const List<Map<String, dynamic>> _fallbackDestinos = [
    {
      'id_destino': 1,
      'nombre': 'Laguna de Huacachina',
      'descripcion':
          'Oasis natural rodeado de dunas, ideal para sandboard y paseos en tubular.',
      'ubicacion': 'Huacachina, Ica, Perú',
      'horario': 'Abierto todo el día',
      'precio_entrada': 0,
      'actividad': 'Sandboarding',
      'id_categoria': 1,
    },
    {
      'id_destino': 2,
      'nombre': 'Parque Temático de Cachiche',
      'descripcion':
          'Parque temático basado en leyendas locales, con la famosa escultura de la bruja de Cachiche.',
      'ubicacion': 'Cachiche, Ica, Perú',
      'horario': '8:00 AM - 6:00 PM',
      'precio_entrada': 0,
      'actividad': 'Cultura y leyendas',
      'id_categoria': 2,
    },
    {
      'id_destino': 3,
      'nombre': 'Hacienda Tacama',
      'descripcion':
          'La bodega más antigua de América, especializada en la producción de vinos y piscos premium.',
      'ubicacion': 'La Tacama, Ica, Perú',
      'horario': '9:00 AM - 5:00 PM',
      'precio_entrada': 0,
      'actividad': 'Cata de vinos y piscos',
      'id_categoria': 5,
    },
    {
      'id_destino': 4,
      'nombre': 'Cañón de los Perdidos',
      'descripcion':
          'Impresionante cañón con paredes de roca ideales para rappel, caminatas y deportes extremos.',
      'ubicacion': 'Los Aquijes, Ica, Perú',
      'horario': '7:00 AM - 4:00 PM',
      'precio_entrada': 0,
      'actividad': 'Rappel y aventura',
      'id_categoria': 4,
    },
    {
      'id_destino': 5,
      'nombre': 'Santuario del Señor de Luren',
      'descripcion':
          'Templo principal de Ica que alberga la imagen del Señor de Luren, patrón de la ciudad.',
      'ubicacion': 'Centro de Ica, Perú',
      'horario': '6:00 AM - 8:00 PM',
      'precio_entrada': 0,
      'actividad': 'Peregrinación religiosa',
      'id_categoria': 3,
    },
    {
      'id_destino': 6,
      'nombre': 'Bosque de Piedras',
      'descripcion':
          'Formaciones rocosas naturales con figuras caprichosas esculpidas por el viento y el tiempo.',
      'ubicacion': 'Subtanjalla, Ica, Perú',
      'horario': '8:00 AM - 5:00 PM',
      'precio_entrada': 0,
      'actividad': 'Caminata y exploración',
      'id_categoria': 1,
    },
    {
      'id_destino': 7,
      'nombre': 'Palmera de las 7 Cabezas',
      'descripcion':
          'Palmera datilera única en el mundo con siete cabezas, considerada patrimonio natural de Ica.',
      'ubicacion': 'San Juan Bautista, Ica, Perú',
      'horario': 'Abierto todo el día',
      'precio_entrada': 0,
      'actividad': 'Visita histórica',
      'id_categoria': 2,
    },
    {
      'id_destino': 8,
      'nombre': 'Fiesta de la Vendimia',
      'descripcion':
          'Celebración anual en honor a la cosecha de uva, con elección de reina, desfiles y degustación de vinos.',
      'ubicacion': 'Plaza de Armas de Ica, Perú',
      'horario': 'Marzo (evento anual)',
      'precio_entrada': 0,
      'actividad': 'Festival y celebración',
      'id_categoria': 2,
    },
    {
      'id_destino': 9,
      'nombre': 'Procesión del Señor de Luren',
      'descripcion':
          'Tradición religiosa centenaria donde la imagen del Señor de Luren recorre las calles de Ica.',
      'ubicacion': 'Centro de Ica, Perú',
      'horario': 'Septiembre (evento anual)',
      'precio_entrada': 0,
      'actividad': 'Procesión religiosa',
      'id_categoria': 3,
    },
    {
      'id_destino': 10,
      'nombre': 'Museo Adolfo Bermúdez Jenkins',
      'descripcion':
          'Museo regional que alberga una importante colección arqueológica de las culturas Paracas, Nazca e Ica.',
      'ubicacion': 'Centro de Ica, Perú',
      'horario': '8:00 AM - 5:00 PM',
      'precio_entrada': 0,
      'actividad': 'Visita cultural y arqueológica',
      'id_categoria': 2,
    },
    {
      'id_destino': 11,
      'nombre': 'Parque de la Palma',
      'descripcion':
          'Parque ubicado frente a la Universidad Nacional San Luis Gonzaga, conocido por su emblemática palmera.',
      'ubicacion': 'Frente a la UNICA, Ica, Perú',
      'horario': 'Abierto todo el día',
      'precio_entrada': 0,
      'actividad': 'Descanso y recreación',
      'id_categoria': 1,
    },
  ];

  // ============================================================
  //  Métodos de la API con logging y reintento automático
  // ============================================================

  /// Obtiene la lista de destinos turísticos.
  /// Siempre intenta la API primero. Si falla, usa datos de respaldo.
  static Future<List<Destination>> getDestinos({
    int? idCategoria,
    String? buscar,
  }) async {
    final uri = Uri.parse('$_baseUrl/destinos').replace(
      queryParameters: {
        if (idCategoria != null) 'id_categoria': idCategoria.toString(),
        if (buscar != null && buscar.isNotEmpty) 'buscar': buscar,
      },
    );

    debugPrint('🔍 [API] Intentando GET $uri');

    try {
      final response = await http.get(uri).timeout(_timeout);

      debugPrint('📡 [API] Respuesta: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        debugPrint('✅ [API] ${data.length} destinos cargados desde la API');
        return data.map((json) => Destination.fromJson(json)).toList();
      } else {
        debugPrint('⚠ [API] Error HTTP ${response.statusCode}, usando fallback');
        return _getFallbackDestinos(idCategoria: idCategoria, buscar: buscar);
      }
    } catch (e) {
      debugPrint('❌ [API] Error de conexión: $e');
      debugPrint('📦 [API] Usando datos de respaldo (${_fallbackDestinos.length} destinos)');
      return _getFallbackDestinos(idCategoria: idCategoria, buscar: buscar);
    }
  }

  /// Obtiene un destino específico por su ID.
  static Future<Destination> getDestinoById(int id) async {
    final url = '$_baseUrl/destinos/$id';
    debugPrint('🔍 [API] Intentando GET $url');

    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);

      debugPrint('📡 [API] Respuesta: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('✅ [API] Destino $id cargado desde la API');
        return Destination.fromJson(json.decode(response.body));
      } else {
        debugPrint('⚠ [API] Error HTTP ${response.statusCode}, usando fallback');
        return _getFallbackDestinoById(id);
      }
    } catch (e) {
      debugPrint('❌ [API] Error de conexión: $e');
      debugPrint('📦 [API] Usando destino $id de respaldo');
      return _getFallbackDestinoById(id);
    }
  }

  /// Obtiene la lista de categorías.
  static Future<List<Category>> getCategorias() async {
    final url = '$_baseUrl/categorias';
    debugPrint('🔍 [API] Intentando GET $url');

    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);

      debugPrint('📡 [API] Respuesta: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        debugPrint('✅ [API] ${data.length} categorías cargadas desde la API');
        return data.map((json) => Category.fromJson(json)).toList();
      } else {
        debugPrint('⚠ [API] Error HTTP ${response.statusCode}, usando fallback');
        return _fallbackCategorias.map((json) => Category.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('❌ [API] Error de conexión: $e');
      debugPrint('📦 [API] Usando categorías de respaldo');
      return _fallbackCategorias.map((json) => Category.fromJson(json)).toList();
    }
  }

  // ============================================================
  //  Métodos auxiliares para filtrar datos de respaldo
  // ============================================================

  static List<Destination> _getFallbackDestinos({
    int? idCategoria,
    String? buscar,
  }) {
    List<Destination> destinos =
        _fallbackDestinos.map((json) => Destination.fromJson(json)).toList();

    if (idCategoria != null) {
      destinos = destinos.where((d) => d.idCategoria == idCategoria).toList();
    }

    if (buscar != null && buscar.isNotEmpty) {
      final query = buscar.toLowerCase();
      destinos = destinos
          .where(
            (d) =>
                d.nombre.toLowerCase().contains(query) ||
                (d.actividad?.toLowerCase().contains(query) ?? false) ||
                (d.descripcion?.toLowerCase().contains(query) ?? false),
          )
          .toList();
    }

    return destinos;
  }

  static Destination _getFallbackDestinoById(int id) {
    for (final json in _fallbackDestinos) {
      if (json['id_destino'] == id) {
        return Destination.fromJson(json);
      }
    }
    throw Exception('Destino con id=$id no encontrado en datos de respaldo');
  }
}
