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
<h2 style="font-family: serif; font-style: italic;">&nbsp;<a href="https://ff.systems">ff.systems</a><h2>

## Почему Haskell?

- Самое простое средство достижения результата
- Уже написана логика

## Почему C++?

Библиотеки:

- Qt
- SwarmDB

## Классический FFI в&nbsp;Haskell

##

```c
// extern "C"
int strlen(const char * s);
```

```haskell
foreign import ccall
    "strlen"
    c_strlen :: Ptr CChar -> IO Int

strlen :: ByteString -> Int
strlen = ... c_strlen ...
```

##

```haskell
strlen = ByteString -> Int

hs_strlen = Ptr CChar -> IO Int
hs_strlen = ... strlen ...

foreign export ccall
    hs_strlen :: Ptr CChar -> IO Int
```

```c
int hs_strlen(const char *);
```

```c
hs_init(&argc, &argv);
...
int n = hs_strlen("hello");
```

<!-- technical area -->

<style>
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
