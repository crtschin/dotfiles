---
name: helix-buffer-modification
description: Helix buffer manipulation; rope operations, text edits, cursors, and transactions.
metadata:
  short-description: Modify Helix buffer content with rope operations
---

# Helix Buffer Text/Rope Modification

This skill guides you through modifying buffer content in Helix editor using the Steel programming language and rope data structures.

## Overview

Helix buffers use a **rope** data structure for efficient text editing. You can:

- Read buffer content as ropes
- Navigate and inspect rope content
- Modify buffers through commands
- Perform advanced text transformations

## Reading Buffer Content

### Get Current Document as Rope

```scheme
(require "helix/editor.scm")
(require-builtin helix/core/text as text.)

;; Get focused view and document
(define focus (editor-focus))
(define focus-doc-id (editor->doc-id focus))

;; Get document as a rope
(define rope (editor->text focus-doc-id))

;; Convert rope to string
(define text-str (text.rope->string rope))
```

### Get All Open Documents

```scheme
(define all-docs (editor-all-documents))

;; Process each document
(for-each
  (lambda (doc-id)
    (when (editor-doc-exists? doc-id)
      (define rope (editor->text doc-id))
      (define text-str (text.rope->string rope))
      ;; Process text-str...
      ))
  all-docs)
```

## Rope Inspection Operations

### Character Access

```scheme
;; Get character at specific position in rope
(text.rope-char-ref rope char-index)

;; Get length in characters
(text.rope-len-chars rope)

;; Convert character position to byte position
(text.rope-char->byte rope char-index)
```

### Line Operations

```scheme
;; Get a specific line (0-indexed)
(define line (text.rope->line rope line-index))

;; Get text up to cursor position
(define byte-pos (text.rope-char->byte rope cursor-position))
(define text-up-to-cursor (text.rope->byte-slice rope 0 byte-pos))
```

### Rope Slicing

```scheme
;; Get a slice from start to end (exclusive)
(text.rope->slice rope start-index end-index)

;; Get a byte slice
(text.rope->byte-slice rope start-byte end-byte)
```

### String Operations on Ropes

```scheme
;; Check if rope starts with string
(text.rope-starts-with? rope "prefix")

;; Trim leading whitespace
(define trimmed (text.rope-trim-start rope))

;; Convert slice to string
(~> line
     (text.rope->slice start end)
     (text.rope->string))
```

## Buffer Modification Commands

### Delete Operations

```scheme
(require "helix/static.scm")

;; Delete current selection (and yank to register)
(delete_selection)

;; Delete selection without yanking to register
(delete_selection_noyank)

;; Delete character before cursor
(delete_char_backward)

;; Delete character after cursor
(delete_char_forward)

;; Delete word before cursor
(delete_word_backward)

;; Delete word after cursor
(delete_word_forward)

;; Kill (delete) to start of line
(kill_to_line_start)

;; Kill to end of line
(kill_to_line_end)

;; Change selection (delete and enter insert mode)
(change_selection)

;; Change selection without yanking
(change_selection_noyank)
```

### Insert Operations

```scheme
;; Enter insert mode at cursor position
(insert_mode)

;; Enter insert mode at line start
(insert_at_line_start)

;; Enter insert mode at line end
(insert_at_line_end)

;; Enter append mode (after selection)
(append_mode)

;; Insert tab
(insert_tab)

;; Insert newline
(insert_newline)

;; Insert newline with custom indentation
(insert-newline-hook "  ")  ;; Two spaces
```

### Replace Operations

```scheme
;; Enter replace mode (replace characters one by one)
(replace)

;; Replace current selection with yanked text
(replace_with_yanked)

;; Replace selections with clipboard content
(replace_selections_with_clipboard)

;; Replace selections with primary clipboard
(replace_selections_with_primary_clipboard)
```

### Paste Operations

```scheme
;; Paste after selection
(paste_after)

;; Paste before selection
(paste_before)

;; Paste clipboard after selections
(paste_clipboard_after)

;; Paste clipboard before selections
(paste_clipboard_before)

;; Paste before selections from clipboard
(clipboard-paste-before)

;; Paste after selections from clipboard
(clipboard-paste-after)

;; Replace selections with clipboard
(clipboard-paste-replace)
```

### Undo/Redo

```scheme
;; Undo last change
(undo)

;; Redo last change
(redo)

;; Move backward in history
(earlier)

;; Move forward in history
(later)

;; Commit changes to new checkpoint
(commit_undo_checkpoint)
```

