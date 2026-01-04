---
name: helix-steel-styling
description: Helix buffer styling and UI rendering; colors, themes, overlays, decorations, components, and visual effects.
---

## What I do

Help you style Helix buffers and render custom UI components using Steel. Covers color manipulation, theme integration, text rendering, overlay decorations, diff visualization, ghost text, and component creation.

## Core Styling Primitives

### Creating styles

```scheme
(require "helix/components.scm")

;; Create a base style
(define base-style (style))

;; Set foreground color
(define red-text (style-fg base-style Color/Red))

;; Set background color
(define blue-bg (style-bg base-style Color/Blue))

;; Both at once
(define style (-> (style)
                  (style-fg Color/White)
                  (style-bg Color/Black)))

;; Chaining multiple style modifications
(define styled-text (-> (style)
                      (style-with-bold)
                      (style-with-italics)
                      (style-fg Color/Green)))
```

### Style modifiers

```scheme
(require "helix/components.scm")

;; Text effects
(style-with-bold style)           ;; Bold text
(style-with-italics style)        ;; Italic text
(style-with-dim style)            ;; Dim text
(style-with-slow-blink style)     ;; Slow blinking
(style-with-rapid-blink style)    ;; Rapid blinking
(style-with-reversed style)        ;; Reversed fg/bg
(style-with-hidden style)          ;; Hidden text
(style-with-crossed-out style)    ;; Strikethrough

;; Underline
(style-underline-color style Color/Blue)
(style-underline-style style Underline/Curl)  ;; Line, Curl, Dotted, Dashed, DoubleLine
```

### Color utilities

```scheme
(require "helix/components.scm")

;; Predefined colors
Color/Reset Color/Black Color/Red Color/Green Color/Yellow
Color/Blue Color/Magenta Color/Cyan Color/White Color/Gray
Color/LightRed Color/LightGreen Color/LightYellow Color/LightBlue
Color/LightMagenta Color/LightCyan Color/LightGray

;; RGB colors
(define custom-color (Color/rgb 255 128 0))  ;; Orange

;; Indexed colors
(define indexed-color (Color/Indexed 42))

;; Access color components
(Color-red custom-color)   ;; => 255
(Color-green custom-color) ;; => 128
(Color-blue custom-color)   ;; => 0

;; Extract colors from styles
(style->fg some-style)     ;; Get foreground color
(style->bg some-style)     ;; Get background color

;; Mutate colors (rare, for performance-critical cases)
(set-color-rgb! color 200 100 50)
(set-color-indexed! color 15)
```

## Theme Integration

### Accessing theme styles

```scheme
(require "helix/components.scm")
(require "helix/themes.scm")

;; Get theme styles by scope
(define text-style (theme-scope "ui.text"))
(define popup-style (theme-scope "ui.popup"))
(define error-style (theme-scope "diagnostic.error"))

;; Get base theme colors
(theme->bg *helix.cx*)  ;; Background style
(theme->fg *helix.cx*)  ;; Foreground style

;; Use theme-aware styling
(define styled-text (theme-scope "string"))
(frame-set-string! frame x y "Hello world" styled-text)
```

### Available theme scopes

#### Syntax highlighting
- `attribute`, `type`, `type.builtin`, `type.parameter`, `type.enum`, `constructor`
- `constant`, `constant.builtin`, `constant.character`, `constant.numeric`
- `string`, `string.regexp`, `string.special`, `string.special.path`, `string.special.url`
- `comment`, `comment.line`, `comment.block`, `comment.block.documentation`
- `variable`, `variable.builtin`, `variable.parameter`, `variable.other.member`
- `keyword`, `keyword.control`, `keyword.operator`, `keyword.function`, `keyword.storage`
- `operator`, `function`, `function.builtin`, `function.method`, `function.macro`
- `tag`, `namespace`, `special`
- `markup` (heading, list, bold, italic, strikethrough, link, quote, raw)

#### Version control diffs
- `diff` - Base diff style
- `diff.plus` - Additions (inline)
- `diff.plus.gutter` - Addition gutter markers
- `diff.minus` - Deletions (inline)
- `diff.minus.gutter` - Deletion gutter markers
- `diff.delta` - Modifications
- `diff.delta.moved` - Renamed/moved files
- `diff.delta.conflict` - Merge conflicts
- `diff.delta.gutter` - Modification gutter markers

