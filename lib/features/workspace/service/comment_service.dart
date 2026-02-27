import 'dart:developer';
import 'package:auto_flow/constants/api_urls.dart';
import 'package:auto_flow/core/api/api_client.dart';
import 'package:auto_flow/models/api_models/comment_model.dart';

class CommentService {
  static Future<Map<String, dynamic>> getComments(
    String workspaceId,
    String documentId,
  ) async {
    try {
      final response = await ApiClient.get(
        "${ApiUrl.allWorkspaces}/$workspaceId",
      );

      if (response['success'] == true && response['data'] != null) {
        final workspaceData = response['data'];
        final List<dynamic> documents = workspaceData['documents'] ?? [];

        final doc = documents.firstWhere(
          (d) => d['analysisId'] == documentId,
          orElse: () => null,
        );

        if (doc != null && doc['comments'] != null) {
          final List<dynamic> commentsData = doc['comments'];
          final comments = commentsData
              .map((e) => CommentModel.fromJson(e))
              .toList();
          return {'success': true, 'data': comments};
        }
        return {'success': true, 'data': <CommentModel>[]}; // No comments found
      }
      return response;
    } catch (e) {
      log("CommentService: Error getting comments: $e");
      return {'success': false, 'message': 'Failed to fetch comments'};
    }
  }

  static Future<Map<String, dynamic>> addComment(
    String workspaceId,
    String documentId,
    String text,
  ) async {
    try {
      if (workspaceId.isEmpty || documentId.isEmpty) {
        return {
          'success': false,
          'message': 'Invalid workspace or document ID',
        };
      }

      final url =
          "${ApiUrl.baseUrl}/workspace/$workspaceId/documents/$documentId/comments";

      final response = await ApiClient.post(url, {'text': text});

      if (response['success'] == true) {
        return {
          'success': true,
          'message': 'Comment added',
          'data': response['data'],
        };
      }
      return response;
    } catch (e) {
      log("CommentService: Error adding comment: $e");
      return {'success': false, 'message': 'Failed to add comment'};
    }
  }

  static Future<Map<String, dynamic>> deleteComment(
    String workspaceId,
    String documentId,
    String commentId,
  ) async {
    try {
      final url =
          "${ApiUrl.baseUrl}/workspace/$workspaceId/documents/$documentId/comments/$commentId";

      final response = await ApiClient.delete(url);

      if (response['success'] == true) {
        return {
          'success': true,
          'message': 'Comment deleted',
          'data': response['data'], // Pass the updated workspace data
        };
      }
      return response;
    } catch (e) {
      log("CommentService: Error deleting comment: $e");
      return {'success': false, 'message': 'Failed to delete comment'};
    }
  }
}
