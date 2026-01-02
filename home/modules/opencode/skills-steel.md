---
name: steel-scheme
description: Steel Scheme programming language (R5RS-compliant Scheme variant in Rust) with immutable data structures, FFI, modules, macros, contracts, transducers. Use when working with Steel code, writing Steel programs, embedding Steel in Rust, or asking about Steel syntax/API.
---

# Steel Scheme

Steel is an R5RS-compliant Scheme variant written in Rust, designed as an extension language or for standalone use.

## Key Features

- **R5RS compliant**: Full Scheme language specification
- **Immutable-by-default**: Lists, vectors, hashmaps, hashsets are immutable
- **First-class Rust FFI**: Rust functions and structs can be passed to Steel interpreter
- **Module system**: `require`/`provide` with contract boundaries
- **Macros**: `syntax-rules` and `syntax-case` with hygiene
- **Contracts**: Higher-order contracts for design-by-contract
- **Transducers**: Lazy iteration framework

## Getting Started

### Basic Syntax
```scheme
; Variable definition
(define x 10)

; Function definition
(define (inc x) (+ x 1))

; Lists
(list 1 2 3)  ; '(1 2 3)
(cons 1 '(2 3)) ; '(1 2 3)
(car '(1 2 3))  ; 1
(cdr '(1 2 3))  ; '(2 3)

; Conditionals
(if (> x 5) "big" "small")
(cond [(= x 0) "zero"]
      [(> x 0) "positive"]
      [else "negative"])
```

### Special Forms
`define`, `lambda`, `if`, `cond`, `let`, `letrec`, `begin`, `quote`, `quasiquote`, `unquote`, `unquote-splicing`, `set!`, `and`, `or`, `case`, `when`, `unless`

## Module Documentation

Steel documentation is organized by module. Each module contains related functions and types.

### Core Language

**[about/about.md](about/about.md)** - Language overview and introduction

**[reference/language.md](reference/language.md)** - Language reference

**[reference/syntax.md](reference/syntax.md)** - Syntax constructs

**[reference/keywords.md](reference/keywords.md)** - Keyword arguments (using `#:name` syntax)

**[reference/macros.md](reference/macros.md)** - Macro system with `syntax-rules` and `syntax-case`

**[reference/modules.md](reference/modules.md)** - Module system (`require`, `provide`, modifiers)

**[reference/contracts.md](reference/contracts.md)** - Higher-order contracts system

**[reference/transducers.md](reference/transducers.md)** - Transducers for lazy iteration

### Built-in Functions

Built-in functions are organized into modules. Each module file contains detailed API documentation with examples.

**steel/base** - Core operations (arithmetic, predicates, basic functions)
- See: [builtins/steel_base.md](builtins/steel_base.md)
- Contains: `+`, `-`, `*`, `/`, `<`, `<=`, `>`, `>=`, `=`, `abs`, `expt`, `sqrt`, `sin`, `cos`, `tan`, `floor`, `ceiling`, `round`, `number?`, `string?`, `char?`, `bool?`, etc.

**steel/lists** - List operations
- See: [builtins/steel_lists.md](builtins/steel_lists.md)
- Contains: `list`, `cons`, `car`, `cdr`, `first`, `rest`, `length`, `append`, `map`, `filter`, `fold`, `range`, `member`, `assoc`, etc.

**steel/vectors** - Immutable and mutable vectors
- See: [builtins/steel_vectors.md](builtins/steel_vectors.md)
- Contains: `vector`, `vector-ref`, `vector-length`, `make-vector`, `mutable-vector`, `mut-vector-set!`, etc.

**steel/strings** - String operations
- See: [builtins/steel_strings.md](builtins/steel_strings.md)
- Contains: `string-append`, `string-length`, `substring`, `string-split`, `string-replace`, `string->symbol`, etc.

**steel/hash** - Hashmap operations
- See: [builtins/steel_hash.md](builtins/steel_hash.md)
- Contains: `hash`, `hash-ref`, `hash-insert`, `hash-remove`, `hash-keys`, `hash-values`, etc.

