import 'package:flutter/material.dart';

import '../../models/profile_feed.dart';
import '../../pages/add_recipe_page.dart';
import '../../pages/create_feed_post_page.dart';

class StoriesHeaderRow extends StatelessWidget {
  const StoriesHeaderRow({super.key});

  @override
  Widget build(BuildContext context) {
    const Color marronPrincipal = Color(0xFF5D4037);

    final stories = [
      _StoryBubble(
        label: 'Ajouter',
        isAddButton: true,
        onTap: () => _showCreateMenu(context),
      ),
      const _StoryBubble(
        label: 'Nutrition',
        assetPath: 'assets/images/foodscan/salade_poulet_scan.png',
      ),
      const _StoryBubble(
        label: 'Recettes',
        assetPath: 'assets/images/foodscan/pates_bolo_scan.png',
      ),
      const _StoryBubble(
        label: 'Sport',
        assetPath: 'assets/images/boss_squat_0.png',
      ),
      const _StoryBubble(
        label: 'Coach',
        assetPath: 'assets/images/coach_1_header.png',
      ),
      const _StoryBubble(
        label: 'Transform.',
        assetPath: 'assets/images/before_after_1.png',
      ),
      const _StoryBubble(
        label: 'Repas ajout.',
        assetPath: 'assets/images/foodscan/burger_scan.png',
      ),
    ];

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemBuilder: (context, index) => stories[index],
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: stories.length,
      ),
    );
  }

  static void _showCreateMenu(BuildContext context) {
    const Color marronPrincipal = Color(0xFF5D4037);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Créer',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: marronPrincipal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.restaurant_menu, color: marronPrincipal),
                ),
                title: const Text(
                  'Nouvelle recette',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddRecipePage()),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC300).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.post_add_rounded, color: Color(0xFFF57F17)),
                ),
                title: const Text(
                  'Nouveau post nutrition',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => CreateFeedPostPage(initialType: FeedPostType.recipe)),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.fitness_center, color: Colors.blue),
                ),
                title: const Text(
                  'Nouveau post sport',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => CreateFeedPostPage(initialType: FeedPostType.sport)),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoryBubble extends StatelessWidget {
  final String label;
  final String? assetPath;
  final bool isAddButton;
  final VoidCallback? onTap;

  const _StoryBubble({
    required this.label,
    this.assetPath,
    this.isAddButton = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bubble = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFFFC93C), Color(0xFFFF9F1C)],
            ),
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: ClipOval(
                child: isAddButton
                    ? const Icon(Icons.add_rounded, color: Color(0xFF5D4037), size: 28)
                    : (assetPath != null
                        ? Image.asset(assetPath!, fit: BoxFit.cover)
                        : const SizedBox.shrink()),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 70,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: const Color(0xFF5D4037),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );

    if (onTap == null && !isAddButton) {
      return bubble;
    }

    return GestureDetector(
      onTap: onTap,
      child: bubble,
    );
  }
}
