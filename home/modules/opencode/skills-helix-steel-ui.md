---
name: helix-steel-ui
description: Structure asynchronous UI elements for Helix plugins using Steel
license: MIT
compatibility: opencode
---

## What I do
Help you build asynchronous, state-driven UI components for Helix editor plugins using Steel with proper screen management, event handling, and rendering patterns.

## Core architecture

**State machine pattern:**
- Define state structs for each screen/mode
- Use boxes `(box value)` for mutable state
- Switch screens by updating current-screen-box
- Each screen has its own render, event-handler, and cursor-handler

**Component registration:**
```scheme
(require "helix/components.scm")
(require "helix/editor.scm")

(define *session* #f)

(define (push-my-window!)
  (set! *session* (create-my-window))
  (push-component!
    (new-component!
      "my-window"
      *session*
      my-render
      (hash "handle_event" (make-my-event-handler)
            "cursor" my-cursor-handler))))

(define (destroy-window!)
  (when *session*
    (cancel-operations! *session*))
  (set! *session* #f))
```

## Component types

**Multi-screen state machine (scooter pattern):**
- Multiple screens with state transitions
- Async operations with polling
- Screen state preservation

**Single-screen components (picker/splash pattern):**
- Single struct with all state
- One-shot use, no transitions
- Simpler event handling

**Persistent components (terminal pattern):**
- Long-lived, can be shown/hidden
- External process interaction
- VTE rendering with cell iteration

## Multi-screen patterns

Define separate structs for each screen/mode:

```scheme
;; Input screen state
(struct InputScreenState
        (field-values-box
         cursor-position-box
         current-field-box
         errors-box))

;; Results screen state (preserves input state)
(struct ResultsScreenState
        (result-count-box
         is-complete-box
         results-box
         selected-index-box
         scroll-offset-box
         content-height-box
         preserved-input-state))

;; Progress screen state
(struct ProgressScreenState
        (operation-id-box
         status-box))

;; Complete screen state
(struct CompleteScreenState
        (results-box
         errors-box))

;; Main window struct
(struct MyWindow
        (current-screen-box
         cursor-position
         engine-box))
```

## Single-screen components

**Picker component:**
```scheme
(struct Picker
        (items items-view
               callback
               preview-func
               text-buffer
               cursor
               max-length
               window-start
               value-formatter
               highlight-prefix
               default-style
               highlight-style
               cursor-position))

(define (picker-event-handler state event)
  (cond
    [(key-event-escape? event) event-result/close]
    [(key-event-down? event)
     (move-cursor-down state)
     event-result/consume]
    [(key-event-up? event)
     (move-cursor-up state)
     event-result/consume]
    [(key-event-enter? event)
     (callback (list-ref (unbox (Picker-items-view state)) (unbox (Picker-cursor state))))
     event-result/close]
    [(key-event-backspace? event)
     (pop-character (Picker-text-buffer state))
     (set-box! (Picker-items-view state)
               (fuzzy-match (text-field->string (Picker-text-buffer state))
                            (Picker-items state)))
     event-result/consume]
    [(char? (key-event-char event))
     (push-character (Picker-text-buffer state) (key-event-char event))
     (set-box! (Picker-items-view state)
               (fuzzy-match (text-field->string (Picker-text-buffer state))
                            (Picker-items state)))
     event-result/consume]
    [else event-result/ignore]))
```

**Splash screen:**
```scheme
(struct Splash ())

(define (splash-event-handler _ event)
  (if (key-event? event) event-result/ignore-and-close event-result/ignore))

(define (show-splash)
  (push-component! (new-component! "splash-screen"
                                    (Splash)
                                    splash-render
                                    (hash "handle_event" splash-event-handler))))
```

## Persistent components (VTE/Terminal)