**steel/sets** - Hashset operations
- See: [builtins/steel_sets.md](builtins/steel_sets.md)
- Contains: `hashset`, `hashset-insert`, `hashset-union`, `hashset-intersection`, etc.

**steel/transducers** - Transducer combinators
- See: [builtins/steel_transducers.md](builtins/steel_transducers.md)
- Contains: `mapping`, `filtering`, `taking`, `dropping`, `compose`, `transduce`, `into-list`, etc.

**steel/ports** - Input/output ports
- See: [builtins/steel_ports.md](builtins/steel_ports.md)
- Contains: `stdin`, `stdout`, `read`, `read-line`, `print`, `println`, `open-input-file`, etc.

**steel/filesystem** - File system operations
- See: [builtins/steel_filesystem.md](builtins/steel_filesystem.md)
- Contains: `read-file`, `write-file!`, `file-exists?`, `create-directory!`, `is-dir?`, `is-file?`, etc.

**steel/process** - Process spawning and control
- See: [builtins/steel_process.md](builtins/steel_process.md)
- Contains: `command`, `spawn-process`, `child-stdin`, `child-stdout`, etc.

**steel/bytevectors** - Bytevector operations
- See: [builtins/steel_bytevectors.md](builtins/steel_bytevectors.md)
- Contains: `bytes`, `bytes-ref`, `bytes-set!`, `bytes->string`, etc.

**steel/numbers** - Extended number operations
- See: [builtins/steel_numbers.md](builtins/steel_numbers.md)
- Contains: Division operations, bitwise, conversions, complex numbers

**steel/characters** - Character operations
- See: [builtins/steel_strings.md](builtins/steel_strings.md) (character section)
- Contains: `char=?`, `char-ci=?`, `char<?`, `char->integer`, etc.

**steel/symbols** - Symbol operations
- See: [builtins/steel_symbols.md](builtins/steel_symbols.md)
- Contains: `symbol?`, `symbol=?`, `symbol->string`, `concat-symbols`

**steel/identity** - Type predicates and identity
- See: [builtins/steel_identity.md](builtins/steel_identity.md)
- Contains: `box`, `unbox`, `make-weak-box`, type predicates

**steel/equality** - Equality predicates
- See: [builtins/steel_equality.md](builtins/steel_equality.md)
- Contains: `equal?`, `eqv?`, `eq?`

**steel/meta** - Meta programming and evaluation
- See: [builtins/steel_meta.md](builtins/steel_meta.md)
- Contains: `eval`, `eval-string`, `load`, `command-line`, `make-struct-type`, profiling, debugging

**steel/syntax** - Syntax object operations
- See: [builtins/steel_syntax.md](builtins/steel_syntax.md)
- Contains: `syntax?`, `syntax->datum`, `syntax-loc`, `syntax-span`

**steel/time** - Time operations
- See: [builtins/steel_time.md](builtins/steel_time.md)
- Contains: `current-second`, `current-milliseconds`, `duration->string`

**steel/random** - Random number generation
- See: [builtins/steel_random.md](builtins/steel_random.md)
- Contains: `random`, `random-integer`, `random-bytes`

**steel/http** - HTTP operations
- See: [builtins/steel_http.md](builtins/steel_http.md)
- Contains: `http-request`, `download-file!`, JSON parsing

**steel/tcp** - TCP operations
- See: [builtins/steel_tcp.md](builtins/steel_tcp.md)
- Contains: `tcp-listen`, `tcp-accept`, `tcp-connect`

**steel/json** - JSON serialization/deserialization
- See: [builtins/steel_json.md](builtins/steel_json.md)
- Contains: `string->jsexpr`, `value->jsexpr-string`, `json-pretty-print`

**steel/immutable-vectors** - Immutable vector operations
- See: [builtins/steel_immutable-vectors.md](builtins/steel_immutable-vectors.md)
- Contains: Additional immutable vector functions

**steel/io** - Basic I/O
- See: [builtins/steel_io.md](builtins/steel_io.md)

