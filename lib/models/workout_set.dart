// lib/models/workout_set.dart

import 'package:flutter/material.dart';

class WorkoutSet {
  final String name;
  final String type;
  int sets;
  int repsOrDuration;
  int caloriesBurned;

  WorkoutSet({
    required this.name,
    required this.type,
    this.sets = 1,
    this.repsOrDuration = 0,
    this.caloriesBurned = 0,
  });

  IconData get iconData {
    if (type == 'Cardio') {
      return Icons.directions_run;
    } else if (type == 'Weight Training') {
      return Icons.fitness_center;
    }
    return Icons.self_improvement;
  }
}