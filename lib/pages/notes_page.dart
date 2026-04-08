import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/note_model.dart';

// Palette moderne
const Color _darkBg = Color(0xFF0D1117);
const Color _cardBg = Color(0xFF161B22);
const Color _cardBgLight = Color(0xFF21262D);
const Color _primaryGold = Color(0xFFFFC300);
const Color _primaryBlue = Color(0xFF58A6FF);
const Color _primaryGreen = Color(0xFF4ECDC4);
const Color _primaryOrange = Color(0xFFFF9F43);
const Color _primaryRed = Color(0xFFFF6B6B);
const Color _textLight = Color(0xFFF0F6FC);
const Color _textMuted = Color(0xFF8B949E);

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> with SingleTickerProviderStateMixin {
  final _notesNotifier = NotesNotifier();
  NoteCategory? _selectedCategory;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _notesNotifier.addListener(_onNotesChanged);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _notesNotifier.removeListener(_onNotesChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onNotesChanged() {
    setState(() {});
  }

  List<Note> get _filteredNotes {
    if (_selectedCategory == null) {
      return _notesNotifier.sortedNotes;
    }
    return _notesNotifier.notesByCategory(_selectedCategory!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      body: Stack(
        children: [
          // Fond gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _primaryGold.withOpacity(0.08),
                  _darkBg,
                ],
                stops: const [0.0, 0.3],
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              // AppBar
              SliverAppBar(
                expandedHeight: 120,
                pinned: true,
                backgroundColor: _darkBg,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _cardBgLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, color: _textLight, size: 18),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(60, 8, 20, 0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [_primaryGold, _primaryGold.withOpacity(0.7)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: _primaryGold.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.sticky_note_2, color: _darkBg, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Mes Notes',
                                style: TextStyle(
                                  color: _textLight,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '${_notesNotifier.notes.length} notes',
                                style: const TextStyle(color: _textMuted, fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Filtres par catégorie
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: _buildCategoryFilters(),
                ),
              ),

              // Liste des notes
              if (_filteredNotes.isEmpty)
                SliverFillRemaining(
                  child: _buildEmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final note = _filteredNotes[index];
                        return _NoteCard(
                          note: note,
                          index: index,
                          animationController: _animationController,
                          onTap: () => _openNoteEditor(note),
                          onPin: () => _notesNotifier.togglePin(note.id),
                          onDelete: () => _confirmDelete(note),
                        );
                      },
                      childCount: _filteredNotes.length,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewNote,
        backgroundColor: _primaryGold,
        icon: const Icon(Icons.add, color: _darkBg),
        label: const Text(
          'Nouvelle note',
          style: TextStyle(color: _darkBg, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _CategoryChip(
            label: 'Toutes',
            icon: Icons.grid_view,
            color: _primaryGold,
            isSelected: _selectedCategory == null,
            onTap: () => setState(() => _selectedCategory = null),
          ),
          const SizedBox(width: 8),
          ...NoteCategory.values.map((cat) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _CategoryChip(
              label: cat.label,
              icon: cat.icon,
              color: cat.color,
              isSelected: _selectedCategory == cat,
              onTap: () => setState(() => _selectedCategory = cat),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _cardBgLight,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.note_alt_outlined, size: 48, color: _textMuted),
          ),
          const SizedBox(height: 24),
          const Text(
            'Aucune note',
            style: TextStyle(
              color: _textLight,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedCategory != null
                ? 'Aucune note dans cette catégorie'
                : 'Crée ta première note !',
            style: const TextStyle(color: _textMuted, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createNewNote,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryGold,
              foregroundColor: _darkBg,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Créer une note', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _createNewNote() {
    HapticFeedback.lightImpact();
    final newNote = Note(
      id: 'note_${DateTime.now().millisecondsSinceEpoch}',
      title: '',
      content: '',
      category: _selectedCategory ?? NoteCategory.general,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _openNoteEditor(newNote, isNew: true);
  }

  void _openNoteEditor(Note note, {bool isNew = false}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _NoteEditorPage(
          note: note,
          isNew: isNew,
          onSave: (updatedNote) {
            if (isNew) {
              _notesNotifier.addNote(updatedNote);
            } else {
              _notesNotifier.updateNote(
                updatedNote.id,
                title: updatedNote.title,
                content: updatedNote.content,
                category: updatedNote.category,
              );
            }
          },
        ),
      ),
    );
  }

  void _confirmDelete(Note note) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Supprimer la note ?',
          style: TextStyle(color: _textLight, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'La note "${note.title.isNotEmpty ? note.title : 'Sans titre'}" sera définitivement supprimée.',
          style: const TextStyle(color: _textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler', style: TextStyle(color: _textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              _notesNotifier.deleteNote(note.id);
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// Widget chip de catégorie
class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : _cardBgLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? color : _textMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : _textMuted,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget carte de note
class _NoteCard extends StatelessWidget {
  final Note note;
  final int index;
  final AnimationController animationController;
  final VoidCallback onTap;
  final VoidCallback onPin;
  final VoidCallback onDelete;

  const _NoteCard({
    required this.note,
    required this.index,
    required this.animationController,
    required this.onTap,
    required this.onPin,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(
          (index * 0.1).clamp(0.0, 0.5),
          ((index * 0.1) + 0.5).clamp(0.5, 1.0),
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    final categoryColor = note.category.color;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animation.value)),
          child: Opacity(opacity: animation.value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: note.isPinned ? _primaryGold.withOpacity(0.5) : _cardBgLight,
            width: note.isPinned ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: categoryColor.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onTap();
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header avec catégorie et actions
                  Row(
                    children: [
                      // Badge catégorie
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(note.category.icon, size: 14, color: categoryColor),
                            const SizedBox(width: 6),
                            Text(
                              note.category.label,
                              style: TextStyle(
                                color: categoryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Bouton épingler
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onPin();
                        },
                        child: Icon(
                          note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                          size: 20,
                          color: note.isPinned ? _primaryGold : _textMuted,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Bouton supprimer
                      GestureDetector(
                        onTap: onDelete,
                        child: const Icon(Icons.delete_outline, size: 20, color: _textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Titre
                  Text(
                    note.title.isNotEmpty ? note.title : 'Sans titre',
                    style: TextStyle(
                      color: note.title.isNotEmpty ? _textLight : _textMuted,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontStyle: note.title.isEmpty ? FontStyle.italic : FontStyle.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (note.content.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      note.content,
                      style: const TextStyle(color: _textMuted, fontSize: 13, height: 1.4),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),
                  // Date
                  Text(
                    _formatDate(note.updatedAt),
                    style: TextStyle(
                      color: _textMuted.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inHours < 1) return 'Il y a ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'Il y a ${diff.inHours}h';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} jours';
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Page d'édition de note
class _NoteEditorPage extends StatefulWidget {
  final Note note;
  final bool isNew;
  final Function(Note) onSave;

  const _NoteEditorPage({
    required this.note,
    required this.isNew,
    required this.onSave,
  });

  @override
  State<_NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<_NoteEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late NoteCategory _selectedCategory;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _selectedCategory = widget.note.category;

    _titleController.addListener(_onChanged);
    _contentController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La note est vide'),
          backgroundColor: _primaryRed,
        ),
      );
      return;
    }

    final updatedNote = widget.note.copyWith(
      title: title.isEmpty ? 'Sans titre' : title,
      content: content,
      category: _selectedCategory,
      updatedAt: DateTime.now(),
    );

    widget.onSave(updatedNote);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.isNew ? 'Note créée !' : 'Note enregistrée'),
        backgroundColor: _primaryGreen,
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Quitter sans enregistrer ?',
          style: TextStyle(color: _textLight, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Les modifications non enregistrées seront perdues.',
          style: TextStyle(color: _textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler', style: TextStyle(color: _textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Quitter', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: _darkBg,
        appBar: AppBar(
          backgroundColor: _darkBg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: _textLight),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text(
            widget.isNew ? 'Nouvelle note' : 'Modifier la note',
            style: const TextStyle(color: _textLight, fontWeight: FontWeight.w700),
          ),
          actions: [
            TextButton.icon(
              onPressed: _saveNote,
              icon: const Icon(Icons.check, color: _primaryGold),
              label: const Text(
                'Enregistrer',
                style: TextStyle(color: _primaryGold, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sélection catégorie
              const Text(
                'Catégorie',
                style: TextStyle(color: _textMuted, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: NoteCategory.values.map((cat) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _CategoryChip(
                      label: cat.label,
                      icon: cat.icon,
                      color: cat.color,
                      isSelected: _selectedCategory == cat,
                      onTap: () {
                        setState(() {
                          _selectedCategory = cat;
                          _hasChanges = true;
                        });
                      },
                    ),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Titre
              Container(
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _cardBgLight),
                ),
                child: TextField(
                  controller: _titleController,
                  style: const TextStyle(
                    color: _textLight,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Titre de la note...',
                    hintStyle: TextStyle(color: _textMuted),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Contenu
              Container(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _cardBgLight),
                ),
                child: TextField(
                  controller: _contentController,
                  style: const TextStyle(color: _textLight, fontSize: 15, height: 1.5),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: 'Écris ta note ici...\n\n💡 Astuce : utilise des emojis pour organiser tes idées !',
                    hintStyle: TextStyle(color: _textMuted),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}









