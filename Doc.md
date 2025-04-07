# The semantics of 257-wrap brainfuck

## Virtual machine of the language

Has separated code and data memory areas.

Has flag wasRead; indicates whether previous command was the input command.

Has byte-oriented I/O feature.

Has success and failure exit statuses.

Has program counter for code memory.

Has data pointer for data memory.

Unspecified maximum length of code and data officially

### Code memory
