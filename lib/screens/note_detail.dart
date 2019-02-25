import 'package:flutter/material.dart';
import 'package:notes_keeper/screens/note_list.dart';
import 'package:notes_keeper/models/note.dart';
import 'package:notes_keeper/utils/database_helper.dart';
import 'package:intl/intl.dart';


class NoteDetail extends StatefulWidget{

  final String appBarTitle;
  final Note note;
  NoteDetail(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail>{

  static var priorities = ['High', 'Low'];

  DatabaseHelper helper = DatabaseHelper();

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String appBarTitle;
  Note note;

  NoteDetailState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;

    titleController.text = note.title;
    descriptionController.text = note.description;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appBarTitle
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
        child: ListView(
          children: <Widget>[
            ListTile(
              title: DropdownButton(
                  items: priorities.map((String dropDownStringItem){
                    return DropdownMenuItem<String>(
                      value: dropDownStringItem,
                      child: Text(dropDownStringItem),
                    );
                  }).toList(),
                  style: titleStyle,
                  value: getPriorityAsString(note.priority),
                  onChanged: (valueSelectedByUser){
                    setState(() {
                      debugPrint('User Selected $valueSelectedByUser');
                      updatePriorityAsInt(valueSelectedByUser);
                    });
                  }
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                controller: titleController,
                style: titleStyle,
                onChanged: (value){
                  debugPrint('something changed in the edittext');
                  updateTitle();
                },
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: titleStyle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0)
                  )
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                controller: descriptionController,
                style: titleStyle,
                onChanged: (value){
                  debugPrint('something changed in the edittext');
                  updateDescription();
                },
                decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: titleStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)
                    )
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      color: Theme.of(context).primaryColorDark,
                      textColor: Theme.of(context).primaryColorLight,
                      child: Text(
                        'Save',
                        textScaleFactor: 1.5,
                      ),
                      onPressed: (){
                        setState(() {
                          debugPrint('save button clicked');
                          save();
                        });
                      }
                    ),
                  ),
                  Container(width: 5.0),
                  Expanded(
                    child: RaisedButton(
                        color: Theme.of(context).primaryColorDark,
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text(
                          'Delete',
                          textScaleFactor: 1.5,
                        ),
                        onPressed: (){
                          setState(() {
                            debugPrint('delete button clicked');
                            delete();
                          });
                        }
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  String getPriorityAsString(int value){
      String priority;
      switch(value){
        case 1:
          priority = priorities[0];
          break;
        case 2:
          priority = priorities[1];
      }
      return priority;
  }

  void updatePriorityAsInt(String value){
    switch(value){
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  void updateTitle(){
    note.title = titleController.text;
  }

  void updateDescription(){
    note.description = descriptionController.text;
  }

  void delete() async {
    if(note.id == null){
      showAlertDialog('status', 'No note was deleted');
    }
    int result = await helper.deleteNote(note.id);

    if(result != 0){
      showAlertDialog('status', 'Note deleted successfully');
    } else {
      showAlertDialog('status', 'Error deleting the note');
    }
    navigateToDetail();
  }

  void save() async{
    int result;
    note.date = DateFormat.yMMMd().format(DateTime.now());
    if(note.id != null){
      result = await helper.updateNote(note);
    } else {
      result = await helper.insertNote(note);
    }

    if(result != 0){
      showAlertDialog('status', 'Note has been saved successfully');
      navigateToDetail();
    } else {
      showAlertDialog('status', 'Error Saving the note');
    }
  }

  void showAlertDialog(String title, String message){
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
      context: context,
      builder: (_) => alertDialog
    );
  }

  void navigateToDetail() async{
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context){
              return NotesList();
            }
        )
    );
  }

}