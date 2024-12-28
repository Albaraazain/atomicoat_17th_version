// lib/features/shared/widgets/main_drawer.dart
import 'package:atomicoat_17th_version/features/auth/data/models/user_model.dart';
import 'package:atomicoat_17th_version/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;
        final isSuperAdmin = user?.role == UserRole.superAdmin;
        final isAdmin = user?.role == UserRole.admin;

        return Drawer(
          child: Column(
            children: [
              _buildHeader(user),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      leading: Icon(Icons.dashboard),
                      title: Text('Dashboard'),
                      onTap: () => _navigateTo(context, '/dashboard'),
                    ),
                    if (isSuperAdmin) ...[
                      ListTile(
                        leading: Icon(Icons.precision_manufacturing),
                        title: Text('Manage Machines'),
                        onTap: () => _navigateTo(context, '/machines'),
                      ),
                      ListTile(
                        leading: Icon(Icons.admin_panel_settings),
                        title: Text('Admin Management'),
                        onTap: () => _navigateTo(context, '/admin-management'),
                      ),
                    ],
                    if (isAdmin) ...[
                      ListTile(
                        leading: Icon(Icons.people),
                        title: Text('User Management'),
                        onTap: () => _navigateTo(context, '/users'),
                      ),
                      ListTile(
                        leading: Icon(Icons.access_time),
                        title: Text('Access Requests'),
                        onTap: () => _navigateTo(context, '/access-requests'),
                      ),
                    ],
                    ListTile(
                      leading: Icon(Icons.science),
                      title: Text('Recipes'),
                      onTap: () => _navigateTo(context, '/recipes'),
                    ),
                    ListTile(
                      leading: Icon(Icons.analytics),
                      title: Text('Experiments'),
                      onTap: () => _navigateTo(context, '/experiments'),
                    ),
                    ListTile(
                      leading: Icon(Icons.build),
                      title: Text('Maintenance'),
                      onTap: () => _navigateTo(context, '/maintenance'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Profile'),
                      onTap: () => _navigateTo(context, '/profile'),
                    ),
                    ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Logout'),
                      onTap: () => _handleLogout(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(UserModel? user) {
    return UserAccountsDrawerHeader(
      accountName: Text(user?.name ?? 'User'),
      accountEmail: Text(user?.email ?? ''),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        child: Text(
          user?.name.substring(0, 1).toUpperCase() ?? 'U',
          style: TextStyle(fontSize: 24),
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.blue,
      ),
    );
  }

  void _navigateTo(BuildContext context, String route) {
    Navigator.pop(context); // Close drawer
    Navigator.pushNamed(context, route);
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<AuthProvider>().signOut();
    }
  }
}

// lib/features/dashboard/screens/home_dashboard_screen.dart
class HomeDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;
        final isSuperAdmin = user?.role == UserRole.superAdmin;
        final isAdmin = user?.role == UserRole.admin;

        return Scaffold(
          appBar: AppBar(
            title: Text('Dashboard'),
          ),
          drawer: MainDrawer(),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(user),
                SizedBox(height: 16),
                if (isSuperAdmin) _buildSuperAdminDashboard(context),
                if (isAdmin) _buildAdminDashboard(context),
                if (!isSuperAdmin && !isAdmin) _buildUserDashboard(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard(UserModel? user) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user?.name}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Role: ${user?.role.toString().split('.').last}',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String route,
    required Color color,
  }) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: color),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSystemStatusCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildStatusRow('Active Machines', '12', Colors.green),
            _buildStatusRow('Maintenance', '3', Colors.orange),
            _buildStatusRow('Inactive', '2', Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildActivityItem(
              'New machine registered',
              'Serial: ABC123',
              Icons.add_circle,
              Colors.green,
            ),
            _buildActivityItem(
              'Maintenance scheduled',
              'Machine: XYZ789',
              Icons.build,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMachineStatusCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Machine Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildStatusRow('Active Users', '8', Colors.green),
            _buildStatusRow('Pending Requests', '3', Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingRequestsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pending Requests',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/access-requests'),
                  child: Text('View All'),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildRequestItem('John Doe', 'Machine: ABC123'),
            _buildRequestItem('Jane Smith', 'Machine: XYZ789'),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestItem(String name, String machine) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            child: Text(name[0]),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  machine,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMachineAccessCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Machine Access',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildAccessItem('Machine ABC123', 'Active', Colors.green),
            _buildAccessItem('Machine XYZ789', 'Pending', Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessItem(String machine, String status, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(machine),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentExperimentsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Experiments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/experiments'),
                  child: Text('View All'),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildExperimentItem(
              'Experiment A',
              'Duration: 2h 30m',
              Icons.science,
              Colors.blue,
            ),
            _buildExperimentItem(
              'Experiment B',
              'Duration: 1h 45m',
              Icons.science,
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperimentItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuperAdminDashboard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('System Overview'),
        Row(
          children: [
            Expanded(
              child: _buildQuickAccessCard(
                context: context,
                title: 'Machines',
                icon: Icons.precision_manufacturing,
                route: '/machines',
                color: Colors.blue,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildQuickAccessCard(
                context: context,
                title: 'Admins',
                icon: Icons.admin_panel_settings,
                route: '/admin-management',
                color: Colors.green,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        _buildSystemStatusCard(),
        SizedBox(height: 16),
        _buildRecentActivityCard(),
      ],
    );
  }

  Widget _buildAdminDashboard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Machine Management'),
        Row(
          children: [
            Expanded(
              child: _buildQuickAccessCard(
                context: context,
                title: 'Users',
                icon: Icons.people,
                route: '/users',
                color: Colors.orange,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildQuickAccessCard(
                context: context,
                title: 'Requests',
                icon: Icons.access_time,
                route: '/access-requests',
                color: Colors.purple,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        _buildMachineStatusCard(),
        SizedBox(height: 16),
        _buildPendingRequestsCard(context),
      ],
    );
  }

  Widget _buildUserDashboard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Quick Access'),
        Row(
          children: [
            Expanded(
              child: _buildQuickAccessCard(
                context: context,
                title: 'Recipes',
                icon: Icons.science,
                route: '/recipes',
                color: Colors.indigo,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildQuickAccessCard(
                context: context,
                title: 'Experiments',
                icon: Icons.analytics,
                route: '/experiments',
                color: Colors.teal,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        _buildMachineAccessCard(),
        SizedBox(height: 16),
        _buildRecentExperimentsCard(context),
      ],
    );
  }
}