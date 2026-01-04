---
name: steel-threading
description: Steel threading and concurrency; native threads, thread pools, channels, sync primitives, cooperative threading, and Helix integration.
---

## What I do

Help you write concurrent and threaded code in Steel, including native OS threads, cooperative threads, thread pools, channels, synchronization primitives, and Helix editor integration patterns.

## Native Threading

### Spawning native OS threads

```scheme
(require "steel/sync")

;; Spawn a native thread with a lambda
(spawn-native-thread
  (lambda ()
    (displayln "Running in background thread")
    ;; Do work here...
    10))

;; Get the current thread ID
(define my-id (current-thread-id))
```

### Thread pools

For managing worker threads efficiently:

```scheme
(require "steel/sync")

;; Create a thread pool
(define pool (make-thread-pool 4))  ;; 4 worker threads

;; Submit tasks to the pool
(submit-task pool
  (lambda ()
    (displayln "Task running in pool")
    42))

;; Close the pool when done
```

### Thread joining

Wait for a thread to complete:

```scheme
(define thread
  (spawn-native-thread
    (lambda ()
      (displayln "Working...")
      (sleep 2)  ;; sleep for 2 seconds
      100)))

;; Block until thread completes
(define result (thread-join! thread))
;; result => 100
```

## Channels

Channels provide thread-safe communication.

### Basic channel usage

```scheme
(require "steel/sync")

;; Create a channel pair
(define channel-pair (channels/new))
(define sender (channels-sender channel-pair))
(define receiver (channels-receiver channel-pair))

;; Send from one thread
(spawn-native-thread
  (lambda ()
    (channel/send sender "Hello from thread!")))

;; Receive in another
(define msg (channel/recv receiver))
;; msg => "Hello from thread!"
```

### Selecting from multiple channels

Wait for any of multiple receivers:

```scheme
(define channel1 (channels/new))
(define channel2 (channels/new))

(define recv1 (channels-receiver channel1))
(define recv2 (channels-receiver channel2))

;; Wait for data on either channel
(define result (receivers-select recv1 recv2))
;; result => 0 (index of receiver that got data, 0-based)

(case result
  [(0) (channel/recv recv1)]
  [(1) (channel/recv recv2)])
```

## Synchronization Primitives

### Mutexes

Protect shared mutable state:

```scheme
(require "steel/sync")

(define counter 0)
(define counter-mutex (make-mutex))

(define (increment-counter!)
  (mutex-lock! counter-mutex)
  (set! counter (+ counter 1))
  (mutex-unlock! counter-mutex))
```

### Condition variables

Wait for a condition:

```scheme
(require "steel/sync")

(define data-ready (make-condition-variable))
(define data-mutex (make-mutex))
(define shared-data #f)

;; Producer thread
(spawn-native-thread
  (lambda ()
    (mutex-lock! data-mutex)
    (set! shared-data "data ready")
    (condition-signal! data-ready)
    (mutex-unlock! data-mutex)))

;; Consumer thread
(spawn-native-thread
  (lambda ()
    (mutex-lock! data-mutex)
    (while (not shared-data)
      (condition-wait! data-ready data-mutex))
    (displayln shared-data)
    (mutex-unlock! data-mutex)))
```

## Helix Integration

When working with Helix, threads must coordinate with the main editor thread.

### Checking thread context

```scheme
(require "helix/ext.scm")

;; Check if running on Helix's main thread
(running-on-main-thread?)  ;; => #t or #f

;; Get current thread ID
(current-thread-id)
```

### Running code on the main thread

Use `enqueue-thread-local-callback` to schedule code to run on Helix's main thread:

```scheme
(require "helix/misc.scm")

;; Schedule a function to run on the main thread
(enqueue-thread-local-callback
  (lambda ()
    (theme "nord")
    (set-status! "Theme changed")))

;; Schedule with a delay (milliseconds)
(enqueue-thread-local-callback-with-delay
  1000
  (lambda ()
    (set-warning! "1 second elapsed")))
```

### Blocking on main thread from background

Use `hx.block-on-task` to safely call Helix APIs from background threads:

```scheme
(require "helix/ext.scm")

(spawn-native-thread
  (lambda ()
    ;; Block on main thread operation from background
    (define all-files (hx.block-on-task
                       (lambda ()
                         (all-open-files))))
    (displayln all-files)))
```

### Submitting to main thread context

Use `hx.with-context` to enqueue work to the main thread without blocking:

```scheme
(require "helix/ext.scm")

(spawn-native-thread
  (lambda ()
    ;; Fire-and-forget - enqueue to main thread
    (hx.with-context
      (lambda ()
        (theme "gruvbox")))))
```

## Cooperative Threading

Steel provides user-space cooperative threads using continuations.

### Basic cooperative threading

