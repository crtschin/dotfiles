---
name: helix-steel-plugin
description: Helix Steel plugin development: package structure, FFI integration, and library patterns.
license: MIT
compatibility: opencode
---

## What I do
Help you write and maintain Helix editor plugins and Steel libraries following the patterns used in the Steel package registry.

## Package structure

**Pure Steel libraries:**
- `cog.scm`: Package metadata (package-name, version, dependencies)
- Main `.scm` files: Library code with `(provide symbol-name ...)` exports
- Use `;;@doc` comments for documentation before function definitions

**Helix plugins with Rust FFI:**
- `cog.scm`: Package metadata including dylibs specification
- `plugin-name.scm`: Main entry point requiring helix modules and Rust dylib
- `src/`: Steel helper modules
- `Cargo.toml`: Rust crate compiled as cdylib
- `src/lib.rs`: Rust FFI module with `declare_module!` macro

**Standard directories:**
- `ui/`: UI components (drawing, fields, window, styles, utils)
- `.github/`: CI/CD configuration

## cog.scm format

```scheme
(define package-name 'package-name)
(define version "0.1.0")
(define dependencies '())
(define dylibs '((#:name "libname" #:modules ("mod1" "mod2"))))
```

## Helix plugin patterns

**Require Helix builtins:**
```scheme
(require-builtin helix/components as helix.components.)
(require-builtin helix/core/typable as helix.)
(require "helix/editor.scm")
(require "helix/misc.scm")
(require "helix/components.scm")
```

**Load Rust dylib:**
```scheme
(#%require-dylib "libplugin_hx" (prefix-in lib. (only-in Type Type-method)))
```

**Define commands:**
```scheme
(provide command-name)

;;@doc
;;Command description here.
(define (command-name . args)
  (helix.command *helix.cx* args))
```

**UI components:**
- Use `*helix.cx*` as global context
- Create components: `new-component!`, `push-component!`
- Drawing: `frame-set-string!`, `frame-set-line!`
- Event handling: Check `key-event-char?`, `key-event-escape?`, `key-event-modifier`
- Constants: `event-result/close`, `key-modifier-ctrl`

## Steel library patterns

**Module structure:**
```scheme
(require "other-module.scm")
(provide export1 export2 export3)

;;@doc
;;Function description with usage example.
(define (export1 arg1 [arg2 default-value])
  body)
```

**Structs:**
```scheme
(struct My-Struct (field1 field2) #:mutable #:transparent)
(provide My-Struct My-Struct? My-Struct-field1)

(define/contract (my-constructor arg)
  (->/c type? My-Struct?)
  (My-Struct val1 val2))
```

**Transducers (for data processing):**
```scheme
(require "steel/transducers")

(transduce data (tmap f) (into-list))
(transduce data (tfilter pred) (into-vector))
```

## Rust FFI patterns

**Cargo.toml for cdylib:**
```toml
[lib]
name = "plugin_hx"
crate-type = ["cdylib"]

[dependencies]
steel-core = { version = "0.7.0", features = ["dylibs", "sync"] }
steel-derive = "0.6.0"
```

**Module registration in lib.rs:**
```rust
use steel::{declare_module, steel_vm::ffi::{FFIModule, RegisterFFIFn}};

declare_module!(create_module);

fn create_module() -> FFIModule {
    let mut module = FFIModule::new("steel/plugin");
    module.register_fn("scheme-name", rust_function);
    module
}
```

## Common patterns

**Logging:**
- Define `plugin-name` and `default-logging-enabled` in `plugin.scm`
- Use `init-plugin` to setup logging with optional config
- Log with `log-info`, `log-debug`, `log-error`

**Configuration:**
- Keep plugin defaults in `plugin.scm`
- Allow user overrides via `init-plugin` arguments
- Use alists or hashmaps for config storage

**Testing:**
- Write tests alongside library code
- Use steel/tests package or define test helpers
- Test Rust code with `#[cfg(test)]` modules

## When to use me

Use when:
- Creating new Helix plugins
- Writing Steel libraries
- Adding Rust FFI functions to existing plugins
- Refactoring plugin architecture
- Debugging Steel code or FFI bindings

Ask clarifying questions if:
- The target Helix version or Steel version is unclear
- Performance requirements suggest pure Rust vs Rust+Steel hybrid
- Plugin should work in contexts without Helix (pure Steel lib needed)
