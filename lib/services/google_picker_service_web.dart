import 'dart:async';
import 'dart:js' as js;
import 'dart:js_util' as js_util;

import 'package:flutter/foundation.dart';

import 'google_picker_models.dart';

class GooglePickerService {
  const GooglePickerService({required this.apiKey});

  final String apiKey;

  Future<GooglePickerResult?> pickSpreadsheet({
    required String oauthToken,
  }) async {
    if (!kIsWeb) {
      throw UnsupportedError('Google Picker is available only on the web.');
    }

    await _ensurePickerIsReady();

    final completer = Completer<GooglePickerResult?>();
    late final void Function(dynamic) responseHandler;
    responseHandler = js.allowInterop((dynamic response) {
      final action = js_util.getProperty<String?>(response, 'action');
      if (action == 'picked') {
        final docs = js_util.getProperty(response, 'docs');
        if (docs != null) {
          final firstDoc = js_util.getProperty(docs, 0);
          final id = js_util.getProperty<String?>(firstDoc, 'id');
          if (id != null && id.isNotEmpty) {
            final name = js_util.getProperty<String?>(firstDoc, 'name') ??
                js_util.getProperty<String?>(firstDoc, 'title') ??
                id;
            final url = js_util.getProperty<String?>(firstDoc, 'url');
            if (!completer.isCompleted) {
              completer.complete(
                GooglePickerResult(id: id, name: name, url: url),
              );
            }
            return;
          }
        }
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      } else if (action == 'cancel' || action == 'canceled') {
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      }
    });

    final pickerNamespace = _googlePickerNamespace();
    final builderCtor = js_util.getProperty(pickerNamespace, 'PickerBuilder');
    final pickerBuilder = js_util.callConstructor(builderCtor, []);

    final docsView = _createSpreadsheetsView(pickerNamespace);
    js_util.callMethod(pickerBuilder, 'addView', [docsView]);
    js_util.callMethod(pickerBuilder, 'setOAuthToken', [oauthToken]);
    js_util.callMethod(pickerBuilder, 'setDeveloperKey', [apiKey]);
    js_util.callMethod(
      pickerBuilder,
      'setSelectableMimeTypes',
      ['application/vnd.google-apps.spreadsheet'],
    );

    final location = js_util.getProperty(js_util.globalThis, 'location');
    final origin = location != null
        ? js_util.getProperty<String?>(location, 'origin')
        : null;
    if (origin != null && origin.isNotEmpty) {
      js_util.callMethod(pickerBuilder, 'setOrigin', [origin]);
    }

    js_util.callMethod(pickerBuilder, 'setCallback', [responseHandler]);
    final picker = js_util.callMethod(pickerBuilder, 'build', []);
    js_util.callMethod(picker, 'setVisible', [true]);

    return completer.future;
  }

  Future<void> _ensurePickerIsReady() async {
    final google = js_util.getProperty(js_util.globalThis, 'google');
    final pickerAvailable =
        google != null && js_util.getProperty(google, 'picker') != null;
    final gapi = await _waitForGapi();
    final hasClient = _isGapiClientReady(gapi);
    String? modulesToLoad;
    if (!hasClient && !pickerAvailable) {
      modulesToLoad = 'client:picker';
    } else if (!hasClient) {
      modulesToLoad = 'client';
    } else if (!pickerAvailable) {
      modulesToLoad = 'picker';
    }
    if (modulesToLoad != null) {
      await _loadGapiModules(gapi, modulesToLoad);
    }
    if (!_isGapiClientReady(gapi)) {
      throw StateError('Google API klijent nije učitan.');
    }
    final pickerReady =
        js_util.getProperty(js_util.globalThis, 'google') != null &&
        js_util.getProperty(
              js_util.getProperty(js_util.globalThis, 'google'),
              'picker',
            ) !=
            null;
    if (!pickerReady) {
      throw StateError('Google Picker nije učitan.');
    }
  }

  Future<Object> _waitForGapi() async {
    final start = DateTime.now();
    while (true) {
      final gapi = js_util.getProperty(js_util.globalThis, 'gapi');
      if (gapi != null) {
        return gapi;
      }
      if (DateTime.now().difference(start) > const Duration(seconds: 10)) {
        throw StateError('Google API nije učitan.');
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  Object _googlePickerNamespace() {
    final google = js_util.getProperty(js_util.globalThis, 'google');
    if (google == null) {
      throw StateError('Google API nije dostupna.');
    }
    final picker = js_util.getProperty(google, 'picker');
    if (picker == null) {
      throw StateError('Google Picker nije inicijalizovan.');
    }
    return picker;
  }

  Object _createSpreadsheetsView(Object pickerNamespace) {
    final docsViewCtor = js_util.getProperty(pickerNamespace, 'DocsView');
    final viewIdEnum = js_util.getProperty(pickerNamespace, 'ViewId');
    final spreadsheetsView =
        js_util.getProperty(viewIdEnum, 'SPREADSHEETS');
    final docsView = js_util.callConstructor(
      docsViewCtor,
      [spreadsheetsView],
    );
    js_util.callMethod(docsView, 'setIncludeFolders', [false]);
    js_util.callMethod(docsView, 'setSelectFolderEnabled', [false]);
    return docsView;
  }

Future<void> _loadGapiModules(Object gapi, String modules) async {
  final completer = Completer<void>();
  final options = js_util.newObject();

  js_util.setProperty(
    options,
    'callback',
    js.allowInterop(() {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }),
  );

  js_util.callMethod(gapi, 'load', [modules, options]);

  await completer.future.timeout(
    const Duration(seconds: 10),
    onTimeout: () {
      throw StateError('Google API modul nije dostupan: $modules.');
    },
  );
}

  bool _isGapiClientReady(Object gapi) {
    final client = js_util.getProperty(gapi, 'client');
    return client != null;
  }
}