## Cursor and Navigation

### Getting Cursor Position

```scheme
(require "helix/misc.scm")

;; Get cursor position as integer
(define pos (cursor-position))

;; Deprecated: use cursor-position instead
(define pos (hx.cx->pos))
```

### Getting Current Context

```scheme
;; Get current line number
(helix.static.get-current-line-number)

;; Get primary cursor position (returns Position? or #false)
(current-cursor)
```

## Advanced Example: Custom Indentation

```scheme
(require-builtin helix/core/text as text.)

(define (calculate-indent rope current-line-number cursor-pos)
  ;; Convert char position to byte position
  (define byte-pos (text.rope-char->byte rope cursor-pos))
  (define text-up-to-cursor (text.rope->byte-slice rope 0 byte-pos))

  ;; Walk backwards to find opening parenthesis/bracket
  (define line (text.rope->line text-up-to-cursor current-line-number))

  ;; Calculate indentation depth
  ;; ... custom logic ...

  ;; Return indent string
  "  ")  ;; Two spaces

;; Apply custom indent on newline
(define (apply-custom-indent)
  (define rope (editor->text (editor->doc-id (editor-focus))))
  (define current-line (helix.static.get-current-line-number))
  (define pos (cursor-position))
  (insert-newline-hook (calculate-indent rope current-line pos)))
```

## Common Patterns

### Pattern 1: Read and Transform Buffer

```scheme
(define (transform-buffer transform-fn)
  (define doc-id (editor->doc-id (editor-focus)))
  (define rope (editor->text doc-id))
  (define text (text.rope->string rope))

  ;; Transform the text
  (define new-text (transform-fn text))

  ;; Note: You need to clear and insert new text
  ;; This is typically done via commands or direct FFI
  )
```

### Pattern 2: Check Before Modifying

```scheme
(define (safe-delete-selection)
  (define mode (editor-mode))
  (when (not (equal? mode "insert"))
    ;; Delete only if not in insert mode
    (delete_selection)))
```

### Pattern 3: Get Context Around Cursor

```scheme
(define (get-context-around-cursor chars-before chars-after)
  (define doc-id (editor->doc-id (editor-focus)))
  (define rope (editor->text doc-id))
  (define pos (cursor-position))

  (define start (max 0 (- pos chars-before)))
  (define end (+ pos chars-after))

  (define slice (text.rope->slice rope start end))
  (text.rope->string slice))
```

## Important Notes

1. **All modifications use the global context `*helix.cx*`** - The command functions automatically use the current editor context
2. **Positions are 0-indexed** - Character positions start at 0
3. **Lines are 0-indexed** - Line numbers start at 0
4. **Rope vs String** - Work with ropes for efficiency, convert to strings only when needed
5. **Byte vs Char positions** - UTF-8 encoding means byte and char positions differ for multi-byte characters
6. **Undo/Redo** - Manual text replacement may not track undo history unless using proper commands

## Best Practices

1. **Use existing commands when possible** - They handle undo history, selections, and edge cases
2. **Check document exists** before operations: `(editor-doc-exists? doc-id)`
3. **Handle mode appropriately** - Some operations only work in specific modes
4. **Check dirty status** before destructive operations: `(editor-document-dirty? doc-id)`
5. **Test with small documents first** - Rope operations are efficient but test logic on small inputs
6. **Convert to string only when needed** - Rope operations are more efficient for large texts

## Example: Simple Find and Replace

```scheme
(define (find-and-replace-in-buffer find-text replace-text)
  (define doc-id (editor->doc-id (editor-focus)))
  (define rope (editor->text doc-id))
  (define text-str (text.rope->string rope))

  ;; Simple string replacement
  (define new-text (string-replace text-str find-text replace-text))

  ;; Note: This would require clearing buffer and inserting new text
  ;; In practice, use clipboard-paste-replace or other commands
  )
```

## Troubleshooting

**Problem**: Rope operations return unexpected results
- **Solution**: Check if you're using character or byte positions consistently

**Problem**: Modifications don't show up
- **Solution**: Ensure you're calling modification commands, not just reading content

**Problem**: Undo history broken
- **Solution**: Use built-in commands instead of direct text replacement to preserve undo history

**Problem**: Multi-byte character issues
- **Solution**: Use `text.rope-char->byte` to convert between character and byte positions
