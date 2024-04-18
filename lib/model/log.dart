import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Logger {
  static late File _logFile;
  static late IOSink _sink;

  static Future<void> init() async {
    // Get the directory where the app can store files.
    final Directory directory = await getApplicationDocumentsDirectory();
    // Create the log file.
    _logFile = File('${directory.path}/app.log');
    // Open the file in append mode and create the sink.
    _sink = _logFile.openWrite(mode: FileMode.append);
  }

  static void log(String message) {
    final DateTime now = DateTime.now();
    final String formattedTime = now.toIso8601String();
    // Write the log message with timestamp to the file.
    _sink.writeln('[$formattedTime] $message');
  }

  static void dispose() {
    // Close the sink when done logging.
    _sink.close();
  }
}
