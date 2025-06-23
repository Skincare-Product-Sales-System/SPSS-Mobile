import 'package:shopsmart_users_en/models/skin_analysis_models.dart';
import 'package:shopsmart_users_en/models/view_state.dart';

/// Enum định nghĩa các loại da
enum SkinType { dry, oily, combination, normal, sensitive, unknown }

/// Class mở rộng cho SkinConcern
class SkinConcern {
  final String name;
  final String type;
  final String description;
  final int severity;

  const SkinConcern({
    required this.name,
    required this.type,
    required this.description,
    required this.severity,
  });

  factory SkinConcern.fromSkinIssue(SkinIssue issue) {
    String type = 'unknown';
    if (issue.issueName.toLowerCase().contains('acne')) {
      type = 'acne';
    } else if (issue.issueName.toLowerCase().contains('wrinkle')) {
      type = 'wrinkles';
    } else if (issue.issueName.toLowerCase().contains('dark spot')) {
      type = 'pigmentation';
    } else if (issue.issueName.toLowerCase().contains('dry')) {
      type = 'dryness';
    } else if (issue.issueName.toLowerCase().contains('oil')) {
      type = 'oiliness';
    } else if (issue.issueName.toLowerCase().contains('sensitive')) {
      type = 'sensitivity';
    } else if (issue.issueName.toLowerCase().contains('red')) {
      type = 'redness';
    }

    return SkinConcern(
      name: issue.issueName,
      type: type,
      description: issue.description,
      severity: issue.severity,
    );
  }
}

/// Class mở rộng cho RoutineStep
class RoutineStep {
  final String name;
  final String description;
  final int order;

  const RoutineStep({
    required this.name,
    required this.description,
    required this.order,
  });
}

/// Class mở rộng cho SkinCareRoutine
class SkinCareRoutine {
  final List<RoutineStep> morning;
  final List<RoutineStep> evening;
  final List<RoutineStep> weekly;

  const SkinCareRoutine({
    required this.morning,
    required this.evening,
    required this.weekly,
  });
}

/// Mở rộng class SkinAnalysisResult
extension SkinAnalysisResultExtension on SkinAnalysisResult {
  /// Ngày phân tích (giả định là ngày hiện tại)
  DateTime get analysisDate => DateTime.now();

  /// Loại da
  SkinType get skinType {
    final type = skinCondition.skinType.toLowerCase();
    if (type.contains('dry')) {
      return SkinType.dry;
    } else if (type.contains('oily')) {
      return SkinType.oily;
    } else if (type.contains('combination')) {
      return SkinType.combination;
    } else if (type.contains('normal')) {
      return SkinType.normal;
    } else if (type.contains('sensitive')) {
      return SkinType.sensitive;
    } else {
      return SkinType.unknown;
    }
  }

  /// Các vấn đề về da
  List<SkinConcern> get skinConcerns {
    return skinIssues.map((issue) => SkinConcern.fromSkinIssue(issue)).toList();
  }

  /// Lộ trình chăm sóc da
  SkinCareRoutine get skinCareRoutine {
    final morning = <RoutineStep>[];
    final evening = <RoutineStep>[];
    final weekly = <RoutineStep>[];

    for (final step in routineSteps) {
      final routineStep = RoutineStep(
        name: step.stepName,
        description: step.instruction,
        order: step.order,
      );

      // Phân loại các bước theo thời gian trong ngày dựa trên tên
      final name = step.stepName.toLowerCase();
      if (name.contains('morning') || name.contains('sáng')) {
        morning.add(routineStep);
      } else if (name.contains('evening') ||
          name.contains('night') ||
          name.contains('tối')) {
        evening.add(routineStep);
      } else if (name.contains('weekly') || name.contains('tuần')) {
        weekly.add(routineStep);
      } else {
        // Mặc định thêm vào buổi sáng
        morning.add(routineStep);
      }
    }

    // Sắp xếp theo thứ tự
    morning.sort((a, b) => a.order.compareTo(b.order));
    evening.sort((a, b) => a.order.compareTo(b.order));
    weekly.sort((a, b) => a.order.compareTo(b.order));

    return SkinCareRoutine(morning: morning, evening: evening, weekly: weekly);
  }
}

/// Mở rộng ViewState để thêm các getter mới
extension ViewStateExtension<T> on ViewState<T> {
  bool get isError => status == ViewStateStatus.error;
  bool get isLoaded => status == ViewStateStatus.loaded;
  String? get error => message;
}
