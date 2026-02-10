import 'dart:convert';
import 'dart:developer';
import 'package:auto_flow/constants/api_urls.dart';
import 'package:auto_flow/core/api/api_client.dart';
import 'package:auto_flow/models/api_models/workspace_model.dart';

class WorkspaceService {
  static Future<Map<String, dynamic>> getAllWorkspaces() async {
    try {
      final response = await ApiClient.get(ApiUrl.allWorkspaces);

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
    String description,
  ) async {
    try {
      final response = await ApiClient.post(
        ApiUrl.createWorkspace,
        {'name': name, 'description': description},
      );

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

  // Join Workspace
  static Future<Map<String, dynamic>> joinWorkspace(String code) async {
    try {
      final response = await ApiClient.post(
        ApiUrl.joinWorkspace,
        {'code': code.toUpperCase()},
      );

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

  // Get Workspace Details
  static Future<Map<String, dynamic>> getWorkspaceById(String id) async {
    try {
      // cause The backend API is be /workspace/:id couldnt make constant of it
      final response = await ApiClient.get("${ApiUrl.baseUrl}/workspace/$id");

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
      log("WorkspaceService: Error fetching workspace detail: $e");
      return {'success': false, 'message': 'Failed to fetch workspace details'};
    }
  }

  // Delete Workspace
  static Future<Map<String, dynamic>> deleteWorkspace(String id) async {
    try {
      // Using ApiClient.post as placeholder if DELETE not supported yet,
      // but assuming similar response structure handling needed if we implement it.
      // For now, keeping the placeholder error return as is to minimize scope,
      // but technically this method was incomplete anyway.
      return {'success': false, 'message': 'Delete not implemented yet'};
    } catch (e) {
      return {'success': false, 'message': 'Error deleting'};
    }
  }

  // Remove Member
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
}
