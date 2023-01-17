import 'package:flutter/material.dart';
import 'package:trial/services/auth/auth_service.dart';
import 'package:trial/services/crud/notes_service.dart';
import 'package:trial/utilities/generics/get_arguments.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({Key? key}) : super(key: key);

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  DatabaseNotes? _note;
  late final NotesService _notesService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _notesService = NotesService();
    _textController = TextEditingController();
    super.initState();
  }

  ///listener -update current node on text change
  void _textControllerListner() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textController.text;
    await _notesService.updateNote(
      note: note,
      text: text,
    );
  }

  void _setUpTextControllerListener(){
    _textController.removeListener(_textControllerListner);
    _textController.addListener(_textControllerListner);
  }

  Future<DatabaseNotes> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<DatabaseNotes>();
    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;

    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }

    ///unwrap (!) current user
    final currentUser = AuthService.firebase().currentUser!;

    /// unwrap email
    final email = currentUser.email!;
    final owner = await _notesService.getUser(email: email);
    final newNote = await _notesService.createNote(owner: owner);
    _note = newNote;
    return newNote;
  }

  ///delete  note if instance created but empty
  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      _notesService.deleteNote(id: note.id);
    }
  }

  ///Auto-save notes
  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (note != null && text.isNotEmpty) {
      await _notesService.updateNote(
        note: note,
        text: text,
      );
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Note"),
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context,snapshot) {
          switch (snapshot.connectionState){
            case ConnectionState.done:
              _setUpTextControllerListener();
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: "start typing your note...",
                ),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
