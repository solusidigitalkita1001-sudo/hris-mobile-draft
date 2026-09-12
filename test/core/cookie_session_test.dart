import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hrm_app/core/security/cookie_session.dart';

void main() {
  test('reads exact cookie names and decodes CSRF header values', () {
    expect(
      cookieValue('csrf=nonce%2Bpart.signature; at=access', 'csrf'),
      'nonce+part.signature',
    );
    expect(cookieValue('not-at=other; rt=refresh', 'at'), isNull);
    expect(cookieValue('at=', 'at'), isNull);
    expect(cookieValue('csrf=%invalid', 'csrf'), isNull);
    expect(cookieValue(null, 'at'), isNull);
  });

  test('extracts request cookie pairs from Set-Cookie headers', () {
    final headers = Headers.fromMap({
      'set-cookie': [
        'accessToken=jwt-value; Path=/; HttpOnly; SameSite=Strict',
        'refreshToken=refresh-value; Path=/api/v1/auth; HttpOnly',
      ],
    });

    expect(
      cookieHeaderFromResponse(headers),
      'accessToken=jwt-value; refreshToken=refresh-value',
    );
  });

  test('merges rotated cookies and removes expired cookies', () {
    expect(
      mergeCookieHeaders(
        'accessToken=old; refreshToken=refresh',
        'accessToken=new',
      ),
      'accessToken=new; refreshToken=refresh',
    );
    expect(
      mergeCookieHeaders(
        'accessToken=jwt; refreshToken=refresh',
        'accessToken=',
      ),
      'refreshToken=refresh',
    );
  });
}