#### UI elements
- `ui.cursor`, `ui.cursor.normal`, `ui.cursor.insert`, `ui.cursor.select`
- `ui.cursor.primary`, `ui.cursor.primary.normal`, `ui.cursor.primary.insert`, `ui.cursor.primary.select`
- `ui.cursor.match` - Matching brackets/parentheses
- `ui.selection`, `ui.selection.primary`
- `ui.cursorline`, `ui.cursorline.primary`, `ui.cursorline.secondary`
- `ui.cursorcolumn.primary`, `ui.cursorcolumn.secondary`
- `ui.gutter`, `ui.gutter.selected`
- `ui.linenr`, `ui.linenr.selected`
- `ui.statusline`, `ui.statusline.inactive`, `ui.statusline.normal`, `ui.statusline.insert`, `ui.statusline.select`
- `ui.statusline.separator`, `ui.bufferline`, `ui.bufferline.active`, `ui.bufferline.background`
- `ui.popup`, `ui.popup.info`
- `ui.menu`, `ui.menu.selected`, `ui.menu.scroll`
- `ui.text`, `ui.text.focus`, `ui.text.inactive`, `ui.text.info`

#### Virtual elements
- `ui.virtual.whitespace`, `ui.virtual.indent-guide`, `ui.virtual.wrap`
- `ui.virtual.ruler` - Vertical ruler lines
- `ui.virtual.jump-label` - Jump labels
- `ui.virtual.inlay-hint` - Ghost text
- `ui.virtual.inlay-hint.parameter` - Parameter hints
- `ui.virtual.inlay-hint.type` - Type hints

#### Diagnostics
- `warning`, `error`, `info`, `hint` - Gutter diagnostics
- `diagnostic`, `diagnostic.hint`, `diagnostic.info`, `diagnostic.warning`, `diagnostic.error`
- `diagnostic.unnecessary`, `diagnostic.deprecated`

#### Other UI
- `ui.highlight`, `ui.highlight.frameline`
- `ui.background`, `ui.background.separator`
- `ui.window`, `ui.help`
- `ui.debug.breakpoint`, `ui.debug.active`

## Buffer Drawing

### Direct text rendering

```scheme
(require "helix/components.scm")

;; Render text at specific position
(frame-set-string! frame x y "Hello" style)

;; Style text with theme
(frame-set-string! frame x y "Error message"
                      (theme-scope "diagnostic.error"))

;; Multi-line text
(for i in (range 0 10)
  (frame-set-string! frame 5 i
                     (string-append "Line " (int->string i))
                     (theme-scope "ui.text")))
```

### Area manipulation

```scheme
(require "helix/components.scm")

;; Create rectangular areas
(define my-area (area x y width height))

;; Access area components
(area-x area)        ;; x position
(area-y area)        ;; y position
(area-width area)    ;; width
(area-height area)    ;; height

;; Get buffer area
(define buffer-rect (buffer-area frame))

;; Clear areas
(buffer/clear frame area)                    ;; Clear to default
(buffer/clear-with frame area style)           ;; Clear with specific style
```

### Styled segments

```scheme
(require "scooter/ui/drawing.scm")

;; Render multi-colored text
(define segments (list
  (cons "Error: " (theme-scope "diagnostic.error"))
  (cons "file not found" (theme-scope "ui.text"))))

;; Render with automatic truncation and fill
(render-styled-segments frame x y segments max-width fill-style)

;; Render within a specific area
(render-styled-segments-in-area frame area row segments fill-style)

;; Complex multi-segment rendering
(define status-segments (list
  (cons "MODE" (style-with-bold (theme-scope "ui.statusline.normal")))
  (cons " " (style))
  (cons "normal" (theme-scope "ui.statusline.normal"))
  (cons " | " (theme-scope "ui.statusline.separator"))
  (cons "line 42" (theme-scope "ui.text"))))
```

## Block and Border Rendering

### Creating styled blocks

```scheme
(require "helix/components.scm")

;; Create a block with borders
(define block-style (theme-scope "ui.background"))
(define border-style (theme-scope "ui.border"))
(define my-block (make-block block-style border-style "all" "plain"))

;; Border options: "all", "top", "bottom", "left", "right", "none"
;; Border types: "plain", "rounded", "double", "thick"

;; Render block to area
(block/render frame area my-block)

;; Example: popup window
(define popup-area (area 10 5 60 20))
(block/render frame popup-area
              (make-block (theme-scope "ui.background")
                          (theme-scope "ui.border")
                          "all" "rounded"))
```

### Custom border drawing

