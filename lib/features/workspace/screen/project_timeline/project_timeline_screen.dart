import 'package:auto_flow/core/custom_widgets/custom_button.dart';
import 'package:auto_flow/features/workspace/screen/project_timeline/gantt_chart_view.dart';
import 'package:auto_flow/features/workspace/service/workspace_service.dart';
import 'package:auto_flow/models/api_models/activity_model.dart';
import 'package:auto_flow/models/api_models/workspace_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class TimelineScreen extends StatefulWidget {
  final String workspaceId;

  const TimelineScreen({super.key, required this.workspaceId});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  final _storage = const FlutterSecureStorage();
  bool _isLoading = false;
  String? _errorMessage;
  List<ActivityModel> _activities = [];
  String? _currentUserId;
  bool _isOwner = false;
  WorkspaceModel? _workspace;

  final List<Color> _taskColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.blueGrey,
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      _currentUserId = await _storage.read(key: 'userId');
      final result = await WorkspaceService.getWorkspaceById(
        widget.workspaceId,
      );

      if (!mounted) return;

      if (result['success'] == true && result['data'] != null) {
        final workspace = result['data'] as WorkspaceModel;

        setState(() {
          _workspace = workspace;
          _isOwner = workspace.ownerId == _currentUserId;
          _activities = [];
          if (workspace.boards != null) {
            debugPrint(
              "Timeline Debug: Board count: ${workspace.boards!.length}",
            );
            for (var board in workspace.boards!) {
              debugPrint(
                "Timeline Debug: Board ${board.id} has ${board.tasks.length} tasks",
              );
              _activities.addAll(board.tasks);
            }
          } else {
            debugPrint("Timeline Debug: workspace.boards is null");
          }
          debugPrint(
            "Timeline Debug: Total activities found: ${_activities.length}",
          );
          _activities.sort((a, b) {
            final aDone = a.status == 'Done';
            final bDone = b.status == 'Done';
            if (aDone != bDone) return aDone ? 1 : -1;
            if (a.deadline != null && b.deadline != null) {
              return a.deadline!.compareTo(b.deadline!);
            }
            return 0;
          });
        });
      } else {
        setState(() => _errorMessage = "Failed to load: ${result['message']}");
      }
    } catch (e) {
      debugPrint("Error fetching timeline: $e");
      setState(() => _errorMessage = "Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteActivity(String taskId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity'),
        content: const Text('Are you sure you want to delete this activity?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    final result = await WorkspaceService.deleteTask(
      widget.workspaceId,
      taskId,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success'] == true) {
        _fetchData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to delete')),
        );
      }
    }
  }

  Future<void> _updateMemberStatus(
    ActivityModel activity,
    String userId,
    String newStatus,
  ) async {
    if (!_isOwner && userId != _currentUserId) return;

    setState(() => _isLoading = true);

    List<MemberStatus> currentStatuses = activity.memberStatuses ?? [];

    List<Map<String, dynamic>> updatedList = currentStatuses
        .map((s) => s.toJson())
        .toList();

    updatedList.removeWhere((s) => s['userId'] == userId);

    updatedList.add({
      'userId': userId,
      'status': newStatus,
      'updatedAt': DateTime.now().toIso8601String(),
    });

    final updatePayload = {'memberStatuses': updatedList};

    final result = await WorkspaceService.updateTask(
      widget.workspaceId,
      activity.id,
      updatePayload,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success'] == true) {
        _fetchData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to update status'),
          ),
        );
      }
    }
  }

  Future<void> _createActivity() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 7));
    Color selectedColor = _taskColors[0];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add Activity'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Start Date",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                  initialDate: startDate,
                                );
                                if (d != null)
                                  setDialogState(() => startDate = d);
                              },
                              child: Text(
                                DateFormat('MM/dd/yyyy').format(startDate),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "End Date",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                  initialDate: endDate,
                                );
                                if (d != null)
                                  setDialogState(() => endDate = d);
                              },
                              child: Text(
                                DateFormat('MM/dd/yyyy').format(endDate),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Activity Color (Gantt Only)",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _taskColors
                        .map(
                          (color) => GestureDetector(
                            onTap: () =>
                                setDialogState(() => selectedColor = color),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: selectedColor == color
                                    ? Border.all(color: Colors.black, width: 2)
                                    : null,
                              ),
                              child: selectedColor == color
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : null,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isNotEmpty) {
                    Navigator.pop(context);
                    setState(() => _isLoading = true);

                    String colorHex =
                        '#${selectedColor.value.toRadixString(16).substring(2)}';

                    await WorkspaceService.createTask(widget.workspaceId, {
                      'title': titleController.text,
                      'description': descController.text,
                      'startDate': startDate.toIso8601String(),
                      'deadline': endDate.toIso8601String(),
                      'color': colorHex,
                      'boardId': _workspace?.boards?.firstOrNull?.id,
                    });
                    if (mounted) {
                      setState(() => _isLoading = false);
                      _fetchData();
                    }
                  }
                },
                child: const Text('Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _editActivity(ActivityModel activity) async {
    if (!_isOwner) return;

    final titleController = TextEditingController(text: activity.title);
    final descController = TextEditingController(text: activity.description);
    DateTime startDate = activity.startDate ?? activity.createdAt;
    DateTime endDate =
        activity.deadline ?? startDate.add(const Duration(days: 7));

    Color selectedColor = _taskColors[0];
    if (activity.color != null) {
      try {
        String hex = activity.color!.replaceAll("#", "");
        if (hex.length == 6) hex = "FF$hex";
        selectedColor = Color(int.parse(hex, radix: 16));
      } catch (_) {}
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Edit Activity'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Start Date",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                  initialDate: startDate,
                                );
                                if (d != null)
                                  setDialogState(() => startDate = d);
                              },
                              child: Text(
                                DateFormat('MM/dd/yyyy').format(startDate),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "End Date",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                  initialDate: endDate,
                                );
                                if (d != null)
                                  setDialogState(() => endDate = d);
                              },
                              child: Text(
                                DateFormat('MM/dd/yyyy').format(endDate),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Activity Color (Gantt Only)",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _taskColors
                        .map(
                          (color) => GestureDetector(
                            onTap: () =>
                                setDialogState(() => selectedColor = color),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: selectedColor == color
                                    ? Border.all(color: Colors.black, width: 2)
                                    : null,
                              ),
                              child: selectedColor == color
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : null,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteActivity(activity.id);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete Activity'),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isNotEmpty) {
                    Navigator.pop(context);
                    setState(() => _isLoading = true);

                    String colorHex =
                        '#${selectedColor.value.toRadixString(16).substring(2)}';

                    await WorkspaceService.updateTask(
                      widget.workspaceId,
                      activity.id,
                      {
                        'title': titleController.text,
                        'description': descController.text,
                        'startDate': startDate.toIso8601String(),
                        'deadline': endDate.toIso8601String(),
                        'color': colorHex,
                      },
                    );

                    if (mounted) {
                      setState(() => _isLoading = false);
                      _fetchData();
                    }
                  }
                },
                child: const Text('Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _activities.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const SizedBox.shrink(), // Hide default title if any
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 0,
          bottom: TabBar(
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: const [
              Tab(text: "Activities"),
              Tab(text: "Timeline"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _activities.length + (_isOwner ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _activities.length)
                  return const SizedBox(height: 80);
                return _buildActivityCard(_activities[index]);
              },
            ),

            // Gantt Chart
            GanttChartView(
              activities: _activities,
              onActivityTap: (activity) {
                if (_isOwner) _editActivity(activity);
              },
            ),
          ],
        ),
        floatingActionButton: _isOwner
            ? FloatingActionButton.extended(
                onPressed: _createActivity,
                label: const Text("Add Activity"),
                icon: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }

  Widget _buildActivityCard(ActivityModel activity) {
    MemberStatus? myStatusObj;
    try {
      myStatusObj = activity.memberStatuses?.firstWhere(
        (s) => s.userId == _currentUserId,
      );
    } catch (_) {}

    String? displayStatus;
    if (myStatusObj != null) {
      if (myStatusObj.status == 'To Do')
        displayStatus = 'To Do';
      else if (myStatusObj.status == 'In Progress')
        displayStatus = 'In Progress';
      else if (myStatusObj.status == 'Completed')
        displayStatus = 'Completed';
      else
        displayStatus = 'To Do';
    }

    return Card(
      elevation: 2,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    activity.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_isOwner)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                    onPressed: () => _editActivity(activity),
                  ),
              ],
            ),
            if (activity.description != null &&
                activity.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                activity.description!,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 6),
                Text(
                  "${DateFormat.MMMd().format(activity.startDate ?? activity.createdAt)} - ${activity.deadline != null ? DateFormat.MMMd().format(activity.deadline!) : 'No End'}",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
            const Divider(height: 24),
            // Member Progress Section
            if (!_isOwner)
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.teal.shade100,
                    child: Text(
                      "ME",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.teal.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Your Progress",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const Spacer(),
                  // Status Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 0,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: displayStatus,
                      hint: const Text(
                        "Set Status",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      underline: const SizedBox(),
                      icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                      onChanged: (newValue) {
                        if (newValue != null && _currentUserId != null) {
                          _updateMemberStatus(
                            activity,
                            _currentUserId!,
                            newValue,
                          );
                        }
                      },
                      items: ["To Do", "In Progress", "Completed"].map((
                        status,
                      ) {
                        Color statusColor = Colors.grey;
                        if (status == "In Progress") statusColor = Colors.blue;
                        if (status == "Completed") statusColor = Colors.green;

                        return DropdownMenuItem(
                          value: status,
                          child: Text(
                            status,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),

            // ADMIN OVERRIDE SECTION
            if (_isOwner && _workspace?.members != null) ...[
              if (!_isOwner)
                const Divider(height: 32)
              else
                const SizedBox(height: 12),

              const Text(
                "Team Progress",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              ..._workspace!.members!.map((member) {
                // Find this member's status
                final memberStatusObj = activity.memberStatuses?.firstWhere(
                  (s) => s.userId == member.id,
                  orElse: () => MemberStatus(
                    userId: member.id ?? '',
                    status: '',
                    updatedAt: DateTime.now(),
                  ),
                );

                String? memberDisplayStatus;
                if (memberStatusObj != null &&
                    memberStatusObj.status.isNotEmpty) {
                  if (memberStatusObj.status == 'To Do')
                    memberDisplayStatus = 'To Do';
                  else if (memberStatusObj.status == 'In Progress')
                    memberDisplayStatus = 'In Progress';
                  else if (memberStatusObj.status == 'Completed')
                    memberDisplayStatus = 'Completed';
                  else
                    memberDisplayStatus = 'To Do';
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: member.logoUrl != null
                            ? NetworkImage(member.logoUrl!)
                            : null,
                        child: member.logoUrl == null
                            ? Text(
                                member.name.isNotEmpty
                                    ? member.name[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade800,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.name.isNotEmpty
                                  ? member.name
                                  : (member.email.isNotEmpty
                                        ? member.email
                                        : 'Unknown Member'),
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (memberStatusObj != null &&
                                memberStatusObj.status.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Text(
                                  "Updated ${DateFormat('M/d/yyyy').format(memberStatusObj.updatedAt)}",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        height: 30,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: DropdownButton<String>(
                          value: memberDisplayStatus,
                          hint: const Text(
                            "Set Status",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          underline: const SizedBox(),
                          icon: const Icon(Icons.keyboard_arrow_down, size: 14),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                          onChanged: (newValue) {
                            if (newValue != null && member.id != null) {
                              _updateMemberStatus(
                                activity,
                                member.id!,
                                newValue,
                              );
                            }
                          },
                          items: ["To Do", "In Progress", "Completed"].map((
                            status,
                          ) {
                            Color statusColor = Colors.grey;
                            if (status == "In Progress")
                              statusColor = Colors.blue;
                            if (status == "Completed")
                              statusColor = Colors.green;
                            return DropdownMenuItem(
                              value: status,
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }
}