**Terminal struct with VTE rendering:**
```scheme
(struct Terminal
        (name
         cursor
         viewport-width
         viewport-height
         focused?
         active
         *pty-process*
         *vte*
         style-cursor
         color-cursor-fg
         color-cursor-bg
         kill-switch
         str-cell
         cell-fg
         cell-bg
         area
         dragged?
         renderer
         event-handler
         cursor-handler
         x-term
         y-term))

;; Cell-by-cell rendering (efficient pattern)
(define (terminal-render state rect frame)
  (let* ([block-area (calculate-area state rect)]
         [x-offset (+ 1 (area-x block-area))]
         [y-offset (+ 1 (area-y block-area))]
         [*vte* (Terminal-*vte* state)]
         [style-cursor (Terminal-style-cursor state)]
         [cell-str (Terminal-str-cell state)]
         [cell-fg (Terminal-cell-fg state)]
         [cell-bg (Terminal-cell-bg state)])

    (buffer/clear frame block-area)
    (block/render frame block-area (make-block style-cursor style-cursor "all" "plain"))

    (unless (unbox (Terminal-dragged? state))
      (vte/reset-iterator! *vte*)

      ;; Iterate over all VTE cells
      (while (vte/advance-iterator-and-update-cells! *vte* cell-str cell-bg cell-fg)
             (cell-fg-bg->style style-cursor cell-fg cell-bg)
             (frame-set-string! frame
                                (+ x-offset (vte/iter-x *vte*))
                                (+ y-offset (vte/iter-y *vte*))
                                cell-str
                                style-cursor)))

    ;; Update cursor position
    (set-position-row! cursor (+ y-offset (vte/cursor-y *vte*)))
    (set-position-col! cursor (+ x-offset (vte/cursor-x *vte*) 1))))
```

**Mouse event handling:**
```scheme
(define (handle-mouse-event state event)
  (cond
    [(mouse-event-within-area? event (unbox (Terminal-area state)))
     (case (event-mouse-kind event)
       ;; Mouse down
       [(0 1 2)
        (vector-set! on-click-start 0 (event-mouse-col event))
        (vector-set! on-click-start 1 (event-mouse-row event))
        event-result/consume]

       ;; Mouse drag
       [(6 7 8)
        (define delta-x (- (event-mouse-col event) (mut-vector-ref on-click-start 0)))
        (define delta-y (- (event-mouse-row event) (mut-vector-ref on-click-start 1)))

        ;; Update terminal position
        (when x-term
          (set-box! (Terminal-x-term state) (max (+ x-term delta-x) min-x)))
        (when y-term
          (set-box! (Terminal-y-term state) (max (+ y-term delta-y) min-y)))

        event-result/consume]

       ;; Mouse wheel scroll
       [(10)
        (vte/scroll-down *vte*)
        event-result/consume]
       [(11)
        (vte/scroll-up *vte*)
        event-result/consume]

       [else event-result/consume])]
    [else event-result/ignore]))
```

## Accessors and mutators

Use boxes for mutable state accessors:

```scheme
(define (get-current-screen state)
  (unbox (MyWindow-current-screen-box state)))

(define (set-current-screen! state screen-state)
  (set-box! (MyWindow-current-screen-box state) screen-state))

(define (get-engine state)
  (unbox (MyWindow-engine-box state)))

;; Define helper for hash-in-box accessors
(define-syntax define-hash-accessors
  (syntax-rules ()
    [(define-hash-accessors getter setter! state-accessor)
     (begin
       (define (getter state key)
         (hash-ref (unbox (state-accessor state)) key))
       (define (setter! state key value)
         (set-box! (state-accessor state)
                   (hash-insert (unbox (state-accessor state)) key value))))]))
```

## Async operations

**Polling pattern for long-running operations:**

```scheme
(define (start-async-operation! state)
  (let ([engine (get-engine state)])
    (Engine-start-operation engine)
    (set-current-screen! state (ProgressScreenState (box op-id) (box "Starting...")))
    (poll-progress state)))

(define (poll-progress state)
  (let ([engine (get-engine state)])
    (enqueue-thread-local-callback
      (lambda ()
        (let ([is-complete (Engine-complete? engine)]
              [status (Engine-status engine)])
          (set-box! (ProgressScreenState-status-box (get-current-screen state)) status)
          (cond
            [is-complete
             (handle-complete! state)]
            ;; Continue polling only if still on progress screen
            [(ProgressScreenState? (get-current-screen state))
             (enqueue-thread-local-callback (lambda () (poll-progress state)))]))))))
```

