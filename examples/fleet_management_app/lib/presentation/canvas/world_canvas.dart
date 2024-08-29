import 'dart:math';

import 'package:fleet_management_app/ecs/components/route.dart';
import 'package:fleet_management_app/ecs/components/station.dart';
import 'package:flutter/material.dart';
import 'package:reactive_ecs/state.dart';
import '../../ecs/components/unique/camera.dart';
import '../../ecs/components/vehicle.dart';

class WorldCanvas extends CustomPainter {
  final Camera camera;
  final List<Entity> stations;
  final List<Entity> vehicles;
  // constructor
  WorldCanvas({super.repaint, required this.camera, required this.stations, required this.vehicles});

  static const boardSize = 10.0;
  Position camPosition(Size size) => Position(x: camera.position.x - (size.width / boardSize) / 2, y: camera.position.y - (size.height / boardSize) / 2);

  @override
  void paint(Canvas canvas, Size size) {
    // background
    final paint = Paint()..color = Colors.blueGrey;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // draw grid
    final gridPaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 1;
    double cellSize = 10;
    for (var i = 0; i < size.width; i += 10) {
      final x = (i.toDouble() * cellSize - camPosition(size).x * boardSize);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    for (var i = 0; i < size.height; i += 10) {
      final y = (i.toDouble() * cellSize - camPosition(size).y * boardSize);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (final station in stations) {
      final position = station.get<Station>().position;
      final offsetPosition = Offset(position.x - camPosition(size).x, position.y - camPosition(size).y);
      final stationPaint = Paint()
        ..color = Colors.green
        ..strokeWidth = 2;
      canvas.drawCircle(offsetPosition * boardSize, 30, stationPaint);
    }

    for (final vehicle in vehicles) {
      final transform = vehicle.get<Vehicle>();
      final offsetPosition = Offset(transform.position.x - camPosition(size).x, transform.position.y - camPosition(size).y);
      final vehiclePaint = Paint()
        ..color = Colors.red
        ..strokeWidth = 2;

      canvas.save();
      canvas.translate(offsetPosition.dx * boardSize, offsetPosition.dy * boardSize);
      canvas.rotate(transform.rotation * (pi / 180)); // Convert degrees to radians
      canvas.drawRect(Rect.fromCenter(center: Offset(0, 0), width: 50, height: 20), vehiclePaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}