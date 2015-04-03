;;==============================================================================
;; Texinfo using TeX setup
;;==============================================================================
(require 'tex-mode)
(require 'mode-tex)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; FUNCTIONS

(defun texinfo-menu-update ()
  "Update texinfo node menu automatically."
  (interactive)
  (hack-local-variables)
  (let
      ;; Master file.
      ((local-master (if (not masterfile) buffer-file-name masterfile)))

    (texinfo-multiple-files-update local-master t 8)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; HOOKS

(add-hook-and-eval
 'texinfo-mode-hook
 (lambda ()
   (setq fill-column 80) ;; Really needed?
   (local-set-key (kbd "C-c C-b") 'texinfo-menu-update)
   (set (make-local-variable 'tex-extension-list)
         '("aux" "cp" "cps" "fn" "ky" "log" "pg" "toc" "tp" "vr" "vrs"))
   (set (make-local-variable 'tex-start-options) nil)
   (set (make-local-variable 'tex-command) "texi2pdf -b")
   (tex-set-compiler)))

(provide 'mode-texinfo)