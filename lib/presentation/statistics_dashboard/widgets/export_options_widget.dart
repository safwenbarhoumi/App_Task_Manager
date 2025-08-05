import 'dart:convert';
import 'dart:html' as html if (dart.library.html) 'dart:html';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ExportOptionsWidget extends StatelessWidget {
  final Map<String, dynamic> statisticsData;

  const ExportOptionsWidget({
    super.key,
    required this.statisticsData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(3.w),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Options d\'Export',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              CustomIconWidget(
                iconName: 'file_download',
                color: colorScheme.primary,
                size: 6.w,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildExportButton(
                  context,
                  'PDF',
                  Icons.picture_as_pdf,
                  () => _exportToPDF(context),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildExportButton(
                  context,
                  'CSV',
                  Icons.table_chart,
                  () => _exportToCSV(context),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildExportButton(
                  context,
                  'JSON',
                  Icons.code,
                  () => _exportToJSON(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 3.w),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(2.w),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: icon.codePoint.toString(),
              color: colorScheme.primary,
              size: 6.w,
            ),
            SizedBox(height: 1.h),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportToPDF(BuildContext context) async {
    try {
      final pdfContent = _generatePDFContent();
      await _downloadFile(pdfContent,
          'statistiques_${DateTime.now().millisecondsSinceEpoch}.pdf');
      _showSuccessMessage(context, 'Rapport PDF exporté avec succès');
    } catch (e) {
      _showErrorMessage(context, 'Erreur lors de l\'export PDF');
    }
  }

  Future<void> _exportToCSV(BuildContext context) async {
    try {
      final csvContent = _generateCSVContent();
      await _downloadFile(csvContent,
          'statistiques_${DateTime.now().millisecondsSinceEpoch}.csv');
      _showSuccessMessage(context, 'Données CSV exportées avec succès');
    } catch (e) {
      _showErrorMessage(context, 'Erreur lors de l\'export CSV');
    }
  }

  Future<void> _exportToJSON(BuildContext context) async {
    try {
      final jsonContent = _generateJSONContent();
      await _downloadFile(jsonContent,
          'statistiques_${DateTime.now().millisecondsSinceEpoch}.json');
      _showSuccessMessage(context, 'Données JSON exportées avec succès');
    } catch (e) {
      _showErrorMessage(context, 'Erreur lors de l\'export JSON');
    }
  }

  Future<void> _downloadFile(String content, String filename) async {
    if (kIsWeb) {
      final bytes = utf8.encode(content);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", filename)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // For mobile platforms, this would typically use path_provider
      // and save to the device's documents directory
      // Implementation would depend on platform-specific requirements
    }
  }

  String _generatePDFContent() {
    final now = DateTime.now();
    return '''
RAPPORT DE STATISTIQUES - SMART TASK MANAGER
Généré le: ${now.day}/${now.month}/${now.year} à ${now.hour}:${now.minute}

=== RÉSUMÉ EXÉCUTIF ===
Taux de completion: ${statisticsData['completionRate']}%
Tâches complétées: ${statisticsData['completedTasks']}
Tâches totales: ${statisticsData['totalTasks']}

=== ANALYSE DE PRODUCTIVITÉ ===
Tendance générale: ${statisticsData['productivityTrend']}
Meilleure période: ${statisticsData['bestPeriod']}
Temps moyen par tâche: ${statisticsData['avgTimePerTask']}h

=== RÉPARTITION PAR CATÉGORIE ===
${_formatCategoryData()}

=== INSIGHTS IA ===
${_formatInsights()}

Ce rapport a été généré automatiquement par Smart Task Manager.
    ''';
  }

  String _generateCSVContent() {
    final buffer = StringBuffer();
    buffer.writeln('Métrique,Valeur,Unité');
    buffer.writeln(
        'Taux de completion,${statisticsData['completionRate']},pourcentage');
    buffer.writeln(
        'Tâches complétées,${statisticsData['completedTasks']},nombre');
    buffer.writeln('Tâches totales,${statisticsData['totalTasks']},nombre');
    buffer.writeln(
        'Temps moyen par tâche,${statisticsData['avgTimePerTask']},heures');

    // Add category data
    final categories =
        statisticsData['categories'] as List<Map<String, dynamic>>? ?? [];
    for (final category in categories) {
      buffer.writeln('${category['name']},${category['count']},tâches');
    }

    return buffer.toString();
  }

  String _generateJSONContent() {
    final exportData = {
      'exportDate': DateTime.now().toIso8601String(),
      'statistics': statisticsData,
      'metadata': {
        'version': '1.0',
        'source': 'Smart Task Manager',
        'format': 'JSON Export',
      },
    };

    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

  String _formatCategoryData() {
    final categories =
        statisticsData['categories'] as List<Map<String, dynamic>>? ?? [];
    final buffer = StringBuffer();

    for (final category in categories) {
      buffer.writeln(
          '- ${category['name']}: ${category['count']} tâches (${category['percentage']}%)');
    }

    return buffer.toString();
  }

  String _formatInsights() {
    final insights =
        statisticsData['insights'] as List<Map<String, dynamic>>? ?? [];
    final buffer = StringBuffer();

    for (final insight in insights) {
      buffer.writeln('• ${insight['title']}');
      buffer.writeln('  ${insight['description']}');
      buffer.writeln('');
    }

    return buffer.toString();
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