**Async I/O for terminal:**
```scheme
(define (terminal-loop term callback-function)
  (define *pty-process* (Terminal-*pty-process* term))
  (define *vte* (Terminal-*vte* term))
  (define *kill-switch* (Terminal-kill-switch term))

  (define (terminal-loop-inner)
    (if (unbox *kill-switch*)
        (pop-last-component! (Terminal-name term))
        (helix-await-callback (async-try-read-line *pty-process*)
                              (lambda (line)
                                (when line
                                  (vte/advance-bytes *vte* line)
                                  (callback-function *vte* line))
                                (terminal-loop-inner)))))

  (terminal-loop-inner))
```

**Cancel operations:**
```scheme
(define (cancel-operations! state)
  (let ([engine (get-engine state)])
    (Engine-cancel-operation engine)))

(define (stop-terminal terminal)
  (kill-pty-process! (Terminal-*pty-process* terminal))
  (set-box! (Terminal-kill-switch terminal) #t)
  (set-box! (Terminal-focused? terminal) #f)
  (set-box! (Terminal-active terminal) #f)
  (pop-last-component! (Terminal-name terminal)))
```

## Rendering

**Main render function (multi-screen):**

```scheme
(define (my-render state rect frame)
  (let* ([window-area (calculate-window-area rect)]
         [content-area (calculate-content-area window-area)]
         [screen-state (get-current-screen state)]
         [popup-style (UIStyles-popup (ui-styles))])

    ;; Clear and draw window border
    (buffer/clear frame window-area)
    (block/render frame window-area (make-block popup-style popup-style "all" "plain"))

    ;; Render current screen
    (cond
      [(InputScreenState? screen-state) (draw-input-screen frame content-area state)]
      [(ResultsScreenState? screen-state) (draw-results-screen frame content-area state)]
      [(ProgressScreenState? screen-state) (draw-progress-screen frame content-area state)]
      [(CompleteScreenState? screen-state) (draw-complete-screen frame content-area state)])

    ;; Draw common elements (title, help text)
    (let ([title-area (calculate-title-area window-area)])
      (draw-title frame title-area "My Window"))
    (let ([help-area (calculate-help-area content-area)])
      (draw-help-text frame help-area (get-help-keybindings screen-state)))))
```

**Picker rendering with split layout:**
```scheme
(define (picker-render state rect frame)
  (let* ([half-parent-width (round (/ (area-width rect) 2)]
         [half-parent-height (round (/ (area-height rect) 2)]
         [starting-x-offset (round (/ (area-width rect) 4))]
         [starting-y-offset (round (/ (area-height rect) 4)]
         [block-area (area starting-x-offset (- starting-y-offset 1)
                          half-parent-width half-parent-height)]
         [preview-area (area (+ starting-x-offset (round (/ half-parent-width 2)))
                          (area-y block-area)
                          (round (/ (area-width block-area) 2))
                          (area-height block-area)])

    ;; Draw list and preview areas
    (buffer/clear frame block-area)
    (block/render frame block-area (make-block bg-style bg-style "all" "plain"))
    (block/render frame preview-area (make-block bg-style bg-style "all" "plain"))

    ;; Draw text input
    (frame-set-string! frame x y (text-field->string (Picker-text-buffer state)) found-style)

    ;; Draw list items
    (let* ([start (unbox (Picker-window-start state))]
           [view-slice (slice (unbox (Picker-items-view state))
                           start (- (unbox (Picker-max-length state)) 1)]
           [currently-highlighted (- (unbox (Picker-cursor state)) start)])

      (for-each-index
       (lambda (index row)
         (let ([style (if (= index currently-highlighted)
                          highlight-style
                          default-style)]
               [prefix (if (= index currently-highlighted)
                           highlight-prefix
                           "  ")])
           (frame-set-string! frame x (+ y 1 index)
                              (string-append prefix ((Picker-value-formatter state) row))
                              style)))
       view-slice
       0))))
```

