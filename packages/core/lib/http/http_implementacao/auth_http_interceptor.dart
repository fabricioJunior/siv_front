import 'dart:async';

import 'package:http_interceptor/http_interceptor.dart';

typedef GetToken = Future<String>;

class AuthHttpInterceptor extends InterceptorContract {
  final GetToken getToken;

  AuthHttpInterceptor(this.getToken);

  @override
  FutureOr<BaseRequest> interceptRequest({required BaseRequest request}) async {
    if (request.url.toString().contains('v1/auth/signIn')) {
      return request;
    }
    var token = await getToken;
    request.headers['Authorization'] = 'Bearer $token';
    return request;
  }

  @override
  FutureOr<BaseResponse> interceptResponse({required BaseResponse response}) {
    return response;
  }
}