```scheme
(require "scooter/ui/drawing.scm")

;; Draw custom borders
(draw-border! frame x y width height style)

;; Draw box with title and content
(draw-box! frame x y width height style
           #:title "Warning"
           #:content '("Line 1" "Line 2" "Line 3")
           #:padding 2)

;; Draw block border with custom type
(draw-block-border! frame area style #:border-type "double")

;; Draw horizontal lines
(draw-horizontal-line! frame x y width style
                        #:left-cap "┌"
                        #:right-cap "┐")

;; Draw vertical lines
(draw-vertical-lines! frame (list 10 20 30) y style)

;; Draw single text line
(draw-text-line! frame x y "text" style)
```

### Advanced: Using blocks for highlighting regions

```scheme
;; Highlight a specific region with border
(define highlight-area (area start-x start-y width height))
(block/render frame highlight-area
              (make-block (theme-scope "ui.highlight")
                          (theme-scope "ui.highlight")
                          "all" "plain"))

;; Nested blocks for complex UI
(define outer-area (area 0 0 80 25))
(block/render frame outer-area
              (make-block (theme-scope "ui.background")
                          (theme-scope "ui.border")
                          "all" "rounded"))

(define inner-area (area 2 2 76 21))
(block/render frame inner-area
              (make-block (theme-scope "ui.background")
                          (theme-scope "ui.border")
                          "all" "plain"))
```

## Custom Components

### Component structure

```scheme
(require "helix/components.scm")
(require "helix/misc.scm")

;; Define component state
(struct MyComponent (text counter))

;; Define render function
(define (my-render state rect)
  (lambda (frame)
    (define area (buffer-area frame))
    (buffer/clear frame area)
    (frame-set-string! frame 1 1 (MyComponent-text state)
                      (theme-scope "ui.text"))
    (frame-set-string! frame 1 2
                      (string-append "Count: " (int->string (MyComponent-counter state)))
                      (theme-scope "ui.menu.selected"))))

;; Define event handler
(define (my-handle-event state event)
  (if (key-event-escape? event)
      event-result/close
      event-result/consume))

;; Create and push component
(define my-state (MyComponent "Hello" 0))
(define my-component
  (new-component! "my-component"
                  my-state
                  my-render
                  (hash "handle_event" my-handle-event)))

(push-component! my-component)
```

### Advanced: Interactive list picker

```scheme
(struct Picker (items cursor highlight-style))

(define (picker-render state rect)
  (lambda (frame)
    (define area (buffer-area frame))
    (buffer/clear frame area)

    ;; Render each item
    (for i in (range 0 (length (Picker-items state)))
      (define is-selected (= i (Picker-cursor state)))
      (define style (if is-selected
                      (Picker-highlight-style state)
                      (theme-scope "ui.text")))
      (frame-set-string! frame 2 (+ i 1)
                        (list-ref (Picker-items state) i)
                        style))))

(define (picker-handle-event state event)
  (cond
    [(key-event-escape? event) event-result/close]
    [(key-event-down? event)
     (define new-cursor (min (+ (Picker-cursor state) 1)
                              (- (length (Picker-items state)) 1)))
     (event-result/consume (Picker (Picker-items state) new-cursor
                                   (Picker-highlight-style state)))]
    [(key-event-enter? event)
     (define selected (list-ref (Picker-items state) (Picker-cursor state)))
     (displayln selected)
     event-result/close]
    [else event-result/ignore]))

;; Create picker
(define items (list "Option 1" "Option 2" "Option 3"))
(define picker-state (Picker items 0 (style-with-bold (theme-scope "ui.menu.selected"))))
(define picker-component
  (new-component! "picker" picker-state
                  (picker-render picker-state)
                  (hash "handle_event" picker-handle-event)))
```

## Ghost Text and Inlay Hints

### Adding inlay hints (experimental)

```scheme
(require "helix/misc.scm")

;; Add inline ghost text
(define hint-id (add-inlay-hint char-index ": string"))

;; hint-id returns (first-line, last-line) for removal
(define first-line (car hint-id))
(define last-line (cdr hint-id))

;; Style automatically uses ui.virtual.inlay-hint scope
;; Can override with:
(define custom-style (style-fg (style) Color/Gray))

;; Remove by ID
(remove-inlay-hint-by-id first-line last-line)

;; Remove at specific position
(remove-inlay-hint char-index ": string")
```

### Type hints visualization

```scheme
;; Add parameter type hints
(add-inlay-hint param-index ": String")
(add-inlay-hint param-index ": int")

;; Add function return type hints
(add-inlay-hint after-function-index "-> bool")

;; Style hints differently based on type
(define param-style (theme-scope "ui.virtual.inlay-hint.parameter"))
(define type-style (theme-scope "ui.virtual.inlay-hint.type"))

;; Note: Custom styling requires direct buffer manipulation
;; as inlay hints use theme scopes automatically
```

