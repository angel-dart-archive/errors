import 'dart:async';
import 'package:angel_framework/angel_framework.dart';
import 'package:angel_framework/src/http/fatal_error.dart';

typedef FatalErrorHandler(AngelFatalError e);

class ErrorHandler extends AngelPlugin {
  FatalErrorHandler fatalErrorHandler;
  final Map<int, RequestHandler> handlers = {};

  ErrorHandler({Map<int, RequestHandler> handlers: const {}}) {
    this.handlers.addAll(handlers ?? {});
  }

  @override
  Future call(Angel app) async {
    final oldHandler = app.errorHandler;

    app.onError((e, req, res) async {
      final result = await middleware()(req, res);

      if (result == true) {
        return await oldHandler(e, req, res);
      } else return result;
    });

    app.fatalErrorStream.listen((error) async {
      if (fatalErrorHandler != null) {
        await fatalErrorHandler(error);
      }
    });
  }

  RequestMiddleware middleware({int defaultStatus: 500}) {
    return (RequestContext req, ResponseContext res) async {
      int key = handlers.containsKey(res.io.statusCode)
          ? res.io.statusCode
          : handlers.containsKey(defaultStatus) ? defaultStatus : null;

      if (key == null || res.io.statusCode == 200)
        return true;
      else {
        final result = await handlers[key](req, res);

        if (result == false || result == null) {
          return false;
        } else
          return result;
      }
    };
  }

  RequestMiddleware throwError({int status: 404}) {
    return (req, ResponseContext res) async {
      res.status(status);
      return true;
    };
  }
}
