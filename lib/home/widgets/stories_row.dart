part of ukan_main;

/// Rangée horizontale de stories style Instagram.
class StoriesRow extends StatelessWidget {
  final List<Story> stories;
  final Function(Story)? onStoryTap;

  const StoriesRow({
    super.key,
    required this.stories,
    this.onStoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: stories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final story = stories[index];
          return _StoryBubble(
            story: story,
            onTap: () => onStoryTap?.call(story),
          );
        },
      ),
    );
  }
}

class _StoryBubble extends StatelessWidget {
  final Story story;
  final VoidCallback? onTap;

  const _StoryBubble({
    required this.story,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: story.isOwnStory
                  ? null
                  : const LinearGradient(
                      colors: [
                        Color(0xFFFFC300),
                        Color(0xFFFF9500),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              border: story.isOwnStory
                  ? Border.all(
                      color: Colors.grey.shade300,
                      width: 2,
                    )
                  : null,
            ),
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: story.isOwnStory
                    ? Colors.grey.shade100
                    : const Color(0xFFFDF6EC),
              ),
              child: Center(
                child: story.isOwnStory
                    ? const Icon(
                        Icons.add,
                        color: Color(0xFF5D4037),
                        size: 28,
                      )
                    : Icon(
                        story.icon ?? Icons.person,
                        color: const Color(0xFF5D4037),
                        size: 28,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 72,
            child: Text(
              story.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF5D4037),
              ),
            ),
          ),
        ],
      ),
    );
  }
}








