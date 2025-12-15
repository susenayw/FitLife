import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

// --- ENUM FOR RUN STATUS ---
enum RunStatus { initial, running, stopped }

class FreeRunScreen extends StatefulWidget {
  const FreeRunScreen({super.key});

  @override
  State<FreeRunScreen> createState() => _FreeRunScreenState();
}

class _FreeRunScreenState extends State<FreeRunScreen> {
  // --- STATE MANAGEMENT ---
  RunStatus _status = RunStatus.initial;
  Timer? _timer;
  int _secondsElapsed = 0;
  double _distanceMeters = 0.0;
  double _caloriesBurned = 0.0;

  final TextEditingController _distanceController = TextEditingController();

  // --- TIMER LOGIC ---
  void _startRun() {
    if (_status == RunStatus.running) return;

    // Reset if previously stopped/initial
    if (_status == RunStatus.stopped || _status == RunStatus.initial) {
      _secondsElapsed = 0;
      _caloriesBurned = 0.0;
      // Distance is maintained from manual input, but must be validated
      _validateAndSetDistance();
    }

    setState(() {
      _status = RunStatus.running;
    });

    // Start timer every 1 second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
        _calculateCalories(); // Recalculate calories every second
      });
    });
  }

  void _stopRun() {
    _timer?.cancel();
    setState(() {
      _status = RunStatus.stopped;
      // Call final calculation after stopping
      _calculateCalories();
    });
    // Display final result SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Run Finished! Calories Burned: ${_caloriesBurned.toStringAsFixed(1)} Kcal')),
    );
  }

  void _resetRun() {
    _timer?.cancel();
    setState(() {
      _status = RunStatus.initial;
      _secondsElapsed = 0;
      _distanceMeters = 0.0;
      _caloriesBurned = 0.0;
      _distanceController.clear();
    });
  }

  // --- MET CALCULATION LOGIC ---
  void _calculateCalories() {
    // Get data from UserProvider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final weightKg = userProvider.currentUser?.weight ?? 70.0; // Default 70 kg if data is missing

    // Time in hours
    final timeHours = _secondsElapsed / 3600.0; // 3600 seconds = 1 hour

    // 1. Determine MET Value
    // Assume moderate running (MET 9.8)
    const double metValue = 9.8;

    // 2. Calculation
    // Formula: Calories Burned = (MET × Body Weight (kg) × Time (hours)) × 1.05
    double calories = (metValue * weightKg * timeHours) * 1.05;

    setState(() {
      _caloriesBurned = calories;
    });
  }

  // --- MANUAL DISTANCE INPUT LOGIC ---
  void _validateAndSetDistance() {
    final double? inputDistance = double.tryParse(_distanceController.text);
    if (inputDistance != null && inputDistance > 0) {
      // Input is in meters
      _distanceMeters = inputDistance;
    } else {
      _distanceMeters = 0.0; // Default distance if input is empty/invalid
    }
  }

  // Listener for input changes
  @override
  void initState() {
    super.initState();
    _distanceController.addListener(_validateAndSetDistance);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _distanceController.removeListener(_validateAndSetDistance);
    _distanceController.dispose();
    super.dispose();
  }

  // --- HELPER WIDGETS ---
  String _formatTime(int totalSeconds) {
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;

    final String hoursStr = hours.toString().padLeft(2, '0');
    final String minutesStr = minutes.toString().padLeft(2, '0');
    final String secondsStr = seconds.toString().padLeft(2, '0');

    return '$hoursStr:$minutesStr:$secondsStr';
  }

  // --- MAIN BUILD WIDGET ---
  @override
  Widget build(BuildContext context) {
    // Consume UserProvider to get Body Weight
    final userProvider = Provider.of<UserProvider>(context);
    final weightKg = userProvider.currentUser?.weight.toStringAsFixed(0) ?? '70'; // Display user's body weight

    final runDataContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Screen Title
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_run_outlined, color: Colors.white, size: 30),
            SizedBox(width: 8),
            Text('Free Run', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.1),

        // Timer
        const Text('Time', style: TextStyle(fontSize: 30, color: Colors.white70)),
        Text(
          _formatTime(_secondsElapsed),
          style: TextStyle(
            fontSize: 55,
            fontWeight: FontWeight.bold,
            color: _status == RunStatus.running ? Colors.lightGreenAccent : Colors.white,
            letterSpacing: 3,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.05),

        // Distance
        const Text('Distance', style: TextStyle(fontSize: 30, color: Colors.white70)),

        // Distance Input (Shown when INITIAL/STOPPED)
        if (_status != RunStatus.running)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60.0),
            child: TextField(
              controller: _distanceController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
              decoration: InputDecoration(
                hintText: '---M',
                hintStyle: const TextStyle(color: Colors.white54, fontSize: 48),
                filled: true,
                fillColor: Colors.black.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                suffixText: 'M',
                suffixStyle: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              ),
            ),
          )
        // Distance Display (Shown when RUNNING)
        else
          Text(
            // NOTE: Distance is based on manual input until GPS/Pedometer integration is added
            '${_distanceMeters.toStringAsFixed(0)}M',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),

        SizedBox(height: MediaQuery.of(context).size.height * 0.05),

        // Start/Stop/Reset Button
        SizedBox(
          width: 200,
          child: _status == RunStatus.running
              ? ElevatedButton(
            onPressed: _stopRun,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Stop', style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
          )
              : Column(
            children: [
              ElevatedButton(
                onPressed: _startRun,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Start', style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              if (_status == RunStatus.stopped)
                TextButton(
                  onPressed: _resetRun,
                  child: const Text('Reset', style: TextStyle(color: Colors.white70)),
                ),
            ],
          ),
        ),

        SizedBox(height: MediaQuery.of(context).size.height * 0.05),

        // Calories Burned
        Icon(Icons.local_fire_department, color: _caloriesBurned > 0 ? Colors.redAccent : Colors.white70, size: 20),
        const SizedBox(height: 5),
        Text(
          _caloriesBurned.toStringAsFixed(1),
          style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const Text(
          'Calories Burned',
          style: TextStyle(fontSize: 14, color: Colors.white70),
        ),
        const SizedBox(height: 10),

        // Body Weight Info
        Text(
          '(Based on ${_caloriesBurned > 0 ? "running time and" : ""} ${weightKg}kg body weight)',
          style: const TextStyle(fontSize: 10, color: Colors.white54),
        ),

      ],
    );

    return Scaffold(
      backgroundColor: const Color(0xFF640A0A),
      body: SafeArea(
        child: SingleChildScrollView( // WRAP content to allow scrolling on small screens
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: runDataContent,
          ),
        ),
      ),
    );
  }
}