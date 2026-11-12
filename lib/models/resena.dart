class Resena {
  final int recetaId;
  final String comentario;

  const Resena({
    required this.recetaId,
    required this.comentario,
  });

  // Objeto -> mapa para SQLite.
  Map<String, Object?> toMap() {
    return {
      'recetaId': recetaId,
      'comentario': comentario,
    };
  }

  // Fila de SQLite -> objeto.
  factory Resena.fromMap(Map<String, Object?> mapa) {
    return Resena(
      recetaId: mapa['recetaId'] as int,
      comentario: mapa['comentario'] as String,
    );
  }
}