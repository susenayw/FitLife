import 'package:flutter/material.dart';

class WorkoutSet {
  final String id; // Unique ID for Firestore
  final String name;
  final String type;
  int sets;
  int repsOrDuration;
  int caloriesBurned;

  WorkoutSet({
    required this.name,
    required this.type,
    this.id = '',
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

  // ---------------------------------------------------
  // FIREBASE SERIALIZATION
  // ---------------------------------------------------

  // Converts WorkoutSet object to a Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'sets': sets,
      'repsOrDuration': repsOrDuration,
      'caloriesBurned': caloriesBurned,
      'timestamp': DateTime.now().toIso8601String(), // Used for sorting/tracking
    };
  }

  // Creates a WorkoutSet object from a Firestore Map
  static WorkoutSet fromMap(String id, Map<String, dynamic> map) {
    return WorkoutSet(
      id: id,
      name: map['name'] ?? 'Unknown Workout',
      type: map['type'] ?? 'Cardio',
      sets: map['sets'] ?? 1,
      repsOrDuration: map['repsOrDuration'] ?? 0,
      caloriesBurned: map['caloriesBurned'] ?? 0,
    );
  }

  // copyWith method for updates
  WorkoutSet copyWith({
    String? id,
    String? name,
    String? type,
    int? sets,
    int? repsOrDuration,
    int? caloriesBurned,
  }) {
    return WorkoutSet(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      sets: sets ?? this.sets,
      repsOrDuration: repsOrDuration ?? this.repsOrDuration,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
    );
  }
}