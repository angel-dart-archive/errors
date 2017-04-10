import 'dart:io';
import 'package:angel_errors/angel_errors.dart';
import 'package:angel_framework/angel_framework.dart';
import 'package:angel_test/angel_test.dart';
import 'package:test/test.dart';

main() {
  Angel app;
  ErrorHandler errorHandler;
  TestClient client;

  setUp(() async {
    app = new Angel();

    await app.configure(errorHandler = new ErrorHandler(handlers: {
      404: (req, res) async {
        return {'not': 'found'};
      }
    }));

    app
      ..get('*', errorHandler.throwError())
      ..delete('/bar', errorHandler.throwError(status: 405))
      ..after.add(errorHandler.middleware(defaultStatus: 404));

    client = await connectTo(app);
  });

  tearDown(() async {
    await client.close();
    app = null;
  });

  test('throws errors', () async {
    final response = await client.get('/foo');
    expect(response, hasStatus(HttpStatus.NOT_FOUND));
    expect(response, isJson({'not': 'found'}));
  });

  test('default status', () async {
    final response = await client.delete('/bar');
    expect(response, hasStatus(HttpStatus.METHOD_NOT_ALLOWED));
    expect(response, isJson({'not': 'found'}));
  });
}
