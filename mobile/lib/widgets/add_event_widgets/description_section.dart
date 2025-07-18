import 'package:flutter/material.dart';

class DescriptionSection extends StatefulWidget {
  final Map<String, String>? description;
  final Function(Map<String, String>?) onDescriptionChanged;

  const DescriptionSection({
    super.key,
    this.description,
    required this.onDescriptionChanged,
  });

  @override
  State<DescriptionSection> createState() => _DescriptionSectionState();
}

class _DescriptionSectionState extends State<DescriptionSection>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _englishController;
  late TextEditingController _spanishController;
  bool _showDescription = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _englishController = TextEditingController(text: widget.description?['en'] ?? '');
    _spanishController = TextEditingController(text: widget.description?['es'] ?? '');
    // Show form if description already exists
    _showDescription = widget.description != null;
  }

  @override
  void dispose() {
    _englishController.dispose();
    _spanishController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _saveDescription() {
    final englishText = _englishController.text.trim();
    final spanishText = _spanishController.text.trim();

    // If both languages are empty, save as null
    if (englishText.isEmpty && spanishText.isEmpty) {
      widget.onDescriptionChanged(null);
      return;
    }

    // Create description map with non-empty values
    final description = <String, String>{};
    if (englishText.isNotEmpty) {
      description['en'] = englishText;
    }
    if (spanishText.isNotEmpty) {
      description['es'] = spanishText;
    }

    widget.onDescriptionChanged(description);
  }

  void _clearDescription() {
    _formKey.currentState!.reset();
    _englishController.clear();
    _spanishController.clear();
    widget.onDescriptionChanged(null);
  }

  void _toggleDescription(bool? value) {
    setState(() {
      _showDescription = value ?? false;
    });
    
    if (!_showDescription) {
      // Clear description when unchecking
      _clearDescription();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Description',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 14,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            Row(
              children: [
                if (_showDescription && widget.description != null)
                  TextButton(
                    onPressed: _clearDescription,
                    child: const Text('Clear'),
                  ),
                Checkbox(
                  value: _showDescription,
                  onChanged: _toggleDescription,
                ),
              ],
            ),
          ],
        ),
        if (_showDescription) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Theme.of(context).colorScheme.onSecondaryContainer,
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  tabs: const [
                    Tab(text: 'EN'),
                    Tab(text: 'ES'),
                  ],
                ),
                SizedBox(
                  height: 200,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDescriptionField(
                        controller: _englishController,
                        hint: 'Enter description in English',
                        onChanged: (_) => _saveDescription(),
                      ),
                      _buildDescriptionField(
                        controller: _spanishController,
                        hint: 'Enter description in Spanish',
                        onChanged: (_) => _saveDescription(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDescriptionField({
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
} 