**Drawing patterns:**
```scheme
;; Clear areas
(buffer/clear frame area)
(frame-set-string! frame x y (make-space-string width) bg-style)

;; Draw text
(frame-set-string! frame x y text style)

;; Draw boxes/borders
(block/render frame area (make-block style style "all" "plain"))

;; Styled segments (for syntax highlighting)
(define styled-segments
  (list (cons "text1" style1)
        (cons "text2" style2)))
(render-styled-segments frame x y styled-segments width)
```

## Layout helpers

```scheme
;; Window layout
(define (calculate-window-area rect)
  (let* ([window-width (min 100 (area-width rect))]
         [window-height (min 40 (area-height rect))]
         [x (quotient (- (area-width rect) window-width) 2)]
         [y (quotient (- (area-height rect) window-height) 2)])
    (area x y window-width window-height)))

(define (calculate-content-area window-area)
  (let ([border-width 2]
         [title-height 1])
    (area (+ (area-x window-area) border-width)
          (+ (area-y window-area) title-height)
          (- (area-width window-area) (* 2 border-width))
          (- (area-height window-area) title-height border-width))))

;; Split areas (for picker-style list + preview)
(define (calculate-split-areas content-area)
  (let* ([width (area-width content-area)]
         [list-width (quotient width 2)])
    (values (area (area-x content-area)
                  (area-y content-area)
                  list-width
                  (area-height content-area))
            (area (+ (area-x content-area) list-width)
                  (area-y content-area)
                  (- width list-width)
                  (area-height content-area)))))
```

## Event handling

**Main event handler (multi-screen):**

```scheme
(define (my-event-handler state event)
  (let ([screen-state (get-current-screen state)])
    (cond
      ;; Global keybindings
      [(key-with-ctrl? event #\r)
       (reset-state! state)
       event-result/consume]

      [(key-event-escape? event) event-result/close]

      ;; Screen-specific handling
      [(InputScreenState? screen-state)
       (handle-input-screen-event state event)]
      [(ResultsScreenState? screen-state)
       (handle-results-screen-event state event)]
      [(ProgressScreenState? screen-state)
       (handle-progress-screen-event state event)]
      [(CompleteScreenState? screen-state)
       (handle-complete-screen-event state event)]

      [else event-result/consume])))
```

**Key matching helpers:**

```scheme
(define (key-matches-char? event char)
  (and (key-event-char event) (equal? (key-event-char event) char)))

(define (key-with-ctrl? event char)
  (and (key-matches-char? event char)
       (equal? (key-event-modifier event) key-modifier-ctrl)))

(define (key-with-alt? event char)
  (and (key-matches-char? event char)
       (equal? (key-event-modifier event) key-modifier-alt)))
```

**Navigation patterns:**

```scheme
(define (navigate-results state direction)
  (let ([screen-state (get-current-screen state)])
    (when (ResultsScreenState? screen-state)
      (let* ([result-count (unbox (ResultsScreenState-result-count-box screen-state))]
             [current-selected (unbox (ResultsScreenState-selected-index-box screen-state))]
             [new-selected (max 0 (min (- result-count 1) (+ current-selected direction)))])
        (set-box! (ResultsScreenState-selected-index-box screen-state) new-selected)
        (ensure-selection-visible state)))))

(define (ensure-selection-visible state)
  (let ([screen-state (get-current-screen state)])
    (when (ResultsScreenState? screen-state)
      (let* ([selected (unbox (ResultsScreenState-selected-index-box screen-state))]
             [scroll (unbox (ResultsScreenState-scroll-offset-box screen-state))]
             [height (unbox (ResultsScreenState-content-height-box screen-state)])
        ;; Adjust scroll to keep selection in view
        (when (< selected scroll)
          (set-box! (ResultsScreenState-scroll-offset-box screen-state) selected))
        (when (>= selected (+ scroll height))
          (set-box! (ResultsScreenState-scroll-offset-box screen-state)
                    (max 0 (- selected height -1))))))))
```

