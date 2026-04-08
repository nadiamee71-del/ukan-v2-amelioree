/// Modèle d'un pack vidéos
class VideoPack {
  final String id;
  final String title; // ex : "Pack HIIT Brûle-graisse"
  final String description;
  final double price;
  final List<String> exerciseIds; // Liste des exercices inclus

  const VideoPack({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.exerciseIds,
  });
}