## Row/Column Emphasis

### Cursor-based highlighting

```scheme
(require "helix/configuration.scm")

;; Enable cursor line highlighting
(set-option! "editor.cursorline" "true")

;; Enable cursor column highlighting
(set-option! "editor.cursorcolumn" "true")

;; Styles applied automatically from theme:
;; - ui.cursorline.primary - Active cursor line
;; - ui.cursorline.secondary - Secondary cursor lines (multi-cursor)
;; - ui.cursorcolumn.primary - Active cursor column
;; - ui.cursorcolumn.secondary - Secondary cursor columns
```

### Manual row/column emphasis

```scheme
;; Highlight specific row
(define row-style (theme-scope "ui.highlight.frameline"))
(for x in (range 0 (area-width area))
  (frame-set-string! frame x target-row " " row-style))

;; Highlight specific column
(define col-style (theme-scope "ui.virtual.ruler"))
(for y in (range 0 (area-height area))
  (frame-set-string! frame target-column y "|" col-style))

;; Create vertical guides at multiple columns
(define guide-columns (list 4 8 12))
(for col in guide-columns
  (for y in (range 0 (area-height area))
    (frame-set-string! frame col y "·"
                      (theme-scope "ui.virtual.indent-guide"))))

;; Create horizontal separator line
(define separator-style (style-fg (style) Color/Gray))
(define separator-line (make-string (area-width area) #\-))
(frame-set-string! frame 0 10 separator-line separator-style)
```

### Diagnostics overlay

```scheme
;; Render error markers in gutter
(define gutter-width 5)
(for line in error-lines
  (frame-set-string! frame 0 line "✗"
                    (theme-scope "error")))

;; Render inline diagnostics
(for diag in diagnostics
  (match (Diagnostic-severity diag)
    ['error
     (frame-set-string! frame diag-start-x diag-line
                       (substring text diag-start diag-end)
                       (theme-scope "diagnostic.error"))]
    ['warning
     (frame-set-string! frame diag-start-x diag-line
                       (substring text diag-start diag-end)
                       (theme-scope "diagnostic.warning"))]))

;; Mix with diff styling
(frame-set-string! frame 10 5 "added text"
                  (theme-scope "diff.plus"))
(frame-set-string! frame 10 6 "removed text"
                  (theme-scope "diff.minus"))
```

## Advanced Patterns

### Hover tooltip with border

```scheme
(struct Tooltip (text position visible?))

(define (tooltip-render state rect)
  (lambda (frame)
    (when (Tooltip-visible? state)
      (define text-width (char-width (Tooltip-text state)))
      (define tooltip-x (Tooltip-position-x state))
      (define tooltip-y (Tooltip-position-y state))
      (define tooltip-area (area tooltip-x tooltip-y (+ text-width 4) 3))

      ;; Draw border and background
      (block/render frame tooltip-area
                    (make-block (theme-scope "ui.popup.info")
                                (theme-scope "ui.border")
                                "all" "rounded"))

      ;; Draw text
      (frame-set-string! frame (+ tooltip-x 2) (+ tooltip-y 1)
                        (Tooltip-text state)
                        (theme-scope "ui.text")))))

;; Update tooltip position based on cursor
(define (update-tooltip! cursor-pos text)
  (define tooltip-state
    (Tooltip text cursor-pos #t))
  (render-tooltip tooltip-state))
```

### Progress bar rendering

```scheme
(define (draw-progress-bar frame x y width progress-percent)
  (define filled-width (floor (/ (* width progress-percent) 100)))
  (define empty-width (- width filled-width))

  ;; Draw filled portion
  (define filled-bar (make-string filled-width #\=))
  (frame-set-string! frame x y filled-bar
                    (theme-scope "ui.menu.selected"))

  ;; Draw empty portion
  (define empty-bar (make-string empty-width #\ ))
  (frame-set-string! frame (+ x filled-width) y empty-bar
                    (theme-scope "ui.menu")))

  ;; Draw percentage text
  (define percent-text (string-append (int->string progress-percent) "%"))
  (frame-set-string! frame (+ x (quotient width 2)) y percent-text
                    (style-with-bold (theme-scope "ui.text"))))
```

### Multi-colored status line

