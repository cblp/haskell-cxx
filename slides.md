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
definition  ║ // extern "C"
& export    ║ int strlen(const char * s) { ... }
```

```haskell
import      ║ foreign import ccall
            ║     "strlen"
            ║     c_strlen :: Ptr CChar -> IO Int

adapter     ║ strlen :: ByteString -> Int
            ║ strlen = ... c_strlen ...
```

## Haskell `>=>` C

```haskell
definition  ║ strlen :: ByteString -> Int
            ║ strlen = ...

adapter     ║ hs_strlen :: Ptr CChar -> IO Int
            ║ hs_strlen = ... strlen ...

export      ║ foreign export ccall
            ║     hs_strlen :: Ptr CChar -> IO Int
            ║
            ║ // hs_strlen.h
            ║ int hs_strlen(const char *);

import      ║ #include "hs_strlen.h"

use         ║ int n = hs_strlen("hello");
```

## Как&nbsp;протащить код&nbsp;на&nbsp;C в&nbsp;программу?

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

## TemplateHaskell

```haskell
addForeignSource
    :: ForeignSrcLang -> String -> Q ()

addForeignFilePath
    :: ForeignSrcLang -> FilePath -> Q ()

data ForeignSrcLang
    = LangC
    | LangCxx
    | LangObjc
    | LangObjcxx
    | RawObject
```

## <code>inline-c&nbsp;&nbsp;&nbsp;&nbsp;<br>inline-c-cpp</code>

```haskell
main = do
    x <- [C.exp| double { cos(1) } |]
    print x
```

##

```haskell
            ║ // TH.addForeignSource
definition  ║ double inline_c_Main_0() { return cos(1); }
                            │
                            ╰───────────────────╮
                                                │
import      ║ foreign import ccall safe "inline_c_Main_0"
            ║     inline_c_ffi_698958 :: IO CDouble
                          │
                          ╰──────────────────────────╮
                                                     │
adapter     ║ inline_c_ffi_a7QR :: IO Double         │
            ║ inline_c_ffi_a7QR = coerce <$> inline_c_ffi_698958
                      │
                      ╰────────╮
                               │
            ║ main = do        │
use         ║     x <- inline_c_ffi_a7QR
            ║     print x
```

<!-- technical area -->

##
<h1>C++</h1>

## <code>C++ &nbsp; Haskell<br>╲ ╱ &nbsp; &nbsp;<br>C &nbsp; &nbsp;</code>

## <code>C++ <-> Haskell<br>↕ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;<br>DB &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</code> {transition="slide-in fade-out"}

## <code>C++ <-> Haskell<br>&nbsp; &nbsp; &nbsp; &nbsp; ↕<br>&nbsp; &nbsp; &nbsp; &nbsp; DB</code> {transition="fade-in slide-out"}

##

```haskell
create    ║ storagePtr <- newStablePtr storage
            [C.block| void {
send      ║     $(Storage * storagePtr)->foo();
            } |]
```

```c
send back ║ hs_bar(storagePtr);
```

```haskell
          ║ foreign export ccall
receive   ║     hs_bar :: StablePtr Storage -> IO ()
            hs_bar storagePtr = do
deref     ║     storage <- deRefStablePtr storagePtr
                ...
```

##

```c
hs_bar(void *);


struct Storage;
hs_bar(Storage *);


struct StorageHandle { struct Storage * ptr; };
hs_bar(StorageHandle);
```

## `StablePtr`

1. Не перемещается в памяти
2. Не собирается как мусор
3. `freeStablePtr`

## `ForeignPtr`

```haskell
C++     ║ class Storage {
        ║ public:
        ║     Storage();
        ║     ~Storage();
        ║ };

Haskell ║ newtype Storage = Storage (ForeignPtr (Proxy Storage))
```

## C++ class binding

```haskell
newtype Storage = Storage (ForeignPtr (Proxy Storage))

newForeignStorage :: IO (ForeignPtr (Proxy Storage))
newForeignStorage = mask_ $ do
    p <- [Cpp.exp| Storage * { new Storage } |]
    newForeignPtr deleteStorage p

foreign import ccall "&deleteStorage"
    deleteStorage :: FinalizerPtr a
```

```c++
extern "C"
void deleteStorage(Storage * p) {
    delete p;
}
```

## C++ method binding

```c++
class Storage {
public:
    int foo(std::string name);
};
```

```haskell
newtype Storage = Storage (ForeignPtr (Proxy Storage))

foo :: Storage -> ByteString -> IO Int
foo (Storage storage) name =
    [Cpp.exp| int {
        $fptr-ptr:(Storage * storage)
            ->foo($bs-cstr:name)
    } |]
```

##

```haskell
$(Cpp.context
    $   Cpp.cppCtx
    <>  Cpp.bsCtx
    <>  Cpp.fptrCtx
    <>  mempty
        { ctxTypesTable =
            Map.singleton
                (TypeName "Storage")
                [t| Proxy Storage |]
        })

$(Cpp.include "<mylib/storage.hpp>")

$(Cpp.verbatim "typedef mylib::Storage Storage;")
```

## Complex binding

```c++
struct UUID { uint64_t x, y; };

struct Status { UUID code; std::string message; };

Status bar();
```

```haskell
data UUID = UUID Word64 Word64

data Status = Status { code :: UUID, message :: ByteString }

bar :: IO Status
bar = ?
```

## Complex binding

```haskell
struct UUID {               ║   data UUID =
    uint64_t x, y;          ║       UUID Word64 Word64
};                          ║

struct Status {             ║   data Status = Status {
    UUID        code;       ║       code    :: UUID,
    std::string message;    ║       message :: ByteString
};                          ║   }

Status bar();               ║   bar :: IO Status
                            ║   bar = ?
```

##

```haskell
decode :: Ptr (Proxy Status) -> IO Status
decode statusPtr = allocaArray 4 $ \arena -> do
    [Cpp.block| void {
        uint64_t * const arena = $(uint64_t * arena);
        uint64_t & x   = arena[0];
        uint64_t & y   = arena[1];
        uint64_t & ptr = arena[2];
        uint64_t & len = arena[3];
        Status & status = * $(Status * statusPtr);
        x   = uint64_t(status.code().value());
        y   = uint64_t(status.code().origin());
        ptr = uintptr_t(status.comment().data());
        len = status.comment().length();
    } |]
    ...
```

##

```haskell
    ...
    x   <- peekElemOff arena 0
    y   <- peekElemOff arena 1
    ptr <- peekElemOff arena 2
    len <- peekElemOff arena 3
    comment <-
        BS.packCStringLen
            (wordPtrToPtr $ fromIntegral ptr, fromIntegral len)
    pure Status{code = UUID x y, comment}
```

##

```haskell
bar :: IO Status
bar = do

    statusPtr <- [Cpp.exp| Status * { new Status } |]

    [Cpp.block| void {
        * $fptr-ptr:(Status * statusPtr) = bar();
    } |]

    status <- decode statusPtr

    [Cpp.block| void { delete $(Status * statusPtr); } |]

    pure status
```

<style>
  .reveal h1,
  .reveal h2,
  .reveal h3,
  .reveal h4,
  .reveal h5,
  .reveal h6 {
    font-family: Helvetica, sans-serif;
  }
  .reveal pre {
    box-shadow: none;
  }
  .reveal pre code {
    max-height: none;
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