## Cursor handling

```scheme
(define (my-cursor-handler state _)
  (let ([screen-state (get-current-screen state)])
    (and (InputScreenState? screen-state)
         (MyWindow-cursor-position state))))

;; Set cursor position in text fields
(define (position-cursor state field-id x-offset y-pos)
  (let ([screen-state (get-current-screen state)])
    (when (InputScreenState? screen-state)
      (let ([cursor-col (get-field-cursor-column state field-id)])
        (set-position-row! (MyWindow-cursor-position state) y-pos)
        (set-position-col! (MyWindow-cursor-position state) cursor-col)))))
```

## Text field handling

**Mutable text fields (append-only pattern):**
```scheme
(struct MutableTextField (text) #:mutable)

(define (push-character field char)
  (define text (MutableTextField-text field))
  (set-MutableTextField-text! field '())
  (set-MutableTextField-text! field (cons char text)))

(define (pop-character field)
  (define text (MutableTextField-text field))
  (set-MutableTextField-text! field '())
  (set-MutableTextField-text! field (if (empty? text) text (cdr text))))

(define (text-field->string field)
  (~> (MutableTextField-text field) reverse list->string))
```

**Load TextField from Rust dylib:**

```scheme
(#%require-dylib "libplugin_hx"
                 (only-in TextField? TextField-new TextField-text
                          TextField-cursor-pos TextField-enter-char
                          TextField-delete-char TextField-move-cursor-left
                          TextField-move-cursor-right TextField-clear
                          TextField-insert-text))

;; Create text fields
(define (create-initial-fields)
  (hash 'search (TextField-new "")
        'replace (TextField-new "")))

;; Handle text input
(define (handle-textfield-key textfield event)
  (cond
    [(key-event-backspace? event) (TextField-delete-char textfield)]
    [(key-event-left? event) (TextField-move-cursor-left textfield)]
    [(key-event-right? event) (TextField-move-cursor-right textfield)]
    [(key-event-char event) (TextField-enter-char textfield (key-event-char event))]
    [else #f]))

;; Handle paste
(define (handle-paste! state field-id text)
  (let ([screen-state (get-current-screen state)])
    (when (InputScreenState? screen-state)
      (let ([textfield (hash-ref (unbox (InputScreenState-field-values-box screen-state)) field-id)])
        (when (TextField? textfield)
          (TextField-insert-text textfield text))))))
```

## Component lifecycle

**Push with conditions (persistent components):**
```scheme
(define (show-term term)
  (set-box! (Terminal-focused? term) #t)

  (set-editor-clip-right! *default-terminal-cols*)

  ;; Only push if not already active
  (unless (unbox (Terminal-active term))
    (set-box! (Terminal-active term) #t)
    (push-component! (new-component! (Terminal-name term)
                                   term
                                   (Terminal-renderer term)
                                   (create-component-dict term)))))

(define (create-component-dict term)
  (define add-handle
    (lambda (t)
      (if (Terminal-event-handler term)
          (hash-insert t "handle_event" (Terminal-event-handler term))
          t)))
  (define add-cursor
    (lambda (t)
      (if (Terminal-cursor-handler term)
          (hash-insert t "cursor" (Terminal-cursor-handler term)) t)))
  (~> (hash) add-handle add-cursor))
```

**Component registry (managing multiple instances):**
```scheme
(struct TerminalRegistry (terminals cursor) #:mutable)

(define *terminal-registry* (TerminalRegistry '() (box 0)))

(define (switch-term index)
  (set-TerminalRegistry-cursor! *terminal-registry* index)
  (let ([term (list-ref (TerminalRegistry-terminals *terminal-registry*) index)])
    (show-term term)))

(define (new-term shell)
  (define cursor (TerminalRegistry-cursor *terminal-registry*))
  (cond
    [cursor (show-term (list-ref (TerminalRegistry-terminals *terminal-registry*) cursor))]
    [else
     (define new-terminal (make-terminal name shell rows cols #f))
     (set-TerminalRegistry-terminals! *terminal-registry*
           (append (TerminalRegistry-terminals *terminal-registry*)
                   (list new-terminal)))]))
```

