# DEPRECATED IN RECENT ANGEL VERSIONS
If you're using Angel `1.1.0-alpha` or later, then instead of using this package,
just overwrite `app.errorHandler`. Requests are handled in `Zone`s, so that uncaught errors don't crash
the server, but instead produce an instance of `AngelHttpException` that you can handle safely.

Check out the new documentation on error handling in recent Angel versions:
https://angel-dart.gitbook.io/angel/the-basics/error-handling

For those migrating from previous Angel versions, check out the official migration guide: https://angel-dart.gitbook.io/angel/1.1.0-migration-guide

# errors
[![build status](https://travis-ci.org/angel-dart/errors.svg)](https://travis-ci.org/angel-dart/errors)

Error handling plugin for Angel.

See the tests for examples.
