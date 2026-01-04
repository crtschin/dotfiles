(require "scooter/scooter.scm")
(require "showkeys/showkeys.scm")

;; Allow loading the buffer into the interpreter.
(require (only-in "helix/ext.scm" evalp eval-buffer))
(require "git-conflict/git-conflict.scm")

(git-conflict-init)