## Focus management

```scheme
(define focused? #f)
(struct FocusMode ())

(define (render-focus-mode _ rect _)
  (define width (exact (round (/ (area-width rect) 6)))
  (set-editor-clip-right! width)
  (set-editor-clip-left! width))

(define (focus)
  (unless focused?
    (set! focused? #t)
    (push-component! (new-component! "focus-mode" (FocusMode) render-focus-mode
                                       (hash "handle_event" event-handler)))
    (enqueue-thread-local-callback (lambda () void))))

(define (unfocus)
  (when focused?
    (set! focused? #f)
    (pop-last-component-by-name! "focus-mode")
    (enqueue-thread-local-callback (lambda ()
      (set-editor-clip-right! 0)
      (set-editor-clip-left! 0)))))
```

## Styles

Define UI styles using Helix theme scopes:

```scheme
(struct UIStyles (text popup active dim status line-num
                   selection cursor error warning info fg bg))

(define (ui-styles)
  (UIStyles (theme-scope *helix.cx* "ui.text")
            (theme-scope *helix.cx* "ui.popup")
            (style-with-bold (theme-scope *helix.cx* "ui.selection"))
            (theme-scope *helix.cx* "ui.text.inactive")
            (theme-scope *helix.cx* "ui.statusline")
            (theme-scope *helix.cx* "special")
            (theme-scope *helix.cx* "ui.selection")
            (theme-scope *helix.cx* "ui.cursor")
            (theme-scope *helix.cx* "error")
            (theme-scope *helix.cx* "warning")
            (theme-scope *helix.cx* "info")
            (theme->fg *helix.cx*)
            (theme->bg *helix.cx*)))
```

## Error handling

```scheme
;; Store errors in screen state
(struct InputScreenState
        (field-values-box
         cursor-position-box
         current-field-box
         errors-box))  ;; Hash: field-id -> (list error-msgs)

;; Clear errors on input
(define (clear-field-error! state field-id)
  (let ([screen-state (get-current-screen state)])
    (when (InputScreenState? screen-state)
      (let ([errors (unbox (InputScreenState-errors-box screen-state))])
        (set-box! (InputScreenState-errors-box screen-state)
                  (hash-remove errors field-id))))))

;; Set field errors
(define (set-field-errors! state field-id error-list)
  (let ([screen-state (get-current-screen state)])
    (when (InputScreenState? screen-state)
      (let ([errors (unbox (InputScreenState-errors-box screen-state))])
        (set-box! (InputScreenState-errors-box screen-state)
                  (hash-insert errors field-id error-list))))))

;; Draw errors
(define (draw-field-errors frame x y errors style)
  (when (and errors (> (length errors) 0))
    (frame-set-string! frame x y (string-append "Error: " (car errors)) style)))
```

## When to use me

Use when:
- Creating multi-screen UI components (input → results → progress → complete)
- Building single-screen pickers with fuzzy matching and preview areas
- Implementing terminal emulators with VTE rendering and PTY interaction
- Creating splash screens or temporary overlays
- Managing persistent components (terminals, file trees)
- Handling asynchronous operations (file searches, API calls, long computations)
- Building interactive forms with validation
- Implementing navigation in lists/tables with scrolling
- Managing component focus and editor clip regions
- Handling mouse events for UI interaction

Key patterns:
- Multi-screen: Screen state machine for mode switching
- Single-screen: Simple struct with one-shot usage
- Persistent: Long-lived with show/hide capability
- Boxed values for mutable state
- Polling with `enqueue-thread-local-callback` for async operations
- VTE cell iteration for terminal rendering
- Mouse event handling for drag/scroll
- Separate render, event-handler, and cursor-handler functions
- Component lifecycle (push with conditions, pop by name)
- Component registry for managing multiple instances
- Helper functions for layout, navigation, and drawing
