import 'dart:convert';
import 'dart:developer';
import 'package:auto_flow/constants/api_urls.dart';
import 'package:auto_flow/core/api/api_client.dart';
import 'package:auto_flow/models/api_models/workspace_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class WorkspaceService {
  static Future<Map<String, dynamic>> getAllWorkspaces({bool? archived}) async {
    try {
      final query = archived != null ? "?archived=$archived" : "";
      final response = await ApiClient.get("${ApiUrl.allWorkspaces}$query");

      if (response['success'] == true && response['data'] != null) {
        final responseBody = response['data'];

        if (responseBody is Map<String, dynamic> &&
            responseBody['data'] is List) {
          final List<dynamic> innerData = responseBody['data'];
          final workspaces = innerData
              .map((json) => WorkspaceModel.fromJson(json))
              .toList();
          return {'success': true, 'data': workspaces};
        }
      }
      return response;
    } catch (e) {
      log("WorkspaceService: Error fetching workspaces: $e");
      return {'success': false, 'message': 'Failed to fetch workspaces'};
    }
  }

  static Future<Map<String, dynamic>> createWorkspace(
    String name,
    String description, {
    String category = 'General',
  }) async {
    try {
      final response = await ApiClient.post(ApiUrl.createWorkspace, {
        'name': name,
        'description': description,
        'category': category,
      });

      if (response['success'] == true && response['data'] != null) {
        final responseBody = response['data'];
        if (responseBody is Map<String, dynamic> &&
            responseBody['data'] != null) {
          return {
            'success': true,
            'data': WorkspaceModel.fromJson(responseBody['data']),
          };
        }
      }
      return response;
    } catch (e) {
      log("WorkspaceService: Error creating workspace: $e");
      return {'success': false, 'message': 'Failed to create workspace'};
    }
  }

  static Future<Map<String, dynamic>> joinWorkspace(String code) async {
    try {
      final response = await ApiClient.post(ApiUrl.joinWorkspace, {
        'code': code.toUpperCase(),
      });

      if (response['success'] == true && response['data'] != null) {
        final responseBody = response['data'];
        if (responseBody is Map<String, dynamic> &&
            responseBody['data'] != null) {
          return {
            'success': true,
            'data': WorkspaceModel.fromJson(responseBody['data']),
          };
        }
      }
      return response;
    } catch (e) {
      log("WorkspaceService: Error joining workspace: $e");
      return {'success': false, 'message': 'Failed to join workspace'};
    }
  }

  static Future<Map<String, dynamic>> getWorkspaceById(String id) async {
    try {
      final response = await ApiClient.get("${ApiUrl.baseUrl}/workspace/$id");
      log("getWorkspaceById raw response success: ${response['success']}");

      if (response['success'] == true && response['data'] != null) {
        final responseBody = response['data'];
        log("getWorkspaceById responseBody type: ${responseBody.runtimeType}");

        if (responseBody is Map<String, dynamic>) {
          // Backend returns {success: true, data: workspaceObject}
          final workspaceData = responseBody['data'];
          if (workspaceData != null && workspaceData is Map<String, dynamic>) {
            log(
              "getWorkspaceById: Parsing workspace from responseBody['data']",
            );
            return {
              'success': true,
              'data': WorkspaceModel.fromJson(workspaceData),
            };
          } else if (responseBody.containsKey('name') &&
              responseBody.containsKey('_id')) {
            // The responseBody itself IS the workspace (no nested data wrapper)
            log(
              "getWorkspaceById: Parsing workspace from responseBody directly",
            );
            return {
              'success': true,
              'data': WorkspaceModel.fromJson(responseBody),
            };
          }
        }
      }
      log("getWorkspaceById: Falling through, returning raw response");
      return {'success': false, 'message': 'Unexpected response format'};
    } catch (e) {
      log("WorkspaceService: Error fetching workspace detail: $e");
      return {
        'success': false,
        'message': 'Failed to fetch workspace details: $e',
      };
    }
  }

  // Delete Workspace
  static Future<Map<String, dynamic>> deleteWorkspace(String id) async {
    try {
      final response = await ApiClient.delete(
        "${ApiUrl.baseUrl}/workspace/$id",
      );

      if (response['success'] == true) {
        return {'success': true, 'message': 'Workspace deleted successfully'};
      }
      return response;
    } catch (e) {
      log("WorkspaceService: Error deleting workspace: $e");
      return {'success': false, 'message': 'Failed to delete workspace'};
    }
  }

  // removing member
  static Future<Map<String, dynamic>> removeMember(
    String workspaceId,
    String memberId,
  ) async {
    try {
      final response = await ApiClient.delete(
        "${ApiUrl.baseUrl}/workspace/$workspaceId/members/$memberId",
      );

      if (response['success'] == true) {
        return {'success': true, 'message': 'Member removed successfully'};
      }
      return response;
    } catch (e) {
      log("WorkspaceService: Error removing member: $e");
      return {'success': false, 'message': 'Failed to remove member'};
    }
  }

  // uploading analysis to workspace
  static Future<Map<String, dynamic>> addAnalysisToWorkspace(
    String workspaceId,
    Map<String, dynamic> analysisData,
  ) async {
    try {
      final response = await ApiClient.post(
        "${ApiUrl.baseUrl}/workspace/$workspaceId/documents",
        analysisData,
      );

      if (response['success'] == true) {
        return {'success': true, 'message': 'Analysis added to workspace'};
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to add analysis',
        };
      }
    } catch (e) {
      log("WorkspaceService: Error adding analysis to workspace: $e");
      return {'success': false, 'message': 'Failed to add analysis'};
    }
  }

  //delete. or remove document
  static Future<Map<String, dynamic>> removeDocument(
    String workspaceId,
    String analysisId,
  ) async {
    try {
      final response = await ApiClient.delete(
        "${ApiUrl.baseUrl}/workspace/$workspaceId/documents/$analysisId",
      );
      log("removeDocument response: ${response['success']}");

      if (response['success'] == true) {
        return {'success': true, 'message': 'Document removed successfully'};
      }

      final responseBody = response['data'];
      if (responseBody is Map<String, dynamic> &&
          responseBody['success'] == true) {
        return {'success': true, 'message': 'Document removed successfully'};
      }

      return {
        'success': false,
        'message': response['message'] ?? 'Failed to remove document',
      };
    } catch (e) {
      log("WorkspaceService: Error removing document: $e");
      return {'success': false, 'message': 'Failed to remove document: $e'};
    }
  }

  //chaning the document status
  static Future<Map<String, dynamic>> updateDocumentStatus(
    String workspaceId,
    String analysisId,
    String status,
  ) async {
    try {
      final response = await ApiClient.patch(
        "${ApiUrl.baseUrl}/workspace/$workspaceId/documents/$analysisId/status",
        {'status': status},
      );

      if (response['success'] == true) {
        return {'success': true, 'message': 'Status updated successfully'};
      }
      return response;
    } catch (e) {
      log("WorkspaceService: Error updating status: $e");
      return {'success': false, 'message': 'Failed to update status'};
    }
  }

  //for comments in documents
  // add
  static Future<Map<String, dynamic>> addDocumentComment(
    String workspaceId,
    String analysisId,
    String text,
  ) async {
    try {
      final response = await ApiClient.post(
        "${ApiUrl.baseUrl}/workspace/$workspaceId/documents/$analysisId/comments",
        {'text': text},
      );

      if (response['success'] == true) {
        return {
          'success': true,
          'message': 'Comment added successfully',
          'data': response['data'],
        };
      }
      return response;
    } catch (e) {
      log("WorkspaceService: Error adding comment: $e");
      return {'success': false, 'message': 'Failed to add comment'};
    }
  }

  // edit
  static Future<Map<String, dynamic>> editDocumentComment(
    String workspaceId,
    String analysisId,
    String commentId,
    String text,
  ) async {
    try {
      final response = await ApiClient.put(
        "${ApiUrl.baseUrl}/workspace/$workspaceId/documents/$analysisId/comments/$commentId",
        {'text': text},
      );

      if (response['success'] == true) {
        return {'success': true, 'message': 'Comment edited successfully'};
      }
      return response;
    } catch (e) {
      log("WorkspaceService: Error editing comment: $e");
      return {'success': false, 'message': 'Failed to edit comment'};
    }
  }

  // Delete Comment
  static Future<Map<String, dynamic>> deleteDocumentComment(
    String workspaceId,
    String analysisId,
    String commentId,
  ) async {
    try {
      final response = await ApiClient.delete(
        "${ApiUrl.baseUrl}/workspace/$workspaceId/documents/$analysisId/comments/$commentId",
      );

      if (response['success'] == true) {
        return {'success': true, 'message': 'Comment deleted successfully'};
      }
      return response;
    } catch (e) {
      log("WorkspaceService: Error deleting comment: $e");
      return {'success': false, 'message': 'Failed to delete comment'};
    }
  }

  // project activity

  // Create Task
  static Future<Map<String, dynamic>> createTask(
    String workspaceId,
    Map<String, dynamic> taskData,
  ) async {
    try {
      final response = await ApiClient.post(
        "${ApiUrl.baseUrl}/workspace/$workspaceId/tasks",
        taskData,
      );

      if (response['success'] == true) {
        return {
          'success': true,
          'message': 'Task created successfully',
          'data': response['data'],
        };
      }
      return response;
    } catch (e) {
      log("WorkspaceService: Error creating task: $e");
      return {'success': false, 'message': 'Failed to create task'};
    }
  }

  // Update Task
  static Future<Map<String, dynamic>> updateTask(
    String workspaceId,
    String taskId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await ApiClient.patch(
        "${ApiUrl.baseUrl}/workspace/$workspaceId/tasks/$taskId",
        updates,
      );

      if (response['success'] == true) {
        return {
          'success': true,
          'message': 'Task updated successfully',
          'data': response['data'],
        };
      }
      return response;
    } catch (e) {
      log("WorkspaceService: Error updating task: $e");
      return {'success': false, 'message': 'Failed to update task'};
    }
  }

  // Delete Task
  static Future<Map<String, dynamic>> deleteTask(
    String workspaceId,
    String taskId,
  ) async {
    try {
      final response = await ApiClient.delete(
        "${ApiUrl.baseUrl}/workspace/$workspaceId/tasks/$taskId",
      );

      if (response['success'] == true) {
        return {'success': true, 'message': 'Task deleted successfully'};
      }
      return response;
    } catch (e) {
      log("WorkspaceService: Error deleting task: $e");
      return {'success': false, 'message': 'Failed to delete task'};
    }
  }

  // ── New APIs ────────────────────────────────────────────────────────────────

  /// Archive a workspace  PATCH /workspace/:id/archive
  static Future<Map<String, dynamic>> archiveWorkspace(String id) async {
    try {
      final response = await ApiClient.patch(
        "${ApiUrl.baseUrl}/workspace/$id/archive",
        {},
      );
      if (response['success'] == true) {
        return {'success': true, 'message': 'Workspace archived'};
      }
      return response;
    } catch (e) {
      log("WorkspaceService: Error archiving workspace: $e");
      return {'success': false, 'message': 'Failed to archive workspace'};
    }
  }

  /// Unarchive a workspace  PATCH /workspace/:id/unarchive
  static Future<Map<String, dynamic>> unarchiveWorkspace(String id) async {
    try {
      final response = await ApiClient.patch(
        "${ApiUrl.baseUrl}/workspace/$id/unarchive",
        {},
      );
      if (response['success'] == true) {
        return {'success': true, 'message': 'Workspace unarchived'};
      }
      return response;
    } catch (e) {
      log("WorkspaceService: Error unarchiving workspace: $e");
      return {'success': false, 'message': 'Failed to unarchive workspace'};
    }
  }

  /// Promote member to co-admin  POST /workspace/:id/members/:memberId/promote
  static Future<Map<String, dynamic>> promoteToCoAdmin(
    String workspaceId,
    String memberId,
  ) async {
    try {
      final response = await ApiClient.post(
        "${ApiUrl.baseUrl}/workspace/$workspaceId/members/$memberId/promote",
        {},
      );
      if (response['success'] == true) {
        return {'success': true, 'message': 'Member promoted to co-admin'};
      }
      return response;
    } catch (e) {
      log("WorkspaceService: Error promoting member: $e");
      return {'success': false, 'message': 'Failed to promote member'};
    }
  }

  /// Demote co-admin to member  POST /workspace/:id/members/:memberId/demote
  static Future<Map<String, dynamic>> demoteToMember(
    String workspaceId,
    String memberId,
  ) async {
    try {
      final response = await ApiClient.post(
        "${ApiUrl.baseUrl}/workspace/$workspaceId/members/$memberId/demote",
        {},
      );
      if (response['success'] == true) {
        return {'success': true, 'message': 'Member demoted to member'};
      }
      return response;
    } catch (e) {
      log("WorkspaceService: Error demoting member: $e");
      return {'success': false, 'message': 'Failed to demote member'};
    }
  }

  /// Get task board data  GET /workspace/:id/board
  static Future<Map<String, dynamic>> getBoard(String workspaceId) async {
    try {
      final response = await ApiClient.get(
        "${ApiUrl.baseUrl}/workspace/$workspaceId/board",
      );
      if (response['success'] == true) {
        return {'success': true, 'data': response['data']};
      }
      return response;
    } catch (e) {
      log("WorkspaceService: Error fetching board: $e");
      return {'success': false, 'message': 'Failed to fetch board'};
    }
  }

  /// Admin direct file upload  POST /workspace/:id/admin-upload  (multipart)
  static Future<Map<String, dynamic>> uploadAdminFile(
    String workspaceId,
    String filePath,
    String fileName,
  ) async {
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'authToken');
      if (token == null)
        return {'success': false, 'message': 'Not authenticated'};

      final uri = Uri.parse(
        "${ApiUrl.baseUrl}/workspace/$workspaceId/admin-upload",
      );
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath('file', filePath, filename: fileName),
      );
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': 'Admin upload failed (${response.statusCode})',
        };
      }
    } catch (e) {
      log("WorkspaceService: Error uploading admin file: $e");
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  /// Delete admin upload  DELETE /workspace/:id/admin-upload/:uploadId
  static Future<Map<String, dynamic>> deleteAdminFile(
    String workspaceId,
    String uploadId,
  ) async {
    try {
      final response = await ApiClient.delete(
        "${ApiUrl.baseUrl}/workspace/$workspaceId/admin-upload/$uploadId",
      );
      if (response['success'] == true) {
        return {'success': true, 'message': 'Admin file deleted'};
      }
      return response;
    } catch (e) {
      log("WorkspaceService: Error deleting admin file: $e");
      return {'success': false, 'message': 'Failed to delete admin file'};
    }
  }

  /// Build download URL for an admin file (includes token as query param).
  static Future<String> getAdminFileDownloadUrl(
    String workspaceId,
    String uploadId,
  ) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'authToken');
    final base =
        "${ApiUrl.baseUrl}/workspace/$workspaceId/admin-upload/$uploadId/download";
    return token != null ? "$base?token=${Uri.encodeComponent(token)}" : base;
  }

  /// Update workspace name/description  PATCH /workspace/:id
  static Future<Map<String, dynamic>> updateWorkspace(
    String workspaceId, {
    String? name,
    String? description,
  }) async {
    try {
      final body = <String, dynamic>{
        if (name != null) 'name': name,
        if (description != null) 'description': description,
      };
      final response = await ApiClient.patch(
        "${ApiUrl.baseUrl}/workspace/$workspaceId",
        body,
      );
      if (response['success'] == true) {
        return {'success': true, 'message': 'Workspace updated'};
      }
      return response;
    } catch (e) {
      log("WorkspaceService: Error updating workspace: $e");
      return {'success': false, 'message': 'Failed to update workspace'};
    }
  }
}
