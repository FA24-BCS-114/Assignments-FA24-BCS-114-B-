import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../providers/nexus_providers.dart';
import 'bookmarks_hub_screen.dart';
import 'home_dashboard_screen.dart';
import 'library_explorer_screen.dart';
import 'settings_control_screen.dart';

class NexusShellScreen114 extends ConsumerWidget {
  const NexusShellScreen114({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ws = ref.watch(nexusWorkspaceProvider);
    final notifier = ref.read(nexusWorkspaceProvider.notifier);

    if (ws.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    const pages = [
      HomeDashboardScreen114(),
      LibraryExplorerScreen114(),
      BookmarksHubScreen114(),
      SettingsControlScreen114(),
    ];

    final wideLayout = MediaQuery.of(context).size.width >= 760;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (ws.latestAlert != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppConstants114.secondaryBlue.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppConstants114.accentCyan),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.notifications_active_rounded,
                      color: AppConstants114.accentCyan,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ws.latestAlert!.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                          ),
                          Text(
                            ws.latestAlert!.message,
                            style: const TextStyle(
                              color: AppConstants114.textSoftGrey,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: notifier.dismissAlert,
                      icon: const Icon(Icons.close_rounded, size: 18),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Row(
                children: [
                  if (wideLayout)
                    NavigationRail(
                      backgroundColor: AppConstants114.primaryNavy,
                      selectedIndex: ws.activeNavIndex,
                      onDestinationSelected: notifier.setNavIndex,
                      labelType: NavigationRailLabelType.all,
                      indicatorColor:
                          AppConstants114.secondaryBlue.withOpacity(0.32),
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.dashboard_outlined),
                          selectedIcon: Icon(
                            Icons.dashboard_rounded,
                            color: AppConstants114.accentCyan,
                          ),
                          label: Text('Home'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.folder_copy_outlined),
                          selectedIcon: Icon(
                            Icons.folder_copy_rounded,
                            color: AppConstants114.accentCyan,
                          ),
                          label: Text('Library'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.bookmarks_outlined),
                          selectedIcon: Icon(
                            Icons.bookmarks_rounded,
                            color: AppConstants114.accentCyan,
                          ),
                          label: Text('Bookmarks'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.settings_outlined),
                          selectedIcon: Icon(
                            Icons.settings_rounded,
                            color: AppConstants114.accentCyan,
                          ),
                          label: Text('Settings'),
                        ),
                      ],
                    ),
                  Expanded(
                    child: IndexedStack(
                      index: ws.activeNavIndex,
                      children: pages,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ws.activeNavIndex <= 1
          ? FloatingActionButton.extended(
              backgroundColor: AppConstants114.secondaryBlue,
              foregroundColor: Colors.white,
              onPressed: () async {
                final summary = await notifier.importFromDevice(
                  allowMultiple: true,
                );
                if (!context.mounted) return;
                if (summary.imported.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Imported ${summary.imported.length} PDF document(s).',
                      ),
                    ),
                  );
                } else if (summary.errors.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(summary.errors.first)),
                  );
                }
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Import PDF',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            )
          : null,
      bottomNavigationBar: wideLayout
          ? null
          : NavigationBar(
              backgroundColor: AppConstants114.primaryNavy,
              indicatorColor: AppConstants114.secondaryBlue.withOpacity(0.32),
              selectedIndex: ws.activeNavIndex,
              onDestinationSelected: notifier.setNavIndex,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(
                    Icons.home_rounded,
                    color: AppConstants114.accentCyan,
                  ),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.library_books_outlined),
                  selectedIcon: Icon(
                    Icons.library_books_rounded,
                    color: AppConstants114.accentCyan,
                  ),
                  label: 'Library',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bookmarks_outlined),
                  selectedIcon: Icon(
                    Icons.bookmarks_rounded,
                    color: AppConstants114.accentCyan,
                  ),
                  label: 'Bookmarks',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(
                    Icons.settings_rounded,
                    color: AppConstants114.accentCyan,
                  ),
                  label: 'Settings',
                ),
              ],
            ),
    );
  }
}
