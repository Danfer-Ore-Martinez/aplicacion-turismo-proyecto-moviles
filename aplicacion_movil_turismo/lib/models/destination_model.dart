/// Modelo de destino turístico que coincide con el endpoint GET /destinos del backend
class Destination {
  final int idDestino;
  final String nombre;
  final String? descripcion;
  final String? ubicacion;
  final String? horario;
  final double precioEntrada;
  final String? actividad;
  final int idCategoria;

  const Destination({
    required this.idDestino,
    required this.nombre,
    this.descripcion,
    this.ubicacion,
    this.horario,
    required this.precioEntrada,
    this.actividad,
    required this.idCategoria,
  });

  /// Crea un Destination desde un JSON recibido por la API
  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      idDestino: json['id_destino'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      ubicacion: json['ubicacion'] as String?,
      horario: json['horario'] as String?,
      precioEntrada: (json['precio_entrada'] as num).toDouble(),
      actividad: json['actividad'] as String?,
      idCategoria: json['id_categoria'] as int,
    );
  }

  /// Convierte el Destination a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'id_destino': idDestino,
      'nombre': nombre,
      'descripcion': descripcion,
      'ubicacion': ubicacion,
      'horario': horario,
      'precio_entrada': precioEntrada,
      'actividad': actividad,
      'id_categoria': idCategoria,
    };
  }
}
