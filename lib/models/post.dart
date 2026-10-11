/// Modelo simple de una publicación devuelta por la API REST.
class Post {
  final int id;
  final String titulo;
  final String cuerpo;

  const Post({required this.id, required this.titulo, required this.cuerpo});

  /// Convierte el JSON de la API en un objeto [Post].
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      titulo: json['title'] as String,
      cuerpo: json['body'] as String,
    );
  }
}
