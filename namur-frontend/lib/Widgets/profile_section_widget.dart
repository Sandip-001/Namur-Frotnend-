// profile_section_widget.dart
import 'package:flutter/material.dart';

typedef OnSaveCallback = Future<void> Function();

class ProfileSectionWidget extends StatefulWidget {
  final String title;
  final Widget child;
  final OnSaveCallback? onSave;
  final bool initiallyExpanded;

  const ProfileSectionWidget({
    super.key,
    required this.title,
    required this.child,
    this.onSave,
    this.initiallyExpanded = false,
  });

  @override
  State<ProfileSectionWidget> createState() => _ProfileSectionWidgetState();
}

class _ProfileSectionWidgetState extends State<ProfileSectionWidget> {
  bool expanded = false;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    expanded = widget.initiallyExpanded;
  }

  Future<void> _handleSave() async {
    if (widget.onSave == null) return;
    setState(() => saving = true);
    try {
      await widget.onSave!();
      // optional: show success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerBg = Colors.green.shade50;
    final headerBorder = Border.all(color: Colors.green.shade200);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: headerBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: headerBorder,
            ),
            child: ListTile(
              title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (saving) const SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: saving ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Save', style: TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(expanded ? Icons.expand_less : Icons.expand_more, color: Colors.green.shade700),
                    onPressed: () => setState(() => expanded = !expanded),
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: widget.child,
            ),
        ],
      ),
    );
  }
}
