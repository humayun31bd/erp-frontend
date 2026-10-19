import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../network/dio_client.dart';

class CustomTranslationState {
  final Map<String, Map<String, String>> translations;
  final bool isLoading;

  CustomTranslationState({this.translations = const {}, this.isLoading = false});

  CustomTranslationState copyWith({Map<String, Map<String, String>>? translations, bool? isLoading}) {
    return CustomTranslationState(
      translations: translations ?? this.translations,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CustomTranslationNotifier extends StateNotifier<CustomTranslationState> {
  final Dio _dio;

  CustomTranslationNotifier(this._dio) : super(CustomTranslationState()) {
    fetchTranslations();
  }

  Future<void> fetchTranslations() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _dio.get('/settings/translations');
      final data = response.data as Map<String, dynamic>;
      
      final Map<String, Map<String, String>> parsed = {};
      data.forEach((key, value) {
        parsed[key] = {
          'en': value['en'].toString(),
          'ar': value['ar'].toString(),
        };
      });
      
      state = state.copyWith(translations: parsed, isLoading: false);
    } catch (e) {
      print('Failed to fetch translations: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> updateTranslation(String key, String en, String ar) async {
    try {
      await _dio.put('/settings/translations', data: {
        'key': key,
        'en': en,
        'ar': ar
      });
      
      final newTranslations = Map<String, Map<String, String>>.from(state.translations);
      newTranslations[key] = {'en': en, 'ar': ar};
      state = state.copyWith(translations: newTranslations);
    } catch (e) {
      print('Failed to update translation: $e');
      rethrow;
    }
  }
}

final customTranslationProvider = StateNotifierProvider<CustomTranslationNotifier, CustomTranslationState>((ref) {
  final dio = ref.watch(dioProvider);
  return CustomTranslationNotifier(dio);
});