**steel/streams** - Lazy streams
- See: [builtins/steel_streams.md](builtins/steel_streams.md)
- Contains: `stream-cons`, `stream-first`, `stream-rest`

**steel/git** - Git operations
- See: [builtins/steel_git.md](builtins/steel_git.md)

**steel/polling** - Async polling
- See: [builtins/steel_polling.md](builtins/steel_polling.md)

**steel/threads** - Threading
- See: [builtins/steel_threads.md](builtins/steel_threads.md)

### Standard Library

**#%private/steel/stdlib** - Preloaded standard library
- See: [stdlib/private_steel_stdlib.md](stdlib/private_steel_stdlib.md)
- Contains: `map`, `filter`, `foldl`, `foldr`, `for-each`, `and`, `or`, `cond`, `case`, `assoc`, `assq`, `pipe operators (~>, ~>>)`, etc.
- This module is automatically loaded (in prelude)

**steel/async** - Async operations
- See: [stdlib/steel_async.md](stdlib/steel_async.md)

**steel/iterators** - Iterator utilities
- See: [stdlib/steel_iterators.md](stdlib/steel_iterators.md)
- Contains: `range`, `infinite-range`, `repeat`, `iterate`, `cycle`, etc.

**steel/option** - Option type (Some/None)
- See: [stdlib/steel_option.md](stdlib/steel_option.md)
- Contains: `Some`, `None`, `option-map`, `option-bind`, `option-unwrap`

**steel/result** - Result type (Ok/Err)
- See: [stdlib/steel_result.md](stdlib/steel_result.md)
- Contains: `Ok`, `Err`, `result-map`, `result-bind`, `result-is-ok`

**steel/sync** - Synchronization primitives
- See: [stdlib/steel_sync.md](stdlib/steel_sync.md)
- Contains: `make-mutex`, `make-condition-variable`, `condition-wait!`

### Private Library Modules

- **#%private/steel/contract**: Contract internals - [stdlib/private_steel_contract.md](stdlib/private_steel_contract.md)
- **#%private/steel/control**: Control flow - [stdlib/private_steel_control.md](stdlib/private_steel_control.md)
- **#%private/steel/match**: Pattern matching - [stdlib/private_steel_match.md](stdlib/private_steel_match.md)
- **#%private/steel/ports**: Port internals - [stdlib/private_steel_ports.md](stdlib/private_steel_ports.md)
- **#%private/steel/print**: Printing - [stdlib/private_steel_print.md](stdlib/private_steel_print.md)
- **#%private/steel/reader**: Reader - [stdlib/private_steel_reader.md](stdlib/private_steel_reader.md)

### FFI and Constants

**steel/ffi** - Foreign Function Interface
- See: [builtins/steel_ffi.md](builtins/steel_ffi.md)

**steel/constants** - Constants
- See: [builtins/steel_constants.md](builtins/steel_constants.md)

**steel/core/types** - Core type utilities
- See: [builtins/steel_core_types.md](builtins/steel_core_types.md)

**steel/core/option** - Core option type
- See: [builtins/steel_core_option.md](builtins/steel_core_option.md)

**steel/core/result** - Core result type
- See: [builtins/steel_core_result.md](builtins/steel_core_result.md)

**steel/hashes** - Hash utilities
- See: [builtins/steel_hashes.md](builtins/steel_hashes.md)

**steel/hash** - Hashing functions
- See: [builtins/steel_hash.md](builtins/steel_hash.md)

**steel/ord** - Ordering comparisons
- See: [builtins/steel_ord.md](builtins/steel_ord.md)

## Rust Integration

### Engine API

**[engine/engine.md](engine/engine.md)** - Engine API overview

**[engine/register_function.md](engine/register_function.md)** - Registering Rust functions

**[engine/embedding_values.md](engine/embedding_values.md)** - Embedding Rust values

### Getting Started

**[start/start.md](start/start.md)** - Getting started guide

**[start/standalone.md](start/standalone.md)** - Using Steel standalone

