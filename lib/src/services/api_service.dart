import 'dart:convert';
import 'dart:typed_data';
import 'dart:io' if (dart.library.html) 'dart:html';

import 'package:apphike/src/config/constants.dart';
import 'package:http/http.dart' as http;

// Cross-platform file handling
class CrossPlatformFile {
  final String? path;
  final String? name;
  final Uint8List? bytes;

  CrossPlatformFile({this.path, this.name, this.bytes});

  // Create from dart:io File (mobile/desktop) or XFile (cross-platform)
  static Future<CrossPlatformFile> fromFile(dynamic file) async {
    if (file.runtimeType.toString().contains('File')) {
      // For dart:io File
      return CrossPlatformFile(
        path: file.path,
        name: file.path.split('/').last,
      );
    } else if (file.runtimeType.toString().contains('XFile')) {
      // For XFile (image_picker)
      final bytes = await file.readAsBytes();
      return CrossPlatformFile(name: file.name, bytes: bytes);
    }
    // Fallback
    return CrossPlatformFile(name: 'file', bytes: Uint8List(0));
  }

  Future<bool> exists() async {
    if (path != null) {
      // For mobile/desktop platforms
      try {
        final File file = File(path!);
        return await file.exists();
      } catch (e) {
        return false;
      }
    }
    return bytes != null;
  }
}

/// API Client for making HTTP requests to the FeedbackNest backend
class ApiService {
  final String baseUrl;

  ApiService({
    this.baseUrl = ApphikeConstants.apiBaseUrl,
  }); // Default to Apphike API base URL

  /// Performs a POST request with JSON data
  Future<String> post(
    String endpoint,
    String apiKey,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl + endpoint),
        headers: {'Content-Type': 'application/json', 'api-key': apiKey},
        body: json.encode(data),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body;
      } else {
        throw Exception(
          'POST request failed with status: ${response.statusCode}, body: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to perform POST request: $e');
    }
  }

  /// Performs a POST request with multipart form data (for file uploads)
  Future<String> postWithMultipart({
    required String endpoint,
    required String apiKey,
    required Map<String, String> fields,
    List<CrossPlatformFile>? files,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(baseUrl + endpoint),
      );

      // Add headers
      request.headers.addAll({'api-key': apiKey});

      // Add text fields
      request.fields.addAll(fields);

      // Convert files to http.MultipartFile
      if (files != null && files.isNotEmpty) {
        for (var file in files) {
          // Check if file exists
          if (!await file.exists()) {
            throw Exception('File does not exist: ${file.name ?? 'unknown'}');
          }

          if (file.path != null) {
            // File from path (mobile/desktop)
            final File ioFile = File(file.path!);
            final fileStream = http.ByteStream(ioFile.openRead());
            final fileLength = await ioFile.length();

            final multipartFile = http.MultipartFile(
              'files',
              fileStream,
              fileLength,
              filename: file.name ?? file.path!.split('/').last,
            );

            request.files.add(multipartFile);
          } else if (file.bytes != null) {
            // File from bytes (web)
            final multipartFile = http.MultipartFile.fromBytes(
              'files',
              file.bytes!,
              filename: file.name ?? 'file',
            );

            request.files.add(multipartFile);
          }
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body;
      } else {
        throw Exception(
          'Multipart request failed with status: ${response.statusCode}, body: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to perform multipart request: $e');
    }
  }
}
