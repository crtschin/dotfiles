;; Steel resolves `require` while compiling, so a single uninstalled cog aborts
;; this whole file and takes `evalp` and every other binding down with it. The
;; cogs live under ~/.local/share/steel/cogs and only `just install-plugins`
;; puts them there, which a home-manager switch never does, so a fresh machine
;; has none of them. Routing through `eval` defers resolution to run time, where
;; `with-handler` can catch the failure and the rest of the file survives.
;; `require` is legal only at the top level, hence the quoted form rather than a
;; macro wrapping a literal one.
(define missing-cogs '())
(define (require-cog path)
  (with-handler
    (lambda (e)
      (set! missing-cogs (cons path missing-cogs))
      (log::error! (string-append "init.scm: cog " path " did not load: " (to-string e))))
    (eval (list 'require path))))

(require-cog "scooter/scooter.scm")
(require-cog "showkeys/showkeys.scm")
(require-cog "stream-cmd/stream-cmd.scm")
(require-cog "stream-cabal/stream-cabal.scm")

;; Allow loading the buffer into the interpreter.
(require (only-in "helix/ext.scm" evalp eval-buffer))
(require (only-in "helix/misc.scm" set-error!))

;; The helix log is easy to miss on a fresh machine, so name the gap in the
;; editor as well.
(unless (empty? missing-cogs)
  (set-error!
    (string-append "Missing Steel cogs, run `just install-plugins`: "
      (string-join (reverse missing-cogs) ", "))))

; (require "git-conflict/git-conflict.scm")
; (git-conflict-init)
