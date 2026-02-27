import 'package:flutter/material.dart';
import 'package:auto_flow/models/api_models/workspace_model.dart';

class WorkspaceMembersSection extends StatelessWidget {
  final WorkspaceModel workspace;
  final String? currentUserId;
  final bool isLoadingDetails;
  final bool showAllMembers;
  final VoidCallback onToggleShowAll;
  final Function(String, String) onPromote;
  final Function(String, String) onDemote;
  final Function(String, String) onRemove;

  const WorkspaceMembersSection({
    super.key,
    required this.workspace,
    required this.currentUserId,
    required this.isLoadingDetails,
    required this.showAllMembers,
    required this.onToggleShowAll,
    required this.onPromote,
    required this.onDemote,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final members = workspace.members ?? [];
    final isOwner = currentUserId != null && currentUserId == workspace.ownerId;

    // Check if members have real names (not placeholder 'Member')
    final hasMemberNames =
        members.isEmpty || members.any((m) => m.name != 'Member');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "WORKSPACE MEMBERS (${members.length})",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
            if (isOwner && members.isNotEmpty)
              TextButton(
                onPressed: onToggleShowAll,
                child: Text(
                  showAllMembers ? "Show Less" : "Manage Members",
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (isLoadingDetails && !hasMemberNames)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else if (!showAllMembers)
          // Compact View
          Row(
            children: [
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: members.length > 8 ? 8 : members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return Align(
                      widthFactor: 0.8,
                      child: Tooltip(
                        message: member.name,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: colorScheme.primary,
                          child: Text(
                            member.name.substring(0, 2).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (members.length > 8)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    "+${members.length - 8} more",
                    style: TextStyle(
                      color: colorScheme.outline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          )
        else
          // Expanded View
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            constraints: const BoxConstraints(maxHeight: 300),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(8),
              itemCount: members.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final member = members[index];
                final memberId = member.id ?? member.studentId ?? '';
                final isMe = memberId == currentUserId;
                final isAdmin = memberId == workspace.ownerId;
                final isCoAdmin =
                    workspace.coAdmins?.contains(memberId) == true;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      member.name.substring(0, 2).toUpperCase(),
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Flexible(
                        child: Text(
                          member.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (isMe)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "You",
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (isAdmin)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Admin",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.amber.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else if (isCoAdmin)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Co-Admin",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Text(member.email),
                  trailing: (isOwner && !isMe)
                      ? PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'promote') {
                              onPromote(memberId, member.name);
                            } else if (value == 'demote') {
                              onDemote(memberId, member.name);
                            } else if (value == 'remove') {
                              onRemove(memberId, member.name);
                            }
                          },
                          itemBuilder: (context) {
                            return [
                              if (!isCoAdmin && !isAdmin)
                                const PopupMenuItem(
                                  value: 'promote',
                                  child: Text('Promote to Co-Admin'),
                                ),
                              if (isCoAdmin && !isAdmin)
                                const PopupMenuItem(
                                  value: 'demote',
                                  child: Text('Demote to Member'),
                                ),
                              const PopupMenuItem(
                                value: 'remove',
                                child: Text(
                                  'Remove Member',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ];
                          },
                        )
                      : null,
                );
              },
            ),
          ),
      ],
    );
  }
}
