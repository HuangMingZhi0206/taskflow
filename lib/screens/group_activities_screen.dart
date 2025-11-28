import 'package:flutter/material.dart';
import '../models/group_model.dart';
import '../services/group_service.dart';
import '../theme/app_theme.dart';

class GroupActivitiesScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const GroupActivitiesScreen({super.key, required this.user});

  @override
  State<GroupActivitiesScreen> createState() => _GroupActivitiesScreenState();
}

class _GroupActivitiesScreenState extends State<GroupActivitiesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<GroupModel> _allGroups = [];
  List<GroupModel> _myGroups = [];
  List<GroupModel> _leadingGroups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadGroups();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadGroups() async {
    setState(() => _isLoading = true);

    try {
      // Load all groups
      final allGroups = await GroupService.instance.getAllGroups();
      final myGroups =
          await GroupService.instance.getUserGroups(widget.user['id']);
      final leadingGroups =
          myGroups.where((g) => g.createdBy == widget.user['id']).toList();

      setState(() {
        _allGroups = allGroups;
        _myGroups = myGroups;
        _leadingGroups = leadingGroups;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading groups: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👥 Group Activities'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.explore), text: 'Discover'),
            Tab(icon: Icon(Icons.groups), text: 'My Groups'),
            Tab(icon: Icon(Icons.supervisor_account), text: 'Leading'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateGroupDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Create Group'),
        backgroundColor: AppTheme.primary,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDiscoverTab(),
          _buildMyGroupsTab(),
          _buildLeadingTab(),
        ],
      ),
    );
  }

  // Discover Tab - Show all available groups
  Widget _buildDiscoverTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final availableGroups = _allGroups
        .where((g) => !_myGroups.any((my) => my.id == g.id))
        .toList();

    if (availableGroups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: AppTheme.textLight),
            const SizedBox(height: 16),
            const Text(
              'No available groups to join',
              style: TextStyle(fontSize: 18, color: AppTheme.textLight),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a new group or wait for others',
              style: TextStyle(color: AppTheme.textLight),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGroups,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: availableGroups.length,
        itemBuilder: (context, index) {
          return _buildDiscoverGroupCard(availableGroups[index]);
        },
      ),
    );
  }

  // My Groups Tab
  Widget _buildMyGroupsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_myGroups.isEmpty) {
      return _buildEmptyState(
        icon: Icons.group_outlined,
        title: 'No groups yet',
        message: 'Join a group from Discover tab or create your own',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGroups,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _myGroups.length,
        itemBuilder: (context, index) {
          final group = _myGroups[index];
          final isLeader = group.createdBy == widget.user['id'];
          return _buildMyGroupCard(group, isLeader);
        },
      ),
    );
  }

  // Leading Tab
  Widget _buildLeadingTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_leadingGroups.isEmpty) {
      return _buildEmptyState(
        icon: Icons.supervisor_account_outlined,
        title: 'Not leading any groups',
        message: 'Create a group to become a leader',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGroups,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _leadingGroups.length,
        itemBuilder: (context, index) {
          return _buildLeaderGroupCard(_leadingGroups[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: AppTheme.textLight),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(color: AppTheme.textLight),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateGroupDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Create Group'),
          ),
        ],
      ),
    );
  }

  // Discover Group Card - with Apply button
  Widget _buildDiscoverGroupCard(GroupModel group) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: _getCategoryColor(group.category),
                  child: Text(
                    group.groupName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.groupName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getCategoryLabel(group.category),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getCategoryColor(group.category),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              group.description,
              style: const TextStyle(fontSize: 14, color: AppTheme.textLight),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.people, size: 16, color: AppTheme.textLight),
                const SizedBox(width: 4),
                Text(
                  '${group.memberIds.length} members',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () => _showApplyDialog(group),
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text('Join Group'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // My Group Card
  Widget _buildMyGroupCard(GroupModel group, bool isLeader) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showGroupDetails(group, isLeader),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getCategoryColor(group.category),
                    child: Text(
                      group.groupName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                group.groupName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isLeader)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.amber),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.stars, size: 12, color: Colors.amber),
                                    SizedBox(width: 4),
                                    Text(
                                      'Leader',
                                      style: TextStyle(
                                        color: Colors.amber,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.primary.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: const Text(
                                  'Member',
                                  style: TextStyle(
                                    color: AppTheme.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getCategoryLabel(group.category),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                group.description,
                style: const TextStyle(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: AppTheme.textLight),
                  const SizedBox(width: 4),
                  Text(
                    '${group.memberIds.length} members',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
                  ),
                  const Spacer(),
                  if (!isLeader)
                    TextButton(
                      onPressed: () => _confirmLeaveGroup(group),
                      child: const Text(
                        'Leave',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Leader Group Card - with more controls
  Widget _buildLeaderGroupCard(GroupModel group) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      child: InkWell(
        onTap: () => _showLeaderGroupDetails(group),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: _getCategoryColor(group.category),
                    child: Text(
                      group.groupName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.groupName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getCategoryLabel(group.category),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getCategoryColor(group.category),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.stars, color: Colors.amber),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                group.description,
                style: const TextStyle(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildGroupStat(
                    Icons.people,
                    '${group.memberIds.length}',
                    'Members',
                  ),
                  const SizedBox(width: 16),
                  _buildGroupStat(
                    Icons.calendar_today,
                    _formatDateShort(group.createdAt),
                    'Created',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showEditGroupDialog(group),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                  ),
                  TextButton.icon(
                    onPressed: () => _confirmDeleteGroup(group),
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupStat(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textLight),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textLight,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'study':
        return Colors.blue;
      case 'project':
        return Colors.green;
      case 'club':
        return Colors.orange;
      default:
        return AppTheme.primary;
    }
  }

  String _getCategoryLabel(String category) {
    final labels = {
      'study': '📚 Study Group',
      'project': '💼 Project Team',
      'club': '🎯 Club Activity',
      'other': '📌 Other',
    };
    return labels[category] ?? category;
  }

  String _formatDateShort(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Apply to join group dialog
  void _showApplyDialog(GroupModel group) {
    String role = 'member';
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Join ${group.groupName}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select your role:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                RadioListTile<String>(
                  title: const Row(
                    children: [
                      Icon(Icons.person, size: 20),
                      SizedBox(width: 8),
                      Text('Member'),
                    ],
                  ),
                  subtitle: const Text('Join as a regular member'),
                  value: 'member',
                  groupValue: role,
                  onChanged: (value) => setState(() => role = value!),
                ),
                RadioListTile<String>(
                  title: const Row(
                    children: [
                      Icon(Icons.stars, size: 20, color: Colors.amber),
                      SizedBox(width: 8),
                      Text('Co-Leader'),
                    ],
                  ),
                  subtitle: const Text('Request to help lead the group'),
                  value: 'leader',
                  groupValue: role,
                  onChanged: (value) => setState(() => role = value!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    labelText: 'Introduction (Optional)',
                    hintText: 'Tell them about yourself...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
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
                try {
                  await GroupService.instance.joinGroup(
                    groupId: group.id,
                    userId: widget.user['id'],
                    role: role,
                  );

                  Navigator.pop(context);
                  _loadGroups();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        role == 'leader'
                            ? '✅ Request sent! Waiting for approval'
                            : '✅ Joined ${group.groupName}!',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Switch to My Groups tab
                  _tabController.animateTo(1);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Join'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateGroupDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String category = 'study';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create New Group'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Group Name *',
                    hintText: 'e.g., CS101 Study Group',
                    prefixIcon: Icon(Icons.groups),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                    hintText: 'What is this group for?',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'study',
                      child: Text('📚 Study Group'),
                    ),
                    DropdownMenuItem(
                      value: 'project',
                      child: Text('💼 Project Team'),
                    ),
                    DropdownMenuItem(
                      value: 'club',
                      child: Text('🎯 Club Activity'),
                    ),
                    DropdownMenuItem(
                      value: 'other',
                      child: Text('📌 Other'),
                    ),
                  ],
                  onChanged: (value) => setState(() => category = value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                if (nameController.text.trim().isEmpty ||
                    descriptionController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                try {
                  await GroupService.instance.createGroup(
                    groupName: nameController.text.trim(),
                    description: descriptionController.text.trim(),
                    createdBy: widget.user['id'],
                    category: category,
                  );

                  Navigator.pop(context);
                  _loadGroups();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Group created successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Switch to Leading tab
                  _tabController.animateTo(2);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showGroupDetails(GroupModel group, bool isLeader) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: _getCategoryColor(group.category),
              child: Text(
                group.groupName[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                group.groupName,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getCategoryColor(group.category).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getCategoryColor(group.category),
                  ),
                ),
                child: Text(
                  _getCategoryLabel(group.category),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getCategoryColor(group.category),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(group.description),
              const SizedBox(height: 16),
              const Text(
                'Group Info:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.people, 'Members', '${group.memberIds.length}'),
              _buildInfoRow(
                Icons.calendar_today,
                'Created',
                _formatDateShort(group.createdAt),
              ),
              if (isLeader)
                _buildInfoRow(Icons.stars, 'Role', 'Group Leader')
              else
                _buildInfoRow(Icons.person, 'Role', 'Member'),
            ],
          ),
        ),
        actions: [
          if (!isLeader)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _confirmLeaveGroup(group);
              },
              child: const Text('Leave Group', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLeaderGroupDetails(GroupModel group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.stars, color: Colors.amber),
            const SizedBox(width: 8),
            Expanded(child: Text(group.groupName)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getCategoryLabel(group.category),
                style: TextStyle(
                  color: _getCategoryColor(group.category),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(group.description),
              const SizedBox(height: 16),
              const Text(
                'Leader Controls:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('• Manage ${group.memberIds.length} members'),
              const Text('• Edit group details'),
              const Text('• Delete group'),
              const Text('• Approve join requests'),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showEditGroupDialog(group);
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _confirmDeleteGroup(group);
            },
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.textLight),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(color: AppTheme.textLight),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _showEditGroupDialog(GroupModel group) {
    final nameController = TextEditingController(text: group.groupName);
    final descriptionController = TextEditingController(text: group.description);
    String category = group.category;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Group'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Group Name',
                    prefixIcon: Icon(Icons.groups),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'study', child: Text('📚 Study Group')),
                    DropdownMenuItem(value: 'project', child: Text('💼 Project Team')),
                    DropdownMenuItem(value: 'club', child: Text('🎯 Club Activity')),
                    DropdownMenuItem(value: 'other', child: Text('📌 Other')),
                  ],
                  onChanged: (value) => setState(() => category = value!),
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
                // TODO: Implement update group
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Group updated!')),
                );
                _loadGroups();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLeaveGroup(GroupModel group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Group?'),
        content: Text('Are you sure you want to leave "${group.groupName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await GroupService.instance.leaveGroup(
                  groupId: group.id,
                  userId: widget.user['id'],
                );

                Navigator.pop(context);
                _loadGroups();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Left the group'),
                    backgroundColor: Colors.orange,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteGroup(GroupModel group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group?'),
        content: Text(
          'Are you sure you want to delete "${group.groupName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await GroupService.instance.deleteGroup(group.id);

                Navigator.pop(context);
                _loadGroups();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Group deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

