import '../../../exception/app_exception_catcher.dart';
import '../enum/http_error_type.dart';
import '../error/http_exception.dart';
import '../request/http_request.dart';
import 'http_interceptor.dart';

class ExceptionCaptureInterceptor extends HttpInterceptor {
  const ExceptionCaptureInterceptor();

  static const String skipCaptureExtraKey = '_skip_exception_capture';

  @override
  Future<HttpException> onError(
    HttpRequest<dynamic> request,
    HttpException error,
  ) async {
    if (request.extra?[skipCaptureExtraKey] == true) {
      return error;
    }

    final context = _buildContext(request, error);
    AppExceptionCatcher.addBreadcrumb(
      'http_error ${request.method.name.toUpperCase()} ${request.path}',
      category: 'network',
      data: context,
    );

    if (!_shouldRecord(error)) {
      return error;
    }

    try {
      await AppExceptionCatcher.recordNetworkError(
        error,
        error.originalError is Error
            ? (error.originalError as Error).stackTrace ?? StackTrace.current
            : StackTrace.current,
        customContext: context,
      );
    } catch (_) {}

    return error;
  }

  bool _shouldRecord(HttpException error) {
    if (error.type == HttpErrorType.cancel ||
        error.type == HttpErrorType.cache) {
      return false;
    }

    final statusCode = error.statusCode;
    if (statusCode != null && statusCode >= 500) {
      return true;
    }

    return switch (error.type) {
      HttpErrorType.parse ||
      HttpErrorType.server ||
      HttpErrorType.unknown ||
      HttpErrorType.unauthorized => true,
      _ => false,
    };
  }

  Map<String, Object?> _buildContext(
    HttpRequest<dynamic> request,
    HttpException error,
  ) {
    return <String, Object?>{
      'method': request.method.name,
      'path': request.path,
      'errorType': error.type.name,
      'statusCode': error.statusCode,
      'businessCode': error.businessCode,
    };
  }
}