```scheme
(require "steel/coop/threads.scm")

;; Spawn a cooperative thread
(spawn (lambda ()
        (displayln "Thread A started")
        (yield)
        (displayln "Thread A resumed")))

;; Spawn another thread
(spawn (lambda ()
        (displayln "Thread B started")
        (yield)
        (displayln "Thread B resumed")))

;; Start the cooperative scheduler
(start-threads)
```

### Yielding control

```scheme
(define (work name iterations)
  (for i in (range 0 iterations)
    (displayln (string-append name " iteration: " (int->string i)))
    (yield)))

(spawn (lambda () (work "Thread A" 5)))
(spawn (lambda () (work "Thread B" 5)))
(start-threads)
```

### Exiting threads

```scheme
(spawn (lambda ()
        (when (some-condition)
          (quit))))
```

## Common Patterns

### Producer-consumer pattern

```scheme
(define queue (channels/new))
(define sender (channels-sender queue))
(define receiver (channels-receiver queue))

;; Producer
(spawn-native-thread
  (lambda ()
    (for i in (range 0 10)
      (channel/send sender i))))

;; Consumer
(spawn-native-thread
  (lambda ()
    (while #t
      (define item (channel/recv receiver))
      (displayln (string-append "Processing: " (int->string item))))))
```

### Worker pool pattern

```scheme
(define pool (make-thread-pool 4))
(define work-queue (channels/new))
(define sender (channels-sender work-queue))

;; Submit work
(for i in (range 0 100)
  (channel/send sender i))

(define receiver (channels-receiver work-queue))

;; Workers
(for _ in (range 0 4)
  (submit-task pool
    (lambda ()
      (while #t
        (define work-item (channel/recv receiver))
        (process-item work-item)))))
```

### Timeout pattern

```scheme
(define done (channels/new))
(define done-sender (channels-sender done))

(spawn-native-thread
  (lambda ()
    (do-work)
    (channel/send done-sender #t)))

;; Wait with timeout
(spawn-native-thread
  (lambda ()
    (sleep 5000)  ;; 5 second timeout
    (channel/send done-sender #f)))

(define result (channel/recv (channels-receiver done)))
```

### Helix async operations

```scheme
(spawn-native-thread
  (lambda ()
    ;; Do async work
    (define result (http-request "https://api.example.com"))

    ;; Update Helix UI on main thread
    (enqueue-thread-local-callback
      (lambda ()
        (set-status! (string-append "Got: " result))))))
```

## Thread-safe patterns

### Atomic counters

```scheme
(define counter 0)
(define counter-mutex (make-mutex))

(define (safe-increment!)
  (mutex-lock! counter-mutex)
  (set! counter (+ counter 1))
  (mutex-unlock! counter-mutex))
```

### Thread-local storage with hash

```scheme
(require "steel/sync")

(define *thread-data* (hash))

(define (get-thread-data key)
  (define thread-id (current-thread-id))
  (define thread-map (hash-get *thread-data* thread-id (hash)))
  (hash-get thread-map key))

(define (set-thread-data! key value)
  (define thread-id (current-thread-id))
  (define thread-map (hash-get *thread-data* thread-id (hash)))
  (set! *thread-data*
        (hash-insert *thread-data* thread-id
                     (hash-insert thread-map key value))))
```

## Best Practices

1. **Prefer channels over shared mutable state** - Channels make data flow explicit
2. **Use thread pools for bounded concurrency** - Avoid spawning unbounded threads
3. **Always use mutexes around shared mutable state** - Prevent race conditions
4. **Minimize time holding locks** - Reduce contention
5. **In Helix, use `enqueue-thread-local-callback` for UI updates** - Never call Helix APIs from background threads directly
6. **Use `hx.block-on-task` when you need results from main thread** - Safely synchronize with main thread
7. **Prefer cooperative threading for CPU-bound work** - Less overhead than native threads
8. **Prefer native threads for I/O-bound work** - Better for blocking operations
9. **Handle errors in threads** - Use `with-handler` to prevent crashes
10. **Clean up threads** - Join threads or ensure they exit cleanly

## When to use what

- **Native threads (`spawn-native-thread`)**: I/O operations, CPU-heavy parallel work, when you need OS-level parallelism
- **Thread pools**: Many short-lived tasks, bounded concurrent workers
- **Cooperative threads**: CPU-bound work, controlled concurrency, when you want manual scheduling
- **Channels**: Inter-thread communication, producer-consumer patterns
- **Mutexes**: Protecting shared mutable state, critical sections
- **Condition variables**: Waiting for state changes, complex coordination
- **Helix callbacks**: Updating UI from background threads, scheduling work on main thread

## When to use me

Use when:
- Writing concurrent Steel programs
- Implementing background processing
- Adding parallelism to CPU-bound tasks
- Creating worker pools or job queues
- Integrating with Helix editor threading
- Implementing producer-consumer patterns
- Handling I/O operations asynchronously

Ask clarifying questions if:
- The concurrency model (cooperative vs native) is unclear
- Helix integration is needed vs standalone Steel program
- Performance characteristics suggest different approaches
- Thread safety requirements are complex