**[start/dylib.md](start/dylib.md)** - Using Rust in Steel

**[start/embedded.md](start/embedded.md)** - Embedding Steel in Rust

**[start/playground.md](start/playground.md)** - Online playground

## Common Patterns

### Modules
```scheme
; Export from module
(provide my-func (contract/out safe-divide (->/c number? (not/c zero?) number?)))

; Import in another file
(require "module.scm")

; Selective import
(require (only-in "mod.scm" func1 func2))
(require (prefix-in p. "mod.scm"))
```

### Contracts
```scheme
(define/contract (safe-divide x y)
  (->/c number? (not/c zero?) number?)
  (/ x y))

; Higher-order
(define/contract (apply-twice f x)
  (->/c (->/c int? int?) int? int?)
  (f (f x)))
```

### Transducers
```scheme
; Pipeline operations
(define xf (compose (filtering even?) (mapping (* 2)) (taking 10)))
(transduce (range 0 100) xf (into-list))

; Common reducers: into-list, into-vector, into-string, into-sum
```

### Pipe Operators
```scheme
; Thread-first (result passed as first argument)
(~> data
    (filter even?)
    (map (* 2))
    (take 10))

; Thread-last (result passed as last argument)
(~>> (list 1 2 3 4 5)
     (filter even?)
     (map (* 2)))
```

### Macros
```scheme
(define-syntax when
  (syntax-rules ()
    [(when test body ...)
     (if test (begin body ...) #void)]))
```

## Implementation Details

**[garbage-collection/gc.md](garbage-collection/gc.md)** - Garbage collection details

**[bytecode/bytecode.md](bytecode/bytecode.md)** - Bytecode compilation

**[bytecode/optimizations.md](bytecode/optimizations.md)** - Optimization passes

## Patterns and Best Practices

**[patterns/patterns.md](patterns/patterns.md)** - Common patterns

**[patterns/async.md](patterns/async.md)** - Async patterns

**[patterns/mutability.md](patterns/mutability.md)** - Interior mutability patterns

## Finding Functions

When you need to find a specific function:

1. Think about the category (lists, strings, math, I/O, etc.)
2. Check the corresponding module documentation file
3. Use `grep` or search within the file to locate the function
4. Read the function's signature and examples

Example: To find string concatenation, check [builtins/steel_strings.md](builtins/steel_strings.md) and search for "append" or "concatenation".

## Quick Reference

### Data Types
- Numbers: `42`, `3.14`, `1/2`, `3+4i` (exact/inexact, rational, complex)
- Strings: `"hello"` (immutable UTF-8)
- Lists: `'(1 2 3)` (unrolled linked lists)
- Vectors: `#(1 2 3)` (immutable)
- Mutable vectors: `#(1 2 3)` (mutable)
- Hashmaps: `#hash((a . 1) (b . 2))` (immutable)
- Hashsets: `#hashset(1 2 3)` (immutable)
- Symbols: `'symbol`
- Characters: `#\a`, `#\newline`
- Bytevectors: `#u8(1 2 3)`

### Key Modules to Remember
- `steel/base` - Most core functions
- `steel/lists` - List operations
- `steel/strings` - String operations
- `steel/hash` - Hashmap operations
- `steel/transducers` - Iteration pipelines
- `steel/ports` - I/O
- `steel/filesystem` - File operations
- `#%private/steel/stdlib` - Standard library (auto-loaded)

### Typical Workflow
1. Start with standard library functions (already loaded)
2. If needed, require additional modules
3. Use transducers for data processing pipelines
4. Define functions with contracts for module boundaries
5. Prefer immutable data structures
6. Use pipe operators (`~>`, `~>>`) for readable pipelines

## Notes

- Steel is compiled to bytecode for efficient execution
- Lists use unrolled linked lists with O(n/64) indexing
- All major data structures are immutable by default (use mutable variants if needed)
- Transducers avoid intermediate allocations
- Modules are compiled once and cached
- No cyclical dependencies in modules
- Reference counting with cycle detection for GC
