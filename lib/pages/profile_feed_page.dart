import 'package:flutter/material.dart';
import '../models/profile_feed.dart';
import '../models/theme_notifier.dart';

class ProfileFeedPage extends StatefulWidget {
  const ProfileFeedPage({super.key});

  @override
  State<ProfileFeedPage> createState() => _ProfileFeedPageState();
}

class _ProfileFeedPageState extends State<ProfileFeedPage> {
  final ProfileFeedNotifier _feedNotifier = ProfileFeedNotifier();

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ThemeNotifier();
    final isDarkMode = themeNotifier.isDarkMode;
    final sortedPosts = _feedNotifier.getSortedPosts();

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0A0E27) : const Color(0xFFFFF9E6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5D4037),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mon Feed',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Compteurs d'abonnés et de suivi
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1A1A2E) : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  label: 'Abonnés',
                  value: _feedNotifier.followers,
                  isDarkMode: isDarkMode,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: isDarkMode ? Colors.white.withOpacity(0.2) : Colors.grey.shade300,
                ),
                _buildStatItem(
                  label: 'Suivi',
                  value: _feedNotifier.following,
                  isDarkMode: isDarkMode,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: isDarkMode ? Colors.white.withOpacity(0.2) : Colors.grey.shade300,
                ),
                _buildStatItem(
                  label: 'Publications',
                  value: sortedPosts.length,
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
          ),
          
          // Grille de posts (style Instagram)
          Expanded(
            child: sortedPosts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.grid_on,
                          size: 64,
                          color: isDarkMode ? Colors.white38 : Colors.black26,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune publication',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(2),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),
                    itemCount: sortedPosts.length,
                    itemBuilder: (context, index) {
                      final post = sortedPosts[index];
                      return _buildPostThumbnail(post, isDarkMode);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required int value,
    required bool isDarkMode,
  }) {
    return Column(
      children: [
        Text(
          _formatNumber(value),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  Widget _buildPostThumbnail(ProfileFeedPost post, bool isDarkMode) {
    return GestureDetector(
      onTap: () => _showPostDetail(post, isDarkMode),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1A1A2E) : Colors.grey.shade100,
          border: Border.all(
            color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
            width: 0.5,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image du post
            Image.asset(
              post.displayImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: isDarkMode ? const Color(0xFF2A2A3E) : Colors.grey.shade200,
                  child: Center(
                    child: Icon(
                      post.type == FeedPostType.recipe
                          ? Icons.restaurant
                          : Icons.fitness_center,
                      size: 32,
                      color: isDarkMode ? Colors.white38 : Colors.black26,
                    ),
                  ),
                );
              },
            ),
            
            // Badge vidéo si c'est une vidéo
            if (post.isVideo)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            
            // Badge type de post
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: post.type == FeedPostType.recipe
                      ? const Color(0xFFFFC300).withOpacity(0.9)
                      : const Color(0xFF2196F3).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  post.type == FeedPostType.recipe ? '🍽️' : '💪',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPostDetail(ProfileFeedPost post, bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC300),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alex Ukan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Il y a 2h',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Image/Video
            Expanded(
              child: Container(
                width: double.infinity,
                color: isDarkMode ? const Color(0xFF2A2A3E) : Colors.grey.shade100,
                child: Image.asset(
                  post.displayImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            post.type == FeedPostType.recipe
                                ? Icons.restaurant
                                : Icons.fitness_center,
                            size: 64,
                            color: isDarkMode ? Colors.white38 : Colors.black26,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            post.type == FeedPostType.recipe
                                ? 'Image de recette'
                                : 'Image/Vidéo de sport',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode ? Colors.white54 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Actions et infos
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.favorite_border),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.comment_outlined),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.share_outlined),
                        onPressed: () {},
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.bookmark_border),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_formatNumber(post.likes)} j\'aime',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (post.caption != null) ...[
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Alex Ukan ',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(text: post.caption!),
                        ],
                      ),
                    ),
                  ],
                  if (post.recipeTitle != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC300).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.restaurant,
                            color: Color(0xFFFFC300),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.recipeTitle!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                if (post.calories != null)
                                  Text(
                                    '${post.calories} kcal',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (post.workoutType != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.fitness_center,
                            color: Color(0xFF2196F3),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            post.workoutType!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (post.comments > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Voir les ${post.comments} commentaires',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

