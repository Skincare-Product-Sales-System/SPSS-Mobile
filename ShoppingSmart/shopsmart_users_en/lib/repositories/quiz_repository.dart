import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_response_model.dart';
import '../services/jwt_service.dart';
import 'dart:developer' as developer;

/// Repository xử lý các tác vụ liên quan đến quiz
class QuizRepository {
  final String _baseUrl = 'https://spssapi-hxfzbchrcafgd2hg.southeastasia-01.azurewebsites.net/api';

  /// Lấy danh sách bộ câu hỏi quiz
  Future<ApiResponse<List<Map<String, dynamic>>>> getQuizSets({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final url =
          '$_baseUrl/quiz-sets?pageNumber=$pageNumber&pageSize=$pageSize';
      developer.log('Calling API: $url', name: 'QuizRepository');

      final response = await http.get(Uri.parse(url));

      developer.log(
        'Response status: ${response.statusCode}',
        name: 'QuizRepository',
      );
      developer.log('Response body: ${response.body}', name: 'QuizRepository');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['data']['items'] as List<dynamic>;
        return ApiResponse<List<Map<String, dynamic>>>(
          success: true,
          data: items.cast<Map<String, dynamic>>(),
          message: 'Quiz sets fetched successfully',
        );
      } else {
        return ApiResponse<List<Map<String, dynamic>>>(
          success: false,
          message:
              'Failed to load quiz sets. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      developer.log(
        'Exception: ${e.toString()}',
        name: 'QuizRepository',
        error: e,
      );
      return ApiResponse<List<Map<String, dynamic>>>(
        success: false,
        message: 'Error fetching quiz sets: ${e.toString()}',
      );
    }
  }

  /// Lấy chi tiết của một bộ câu hỏi quiz
  Future<ApiResponse<Map<String, dynamic>>> getQuizSet(String quizSetId) async {
    try {
      final url = '$_baseUrl/quiz-sets/$quizSetId';
      developer.log('Calling API: $url', name: 'QuizRepository');

      final response = await http.get(Uri.parse(url));

      developer.log(
        'Response status: ${response.statusCode}',
        name: 'QuizRepository',
      );
      developer.log('Response body: ${response.body}', name: 'QuizRepository');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          data: data['data'] as Map<String, dynamic>,
          message: 'Quiz set fetched successfully',
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message:
              'Failed to load quiz set. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      developer.log(
        'Exception: ${e.toString()}',
        name: 'QuizRepository',
        error: e,
      );
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Error fetching quiz set: ${e.toString()}',
      );
    }
  }

  /// Lấy danh sách câu hỏi của một bộ quiz
  Future<ApiResponse<List<Map<String, dynamic>>>> getQuizQuestions(
    String quizSetId,
  ) async {
    try {
      // Sửa lại endpoint theo đúng cấu trúc API Controller
      final url = '$_baseUrl/quiz-questions/by-quiz-set/$quizSetId';
      developer.log('Calling API: $url', name: 'QuizRepository');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      developer.log(
        'Response status: ${response.statusCode}',
        name: 'QuizRepository',
      );
      developer.log('Response body: ${response.body}', name: 'QuizRepository');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Sửa lại cấu trúc dữ liệu theo API response
        final items = data['data'] as List<dynamic>;
        return ApiResponse<List<Map<String, dynamic>>>(
          success: true,
          data: items.cast<Map<String, dynamic>>(),
          message: 'Quiz questions fetched successfully',
        );
      } else {
        return ApiResponse<List<Map<String, dynamic>>>(
          success: false,
          message:
              'Failed to load quiz questions. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      developer.log(
        'Exception: ${e.toString()}',
        name: 'QuizRepository',
        error: e,
      );
      return ApiResponse<List<Map<String, dynamic>>>(
        success: false,
        message: 'Error fetching quiz questions: ${e.toString()}',
      );
    }
  }

  /// Lấy danh sách các tùy chọn cho một câu hỏi
  Future<ApiResponse<List<Map<String, dynamic>>>> getQuizOptionsByQuestion(
    String questionId,
  ) async {
    try {
      final url = '$_baseUrl/quiz-options/by-quiz-question/$questionId';
      developer.log('Calling API: $url', name: 'QuizRepository');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      developer.log(
        'Response status: ${response.statusCode}',
        name: 'QuizRepository',
      );
      developer.log('Response body: ${response.body}', name: 'QuizRepository');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['data'] as List<dynamic>;
        return ApiResponse<List<Map<String, dynamic>>>(
          success: true,
          data: items.cast<Map<String, dynamic>>(),
          message: 'Quiz options fetched successfully',
        );
      } else {
        return ApiResponse<List<Map<String, dynamic>>>(
          success: false,
          message:
              'Failed to load quiz options. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      developer.log(
        'Exception: ${e.toString()}',
        name: 'QuizRepository',
        error: e,
      );
      return ApiResponse<List<Map<String, dynamic>>>(
        success: false,
        message: 'Error fetching quiz options: ${e.toString()}',
      );
    }
  }

  /// Lấy kết quả quiz dựa trên điểm số và bộ câu hỏi
  Future<ApiResponse<Map<String, dynamic>>> getQuizResultByScore(
    int score,
    String quizSetId,
  ) async {
    try {
      final token = await JwtService.getStoredToken();
      final url =
          '$_baseUrl/quiz-results/by-point-and-set?score=$score&quizSetId=$quizSetId';
      developer.log('Calling API: $url', name: 'QuizRepository');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      developer.log(
        'Response status: ${response.statusCode}',
        name: 'QuizRepository',
      );
      developer.log('Response body: ${response.body}', name: 'QuizRepository');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          data: data['data'] as Map<String, dynamic>,
          message: 'Quiz result fetched successfully',
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message:
              'Failed to load quiz result. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      developer.log(
        'Exception: ${e.toString()}',
        name: 'QuizRepository',
        error: e,
      );
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Error fetching quiz result: ${e.toString()}',
      );
    }
  }

  /// Gửi kết quả làm bài quiz
  Future<ApiResponse<Map<String, dynamic>>> submitQuizResult(
    String quizSetId,
    List<Map<String, dynamic>> answers,
  ) async {
    try {
      final url = '$_baseUrl/quiz-sets/$quizSetId/submit';
      developer.log('Calling API: $url', name: 'QuizRepository');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'answers': answers}),
      );

      developer.log(
        'Response status: ${response.statusCode}',
        name: 'QuizRepository',
      );
      developer.log('Response body: ${response.body}', name: 'QuizRepository');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          data: data['data'] as Map<String, dynamic>,
          message: 'Quiz result submitted successfully',
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message:
              'Failed to submit quiz result. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      developer.log(
        'Exception: ${e.toString()}',
        name: 'QuizRepository',
        error: e,
      );
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Error submitting quiz result: ${e.toString()}',
      );
    }
  }
}
