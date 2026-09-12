import 'package:dio/dio.dart';
import 'package:dio_web_adapter/dio_web_adapter.dart';
import 'package:web/web.dart' as web;

const usesBrowserCookieStore = true;

void configurePlatformHttp(Dio dio) {
  dio.httpClientAdapter = BrowserHttpClientAdapter(withCredentials: true);
}

String? readBrowserCookieHeader() => web.document.cookie;
