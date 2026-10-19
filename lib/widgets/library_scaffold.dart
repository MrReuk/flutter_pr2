import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LibraryScaffold extends StatelessWidget {
  const LibraryScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showBack = false,
  });

  final String title;
  final Widget body;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 600;
    return Scaffold(
      appBar: AppBar(
        leading: showBack
            ? BackButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/books');
                  }
                },
              )
            : null,
        title: Text(title),
        actions: [
          _NavButton(
            icon: Icons.menu_book,
            label: 'Книги',
            path: '/books',
            narrow: narrow,
          ),
          _NavButton(
            icon: Icons.people,
            label: 'Авторы',
            path: '/authors',
            narrow: narrow,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: body,
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.path,
    required this.narrow,
  });

  final IconData icon;
  final String label;
  final String path;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    if (narrow) {
      return IconButton(
        tooltip: label,
        icon: Icon(icon),
        onPressed: () => context.go(path),
      );
    }
    return TextButton.icon(
      onPressed: () => context.go(path),
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
