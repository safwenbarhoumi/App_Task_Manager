import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/activity_log_widget.dart';
import './widgets/attachments_widget.dart';
import './widgets/comments_widget.dart';
import './widgets/subtasks_widget.dart';
import './widgets/task_header_widget.dart';
import './widgets/task_info_widget.dart';

class TaskDetail extends StatefulWidget {
  const TaskDetail({super.key});

  @override
  State<TaskDetail> createState() => _TaskDetailState();
}

class _TaskDetailState extends State<TaskDetail> {
  bool _isEditMode = false;
  bool _isLoading = false;

  // Mock task data
  Map<String, dynamic> _taskData = {
    "id": 1,
    "title": "Finaliser la présentation client Q4",
    "description":
        "Préparer et finaliser la présentation trimestrielle pour le client principal. Inclure les métriques de performance, les objectifs atteints et les projections pour le prochain trimestre. Coordonner avec l'équipe marketing pour les visuels et avec l'équipe commerciale pour les données de vente.",
    "dueDate": DateTime.now().add(const Duration(days: 3)),
    "priority": "high",
    "category": "Travail",
    "tags": ["Présentation", "Client", "Q4", "Urgent"],
    "isCompleted": false,
    "createdAt": DateTime.now().subtract(const Duration(days: 5)),
    "assignedTo": "Marie Dubois",
    "estimatedDuration": "4 heures",
  };

  List<Map<String, dynamic>> _attachments = [
    {
      "id": 1,
      "type": "image",
      "name": "mockup_presentation.jpg",
      "url":
          "https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400&h=300&fit=crop",
      "size": 2048576,
      "createdAt": "2025-08-01T10:30:00Z",
    },
    {
      "id": 2,
      "type": "pdf",
      "name": "rapport_q3.pdf",
      "url": null,
      "size": 1024000,
      "createdAt": "2025-08-01T14:15:00Z",
    },
    {
      "id": 3,
      "type": "document",
      "name": "notes_reunion.docx",
      "url": null,
      "size": 512000,
      "createdAt": "2025-08-02T09:45:00Z",
    },
  ];

  List<Map<String, dynamic>> _subtasks = [
    {
      "id": 1,
      "title": "Collecter les données de performance Q3",
      "isCompleted": true,
      "createdAt": "2025-07-30T08:00:00Z",
    },
    {
      "id": 2,
      "title": "Créer les graphiques et visualisations",
      "isCompleted": true,
      "createdAt": "2025-07-31T10:30:00Z",
    },
    {
      "id": 3,
      "title": "Rédiger le résumé exécutif",
      "isCompleted": false,
      "createdAt": "2025-08-01T14:00:00Z",
    },
    {
      "id": 4,
      "title": "Réviser avec l'équipe marketing",
      "isCompleted": false,
      "createdAt": "2025-08-01T16:20:00Z",
    },
    {
      "id": 5,
      "title": "Préparer les slides de conclusion",
      "isCompleted": false,
      "createdAt": "2025-08-02T11:15:00Z",
    },
  ];

  List<Map<String, dynamic>> _comments = [
    {
      "id": 1,
      "author": "Jean Martin",
      "content":
          "N'oublie pas d'inclure les métriques de satisfaction client dans la présentation. Le client y accorde beaucoup d'importance.",
      "timestamp": "2025-08-02T09:30:00Z",
      "avatarUrl":
          "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face",
    },
    {
      "id": 2,
      "author": "Sophie Laurent",
      "content":
          "Les graphiques sont prêts ! Je les ai envoyés par email. Peux-tu confirmer qu'ils correspondent à tes attentes ?",
      "timestamp": "2025-08-02T14:45:00Z",
      "avatarUrl":
          "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100&h=100&fit=crop&crop=face",
    },
    {
      "id": 3,
      "author": "Marie Dubois",
      "content":
          "Parfait ! J'ai intégré les graphiques. La présentation prend forme. Il ne reste plus que la partie projections à finaliser.",
      "timestamp": "2025-08-02T16:20:00Z",
      "avatarUrl":
          "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop&crop=face",
    },
  ];

