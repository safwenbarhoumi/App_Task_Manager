import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/attachment_section.dart';
import './widgets/category_dropdown.dart';
import './widgets/priority_selector.dart';
import './widgets/reminder_settings.dart';
import './widgets/subtask_list.dart';
import './widgets/tag_input.dart';
import './widgets/task_form_header.dart';
import './widgets/voice_input_button.dart';

class TaskCreation extends StatefulWidget {
  const TaskCreation({super.key});

  @override
  State<TaskCreation> createState() => _TaskCreationState();
}

class _TaskCreationState extends State<TaskCreation> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _scrollController = ScrollController();

  // Form data
  String _selectedPriority = 'medium';
  String? _selectedCategory;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  List<Map<String, dynamic>> _attachments = [];
  List<Map<String, dynamic>> _subtasks = [];
  List<String> _tags = [];
  List<Map<String, dynamic>> _reminders = [];
  bool _isAdvancedSectionExpanded = false;
  bool _isAutoSaveEnabled = true;

  // AI suggestions
  List<String> _aiSuggestions = [];
  bool _showAiSuggestions = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onTitleChanged);
    _loadAutoSavedData();
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
    _descriptionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTitleChanged() {
    if (_titleController.text.length > 3) {
      _generateAiSuggestions(_titleController.text);
    } else {
      setState(() {
        _showAiSuggestions = false;
        _aiSuggestions.clear();
      });
    }

    if (_isAutoSaveEnabled) {
      _autoSaveData();
    }
  }

  void _generateAiSuggestions(String title) {
    final suggestions = <String>[];
    final lowerTitle = title.toLowerCase();

    // Category suggestions
    if (lowerTitle.contains('réunion') || lowerTitle.contains('meeting')) {
      suggestions.add('Catégorie suggérée: Travail');
      suggestions.add('Priorité suggérée: Moyenne');
    } else if (lowerTitle.contains('urgent') ||
        lowerTitle.contains('important')) {
      suggestions.add('Priorité suggérée: Urgent');
      suggestions.add('Rappel suggéré: 15 minutes avant');
    } else if (lowerTitle.contains('acheter') ||
        lowerTitle.contains('shopping')) {
      suggestions.add('Catégorie suggérée: Achats');
      suggestions.add('Priorité suggérée: Faible');
    } else if (lowerTitle.contains('santé') || lowerTitle.contains('médecin')) {
      suggestions.add('Catégorie suggérée: Santé');
      suggestions.add('Priorité suggérée: Élevée');
    }

    // Due date suggestions
    if (lowerTitle.contains('demain')) {
      suggestions.add('Échéance suggérée: Demain');
    } else if (lowerTitle.contains('semaine')) {
      suggestions.add('Échéance suggérée: Dans une semaine');
    }

    setState(() {
      _aiSuggestions = suggestions;
      _showAiSuggestions = suggestions.isNotEmpty;
    });
  }

  void _loadAutoSavedData() {
    // Simulate loading auto-saved data
    // In a real app, this would load from local storage
  }

  void _autoSaveData() {
    // Simulate auto-save functionality
    // In a real app, this would save to local storage
    debugPrint('Auto-saving task data...');
  }

  bool get _isSaveEnabled {
    return _titleController.text.trim().isNotEmpty;
  }

  Future<void> _selectDueDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: AppTheme.lightTheme.colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _dueDate = pickedDate;
      });
    }
  }

  Future<void> _selectDueTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: AppTheme.lightTheme.colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _dueTime = pickedTime;
      });
    }
  }

  void _applyAiSuggestion(String suggestion) {
    if (suggestion.contains('Catégorie suggérée:')) {
      final category = suggestion.split(':')[1].trim();
      if (category == 'Travail') {
        setState(() => _selectedCategory = 'work');
      } else if (category == 'Achats') {
        setState(() => _selectedCategory = 'shopping');
      } else if (category == 'Santé') {
        setState(() => _selectedCategory = 'health');
      }
    } else if (suggestion.contains('Priorité suggérée:')) {
      final priority = suggestion.split(':')[1].trim();
      if (priority == 'Urgent') {
        setState(() => _selectedPriority = 'urgent');
      } else if (priority == 'Élevée') {
        setState(() => _selectedPriority = 'high');
      } else if (priority == 'Moyenne') {
        setState(() => _selectedPriority = 'medium');
      } else if (priority == 'Faible') {
        setState(() => _selectedPriority = 'low');
      }
    } else if (suggestion.contains('Échéance suggérée:')) {
      if (suggestion.contains('Demain')) {
        setState(() => _dueDate = DateTime.now().add(const Duration(days: 1)));
      } else if (suggestion.contains('Dans une semaine')) {
        setState(() => _dueDate = DateTime.now().add(const Duration(days: 7)));
      }
    }

    setState(() {
      _showAiSuggestions = false;
      _aiSuggestions.clear();
    });
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate() || !_isSaveEnabled) return;

    final taskData = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'priority': _selectedPriority,
      'category': _selectedCategory,
      'dueDate': _dueDate?.toIso8601String(),
      'dueTime': _dueTime != null
          ? '${_dueTime!.hour.toString().padLeft(2, '0')}:${_dueTime!.minute.toString().padLeft(2, '0')}'
          : null,
      'attachments': _attachments,
      'subtasks': _subtasks,
      'tags': _tags,
      'reminders': _reminders,
      'isCompleted': false,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    // Simulate saving task
    debugPrint('Saving task: ${taskData['title']}');

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              size: 20,
              color: Colors.white,
            ),
            SizedBox(width: 2.w),
            Text('Tâche créée avec succès!'),
          ],
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Créer une autre',
          textColor: Colors.white,
          onPressed: _resetForm,
        ),
      ),
    );

    // Navigate back or reset form
    Navigator.pop(context, taskData);
  }

  void _resetForm() {
    setState(() {
      _titleController.clear();
      _descriptionController.clear();
      _selectedPriority = 'medium';
      _selectedCategory = null;
      _dueDate = null;
      _dueTime = null;
      _attachments.clear();
      _subtasks.clear();
      _tags.clear();
      _reminders.clear();
      _isAdvancedSectionExpanded = false;
      _showAiSuggestions = false;
      _aiSuggestions.clear();
    });
  }

  void _cancelCreation() {
    if (_titleController.text.trim().isNotEmpty ||
        _descriptionController.text.trim().isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Annuler la création',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Voulez-vous vraiment annuler? Les modifications non sauvegardées seront perdues.',
            style: TextStyle(fontSize: 14.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Continuer'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.error,
              ),
              child: Text('Annuler'),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  String _formatDueDate() {
    if (_dueDate == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(_dueDate!.year, _dueDate!.month, _dueDate!.day);

    if (taskDate == today) {
      return 'Aujourd\'hui';
    } else if (taskDate == tomorrow) {
      return 'Demain';
    } else {
      return '${_dueDate!.day.toString().padLeft(2, '0')}/${_dueDate!.month.toString().padLeft(2, '0')}/${_dueDate!.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      body: Column(
        children: [
          TaskFormHeader(
            onCancel: _cancelCreation,
            onSave: _saveTask,
            isSaveEnabled: _isSaveEnabled,
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title input with voice button
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              hintText: 'Titre de la tâche...',
                              hintStyle: TextStyle(
                                fontSize: 18.sp,
                                color: AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 2.h),
                            ),
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.lightTheme.colorScheme.onSurface,
                            ),
                            maxLines: 2,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Le titre est obligatoire';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 3.w),
                        VoiceInputButton(
                          onVoiceInput: (text) {
                            setState(() {
                              _titleController.text = text;
                            });
                          },
                        ),
                      ],
                    ),

                    // AI Suggestions
                    if (_showAiSuggestions) ...[
                      Container(
                        margin: EdgeInsets.only(bottom: 2.h),
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.primary
                                .withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'auto_awesome',
                                  size: 18,
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'Suggestions IA',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1.h),
                            ..._aiSuggestions.map((suggestion) =>
                                GestureDetector(
                                  onTap: () => _applyAiSuggestion(suggestion),
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 0.5.h),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 2.w, vertical: 0.5.h),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        CustomIconWidget(
                                          iconName: 'lightbulb_outline',
                                          size: 14,
                                          color: AppTheme
                                              .lightTheme.colorScheme.secondary,
                                        ),
                                        SizedBox(width: 2.w),
                                        Expanded(
                                          child: Text(
                                            suggestion,
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: AppTheme.lightTheme
                                                  .colorScheme.onSurface,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        hintText: 'Description (optionnelle)...',
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.all(4.w),
                      ),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                      maxLines: 3,
                      minLines: 1,
                    ),

                    SizedBox(height: 3.h),

                    // Due date and time
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _selectDueDate,
                            child: Container(
                              padding: EdgeInsets.all(4.w),
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
                                    iconName: 'calendar_today',
                                    size: 20,
                                    color: _dueDate != null
                                        ? AppTheme
                                            .lightTheme.colorScheme.primary
                                        : AppTheme
                                            .lightTheme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(
                                    _dueDate != null
                                        ? _formatDueDate()
                                        : 'Date d\'échéance',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: _dueDate != null
                                          ? AppTheme
                                              .lightTheme.colorScheme.onSurface
                                          : AppTheme
                                              .lightTheme.colorScheme.onSurface
                                              .withValues(alpha: 0.6),
                                      fontWeight: _dueDate != null
                                          ? FontWeight.w500
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: GestureDetector(
                            onTap: _selectDueTime,
                            child: Container(
                              padding: EdgeInsets.all(4.w),
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
                                    iconName: 'access_time',
                                    size: 20,
                                    color: _dueTime != null
                                        ? AppTheme
                                            .lightTheme.colorScheme.primary
                                        : AppTheme
                                            .lightTheme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(
                                    _dueTime != null
                                        ? '${_dueTime!.hour.toString().padLeft(2, '0')}:${_dueTime!.minute.toString().padLeft(2, '0')}'
                                        : 'Heure',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: _dueTime != null
                                          ? AppTheme
                                              .lightTheme.colorScheme.onSurface
                                          : AppTheme
                                              .lightTheme.colorScheme.onSurface
                                              .withValues(alpha: 0.6),
                                      fontWeight: _dueTime != null
                                          ? FontWeight.w500
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 3.h),

                    // Priority selector
                    PrioritySelector(
                      selectedPriority: _selectedPriority,
                      onPriorityChanged: (priority) {
                        setState(() {
                          _selectedPriority = priority;
                        });
                      },
                    ),

                    SizedBox(height: 3.h),

                    // Category dropdown
                    CategoryDropdown(
                      selectedCategory: _selectedCategory,
                      onCategoryChanged: (category) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                    ),

                    SizedBox(height: 3.h),

                    // Advanced section toggle
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isAdvancedSectionExpanded =
                              !_isAdvancedSectionExpanded;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(3.w),
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
                              iconName: 'tune',
                              size: 20,
                              color: AppTheme.lightTheme.colorScheme.primary,
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Text(
                                'Options avancées',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      AppTheme.lightTheme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            AnimatedRotation(
                              turns: _isAdvancedSectionExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: CustomIconWidget(
                                iconName: 'keyboard_arrow_down',
                                size: 20,
                                color: AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Advanced section content
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: _isAdvancedSectionExpanded ? null : 0,
                      child: _isAdvancedSectionExpanded
                          ? Column(
                              children: [
                                SizedBox(height: 3.h),

                                // Attachments
                                AttachmentSection(
                                  attachments: _attachments,
                                  onAttachmentsChanged: (attachments) {
                                    setState(() {
                                      _attachments = attachments;
                                    });
                                  },
                                ),

                                SizedBox(height: 3.h),

                                // Subtasks
                                SubtaskList(
                                  subtasks: _subtasks,
                                  onSubtasksChanged: (subtasks) {
                                    setState(() {
                                      _subtasks = subtasks;
                                    });
                                  },
                                ),

                                SizedBox(height: 3.h),

                                // Tags
                                TagInput(
                                  tags: _tags,
                                  onTagsChanged: (tags) {
                                    setState(() {
                                      _tags = tags;
                                    });
                                  },
                                ),

                                SizedBox(height: 3.h),

                                // Reminders
                                ReminderSettings(
                                  reminders: _reminders,
                                  onRemindersChanged: (reminders) {
                                    setState(() {
                                      _reminders = reminders;
                                    });
                                  },
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),

                    SizedBox(height: 4.h),

                    // Quick templates
                    Text(
                      'Modèles rapides',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildQuickTemplate(
                            'Réunion',
                            'work',
                            'medium',
                            ['réunion', 'travail'],
                          ),
                          SizedBox(width: 2.w),
                          _buildQuickTemplate(
                            'Appel client',
                            'work',
                            'high',
                            ['client', 'appel'],
                          ),
                          SizedBox(width: 2.w),
                          _buildQuickTemplate(
                            'Courses',
                            'shopping',
                            'low',
                            ['courses', 'achats'],
                          ),
                          SizedBox(width: 2.w),
                          _buildQuickTemplate(
                            'Rendez-vous médical',
                            'health',
                            'high',
                            ['santé', 'médecin'],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 6.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTemplate(
      String title, String category, String priority, List<String> tags) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _titleController.text = title;
          _selectedCategory = category;
          _selectedPriority = priority;
          _tags = tags;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: 'flash_on',
              size: 20,
              color: AppTheme.lightTheme.colorScheme.secondary,
            ),
            SizedBox(height: 0.5.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
