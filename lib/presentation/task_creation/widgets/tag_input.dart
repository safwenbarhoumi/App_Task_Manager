import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TagInput extends StatefulWidget {
  final List<String> tags;
  final ValueChanged<List<String>> onTagsChanged;

  const TagInput({
    super.key,
    required this.tags,
    required this.onTagsChanged,
  });

  @override
  State<TagInput> createState() => _TagInputState();
}

class _TagInputState extends State<TagInput> {
  final TextEditingController _tagController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  static const List<String> suggestedTags = [
    'urgent',
    'important',
    'réunion',
    'projet',
    'personnel',
    'travail',
    'santé',
    'finance',
    'éducation',
    'famille',
    'voyage',
    'sport',
    'créatif',
    'recherche',
    'développement',
  ];

  List<String> get filteredSuggestions {
    if (_tagController.text.isEmpty) return suggestedTags;

    final query = _tagController.text.toLowerCase();
    return suggestedTags
        .where((tag) =>
            tag.toLowerCase().contains(query) && !widget.tags.contains(tag))
        .toList();
  }

  @override
  void dispose() {
    _tagController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    final trimmedTag = tag.trim().toLowerCase();
    if (trimmedTag.isEmpty || widget.tags.contains(trimmedTag)) return;

    final updatedTags = [...widget.tags, trimmedTag];
    widget.onTagsChanged(updatedTags);
    _tagController.clear();
  }

  void _removeTag(String tag) {
    final updatedTags = widget.tags.where((t) => t != tag).toList();
    widget.onTagsChanged(updatedTags);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Étiquettes',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),

        // Tag input field
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'local_offer_outlined',
                size: 20,
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: TextField(
                  controller: _tagController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Ajouter une étiquette...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                  onSubmitted: _addTag,
                  onChanged: (value) => setState(() {}),
                ),
              ),
              if (_tagController.text.isNotEmpty)
                IconButton(
                  onPressed: () => _addTag(_tagController.text),
                  icon: CustomIconWidget(
                    iconName: 'add',
                    size: 20,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                  constraints: BoxConstraints(
                    minWidth: 8.w,
                    minHeight: 8.w,
                  ),
                ),
            ],
          ),
        ),

        // Tag suggestions
        if (_focusNode.hasFocus && filteredSuggestions.isNotEmpty) ...[
          SizedBox(height: 1.h),
          Container(
            constraints: BoxConstraints(maxHeight: 20.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.shadow
                      .withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredSuggestions.length,
              itemBuilder: (context, index) {
                final tag = filteredSuggestions[index];
                return ListTile(
                  dense: true,
                  leading: CustomIconWidget(
                    iconName: 'local_offer',
                    size: 16,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                  title: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                  onTap: () {
                    _addTag(tag);
                    _focusNode.unfocus();
                  },
                );
              },
            ),
          ),
        ],

        // Current tags
        if (widget.tags.isNotEmpty) ...[
          SizedBox(height: 2.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: widget.tags.map((tag) => _buildTagChip(tag)).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildTagChip(String tag) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          SizedBox(width: 1.w),
          GestureDetector(
            onTap: () => _removeTag(tag),
            child: CustomIconWidget(
              iconName: 'close',
              size: 14,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