  List<Map<String, dynamic>> _activities = [
    {
      "id": 1,
      "action": "a créé la tâche",
      "user": "Marie Dubois",
      "timestamp": "2025-07-29T08:00:00Z",
      "type": "created",
      "details": "Tâche créée avec priorité élevée",
    },
    {
      "id": 2,
      "action": "a ajouté une pièce jointe",
      "user": "Sophie Laurent",
      "timestamp": "2025-08-01T10:30:00Z",
      "type": "attachment",
      "details": "mockup_presentation.jpg",
    },
    {
      "id": 3,
      "action": "a terminé une sous-tâche",
      "user": "Marie Dubois",
      "timestamp": "2025-08-01T15:20:00Z",
      "type": "completed",
      "details": "Collecter les données de performance Q3",
    },
    {
      "id": 4,
      "action": "a ajouté un commentaire",
      "user": "Jean Martin",
      "timestamp": "2025-08-02T09:30:00Z",
      "type": "commented",
      "details": "Suggestion sur les métriques client",
    },
    {
      "id": 5,
      "action": "a modifié la description",
      "user": "Marie Dubois",
      "timestamp": "2025-08-02T11:45:00Z",
      "type": "updated",
      "details": "Ajout de détails sur la coordination équipe",
    },
    {
      "id": 6,
      "action": "a terminé une sous-tâche",
      "user": "Sophie Laurent",
      "timestamp": "2025-08-02T14:30:00Z",
      "type": "completed",
      "details": "Créer les graphiques et visualisations",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      body: Column(
        children: [
          TaskHeaderWidget(
            taskTitle: _taskData['title'] ?? 'Tâche sans titre',
            onBackPressed: () => Navigator.pop(context),
            onEditPressed: _toggleEditMode,
            onMorePressed: _showMoreOptions,
          ),
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        TaskInfoWidget(
                          title: _taskData['title'] ?? '',
                          description: _taskData['description'] ?? '',
                          dueDate: _taskData['dueDate'],
                          priority: _taskData['priority'] ?? 'medium',
                          category: _taskData['category'] ?? 'Général',
                          tags: (_taskData['tags'] as List?)?.cast<String>() ??
                              [],
                          isCompleted: _taskData['isCompleted'] ?? false,
                          isEditMode: _isEditMode,
                          onTitleChanged: _updateTitle,
                          onDescriptionChanged: _updateDescription,
                          onDueDateChanged: _updateDueDate,
                          onPriorityChanged: _updatePriority,
                          onCompletionChanged: _updateCompletion,
                        ),
                        AttachmentsWidget(
                          attachments: _attachments,
                          isEditMode: _isEditMode,
                          onAttachmentAdded: _addAttachment,
                          onAttachmentRemoved: _removeAttachment,
                        ),
                        SubtasksWidget(
                          subtasks: _subtasks,
                          isEditMode: _isEditMode,
                          onSubtaskAdded: _addSubtask,
                          onSubtaskToggled: _toggleSubtask,
                          onSubtaskRemoved: _removeSubtask,
                        ),
                        CommentsWidget(
                          comments: _comments,
                          isEditMode: _isEditMode,
                          onCommentAdded: _addComment,
                        ),
                        ActivityLogWidget(
                          activities: _activities,
                        ),
                        SizedBox(height: 10.h),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: _isEditMode ? _buildSaveButton() : null,
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
          SizedBox(height: 2.h),
          Text(
            'Chargement des détails...',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return FloatingActionButton.extended(
      onPressed: _saveChanges,
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      foregroundColor: Colors.white,
      icon: CustomIconWidget(
        iconName: 'save',
        color: Colors.white,
        size: 20,
      ),
      label: const Text('Sauvegarder'),
    );
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });

    if (_isEditMode) {
      HapticFeedback.lightImpact();
    }
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Options de la tâche',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 3.h),
            _buildOptionTile(
              icon: 'share',
              title: 'Partager',
              onTap: _shareTask,
            ),
            _buildOptionTile(
              icon: 'content_copy',
              title: 'Dupliquer',
              onTap: _duplicateTask,
            ),
            _buildOptionTile(
              icon: 'delete',
              title: 'Supprimer',
              onTap: _deleteTask,
              isDestructive: true,
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required String icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: isDestructive
              ? AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.1)
              : AppTheme.lightTheme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomIconWidget(
          iconName: icon,
          color: isDestructive
              ? AppTheme.lightTheme.colorScheme.error
              : AppTheme.lightTheme.colorScheme.primary,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: isDestructive
              ? AppTheme.lightTheme.colorScheme.error
              : AppTheme.lightTheme.colorScheme.onSurface,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _updateTitle(String title) {
    setState(() {
      _taskData['title'] = title;
    });
    _addActivity('a modifié le titre', 'updated', 'Nouveau titre: $title');
  }

  void _updateDescription(String description) {
    setState(() {
      _taskData['description'] = description;
    });
    _addActivity('a modifié la description', 'updated');
  }

  void _updateDueDate(DateTime? dueDate) {
    setState(() {
      _taskData['dueDate'] = dueDate;
    });
    _addActivity(
        'a modifié l\'échéance',
        'due_date',
        dueDate != null
            ? '${dueDate.day}/${dueDate.month}/${dueDate.year}'
            : 'Échéance supprimée');
  }

  void _updatePriority(String priority) {
    setState(() {
      _taskData['priority'] = priority;
    });
    _addActivity(
        'a modifié la priorité', 'priority', 'Nouvelle priorité: $priority');
  }

  void _updateCompletion(bool isCompleted) {
    setState(() {
      _taskData['isCompleted'] = isCompleted;
    });
    _addActivity(
        isCompleted
            ? 'a marqué la tâche comme terminée'
            : 'a marqué la tâche comme non terminée',
        isCompleted ? 'completed' : 'updated');

    HapticFeedback.mediumImpact();
  }

  void _addAttachment(Map<String, dynamic> attachment) {
    setState(() {
      _attachments.add(attachment);
    });
    _addActivity('a ajouté une pièce jointe', 'attachment', attachment['name']);
  }

  void _removeAttachment(int index) {
    if (index >= 0 && index < _attachments.length) {
      final attachment = _attachments[index];
      setState(() {
        _attachments.removeAt(index);
      });
      _addActivity(
          'a supprimé une pièce jointe', 'attachment', attachment['name']);
    }
  }

  void _addSubtask(Map<String, dynamic> subtask) {
    setState(() {
      _subtasks.add(subtask);
    });
    _addActivity('a ajouté une sous-tâche', 'updated', subtask['title']);
  }

  void _toggleSubtask(int index, bool isCompleted) {
    if (index >= 0 && index < _subtasks.length) {
      setState(() {
        _subtasks[index]['isCompleted'] = isCompleted;
      });
      _addActivity(
          isCompleted
              ? 'a terminé une sous-tâche'
              : 'a marqué une sous-tâche comme non terminée',
          isCompleted ? 'completed' : 'updated',
          _subtasks[index]['title']);

      HapticFeedback.lightImpact();
    }
  }

  void _removeSubtask(int index) {
    if (index >= 0 && index < _subtasks.length) {
      final subtask = _subtasks[index];
      setState(() {
        _subtasks.removeAt(index);
      });
      _addActivity('a supprimé une sous-tâche', 'updated', subtask['title']);
    }
  }

  void _addComment(String content) {
    final comment = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'author': 'Vous',
      'content': content,
      'timestamp': DateTime.now().toIso8601String(),
      'avatarUrl': null,
    };

    setState(() {
      _comments.add(comment);
    });
    _addActivity('a ajouté un commentaire', 'commented');
  }

  void _addActivity(String action, String type, [String? details]) {
    final activity = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'action': action,
      'user': 'Vous',
      'timestamp': DateTime.now().toIso8601String(),
      'type': type,
      'details': details,
    };

    setState(() {
      _activities.insert(0, activity);
    });
  }

  void _saveChanges() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
      _isEditMode = false;
    });

    _addActivity('a sauvegardé les modifications', 'updated');

    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Modifications sauvegardées avec succès'),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _shareTask() {
    final taskInfo = '''
Tâche: ${_taskData['title']}
Description: ${_taskData['description']}
Priorité: ${_taskData['priority']}
Échéance: ${_taskData['dueDate'] != null ? '${_taskData['dueDate'].day}/${_taskData['dueDate'].month}/${_taskData['dueDate'].year}' : 'Non définie'}
Statut: ${_taskData['isCompleted'] ? 'Terminée' : 'En cours'}
''';

    // Platform-specific sharing would be implemented here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            const Text('Fonctionnalité de partage disponible prochainement'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _duplicateTask() {
    Navigator.pushNamed(context, '/task-creation');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Redirection vers la création de tâche'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _deleteTask() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la tâche'),
        content: const Text(
            'Êtes-vous sûr de vouloir supprimer cette tâche ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Tâche supprimée'),
                  backgroundColor: AppTheme.lightTheme.colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
