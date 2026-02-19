import 'package:flutter/material.dart';

import 'package:nox_ai/core/theme/app_theme.dart';

import 'package:nox_ai/core/utils/page_transitions.dart';

class MemoriesScreen extends StatefulWidget {
  const MemoriesScreen({super.key});

  @override
  State<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Tag colors
  static const _tagColors = {
    'Strategy': Color(0xFFE57373),
    'Docs': Color(0xFF64B5F6),
    'API': Color(0xFF81C784),
    'Sales': Color(0xFFFFD54F),
    'Market': Color(0xFF4FC3F7),
    'High Priority': Color(0xFFE57373),
    'Finance': Color(0xFF9575CD),
    'Legal': Color(0xFFFFB74D),
  };

  // TODO: Fetch memories from backend API
  // Sample data for UI template
  final List<Map<String, dynamic>> _memories = [
    {
      'id': '1',
      'title': 'Q3 Strategy Call',
      'description':
          'Discussion about revenue targets and hiring plans for the upcoming quarter. Key focus on th...',
      'detail':
          'The client mentioned they are looking to renew their contract in Q3 but wants to discuss pricing tiers before committing. Specifically interested in the enterprise volume discount.',
      'tags': ['Strategy'],
      'type': 'call',
      'timestamp': '2h ago',
      'isPinned': true,
      'linkedSources': [
        {
          'name': 'Q2_Meeting_Transcript.pdf',
          'uploadedAt': '2h ago',
          'size': '1.2 MB',
        },
      ],
    },
    {
      'id': '2',
      'title': 'Project Spec V2',
      'description':
          'Uploaded PDF containing the new API requirements and endpoint definitions. Includes...',
      'detail':
          'Updated project specifications including new REST API endpoints, authentication flow changes, and database schema modifications for the v2 release.',
      'tags': ['Docs', 'API'],
      'type': 'document',
      'timestamp': '5h ago',
      'isPinned': false,
      'linkedSources': [],
    },
    {
      'id': '3',
      'title': 'Client Intro: TechCorp',
      'description':
          'Introductory call with the marketing team. They are interested in the premium tier but requeste...',
      'detail':
          'Initial discovery call with TechCorp marketing team. They have a team of 50+ and are evaluating enterprise solutions. Decision maker is Sarah Chen, VP of Marketing.',
      'tags': ['Sales'],
      'type': 'call',
      'timestamp': '1d ago',
      'isPinned': false,
      'linkedSources': [],
    },
    {
      'id': '4',
      'title': 'Market Trends Report',
      'description':
          'Analysis of competitor features launched this week. Main takeaway is the new AI integration i...',
      'detail':
          'Competitive analysis showing 3 major competitors launched AI features this quarter. Key differentiators: real-time transcription, sentiment analysis, and automated follow-ups.',
      'tags': ['Market'],
      'type': 'chart',
      'timestamp': '2d ago',
      'isPinned': false,
      'linkedSources': [],
    },
    {
      'id': '5',
      'title': 'Customer Renewal Preference',
      'description':
          'The client mentioned they are looking to renew their contract in Q3 but wants to discuss...',
      'detail':
          'The client mentioned they are looking to renew their contract in Q3 but wants to discuss pricing tiers before committing. Specifically interested in the enterprise volume discount.',
      'tags': ['Sales', 'High Priority'],
      'type': 'call',
      'timestamp': '3d ago',
      'isPinned': false,
      'linkedSources': [
        {
          'name': 'Q2_Meeting_Transcript.pdf',
          'uploadedAt': '2h ago',
          'size': '1.2 MB',
        },
      ],
    },
  ];

