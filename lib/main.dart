import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() => runApp(const AsNotsApp());

class AsNotsApp extends StatelessWidget {
  const AsNotsApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'AS NOTS',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3157D5)),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF7F8FC),
    ),
    home: const NotesHome(),
  );
}

class Note {
  final String id;
  String title;
  String body;
  final String createdAt;
  Note({required this.id, required this.title, required this.body, required this.createdAt});
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'body': body, 'createdAt': createdAt};
  factory Note.fromJson(Map<String, dynamic> j) => Note(
    id: j['id'] ?? '', title: j['title'] ?? '', body: j['body'] ?? '', createdAt: j['createdAt'] ?? '');
}

class NotesHome extends StatefulWidget {
  const NotesHome({super.key});
  @override
  State<NotesHome> createState() => _NotesHomeState();
}

class _NotesHomeState extends State<NotesHome> {
  final List<Note> notes = [];
  final search = TextEditingController();
  bool loading = true;

  @override
  void initState() { super.initState(); loadNotes(); }

  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('notes') ?? '[]';
    try {
      final list = jsonDecode(raw) as List;
      notes..clear()..addAll(list.map((e) => Note.fromJson(Map<String,dynamic>.from(e))));
    } catch (_) { notes.clear(); }
    if (mounted) setState(() => loading = false);
  }

  Future<void> saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notes', jsonEncode(notes.map((e) => e.toJson()).toList()));
  }

  Future<void> openEditor([Note? note]) async {
    final title = TextEditingController(text: note?.title ?? '');
    final body = TextEditingController(text: note?.body ?? '');
    final result = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => NoteEditor(title: title, body: body)));
    if (result == true) {
      final t = title.text.trim();
      final b = body.text.trim();
      if (t.isEmpty && b.isEmpty) return;
      setState(() {
        if (note == null) {
          notes.insert(0, Note(id: DateTime.now().microsecondsSinceEpoch.toString(), title: t.isEmpty ? 'Untitled' : t, body: b, createdAt: DateTime.now().toIso8601String()));
        } else { note.title = t.isEmpty ? 'Untitled' : t; note.body = b; }
      });
      await saveNotes();
    }
  }

  Future<void> deleteNote(Note n) async {
    setState(() => notes.removeWhere((x) => x.id == n.id));
    await saveNotes();
  }

  @override
  void dispose() { search.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final filtered = notes.where((n) => ('${n.title} ${n.body}').toLowerCase().contains(search.text.toLowerCase())).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('AS NOTS', style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: false),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => openEditor(), icon: const Icon(Icons.add), label: const Text('New Note')),
      body: loading ? const Center(child: CircularProgressIndicator()) : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: search, onChanged: (_) => setState((){}), decoration: InputDecoration(
            hintText: 'Search your notes', prefixIcon: const Icon(Icons.search),
            filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
          const SizedBox(height: 16),
          Expanded(child: filtered.isEmpty ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.sticky_note_2_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12), Text(notes.isEmpty ? 'No notes yet' : 'No matching notes', style: TextStyle(color: Colors.grey.shade700, fontSize: 17)),
            const SizedBox(height: 6), const Text('Tap “New Note” to get started'),
          ])) : ListView.builder(itemCount: filtered.length, itemBuilder: (_, i) {
            final n = filtered[i];
            return Card(color: Colors.white, margin: const EdgeInsets.only(bottom: 12), child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(n.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Padding(padding: const EdgeInsets.only(top: 6), child: Text(n.body.isEmpty ? 'No additional text' : n.body, maxLines: 2, overflow: TextOverflow.ellipsis)),
              onTap: () => openEditor(n),
              trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => showDialog(context: context, builder: (_) => AlertDialog(
                title: const Text('Delete note?'), content: const Text('This note will be deleted from this device.'),
                actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  TextButton(onPressed: () { Navigator.pop(context); deleteNote(n); }, child: const Text('Delete'))]))),
            ));
          })),
        ]),
      ),
    );
  }
}

class NoteEditor extends StatelessWidget {
  final TextEditingController title, body;
  const NoteEditor({super.key, required this.title, required this.body});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Edit Note'), actions: [TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('SAVE'))]),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      TextField(controller: title, maxLines: 1, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), decoration: const InputDecoration(hintText: 'Title', border: InputBorder.none)),
      const Divider(),
      Expanded(child: TextField(controller: body, expands: true, maxLines: null, textAlignVertical: TextAlignVertical.top, decoration: const InputDecoration(hintText: 'Write your note...', border: InputBorder.none))),
    ])),
  );
}
