import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:json_serializable/json_serializable.dart';
import 'package:uuid/uuid.dart';

import 'package:todo/objects/ColorChoice.dart';

enum TodoCardSettings { add, edit, delete }

class TodoObject {
  TodoObject(this.title, this.icon, this.colorid, {this.tasks}) {
    var choice = ColorChoices.choices[colorid % ColorChoices.choices.length];
    this.color = choice.primary;
    this.gradient = LinearGradient(
        colors: choice.gradient,
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter);
    if (this.tasks == null) {
      this.tasks = <DateTime, List<TaskObject>>{};
    }
    this.uuid = Uuid().v1();
  }

  TodoObject.import(String uuidS, this.title, int sortID, ColorChoice color,
      IconData icon, this.tasks) {
    this.sortID = sortID;
    this.color = color.primary;
    this.gradient = LinearGradient(
        colors: color.gradient,
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter);
    this.icon = icon;
    this.uuid = uuidS;
    if (this.tasks == null) {
      this.tasks = {};
    }
  }

  String uuid;
  int colorid;
  int sortID;
  String title;
  Color color;
  LinearGradient gradient;
  IconData icon;
  Map<DateTime, List<TaskObject>> tasks;

  int taskAmount() {
    int amount = 0;
    tasks.values.forEach((list) {
      amount += list.length;
    });
    return amount;
  }

  //List<TaskObject> tasks;

  double percentComplete() {
    assert(tasks != null);
    if (tasks.isEmpty) {
      return 1.0;
    }
    int completed = 0;
    int amount = 0;
    tasks.values.forEach((list) {
      amount += list.length;
      list.forEach((task) {
        if (task.isCompleted()) {
          completed++;
        }
      });
    });
    return completed / amount;
  }

  // static TodoObject fromJSON(String s) => fromMap(jsonDecode(s));
  static TodoObject fromMap(Map<String, dynamic> map) {
    List<dynamic> tasks = map['tasks'];
    List<TaskObject> decodedTasks = tasks.map((e) => TaskObject.fromMap(e));

    // FIXME: this is really stupid
    Map<DateTime, List<TaskObject>> stupidMap = {};

    for (TaskObject to in decodedTasks) {
      if (stupidMap[to.date] == null) {
        stupidMap[to.date] = [];
      }
      stupidMap[to.date].add(to);
    }

    return TodoObject(map['title'], IconData(map['icon']), map['color'],
        tasks: stupidMap);
  }

  // String toJSON() => jsonEncode(toMap());
  Map<String, dynamic> toMap() {
    var flatTasks = <TaskObject>[];
    tasks.forEach((date, tasks) {
      for (TaskObject t in tasks) {
        flatTasks.add(t);
      }
    });

    var encodedTasks = flatTasks.map((e) => e.toMap());

    return {
      'title': title,
      'icon': icon.codePoint,
      'color': colorid,
      'tasks': encodedTasks
    };
  }
}

class TaskObject {
  DateTime date;
  String task;
  bool _completed;

  TaskObject(String task, DateTime date) {
    this.task = task;
    this.date = date;
    this._completed = false;
  }

  TaskObject.import(String task, DateTime date, bool completed) {
    this.task = task;
    this.date = date;
    this._completed = completed;
  }

  void setComplete(bool value) {
    _completed = value;
  }

  bool isCompleted() => _completed;

  static TaskObject fromJSON(String s) => fromMap(jsonDecode(s));
  static TaskObject fromMap(Map<String, dynamic> map) =>
      TaskObject(map['task'], DateTime.parse(map['date']));

  // String toJSON() => jsonEncode(toMap());
  dynamic toMap() => {'date': date.toString(), 'task': task};
}
