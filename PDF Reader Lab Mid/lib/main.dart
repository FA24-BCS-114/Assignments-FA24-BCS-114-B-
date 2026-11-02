import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'constants/app_constants.dart';
import 'providers/nexus_providers.dart';
import 'screens/cyber_scanner_screen.dart';
import 'screens/nexus_shell_screen.dart';
import 'screens/pdf_reader_workspace.dart';
import 'screens/pdf_to_image_screen.dart';
import 'theme/nexus_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: PdfReader114App()));
}

class PdfReader114App extends ConsumerStatefulWidget {
  const PdfReader114App({super.key});

  @override
  ConsumerState<PdfReader114App> createState() => _PdfReader114AppState();
}

class _PdfReader114AppState extends ConsumerState<PdfReader114App> {
  bool _handledShotRoute = false;

  @override
  Widget build(BuildContext context) {
    final ws = ref.watch(nexusWorkspaceProvider);
    final shot = Uri.base.queryParameters['shot'];

    if (!ws.isLoading && !_handledShotRoute && shot != null && shot.isNotEmpty) {
      _handledShotRoute = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final notifier = ref.read(nexusWorkspaceProvider.notifier);
        if (shot == 'library') {
          notifier.setNavIndex(1);
        } else if (shot == 'library_grid') {
          notifier.setNavIndex(1);
          if (!ws.isGridView) notifier.toggleGridView();
        } else if (shot == 'bookmarks') {
          notifier.setNavIndex(2);
        } else if (shot == 'settings') {
          notifier.setNavIndex(3);
        }
      });
    }

    Widget homeWidget = const NexusShellScreen114();
    if (!ws.isLoading && shot != null && ws.documents.isNotEmpty) {
      final targetDoc = ws.documents.firstWhere(
        (d) => d.id == 'doc_114_arch',
        orElse: () => ws.documents.first,
      );
      if (shot == 'reader') {
        homeWidget = PdfReaderWorkspace114(
          doc: targetDoc,
          initialPageOverride: 1,
        );
      } else if (shot == 'reader_annotate') {
        homeWidget = PdfReaderWorkspace114(
          doc: targetDoc,
          initialPageOverride: 1,
          openAnnotationToolbarInitially: true,
        );
      } else if (shot == 'reader_search') {
        homeWidget = PdfReaderWorkspace114(
          doc: targetDoc,
          initialPageOverride: 1,
          initialSearchQuery: 'Architecture',
        );
      } else if (shot == 'scanner') {
        homeWidget = const CyberScannerScreen114();
      } else if (shot == 'converter') {
        homeWidget = PdfToImageScreen114(initialDocument: ws.documents.last);
      }
    }

    return MaterialApp(
      title: AppConstants114.appName,
      debugShowCheckedModeBanner: false,
      theme: NexusTheme114.lightFallbackTheme,
      darkTheme: NexusTheme114.darkTheme,
      themeMode: ws.settings.darkAppTheme ? ThemeMode.dark : ThemeMode.light,
      home: homeWidget,
    );
  }
}
