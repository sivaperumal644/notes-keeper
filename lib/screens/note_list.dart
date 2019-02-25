import 'package:flutter/material.dart';
import 'package:notes_keeper/screens/note_detail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:notes_keeper/models/note.dart';
import 'package:notes_keeper/utils/database_helper.dart';

class NotesList extends StatefulWidget{

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int count = 0;

  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}

class NoteListState extends State<NotesList>{

  DatabaseHelper databaseHelper = DatabaseHelper();
  int count = 0;
  List<Note> noteList;

  @override
  Widget build(BuildContext context) {

    if(noteList == null){
      noteList = List<Note>();
      updateListView();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notes Keeper'
        ),
      ),
      body: getNotesListView(),
      floatingActionButton: FloatingActionButton(
          onPressed:(){
            debugPrint('Add note');
            navigateToDetail(Note('', '', 2), 'Add Note');
          },
        tooltip: 'Add note',
        child: Icon(Icons.add),
      ),
    );
  }
  ListView getNotesListView(){
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position){
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: getPriorityColor(this.noteList[position].priority),
              child: getPriorityIcon(this.noteList[position].priority),
            ),
            title: Text(
              this.noteList[position].title,
              style: titleStyle,
            ),
            subtitle: Text(this.noteList[position].date),
            trailing:GestureDetector(
              child:Icon(Icons.delete, color: Colors.grey),
              onTap: (){
                delete(context, noteList[position]);
              },
            ),
            onTap: (){
              debugPrint('tapped');
              navigateToDetail(this.noteList[position], 'Edit Note');
            },
          ),
        );
      },
    );
  }

  Icon getPriorityIcon(int priority){
    switch(priority){
      case 1:
        return Icon(Icons.play_arrow);
      case 2:
        return Icon(Icons.keyboard_arrow_right);
      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }

  void delete(BuildContext context, Note note) async{
    int result = await databaseHelper.deleteNote(note.id);
    if(result != 0){
      _showSnackBar(context, 'Note Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message){
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  Color getPriorityColor(int priority){
    switch(priority){
      case 1:
        return Colors.red;
      case 2:
        return Colors.yellow;
      default:
        return Colors.yellow;
    }
  }

  void navigateToDetail(Note note, String title) async{
    bool result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context){
              return NoteDetail(note, title);
            }
        )
    );
    if(result == true){
      updateListView();
    }
  }

  void updateListView(){
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database){
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList){
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }
}