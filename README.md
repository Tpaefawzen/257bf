# 257bf

[257-wrap brainfuck] interpreter.

[257-wrap brainfuck]: https://www.esolangs.org/wiki/257-wrap_brainfuck

## Features

* Ignore comments
* Lazy braces
* EOF is falsey (but 0 is truthy) iff read command is done immediately before the brace

## Dependency

Zig compiler.

## How to build

Compiles into an executable:

```
zig build
```

## Synopsis

```
257bf FILE
257bf -c CODE
257bf --code=CODE
```

## License

Written by Tpeafawzen

Forked from [dantecatalfamo's project](https://github.com/dantecatalfamo/brainfuck-zig)

Licensed under the MIT License
