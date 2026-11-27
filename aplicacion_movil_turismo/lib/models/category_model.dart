/// Modelo de categoría que coincide con el endpoint GET /categorias del backend
class Category {
  final int idCategoria;
  final String nombre;
  final String? descripcion;

  const Category({
    required this.idCategoria,
    required this.nombre,
    this.descripcion,
  });

  /// Crea un Category desde un JSON recibido de la API
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      idCategoria: json['id_categoria'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
    );
  }

  /// Convierte el Category a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'id_categoria': idCategoria,
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }
}
