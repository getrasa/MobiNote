import 'package:drift_db_viewer/drift_db_viewer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobi_note/database/notes.dart';
import 'create_note.dart';
import 'database/database_def.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(MobiNoteDatabase());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final database = Get.find<MobiNoteDatabase>();
  late Future<List<Note>> _notesFuture;

  void showDatabase() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => DriftDbViewer(database),
    ));
  }

  void createNewNotePage() {
    openNoteEditorPage(-1, '', 'content');
  }

  void openNoteEditorPage(int id, String title, String content) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return NoteEditorPage(id: id, title: title, content: content);
        },
      ),
    ).then((value) => updateNotesListView());
  }

  Future<List<Note>> fetchNotes() {
    return database.select(database.notes).get();
  }

  void updateNotesListView() {
    setState(() {
      _notesFuture = fetchNotes();
    });
  }

  @override
  void initState() {
    super.initState();
    _notesFuture = fetchNotes();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: showDatabase,
            tooltip: 'Show Database',
            icon: const Icon(Icons.storage),
          ),
        ],
      ),
      body: FutureBuilder<List<Note>>(
          future: _notesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData) {
              List<Note> allNotes = snapshot.data?.toList() ?? [];
              List<Widget> noteListWidgets = [];
              noteListWidgets.add(const SizedBox(height: 30));
              for (var note in allNotes) {
                noteListWidgets.add(NoteWidget(note: note, noteAction: openNoteEditorPage, updateViewAction: updateNotesListView));
                noteListWidgets.add(const SizedBox(height: 30));
              }

              return Center(
                child: ListView(
                  children: noteListWidgets,
                ),
              );
            } else {
              return const Center(child: Text("No notes found"));
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewNotePage,
        tooltip: 'Create a new Note',
        child: const Icon(Icons.create),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
