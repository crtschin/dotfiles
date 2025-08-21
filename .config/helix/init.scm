(require (prefix-in helix. "helix/commands.scm"))
(require (prefix-in helix.static. "helix/static.scm"))

; (require "/home/crtschin/.local/share/steel/cogs/scooter/scooter.scm")
(require "scooter/scooter.scm")
(require "smooth-scroll/smooth-scroll.scm")
(require "helix-file-watcher/file-watcher.scm")

(spawn-watcher)
