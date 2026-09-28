(require (prefix-in helix. "helix/commands.scm"))
(require (prefix-in helix.static. "helix/static.scm"))

(require "helix/editor.scm")

(provide open-helix-scm
         open-init-scm
         load-buffer
         expanded-shell
         current-path
         csv-table)

;;@doc
;; Open the helix.scm file
(define (open-helix-scm)
  (helix.open (helix.static.get-helix-scm-path)))

;;@doc
;; Opens the init.scm file
(define (open-init-scm)
  (helix.open (helix.static.get-init-scm-path)))

(define load-buffer helix.static.load-buffer!)

;;@doc
;; Specialized shell - also be able to override the existing definition, if possible.
(define (expanded-shell . args)
  ;; Replace the % with the current file
  (define expanded
    (map (lambda (x)
           (if (equal? x "%")
               (current-path)
               x))
         args))
  (apply helix.run-shell-command expanded))

(define (current-path)
  (let* ([focus (editor-focus)]
         [focus-doc-id (editor->doc-id focus)])
    (editor-document->path focus-doc-id)))

;;@doc
;; Align the whole buffer's CSV into a padded table
(define (csv-table)
  (helix.static.select_all)
  ;; --ofs keeps the commas; plain --opprint would drop them for spaces
  (helix.pipe "mlr --icsv --opprint --ofs , cat"))
