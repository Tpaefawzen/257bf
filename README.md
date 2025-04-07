# 257bf

[257-wrap brainfuck] interpreter.

[257-wrap brainfuck]: https://www.esolangs.org/wiki/257-wrap_brainfuck

## What 257-wrap brainfuck excels

It excels at distinguishing usual bytes (including 0x00 and 0xff) from the actual EOF. It is done by introducing 257-wrap value.

## Features

* Ignore comments
* Braces are evaluated lazily
* EOF is falsey (but 0 is truthy) iff read command is done immediately before the brace; otherwise only 0 is falsey
* The comma command (read a byte) is merged into the period command

## Dependency

Zig compiler.
Tested on v0.13.0.

## How to build

Compiles into an executable:

```
zig build
```

The compiler can be seen on zig-out/bin/257bf.
For more details of building, please consult the Zig documentation.

## Synopsis

Synopsis for command line interface:

```
257bf FILE
257bf -c CODE
257bf --code=CODE
```

## Contributing 
* By writing tests
* By adding more example programs
* By refactoring
* By adding some new features to the interface

## License

Written by Tpeafawzen

Forked from [dantecatalfamo's project](https://github.com/dantecatalfamo/brainfuck-zig)

Licensed under the MIT License
