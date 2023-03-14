// ignore_for_file: non_constant_identifier_names, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_todo_app/data/local_storage.dart';
import 'package:flutter_todo_app/main.dart';
import 'package:flutter_todo_app/widgets/custom_search_delegete.dart';
import 'package:flutter_todo_app/widgets/task_list_item.dart';

import '../models/task_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Task> _allTasks;
  late LocalStorage _LocalStorage;


  @override
  void initState()  {
    super.initState();
    _LocalStorage = locator<LocalStorage>();
    _getAllTaskFromDb();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            _showAddTaskBottomSheet();
          },
          child: const Text(
            'TO DO LIST',
            style: TextStyle(color: Colors.white, fontFamily : 'TiltWarp'),
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(onPressed: () {
            _showSearchPage();
          }, icon: const Icon(Icons.search_rounded)),
          IconButton(
              onPressed: () {
                _showAddTaskBottomSheet();
              },
              icon: const Icon(Icons.add)),
        ],
      ),
      body: _allTasks.isNotEmpty
          ? ListView.builder(
              itemBuilder: (context, index) {
                var _oAnkiListeElemani = _allTasks[index];
                return Dismissible(
                  background: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        SizedBox(width: 8),
                        Text('REMOVED',style: TextStyle(fontSize: 18),),
                      ]),
                  key: Key(_oAnkiListeElemani.id),
                  onDismissed: (direction) {
                    _allTasks.removeAt(index);
                    _LocalStorage.deleteTask(task: _oAnkiListeElemani);
                    setState(() {});
                  },
                  child: TaskItem(task: _oAnkiListeElemani),
                );
              },
              itemCount: _allTasks.length,
            )
          : const Center(
              child: Text('LIST IS EMPTY' , style: TextStyle(fontSize: 24, fontFamily: 'Tilt Wrap'),),
            ),
    );
  }

  void _showAddTaskBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            width: MediaQuery.of(context).size.width,
            child: ListTile(
              title: TextField(
                autofocus: true,
                  style: const TextStyle(fontSize: 20),
                  decoration: const InputDecoration(
                    hintText: 'What is Task? ',
                    border: InputBorder.none,
                  ),
                  onSubmitted: (value) {
                    Navigator.of(context).pop();
                    if (value.length > 3) {
                      DatePicker.showTimePicker(context,
                          showSecondsColumn: false, onConfirm: (time) async {
                        var yeniEklenecekGorev =
                            Task.create(name: value, createdAt: time);
                        _allTasks.add(yeniEklenecekGorev);
                       await _LocalStorage.addTask(task: yeniEklenecekGorev);
                        setState(() {});
                      });
                    }
                  }),
            ),
          );
        });
  }
  
  void _getAllTaskFromDb() async {
    _allTasks = await _LocalStorage.getAllTask();
    setState(() {
      
    });
  }
  
  void _showSearchPage() async {
  await  showSearch(context: context, delegate: CustomSearchDelegate(allTasks: _allTasks));
  _getAllTaskFromDb();
  }
}
