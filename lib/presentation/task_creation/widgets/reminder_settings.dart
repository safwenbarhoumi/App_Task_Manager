import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ReminderSettings extends StatefulWidget {
  final List<Map<String, dynamic>> reminders;
  final ValueChanged<List<Map<String, dynamic>>> onRemindersChanged;

  const ReminderSettings({
    super.key,
    required this.reminders,
    required this.onRemindersChanged,
  });

  @override
  State<ReminderSettings> createState() => _ReminderSettingsState();
}

class _ReminderSettingsState extends State<ReminderSettings> {
  static const List<Map<String, dynamic>> reminderOptions = [
    {
      'value': '5min',
      'label': '5 minutes avant',
      'minutes': 5,
      'icon': 'notifications_active',
    },
    {
      'value': '15min',
      'label': '15 minutes avant',
      'minutes': 15,
      'icon': 'schedule',
    },
    {
      'value': '30min',
      'label': '30 minutes avant',
      'minutes': 30,
      'icon': 'access_time',
    },
    {
      'value': '1hour',
      'label': '1 heure avant',
      'minutes': 60,
      'icon': 'watch_later',
    },
    {
      'value': '1day',
      'label': '1 jour avant',
      'minutes': 1440,
      'icon': 'today',
    },
    {
      'value': '1week',
      'label': '1 semaine avant',
      'minutes': 10080,
      'icon': 'date_range',
    },
  ];

  void _toggleReminder(Map<String, dynamic> option) {
    final existingIndex =
        widget.reminders.indexWhere((r) => r['value'] == option['value']);

    List<Map<String, dynamic>> updatedReminders;

    if (existingIndex >= 0) {
      // Remove existing reminder
      updatedReminders = [...widget.reminders];
      updatedReminders.removeAt(existingIndex);
    } else {
      // Add new reminder
      final newReminder = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'value': option['value'],
        'label': option['label'],
        'minutes': option['minutes'],
        'isEnabled': true,
        'createdAt': DateTime.now().toIso8601String(),
      };
      updatedReminders = [...widget.reminders, newReminder];
    }

    widget.onRemindersChanged(updatedReminders);
  }

  void _addCustomReminder() {
    showDialog(
      context: context,
      builder: (context) => _CustomReminderDialog(
        onReminderAdded: (reminder) {
          final updatedReminders = [...widget.reminders, reminder];
          widget.onRemindersChanged(updatedReminders);
        },
      ),
    );
  }

  void _removeReminder(String id) {
    final updatedReminders =
        widget.reminders.where((r) => r['id'] != id).toList();
    widget.onRemindersChanged(updatedReminders);
  }

  bool _isReminderSelected(String value) {
    return widget.reminders.any((r) => r['value'] == value);
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
              'Rappels',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            TextButton.icon(
              onPressed: _addCustomReminder,
              icon: CustomIconWidget(
                iconName: 'add',
                size: 16,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              label: Text(
                'Personnalisé',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),

        // Quick reminder options
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: reminderOptions.map((option) {
            final isSelected = _isReminderSelected(option['value']);
            return GestureDetector(
              onTap: () => _toggleReminder(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: option['icon'],
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      option['label'],
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        // Active reminders list
        if (widget.reminders.isNotEmpty) ...[
          SizedBox(height: 2.h),
          Text(
            'Rappels actifs',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: 1.h),
          ...widget.reminders.map((reminder) => _buildReminderItem(reminder)),
        ],
      ],
    );
  }

  Widget _buildReminderItem(Map<String, dynamic> reminder) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'notifications',
            size: 18,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              reminder['label'] ?? 'Rappel personnalisé',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _removeReminder(reminder['id']),
            icon: CustomIconWidget(
              iconName: 'close',
              size: 16,
              color: AppTheme.lightTheme.colorScheme.error,
            ),
            constraints: BoxConstraints(
              minWidth: 8.w,
              minHeight: 8.w,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomReminderDialog extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onReminderAdded;

  const _CustomReminderDialog({
    required this.onReminderAdded,
  });

  @override
  State<_CustomReminderDialog> createState() => _CustomReminderDialogState();
}

class _CustomReminderDialogState extends State<_CustomReminderDialog> {
  int _selectedValue = 10;
  String _selectedUnit = 'minutes';

  final List<String> _units = ['minutes', 'heures', 'jours'];
  final Map<String, int> _unitMultipliers = {
    'minutes': 1,
    'heures': 60,
    'jours': 1440,
  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Rappel personnalisé',
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Valeur',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedValue = int.tryParse(value) ?? 10;
                    });
                  },
                  controller:
                      TextEditingController(text: _selectedValue.toString()),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  value: _selectedUnit,
                  decoration: const InputDecoration(
                    labelText: 'Unité',
                    border: OutlineInputBorder(),
                  ),
                  items: _units.map((unit) {
                    return DropdownMenuItem(
                      value: unit,
                      child: Text(unit),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedUnit = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Rappel: $_selectedValue $_selectedUnit avant',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            final totalMinutes =
                _selectedValue * _unitMultipliers[_selectedUnit]!;
            final reminder = {
              'id': DateTime.now().millisecondsSinceEpoch.toString(),
              'value': 'custom_${totalMinutes}min',
              'label': '$_selectedValue $_selectedUnit avant',
              'minutes': totalMinutes,
              'isEnabled': true,
              'createdAt': DateTime.now().toIso8601String(),
            };

            widget.onReminderAdded(reminder);
            Navigator.pop(context);
          },
          child: Text('Ajouter'),
        ),
      ],
    );
  }
}