  List<Map<String, dynamic>> get _filteredMemories {
    if (_searchQuery.isEmpty) return _memories;
    final query = _searchQuery.toLowerCase();
    return _memories.where((m) {
      final title = (m['title'] as String).toLowerCase();
      final desc = (m['description'] as String).toLowerCase();
      final tags = (m['tags'] as List<String>).join(' ').toLowerCase();
      return title.contains(query) ||
          desc.contains(query) ||
          tags.contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            _buildTopBar(),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: _buildSearchBar(),
            ),

            // Memory list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filteredMemories.length,
                itemBuilder: (context, index) {
                  final memory = _filteredMemories[index];
                  return _MemoryCard(
                    memory: memory,
                    tagColors: _tagColors,
                    onTap: () => _showMemoryDetail(memory),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.chevron_left,
              color: context.textSecondary,
              size: 28,
            ),
          ),

          const Spacer(),

          // Title
          Text(
            'Memories',
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(),

          // Filter button
          GestureDetector(
            onTap: () => _showFilterSheet(),
            child: Icon(
              Icons.filter_list_outlined,
              color: context.textSecondary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.cardBorder, width: 1),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        style: TextStyle(color: context.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Search memories...',
          hintStyle: TextStyle(color: context.textSecondary.withOpacity(0.5)),
          prefixIcon: Icon(
            Icons.search,
            color: context.textSecondary.withOpacity(0.5),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: context.cardBorder, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'FILTER BY TYPE',
              style: TextStyle(
                color: context.gold,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _FilterChip(label: 'All', isSelected: true),
                _FilterChip(label: 'Calls', isSelected: false),
                _FilterChip(label: 'Documents', isSelected: false),
                _FilterChip(label: 'Notes', isSelected: false),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'FILTER BY TAG',
              style: TextStyle(
                color: context.gold,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tagColors.keys.map((tag) {
                return _FilterChip(
                  label: tag,
                  isSelected: false,
                  color: _tagColors[tag],
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showMemoryDetail(Map<String, dynamic> memory) {
    Navigator.push(
      context,
      fadeSlideRoute(
        _MemoryDetailScreen(memory: memory, tagColors: _tagColors),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? context.gold.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? context.gold : (color ?? context.cardBorder),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color ?? (isSelected ? context.gold : context.textPrimary),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _MemoryCard extends StatelessWidget {
  final Map<String, dynamic> memory;
  final Map<String, Color> tagColors;
  final VoidCallback onTap;

  const _MemoryCard({
    required this.memory,
    required this.tagColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final type = memory['type'] as String;
    final tags = memory['tags'] as List<String>;
    final isPinned = memory['isPinned'] as bool;

    IconData typeIcon;
    switch (type) {
      case 'call':
        typeIcon = Icons.phone_outlined;
        break;
      case 'document':
        typeIcon = Icons.description_outlined;
        break;
      case 'chart':
        typeIcon = Icons.insights_outlined;
        break;
      default:
        typeIcon = Icons.note_outlined;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.cardBorder, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: context.gold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(typeIcon, color: context.gold, size: 20),
                ),
                const SizedBox(width: 12),

                // Title
                Expanded(
                  child: Text(
                    memory['title'],
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Pin indicator
                if (isPinned)
                  Icon(Icons.push_pin, color: context.gold, size: 18),
              ],
            ),

            const SizedBox(height: 10),

            // Description
            Text(
              memory['description'],
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Tags and timestamp row
            Row(
              children: [
                // Tags
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags.map((tag) {
                      final tagColor = tagColors[tag] ?? context.gold;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: tagColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: tagColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: tagColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Timestamp
                Text(
                  memory['timestamp'],
                  style: TextStyle(
                    color: context.textSecondary.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== MEMORY DETAIL SCREEN ====================

class _MemoryDetailScreen extends StatefulWidget {
  final Map<String, dynamic> memory;
  final Map<String, Color> tagColors;

  const _MemoryDetailScreen({required this.memory, required this.tagColors});

  @override
  State<_MemoryDetailScreen> createState() => _MemoryDetailScreenState();
}

class _MemoryDetailScreenState extends State<_MemoryDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _detailController;
  late List<String> _tags;
  late List<Map<String, dynamic>> _linkedSources;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.memory['title']);
    _detailController = TextEditingController(text: widget.memory['detail']);
    _tags = List<String>.from(widget.memory['tags']);
    _linkedSources = List<Map<String, dynamic>>.from(
      widget.memory['linkedSources'] ?? [],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            _buildTopBar(),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Title section
                    _buildSectionLabel('TITLE / TOPIC'),
                    const SizedBox(height: 8),
                    _buildTitleField(),

                    const SizedBox(height: 24),

                    // Memory detail section
                    _buildSectionLabel('MEMORY DETAIL'),
                    const SizedBox(height: 8),
                    _buildDetailField(),

                    const SizedBox(height: 24),

                    // Tags section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionLabel('TAGS'),
                        Text(
                          '${_tags.length} active',
                          style: TextStyle(
                            color: context.textSecondary.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTagsSection(),

                    const SizedBox(height: 24),

                    // Linked sources section
                    _buildSectionLabel('LINKED SOURCES'),
                    const SizedBox(height: 12),
                    _buildLinkedSourcesSection(),

                    const SizedBox(height: 16),

                    // Action buttons
                    _buildActionButtons(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Close button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.close, color: context.textSecondary, size: 24),
          ),

          const Spacer(),

          // Title
          Text(
            'Edit Memory',
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(),

          // Save button
          GestureDetector(
            onTap: () {
              // TODO: Save memory to backend
              Navigator.pop(context);
            },
            child: Text(
              'Save',
              style: TextStyle(
                color: context.gold,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        color: context.textSecondary.withOpacity(0.7),
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildTitleField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.cardBorder, width: 1),
      ),
      child: TextField(
        controller: _titleController,
        style: TextStyle(color: context.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Enter title...',
          hintStyle: TextStyle(color: context.textSecondary.withOpacity(0.5)),
        ),
      ),
    );
  }

  Widget _buildDetailField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.cardBorder, width: 1),
      ),
      child: TextField(
        controller: _detailController,
        style: TextStyle(color: context.textPrimary, fontSize: 14, height: 1.5),
        maxLines: 6,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Enter memory details...',
          hintStyle: TextStyle(color: context.textSecondary.withOpacity(0.5)),
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        // Existing tags
        ..._tags.map((tag) {
          final tagColor = widget.tagColors[tag] ?? context.gold;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: tagColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: tagColor.withOpacity(0.4), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tag,
                  style: TextStyle(
                    color: tagColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => setState(() => _tags.remove(tag)),
                  child: Icon(Icons.close, color: tagColor, size: 16),
                ),
              ],
            ),
          );
        }),

        // Add tag button
        GestureDetector(
          onTap: () => _showAddTagDialog(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.cardBorder, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: context.textSecondary, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Add Tag',
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAddTagDialog() {
    final controller = TextEditingController();
    final availableTags = widget.tagColors.keys
        .where((tag) => !_tags.contains(tag))
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: context.cardBorder, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'ADD TAG',
                style: TextStyle(
                  color: context.gold,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),

              // Custom tag input
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.cardBorder, width: 1),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter custom tag...',
                          hintStyle: TextStyle(
                            color: context.textSecondary.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (controller.text.isNotEmpty) {
                          setState(() => _tags.add(controller.text));
                          Navigator.pop(context);
                        }
                      },
                      child: Icon(
                        Icons.add_circle,
                        color: context.gold,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              if (availableTags.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'SUGGESTED TAGS',
                  style: TextStyle(
                    color: context.textSecondary.withOpacity(0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableTags.map((tag) {
                    final tagColor = widget.tagColors[tag] ?? context.gold;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _tags.add(tag));
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: tagColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: tagColor.withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: tagColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinkedSourcesSection() {
    return Column(
      children: [
        // Existing sources
        ..._linkedSources.map((source) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.cardBorder, width: 1),
            ),
            child: Row(
              children: [
                // File icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.gold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    color: context.gold,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // File info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        source['name'],
                        style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Uploaded ${source['uploadedAt']} • ${source['size']}',
                        style: TextStyle(
                          color: context.textSecondary.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Delete button
                GestureDetector(
                  onTap: () => setState(() => _linkedSources.remove(source)),
                  child: Icon(
                    Icons.delete_outline,
                    color: context.textSecondary.withOpacity(0.5),
                    size: 22,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Upload File button
        Expanded(
          child: GestureDetector(
            onTap: () {
              // TODO: Implement file upload
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.cardBorder, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.upload_outlined,
                    color: context.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Upload File',
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Add Link button
        Expanded(
          child: GestureDetector(
            onTap: () => _showAddLinkDialog(),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.cardBorder, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.link, color: context.textSecondary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Add Link',
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddLinkDialog() {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: context.cardBorder, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'ADD LINK',
                style: TextStyle(
                  color: context.gold,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.cardBorder, width: 1),
                ),
                child: TextField(
                  controller: controller,
                  style: TextStyle(color: context.textPrimary, fontSize: 15),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Paste URL here...',
                    hintStyle: TextStyle(
                      color: context.textSecondary.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () {
                    if (controller.text.isNotEmpty) {
                      setState(() {
                        _linkedSources.add({
                          'name': controller.text,
                          'uploadedAt': 'Just now',
                          'size': 'Link',
                        });
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: context.gold,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Add Link',
                        style: TextStyle(
                          color: context.bg,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
