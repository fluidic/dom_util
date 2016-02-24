// Copyright (c) 2016, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library dom_util.base;

import 'dart:html';

import 'package:disposable/disposable.dart';

/// Throttles the resize event using requestAnimationFrame since resize
/// events can fire at a high rate.
Disposable onResize(Element element, void callback()) {
  var elementWidth = element.style.width;
  var elementHeight = element.style.height;
  void checkForChanges() {
    if (elementWidth != element.style.width ||
        elementHeight != element.style.height) {
      elementWidth = element.style.width;
      elementHeight = element.style.height;
      callback();
    }
  }

  var running = false;
  void debounce() {
    if (running) return;
    running = true;
    window.animationFrame.whenComplete(() {
      checkForChanges();
      running = false;
    });
  }

  final disposables = new CompositeDisposable();

  final observer = new MutationObserver((mutations, observer) => debounce());
  observer.observe(document.body,
      attributes: true, childList: true, characterData: true, subtree: true);
  disposables.add(new Disposable.create(observer.disconnect));

  final subscription = window.onResize.listen((_) => debounce());
  disposables.add(new Disposable.from(subscription));

  return disposables;
}
