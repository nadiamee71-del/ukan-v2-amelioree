part of ukan_main;

/// Carte de publication style Instagram.
class PublicationCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;
  final VoidCallback? onAddToMeal;

  const PublicationCard({
    super.key,
    required this.post,
    this.onTap,
    this.onAddToMeal,
  });

  String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays > 0) {
      return 'il y a ${diff.inDays}j';
    } else if (diff.inHours > 0) {
      return 'il y a ${diff.inHours}h';
    } else if (diff.inMinutes > 0) {
      return 'il y a ${diff.inMinutes}min';
    } else {
      return 'à l\'instant';
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color cardColor = Color(0xFFFDF6EC);
    const Color textColor = Color(0xFF5D4037);
    const Color accentColor = Color(0xFFFFC300);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec avatar et nom
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: textColor.withOpacity(0.1),
                    child: Text(
                      post.authorName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: textColor,
                          ),
                        ),
                        Text(
                          _timeAgo(post.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: textColor.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (post.isRecipe)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '🍽️ Recette',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Image
            ClipRRect(
              child: AspectRatio(
                aspectRatio: 1.2,
                child: Image.asset(
                  post.imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: textColor.withOpacity(0.1),
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 48,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Titre et sous-titre
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                  if (post.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      post.subtitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  _ActionButton(
                    icon: Icons.favorite_border_rounded,
                    label: '${post.likes}',
                  ),
                  const SizedBox(width: 16),
                  _ActionButton(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: '${post.comments}',
                  ),
                  const SizedBox(width: 16),
                  const _ActionButton(
                    icon: Icons.share_outlined,
                    label: '',
                  ),
                  const Spacer(),
                  const _ActionButton(
                    icon: Icons.bookmark_border_rounded,
                    label: '',
                  ),
                ],
              ),
            ),

            // Bouton "Ajouter au repas" pour les recettes
            if (post.isRecipe && onAddToMeal != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onAddToMeal,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Ajouter au repas du jour'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: textColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionButton({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    const Color textColor = Color(0xFF5D4037);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 22,
          color: textColor,
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ],
    );
  }
}








