import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/support_remote_datasource.dart';
import '../../data/repositories/support_repository_impl.dart';
import '../../domain/entities/faq_item.dart';
import '../../domain/entities/support_page.dart';

final supportRemoteDataSourceProvider = Provider<SupportRemoteDataSource>((ref) {
  return SupportRemoteDataSourceImpl();
});

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  final remoteDataSource = ref.watch(supportRemoteDataSourceProvider);
  return SupportRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Future provider for fetching a support page by its slug (e.g. 'privacy-policy', 'contact-us', 'help-center', 'safety-guidelines')
final supportPageProvider = FutureProvider.family<SupportPage, String>((ref, slug) async {
  final repository = ref.watch(supportRepositoryProvider);
  return repository.getPage(slug);
});

/// Future provider for fetching FAQs, optionally filtered by category
final faqsProvider = FutureProvider.family<List<FaqItem>, String?>((ref, category) async {
  final repository = ref.watch(supportRepositoryProvider);
  return repository.getFaqs(category: category);
});

/// Controller for submitting contact inquiries from Contact Us screen
class ContactFormState {
  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;

  const ContactFormState({
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  ContactFormState copyWith({
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return ContactFormState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
    );
  }
}

class ContactFormNotifier extends StateNotifier<ContactFormState> {
  final SupportRepository _repository;

  ContactFormNotifier(this._repository) : super(const ContactFormState());

  Future<bool> submitInquiry({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    state = state.copyWith(isSubmitting: true, isSuccess: false, errorMessage: null);

    try {
      final success = await _repository.submitContactInquiry(
        name: name,
        email: email,
        subject: subject,
        message: message,
      );

      if (success) {
        state = state.copyWith(isSubmitting: false, isSuccess: true, errorMessage: null);
        return true;
      } else {
        state = state.copyWith(
          isSubmitting: false,
          isSuccess: false,
          errorMessage: 'Failed to send your message. Please check your connection.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        isSuccess: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  void reset() {
    state = const ContactFormState();
  }
}

final contactFormNotifierProvider = StateNotifierProvider<ContactFormNotifier, ContactFormState>((ref) {
  final repository = ref.watch(supportRepositoryProvider);
  return ContactFormNotifier(repository);
});
