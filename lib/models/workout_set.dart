// lib/models/workout_set.dart (KODE LENGKAP)

import 'package:flutter/material.dart';

class WorkoutSet {
  final String id; // ID unik untuk Firestore
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

  // Konversi objek WorkoutSet menjadi Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'sets': sets,
      'repsOrDuration': repsOrDuration,
      'caloriesBurned': caloriesBurned,
      'timestamp': DateTime.now().toIso8601String(), // Untuk sorting/tracking
    };
  }

  // Membuat objek WorkoutSet dari Map Firestore
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

  // Metode copyWith untuk pembaruan
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