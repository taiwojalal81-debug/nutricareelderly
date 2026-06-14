import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/foundation.dart';

class OcrResult {
  final String? likelyName;
  final String? likelyDosage;
  final String fullText;

  OcrResult({this.likelyName, this.likelyDosage, required this.fullText});
}

class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<OcrResult> processImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      String fullText = recognizedText.text;
      debugPrint('OCR Full Text: \n$fullText');

      String? likelyName;
      String? likelyDosage;

      final lines = fullText.split('\n');
      
      // Basic heuristic to parse medication details:
      // - Dosage usually has 'mg', 'ml', 'mcg', 'g'
      // - Name is often uppercase, or the largest line before dosage
      
      final dosageRegex = RegExp(r'\b(\d+(?:\.\d+)?\s*(mg|ml|mcg|g|IU))\b', caseSensitive: false);
      
      for (String line in lines) {
        final cleanLine = line.trim();
        if (cleanLine.isEmpty) continue;
        
        // Find Dosage
        if (likelyDosage == null) {
          final dosageMatch = dosageRegex.firstMatch(cleanLine);
          if (dosageMatch != null) {
            likelyDosage = dosageMatch.group(0);
            
            // Sometimes the name is on the same line before the dosage
            final withoutDosage = cleanLine.replaceAll(dosageMatch.group(0)!, '').trim();
            if (withoutDosage.length > 3 && likelyName == null) {
              // Remove special characters, keep only letters and spaces
              final nameClean = withoutDosage.replaceAll(RegExp(r'[^a-zA-Z\s]'), '').trim();
              if (nameClean.isNotEmpty) {
                 likelyName = nameClean;
              }
            }
            continue;
          }
        }
        
        // Find Name if not found yet (often the first or second prominent line with all caps or title case)
        if (likelyName == null && likelyDosage == null) {
           if (cleanLine.length > 3 && RegExp(r'^[A-Z][A-Z\s]+$').hasMatch(cleanLine)) {
              likelyName = cleanLine;
           } else if (cleanLine.length > 4 && !cleanLine.toLowerCase().contains('pharmacy') && !cleanLine.toLowerCase().contains('take')) {
              // Fallback, grab a meaty looking line
              if (likelyName == null) {
                  final nameClean = cleanLine.replaceAll(RegExp(r'[^a-zA-Z\s]'), '').trim();
                  if (nameClean.length > 4) {
                     likelyName = nameClean;
                  }
              }
           }
        }
      }

      return OcrResult(
        likelyName: likelyName,
        likelyDosage: likelyDosage,
        fullText: fullText,
      );
    } catch (e) {
      debugPrint('OCR Error: $e');
      return OcrResult(fullText: '', likelyName: null, likelyDosage: null);
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
