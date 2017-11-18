/// Angel's built-in error handling support is now robust enough that this library is no logner required.
///
/// https://github.com/angel-dart/angel/wiki/Error-Handling
@deprecated
library angel_errors;

import 'dart:async';
import 'package:angel_framework/angel_framework.dart';
import 'package:angel_framework/src/http/fatal_error.dart';

typedef FatalErrorHandler(AngelFatalError e);

/// Convenient error handling plugin for Angel application.
class ErrorHandler extends AngelPlugin {
  /// Called on fatal errors, which hopefully are rare.
  FatalErrorHandler fatalErrorHandler;

  /// Response to request based on their outgoing status code.
  ///
  /// [AngelHttpException] instances will be available as `req.error`.
  final Map<int, RequestHandler> handlers = {};

  ErrorHandler({Map<int, RequestHandler> handlers: const {}}) {
    this.handlers.addAll(handlers ?? {});
  }

  @override
  Future call(Angel app) async {
    final oldHandler = app.errorHandler;

    app.errorHandler = (e, req, res) async {
      final result = await middleware()(req..properties['error'] = e, res);

      if (result == true) {
        return await oldHandler(e, req, res);
      } else
        return result;
    };

    app.fatalErrorStream.listen((error) async {
      if (fatalErrorHandler != null) {
        await fatalErrorHandler(error);
      }
    });
  }

  /// Handles a request based on its outgoing status code.
  RequestMiddleware middleware({int defaultStatus: 500}) {
    return (RequestContext req, ResponseContext res) async {
      int key = handlers.containsKey(res.statusCode)
          ? res.statusCode
          : handlers.containsKey(defaultStatus) ? defaultStatus : null;

      if (key == null || res.statusCode == 200)
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

  /// Sets a response's status code.
  RequestMiddleware throwError({int status: 404}) {
    return (req, ResponseContext res) async {
      res.statusCode = status;
      return true;
    };
  }
}
