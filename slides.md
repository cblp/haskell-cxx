---
author: Юрий Сыровецкий
# lang: ru-RU
# monofont: Hasklig
slideNumber: true
theme: simple
title:
  <span class="subtitle haskell">Haskell</span><span class="subtitle cxx">C++</span>
...

##

<h1><div style="font-size: 2em; letter-spacing: -0.155em;">▶▶</div></h1>
<h2><code><a href="https://ff.systems">&nbsp;ff.systems</a></code><h2>

## Почему Haskell?

- Самое простое средство достижения результата
- Уже написана логика

## Почему C++?

Библиотеки:

- Qt
- SwarmDB

## Классический FFI в&nbsp;Haskell

## C `>=>` Haskell

```c
        ┌
define/ │ // extern "C"
export  │ int strlen(const char * s);
        └
```

```haskell
        ┌
import  │ foreign import ccall
        │     "strlen"
        │     c_strlen :: Ptr CChar -> IO Int
        ┝
adapt   │ strlen :: ByteString -> Int
        │ strlen = ... c_strlen ...
        └
```

## Haskell `>=>` C

```haskell
        ┌
define  │ strlen :: ByteString -> Int
        │ strlen = ...
        ┝
adapt   │ hs_strlen :: Ptr CChar -> IO Int
        │ hs_strlen = ... strlen ...
        ┝
export  │ foreign export ccall
        │     hs_strlen :: Ptr CChar -> IO Int
        └
```

```c
        ┌
        │ // hs_strlen.h
export  │ int hs_strlen(const char *);
        └
```

## Haskell `>=>` C

```c
        ┌
import  │ #include "hs_strlen.h"
        ┝
prepare │ hs_init(&argc, &argv);
        ┝
use     │ int n = hs_strlen("hello");
        └
```

## _.cabal

```yaml
extra-source-files: hs_exports.h

component
    c-sources: foo.c bar/baz.c
    cc-options: -DQUX=42
    include-dirs: /usr/local/include

    if os(linux)
        extra-libraries: Qt5Core Qt5Gui Qt5Widgets
        extra-lib-dirs: /opt/qt512/lib
    if os(osx)
        include-dirs: /usr/local/opt/qt5/include
        extra-framework-dirs: /usr/local/opt/qt5/lib
        frameworks: QtCore QtGui QtWidgets
```

<a href="https://haskell.org/cabal/users-guide/developing-packages.html">`haskell.org/cabal`</a>

<!-- technical area -->

<style>
  .reveal h1,
  .reveal h2,
  .reveal h3,
  .reveal h4,
  .reveal h5,
  .reveal h6 {
    font-family: Helvetica, sans-serif !important;
  }
  .title .subtitle {
    border-color: black;
    border-style: solid;
    padding-left: 0.25em;
    padding-right: 0.25em;
  }
  .title .haskell {
    border-width: 0 0.05em 0.05em 0;
    padding-top: 0.05em;
  }
  .title .cxx {
    border-width: 0.05em 0 0 0;
  }
</style>