```scheme
(define (render-status-line frame area components)
  (define total-width (area-width area))
  (define current-x (area-x area))
  (define y (area-y area))

  (for comp in components
    (define text (Component-text comp))
    (define style (Component-style comp))
    (define text-width (char-width text))

    ;; Ensure we don't overflow
    (when (> text-width 0)
      (define truncated (if (> (+ current-x text-width) total-width)
                           (truncate-string text (- total-width current-x))
                           text))
      (frame-set-string! frame current-x y truncated style)
      (set! current-x (+ current-x text-width))))

;; Usage
(render-status-line frame status-area
                   (list (Component "MODE" (style-with-bold (theme-scope "ui.statusline.normal")))
                         (Component "normal" (theme-scope "ui.statusline.normal"))
                         (Component "  |  " (theme-scope "ui.statusline.separator"))
                         (Component "line 42" (theme-scope "ui.text"))))
```

### File tree with icons and colors

```scheme
(define (draw-tree-item frame x y path indent-level is-expanded is-directory)
  (define indent (make-string (* indent-level 2) #\space))
  (define icon (if is-expanded "▼ " (if is-directory "▶ " "  ")))
  (define name (path-basename path))

  (define base-style (theme-scope "ui.text"))
  (define dir-style (style-with-bold base-style))
  (define file-style base-style)

  (define style (if is-directory dir-style file-style))
  (define display-text (string-append indent icon name))

  (frame-set-string! frame x y display-text style))

;; Render entire tree
(define (draw-tree frame area tree-structure)
  (buffer/clear frame area)
  (for item in tree-structure
    (let ([level (TreeItem-level item)]
          [path (TreeItem-path item)]
          [expanded (TreeItem-expanded? item)]
          [is-dir (TreeItem-is-directory? item)])
      (draw-tree-item frame (area-x area) (+ (area-y area) (TreeItem-index item))
                    path level expanded is-dir))))
```

### Search results with highlighting

```scheme
(define (draw-search-result frame x y line query start-idx end-idx)
  (define before (substring line 0 start-idx))
  (define match (substring line start-idx end-idx))
  (define after (substring line end-idx))

  (define normal-style (theme-scope "ui.text"))
  (define match-style (style-with-bold (theme-scope "ui.text.focus")))
  (define cursor-x x)

  (frame-set-string! frame cursor-x y before normal-style)
  (set! cursor-x (+ cursor-x (char-width before)))

  (frame-set-string! frame cursor-x y match match-style)
  (set! cursor-x (+ cursor-x (char-width match)))

  (frame-set-string! frame cursor-x y after normal-style))
```

### Diff visualization with context

```scheme
(define (draw-diff-hunk frame x y old-line new-line diff-type)
  (define line-num-width 5)
  (define separator "│")

  (match diff-type
    ['addition
     (frame-set-string! frame x y "     " (theme-scope "ui.gutter"))
     (frame-set-string! frame (+ x line-num-width) y separator (theme-scope "ui.text"))
     (frame-set-string! frame (+ x line-num-width 2) y
                       (string-append "+ " new-line)
                       (theme-scope "diff.plus"))]

    ['deletion
     (frame-set-string! frame x y "     " (theme-scope "ui.gutter"))
     (frame-set-string! frame (+ x line-num-width) y separator (theme-scope "ui.text"))
     (frame-set-string! frame (+ x line-num-width 2) y
                       (string-append "- " old-line)
                       (theme-scope "diff.minus"))]

    ['modification
     (frame-set-string! frame x y "     " (theme-scope "ui.gutter"))
     (frame-set-string! frame (+ x line-num-width) y separator (theme-scope "ui.text"))
     (frame-set-string! frame (+ x line-num-width 2) y
                       (string-append "~ " new-line)
                       (theme-scope "diff.delta"))]))
```

## Best Practices

1. **Always use theme scopes** - Ensures consistency with user's color scheme
2. **Clear areas before rendering** - Prevent visual artifacts
3. **Handle text overflow** - Use truncation and width calculations
4. **Cache styles** - Reuse style objects instead of recreating
5. **Use blocks for UI components** - Handles borders and padding automatically
6. **Test with different terminal widths** - Ensure responsive layouts
7. **Respect user preferences** - Don't hardcode colors or styles
8. **Use semantic color names** - "diagnostic.error" not "red"
9. **Consider accessibility** - Ensure sufficient contrast
10. **Clean up inlay hints** - Remove hints when no longer needed

## When to use me

Use when:
- Creating custom UI components and popups
- Rendering overlays and decorations
- Visualizing diffs or conflicts
- Adding ghost text or type hints
- Implementing interactive widgets
- Creating custom pickers or menus
- Building diagnostic visualizations
- Adding inline decorations to code

Ask clarifying questions if:
- The component needs state management complexity
- Performance requirements suggest different rendering approaches
- Integration with existing Helix features is unclear
- Custom theme support is needed
