import 'google_picker_models.dart';

class GooglePickerService {
  const GooglePickerService({required this.apiKey});

  final String apiKey;

  Future<GooglePickerResult?> pickSpreadsheet({
    required String oauthToken,
  }) {
    throw UnsupportedError('Google Picker is supported only on the web.');
  }
}

