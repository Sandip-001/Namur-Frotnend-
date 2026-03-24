import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final List<Widget>? extraActions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBack = false,
    this.extraActions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      //automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),

      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff107B28), // top gradient
              Color(0xff4C7B10), // bottom gradient
            ],
          ),
        ),
      ),
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          letterSpacing: .5,
          fontFamily: 'Poppins',
        ),
      ),
      actions: [
        if (extraActions != null) ...extraActions!,
        if (showBack)
          IconButton(
            icon: const Icon(
              Icons.keyboard_arrow_left,
              size: 35,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        if (showBack) const SizedBox(width: 10),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
