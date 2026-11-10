import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kDarkMode = 'app_theme_dark_mode';
const _kUserName = 'user_display_name';
const _kNotes = 'notes_list';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool(_kDarkMode) ?? false;

  runApp(MyApp(prefs: prefs, initialDark: isDark));
}

class NoteItem {
  final String id;
  final String title;
  final String dateText;
  bool isCompleted;

  NoteItem({
    required this.id,
    required this.title,
    required this.dateText,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'dateText': dateText,
    'isCompleted': isCompleted,
  };

  factory NoteItem.fromJson(Map<String, dynamic> json) {
    return NoteItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      dateText: json['dateText'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

class MyApp extends StatefulWidget {
  final SharedPreferences prefs;
  final bool initialDark;

  const MyApp({super.key, required this.prefs, required this.initialDark});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDark = widget.initialDark;

  void _setDark(bool value) {
    setState(() => _isDark = value);
    widget.prefs.setBool(_kDarkMode, value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(
        prefs: widget.prefs,
        isDark: _isDark,
        onThemeChanged: _setDark,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final SharedPreferences prefs;
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;

  const HomeScreen({
    super.key,
    required this.prefs,
    required this.isDark,
    required this.onThemeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String _username;
  late List<NoteItem> _notes;
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final savedName = widget.prefs.getString(_kUserName);
    _username = savedName ?? 'Guest User';
    _nameController.text = savedName ?? '';

    final raw = widget.prefs.getString(_kNotes);
    _notes = raw == null
        ? []
        : (jsonDecode(raw) as List<dynamic>)
        .map((e) => NoteItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveName() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    widget.prefs.setString(_kUserName, name);
    setState(() => _username = name);
  }

  void _saveNotes() {
    final json = jsonEncode(_notes.map((n) => n.toJson()).toList());
    widget.prefs.setString(_kNotes, json);
  }

  void _addNote() {
    final title = _noteController.text.trim();
    if (title.isEmpty) return;

    final now = DateTime.now().toString().substring(0, 16);
    setState(() {
      _notes.insert(
        0,
        NoteItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          dateText: now,
        ),
      );
    });
    _noteController.clear();
    _saveNotes();
  }

  void _toggleNote(NoteItem note) {
    setState(() => note.isCompleted = !note.isCompleted);
    _saveNotes();
  }

  void _deleteNote(NoteItem note) {
    setState(() => _notes.remove(note));
    _saveNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello, $_username'),
        actions: [
          Switch(value: widget.isDark, onChanged: widget.onThemeChanged),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _saveName, child: const Text('Save')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'New note',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _addNote, child: const Text('Add')),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  final note = _notes[index];
                  return ListTile(
                    leading: Checkbox(
                      value: note.isCompleted,
                      onChanged: (_) => _toggleNote(note),
                    ),
                    title: Text(note.title),
                    subtitle: Text(note.dateText),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteNote(note),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}