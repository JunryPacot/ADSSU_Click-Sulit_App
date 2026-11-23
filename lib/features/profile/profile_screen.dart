import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/mock/mock_database.dart';

/// Screen 7: Student Profile Screen
/// Fulfills Task 1 (Screen Development), Task 2 (Stack Navigation),
/// and Task 2 of Lab 2 (Local Storage UPDATE of student record).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showEditProfileDialog(BuildContext context, MockDatabase db) {
    final nameController = TextEditingController(text: db.currentUser.name);
    final collegeController = TextEditingController(text: db.currentUser.college);
    final bioController = TextEditingController(text: db.currentUser.bio);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Student Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Full Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.cardWhite,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              const Text('College / Department', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              TextField(
                controller: collegeController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.cardWhite,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Bio', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              TextField(
                controller: bioController,
                maxLines: 2,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.cardWhite,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDarkGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                // UPDATE CRUD: Persists updated profile to SharedPreferences
                await db.updateProfile(
                  name: nameController.text.trim(),
                  college: collegeController.text.trim(),
                  bio: bioController.text.trim(),
                );
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated and saved to SharedPreferences!')),
                  );
                }
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final user = db.currentUser;
    final myListings = db.myItems;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDarkGreen,
        foregroundColor: AppColors.cardWhite,
        title: const Text(
          'Student Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Student Profile Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primaryDarkGreen,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0] : 'S',
                      style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: const TextStyle(fontSize: 13, color: AppColors.primaryDarkGreen, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.college,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: AppColors.textMedium),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Student ID: ${user.studentId}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.bio,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryDarkGreen,
                      side: const BorderSide(color: AppColors.primaryDarkGreen),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit Profile (CRUD Update)'),
                    onPressed: () => _showEditProfileDialog(context, db),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Statistics Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${myListings.length}',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryDarkGreen),
                        ),
                        const SizedBox(height: 4),
                        const Text('My Listings', style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${db.savedItems.length + db.savedExternalProducts.length}',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.accentGold),
                        ),
                        const SizedBox(height: 4),
                        const Text('Saved Records', style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // My Listings Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('My Campus Listings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      TextButton.icon(
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add New'),
                        onPressed: () => context.push('/add-item'),
                      ),
                    ],
                  ),
                  if (myListings.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Text('You have not posted any listings yet.', style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
                    )
                  else
                    ...myListings.map(
                      (item) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text('₱${item.price.toStringAsFixed(2)} • ${item.category}'),
                        trailing: const Icon(Icons.chevron_right, size: 18),
                        onTap: () => context.push('/item-detail', extra: item),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Action
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Log Out (Clear Session in SharedPreferences)'),
                onPressed: () async {
                  await db.logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
