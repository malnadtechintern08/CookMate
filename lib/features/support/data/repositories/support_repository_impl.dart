import '../../domain/entities/faq_item.dart';
import '../../domain/entities/support_page.dart';
import '../datasources/support_remote_datasource.dart';

abstract class SupportRepository {
  Future<SupportPage> getPage(String slug);
  Future<List<FaqItem>> getFaqs({String? category});
  Future<bool> submitContactInquiry({
    required String name,
    required String email,
    required String subject,
    required String message,
  });
}

class SupportRepositoryImpl implements SupportRepository {
  final SupportRemoteDataSource remoteDataSource;

  SupportRepositoryImpl({required this.remoteDataSource});

  @override
  Future<SupportPage> getPage(String slug) {
    return remoteDataSource.getPage(slug);
  }

  @override
  Future<List<FaqItem>> getFaqs({String? category}) {
    return remoteDataSource.getFaqs(category: category);
  }

  @override
  Future<bool> submitContactInquiry({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) {
    return remoteDataSource.submitContactInquiry(
      name: name,
      email: email,
      subject: subject,
      message: message,
    );
  }
}
