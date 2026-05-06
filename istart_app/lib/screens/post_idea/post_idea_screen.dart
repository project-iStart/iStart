// lib/screens/post_idea/post_idea_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/startup_idea.dart';
import '../../providers/idea_provider.dart';

class PostIdeaScreen extends StatefulWidget {
  final StartupIdea? idea; // null = create mode, non-null = edit mode

  const PostIdeaScreen({super.key, this.idea});

  @override
  State<PostIdeaScreen> createState() => _PostIdeaScreenState();
}

class _PostIdeaScreenState extends State<PostIdeaScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _problemController = TextEditingController();

  String? _selectedCategory;
  String? _selectedStage;
  bool _loading = false;

  static const _categories = [
    'Tech', 'Health', 'Finance', 'Education', 'Social', 'Other'
  ];

  static const _stages = ['Idea', 'MVP', 'Growth', 'Scaling'];

  bool get _isEditMode => widget.idea != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _titleController.text = widget.idea!.title;
      _descController.text = widget.idea!.description;
      _problemController.text = widget.idea!.problemStatement ?? '';
      _selectedCategory = widget.idea!.category;
      _selectedStage = widget.idea!.stage;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _problemController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and description are required')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final provider = context.read<IdeaProvider>();

      if (_isEditMode) {
        await provider.updateIdea(
          ideaId: widget.idea!.id,
          title: title,
          description: desc,
          problemStatement: _problemController.text.trim().isEmpty
              ? null
              : _problemController.text.trim(),
          category: _selectedCategory,
          stage: _selectedStage,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Idea updated!')),
          );
          Navigator.pop(context);
        }
      } else {
        await provider.createIdea(
          title: title,
          description: desc,
          problemStatement: _problemController.text.trim().isEmpty
              ? null
              : _problemController.text.trim(),
          category: _selectedCategory,
          stage: _selectedStage,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Idea posted!')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontFamily: 'DM Sans')),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontFamily: 'DM Sans'),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF1A1A2E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFF6366F1), width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required String? value,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontFamily: 'DM Sans')),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          dropdownColor: const Color(0xFF1A1A2E),
          style: const TextStyle(color: Colors.white, fontFamily: 'DM Sans'),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1A1A2E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          hint: const Text('Select',
              style: TextStyle(color: Colors.white38)),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        title: Text(
          _isEditMode ? 'Edit Idea' : 'Post Idea',
          style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Sora',
              fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField(
              label: 'Title *',
              controller: _titleController,
              hint: 'e.g. AI-powered tutor app',
            ),
            _buildField(
              label: 'Description *',
              controller: _descController,
              maxLines: 4,
              hint: 'Describe your startup idea...',
            ),
            _buildField(
              label: 'Problem Statement',
              controller: _problemController,
              maxLines: 3,
              hint: 'What problem does this solve?',
            ),
            _buildDropdown(
              label: 'Category',
              items: _categories,
              value: _selectedCategory,
              onChanged: (v) => setState(() => _selectedCategory = v),
            ),
            _buildDropdown(
              label: 'Stage',
              items: _stages,
              value: _selectedStage,
              onChanged: (v) => setState(() => _selectedStage = v),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isEditMode ? 'Update Idea' : 'Post Idea',
                        style: const TextStyle(
                            fontFamily: 'Sora',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}