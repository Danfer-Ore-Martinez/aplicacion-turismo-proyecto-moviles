// Modelo local de itinerario para el modulo Mi viaje.
// Se guarda en el dispositivo con SharedPreferences; no requiere backend.

// Destino agregado a un dia del itinerario.
class DetalleViaje {
  final String id;
  final int idDestino;
  final String nombreDestino;
  final String? actividad;
  final double precioEntrada;
  final DateTime fechaVisita;
  final String? horaVisita; // formato HH:mm

  const DetalleViaje({
    required this.id,
    required this.idDestino,
    required this.nombreDestino,
    this.actividad,
    this.precioEntrada = 0,
    required this.fechaVisita,
    this.horaVisita,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_destino': idDestino,
      'nombre_destino': nombreDestino,
      'actividad': actividad,
      'precio_entrada': precioEntrada,
      'fecha_visita': fechaVisita.toIso8601String(),
      'hora_visita': horaVisita,
    };
  }

  factory DetalleViaje.fromJson(Map<String, dynamic> json) {
    return DetalleViaje(
      id: json['id'] as String,
      idDestino: json['id_destino'] as int,
      nombreDestino: json['nombre_destino'] as String,
      actividad: json['actividad'] as String?,
      precioEntrada: (json['precio_entrada'] as num?)?.toDouble() ?? 0,
      fechaVisita: DateTime.parse(json['fecha_visita'] as String),
      horaVisita: json['hora_visita'] as String?,
    );
  }
}

// Itinerario turistico creado por el usuario.
class Itinerario {
  final String id;
  final String nombre;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final double presupuestoEstimado;
  final List<DetalleViaje> detalles;

  const Itinerario({
    required this.id,
    required this.nombre,
    required this.fechaInicio,
    required this.fechaFin,
    this.presupuestoEstimado = 0,
    this.detalles = const [],
  });

  // Suma de precios de entrada de los destinos agregados.
  double get costoDestinos =>
      detalles.fold(0, (total, d) => total + d.precioEntrada);

  // Presupuesto estimado por el usuario + costo de entradas.
  double get presupuestoTotal => presupuestoEstimado + costoDestinos;

  // Destinos agrupados por dia, ordenados cronologicamente.
  Map<DateTime, List<DetalleViaje>> get porDia {
    final mapa = <DateTime, List<DetalleViaje>>{};
    for (final d in detalles) {
      final dia = DateTime(
        d.fechaVisita.year,
        d.fechaVisita.month,
        d.fechaVisita.day,
      );
      mapa.putIfAbsent(dia, () => []).add(d);
    }
    final ordenado = mapa.keys.toList()..sort();
    final resultado = <DateTime, List<DetalleViaje>>{};
    for (final dia in ordenado) {
      final lista = mapa[dia]!
        ..sort((a, b) => (a.horaVisita ?? '').compareTo(b.horaVisita ?? ''));
      resultado[dia] = lista;
    }
    return resultado;
  }

  Itinerario copyWith({
    String? nombre,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    double? presupuestoEstimado,
    List<DetalleViaje>? detalles,
  }) {
    return Itinerario(
      id: id,
      nombre: nombre ?? this.nombre,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      presupuestoEstimado: presupuestoEstimado ?? this.presupuestoEstimado,
      detalles: detalles ?? this.detalles,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'fecha_fin': fechaFin.toIso8601String(),
      'presupuesto_estimado': presupuestoEstimado,
      'detalles': detalles.map((d) => d.toJson()).toList(),
    };
  }

  factory Itinerario.fromJson(Map<String, dynamic> json) {
    return Itinerario(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      fechaInicio: DateTime.parse(json['fecha_inicio'] as String),
      fechaFin: DateTime.parse(json['fecha_fin'] as String),
      presupuestoEstimado:
          (json['presupuesto_estimado'] as num?)?.toDouble() ?? 0,
      detalles: (json['detalles'] as List<dynamic>? ?? [])
          .map((d) => DetalleViaje.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }
}
