;;; Emacs config

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Prerequisites

(let ((minver "24.1"))
  (when (version< emacs-version minver)
    (error "Your Emacs is too old -- this config requires v%s or higher" minver)))

;;; Speed up init.
;;; Temporarily reduce garbage collection during startup. Inspect `gcs-done'.
(defun reset-gc-cons-threshold ()
  (setq gc-cons-threshold (car (get 'gc-cons-threshold 'standard-value))))
(setq gc-cons-threshold (* 64 1024 1024))
(add-hook 'after-init-hook 'reset-gc-cons-threshold)
;;; Temporarily disable the file name handler.
(setq default-file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)
(defun reset-file-name-handler-alist ()
  (setq file-name-handler-alist default-file-name-handler-alist))
(add-hook 'after-init-hook 'reset-file-name-handler-alist)

;;; Enable debug during loading.
(setq debug-on-error t)

(defvar emacs-cache-folder "~/.cache/emacs/"
  "Cache folder is everything we do not want to track together
  with the configuration files.")
(if (not (file-directory-p emacs-cache-folder))
    (make-directory emacs-cache-folder t))

;;; Store additional config in a 'lisp' subfolder and add it to the load path so
;;; that `require' can find the files.
(add-to-list 'load-path "~/.emacs.d/lisp")

;;; Local plugin folder for quick install. All files in this folder will be
;;; accessible to Emacs config.  This is done to separate the versioned config
;;; files from the external packages.
(add-to-list 'load-path "~/.emacs.d/local")

(when (require 'package nil t)
  ;; (add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
  (add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/"))
  (add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)
  (setq package-user-dir (concat emacs-cache-folder "elpa"))
  (package-initialize))

(require 'functions)
(require 'main)
(require 'visual)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Assembly
(push 'nasm-mode package-selected-packages)

;;; Asymptote
(add-to-list 'load-path "/usr/share/asymptote")
(autoload 'asy-mode "asy-mode" "Asymptote major mode." t)
(autoload 'lasy-mode "asy-mode" "Hybrid Asymptote/Latex major mode." t)
(autoload 'asy-insinuate-latex "asy-mode" "Asymptote insinuate LaTeX." t)
(add-to-list 'auto-mode-alist '("\\.asy$" . asy-mode))

;;; BBCode
(nconc package-selected-packages '(bbcode-mode))
(with-eval-after-load 'bbcode-mode (require 'init-bbcode))

;;; Bibtex
(setq bibtex-entry-format '(opts-or-alts required-fields numerical-fields whitespace realign last-comma delimiters braces sort-fields))
(setq bibtex-field-delimiters 'double-quotes)
(add-hook 'bibtex-mode-hook 'turn-off-indent-tabs)

;;; Bison/Flex
;; (nconc package-selected-packages '(bison-mode))

;;; C/C++
(with-eval-after-load 'cc-mode (require 'init-cc))

;;; ChangeLog
(defun change-log-set-indent-rules ()
  (setq tab-width 2 left-margin 2))
(add-hook 'change-log-mode-hook 'change-log-set-indent-rules)

;;; Completion
(nconc package-selected-packages '(company helm-company))
(when (require 'company nil t)
  (setq company-idle-delay nil))

;;; Debbugs
(nconc package-selected-packages '(debbugs))
(with-eval-after-load 'debbugs
  (setq debbugs-gnu-persistency-file (expand-file-name "debbugs" emacs-cache-folder)))

;;; Diff
;;; REVIEW: Show permissions in ztree.
;;; See https://github.com/fourier/ztree/issues/50.
(nconc package-selected-packages '(ztree))

;;; Dired
;;; Dired is loaded after init.el, so configure it only then.
;;; TODO: Improve dired-du:
;;; - Hangs when the `ls` time format is changed.
;;; - Cache recursive results.
(nconc package-selected-packages '(dired-du))
(with-eval-after-load 'dired (require 'init-dired))

;;; Emms
(nconc package-selected-packages '(emms helm-emms emms-player-mpv))
(when (fboundp 'emms-all)
  ;; Emms has no autoload to switch to the browser, let's add one.
  (autoload 'emms-smart-browse "emms-browser" nil t))
(with-eval-after-load 'emms (require 'init-emms))

;;; Evil
(nconc package-selected-packages '(evil evil-commentary evil-ediff evil-magit evil-mc evil-mc-extras linum-relative evil-mu4e))
(when (require 'evil nil t) (require 'init-evil))

;;; Eshell
;;; Extend completion.
(nconc package-selected-packages '(pcomplete-extension))
(with-eval-after-load 'eshell (require 'init-eshell))
(autoload 'eshell-or-new-session "eshell")

;;; Esup
(nconc package-selected-packages '(esup))

;;; GLSL
(nconc package-selected-packages '(glsl-mode))

;;; Go
(nconc package-selected-packages '(go-mode go-eldoc go-guru go-rename helm-go-package company-go))
(with-eval-after-load 'go-mode (require 'init-go))

;;; Graphviz dot
;;; The view command is broken but the preview command works (it displays the PNG
;;; in a new window), which is enough and probably not worth a fix.
(nconc package-selected-packages '(graphviz-dot-mode))

;;; GUD (GDB, etc.)
(with-eval-after-load 'gud (require 'init-gud))

;;; Helm
(nconc package-selected-packages '(helm helm-descbinds helm-ls-git))
(when (require 'helm-config nil t) (require 'init-helm))

;;; Hex editing
(nconc package-selected-packages '(nhexl-mode))

;;; Indentation engine fix.
;; (require 'smiext "init-smiext")

;;; Indentation style guessing.
;; (nconc 'package-selected-packages '(dtrt-indent))

;;; JavaScript
(add-hook 'js-mode-hook (lambda () (defvaralias 'js-indent-level 'tab-width)))

;;; Lisp
(dolist (hook '(lisp-mode-hook emacs-lisp-mode-hook))
  (add-hook hook 'turn-on-fmt-before-save)
  (add-hook hook 'turn-on-tab-width-to-8) ; Because some existing code uses tabs.
  (add-hook hook 'turn-off-indent-tabs)) ; Should not use tabs.
(define-key lisp-mode-shared-map "\M-." 'find-symbol-at-point)
;;; Common LISP
(setq inferior-lisp-program "clisp")

;;; Lua
(nconc package-selected-packages '(lua-mode))
(with-eval-after-load 'lua-mode (require 'init-lua))

;;; Magit
;;; Magit can be loaded just-in-time.
(nconc package-selected-packages '(magit))
(with-eval-after-load 'magit
  (setq auto-revert-mode-text "")
  (set-face-foreground 'magit-branch-remote "orange red")
  (setq git-commit-summary-max-length fill-column)
  ;; Avoid conflict with WM.
  (define-key magit-mode-map (kbd "s-<tab>") nil)
  (setq magit-diff-refine-hunk 'all))
(when (fboundp 'magit-status)
  (global-set-key (kbd "C-x g") 'magit-status))

;;; Mail
;;; mu4e is usually site-local and not part of ELPA.
(when (delq nil (mapcar (lambda (path) (string-match "/mu4e/\\|/mu4e$" path)) load-path))
  (nconc package-selected-packages '(helm-mu mu4e-maildirs-extension)))
(with-eval-after-load 'mu4e (require 'init-mu4e))
(autoload 'mu4e-headers "mu4e")

;;; Makefile
(with-eval-after-load 'make-mode (require 'init-makefile))

;;; Markdown
(nconc package-selected-packages '(markdown-mode))
(with-eval-after-load 'markdown-mode (require 'init-markdown))

;;; Matlab / Octave
(add-to-list 'auto-mode-alist '("\\.m\\'" . octave-mode)) ; matlab
(defun octave-set-comment-start ()
  "Set comment character to '%' to be Matlab-compatible."
  (set (make-local-variable 'comment-start) "% "))
(add-hook 'octave-mode-hook 'octave-set-comment-start)

;;; Maxima
(autoload 'maxima-mode "maxima" "Maxima mode" t)
(autoload 'maxima "maxima" "Maxima interaction" t)
(add-to-list 'auto-mode-alist '("\\.mac" . maxima-mode))

;;; Mediawiki
(nconc package-selected-packages '(mediawiki))
(add-to-list 'auto-mode-alist '("\\.wiki\\'" . mediawiki-mode))
(with-eval-after-load 'mediawiki (require 'init-mediawiki))

;;; News
(nconc package-selected-packages '(elfeed))
(with-eval-after-load 'elfeed
  (setq elfeed-db-directory (concat emacs-cache-folder "elfeed"))
  (defun elfeed-play-in-mpv ()
    ;; TODO: Wrap around `elfeed-search-browse-url'/`elfeed-show-visit'?
    (interactive)
    (let ((entry (if (eq major-mode 'elfeed-show-mode) elfeed-show-entry (elfeed-search-selected :single)))
          (quality-arg "")
          (quality-val (completing-read "Max height resolution (0 for unlimited): " '("0" "480" "720") nil nil)))
      (setq quality-val (string-to-number quality-val))
      (message "Opening %s with height≤%s with mpv..." (elfeed-entry-link entry) quality-val)
      (when (< 0 quality-val)
        (setq quality-arg (format "--ytdl-format=[height<=?%s]" quality-val)))
      (start-process "elfeed-mpv" nil "mpv" quality-arg (elfeed-entry-link entry))))
  (define-key elfeed-search-mode-map "v" #'elfeed-play-in-mpv)
  (load "~/personal/news/elfeed.el" t))

;;; Org-mode
(nconc package-selected-packages '(org-plus-contrib)) ; Contains latest 'org.
(with-eval-after-load 'org (require 'init-org))
(autoload 'org-find-first-agenda "org")

;;; PDF
;;; pdf-tools requires poppler built with cairo support.
;;; We cannot defer loading as `pdf-tools-install' is required for PDF
;;; association.
;;; REVIEW: `save-place' does not seem to work with pdf-tools.
;;; See https://github.com/politza/pdf-tools/issues/18.
(nconc package-selected-packages '(pdf-tools))
(when (require 'pdf-tools nil t)
  (setq pdf-view-midnight-colors '("#ffffff" . "#000000"))
  (pdf-tools-install t t t))

;;; Perl
(defun perl-set-indent-rules ()
  (defvaralias 'perl-indent-level 'tab-width))
(defun perl-set-compiler ()
  (setq compile-command (concat "perl " (shell-quote-argument buffer-file-name))))
(add-hook 'perl-mode-hook 'perl-set-indent-rules)
(add-hook 'perl-mode-hook 'perl-set-compiler)

;;; po
(nconc package-selected-packages '(po-mode))

;;; Python
(with-eval-after-load 'python (require 'init-python))

;;; Rainbow-mode
(nconc package-selected-packages '(rainbow-mode))
(when (require 'rainbow-mode nil t)
  (dolist (hook '(css-mode-hook html-mode-hook sass-mode-hook))
    (add-hook hook 'rainbow-mode)))

;;; Roff / Nroff
(with-eval-after-load 'nroff-mode (require 'init-nroff))

;;; Shell
(with-eval-after-load 'sh-script (require 'init-sh))
;;; Arch Linux PKGBUILD
(add-to-list 'auto-mode-alist '("PKGBUILD" . sh-mode))
;;; If we ever need to edit exotic shell configs:
;; (nconc package-selected-packages '(fish-mode rc-mode))

;;; Srt (subtitles)
(add-to-list 'auto-mode-alist '("\\.srt\\'" . text-mode))

;;; StackExchange
(nconc package-selected-packages '(sx))
(with-eval-after-load 'sx
  (setq sx-cache-directory (concat emacs-cache-folder "sx")))

;;; Syntax checking
(nconc package-selected-packages '(flycheck helm-flycheck))
(when (require 'flycheck nil t) (require 'init-flycheck))

;;; Terminal
(with-eval-after-load 'term
  (setq term-buffer-maximum-size 0))

;;; TeX / LaTeX / Texinfo
(with-eval-after-load 'tex-mode (require 'init-tex))
(with-eval-after-load 'texinfo (require 'init-texinfo))
;;; LaTeX is defined in the same file as TeX. To separate the loading, we add it
;;; to the hook.
(add-hook 'latex-mode-hook (lambda () (require 'init-latex)))
(nconc package-selected-packages '(latex-math-preview))

;;; Torrent
(nconc package-selected-packages '(transmission))
(when (fboundp 'transmission)
  (setq transmission-refresh-modes '(transmission-mode transmission-files-mode transmission-info-mode transmission-peers-mode)
        transmission-refresh-interval 1))

;;; Translator
;;; TODO: Find alternative package.
(autoload 'itranslate "init-itranslate" nil t)
(autoload 'itranslate-lines "init-itranslate" nil t)
(autoload 'itranslate-region "init-itranslate" nil t)

;;; Web forms.
;;; Remove auto-fill in web edits because wikis and forums do not like it.
;;; This works for qutebrowser, but may need changes for other browsers.
(defun browser-edit ()
  (when (require 'with-editor nil t) (with-editor-mode))
  (auto-fill-mode -1))
(add-to-list 'auto-mode-alist `(,(concat (getenv "BROWSER") "-editor-*") . browser-edit))

;;; Wgrep
(nconc package-selected-packages '(wgrep-helm wgrep-pt))
(when (require 'wgrep nil t)
  ;; TODO: wgrep-face is not so pretty.
  (set-face-attribute 'wgrep-face nil :inherit 'ediff-current-diff-C :foreground 'unspecified :background 'unspecified :box nil))

;;; Window manager
(nconc package-selected-packages '(exwm))
(when (require 'exwm nil t) (require 'init-exwm))

;;; XML / SGML
(defun sgml-setup ()
  (setq sgml-xml-mode t)
  ;; (toggle-truncate-lines) ; This seems to slow down Emacs.
  (turn-off-auto-fill))
(add-hook 'sgml-mode-hook 'sgml-setup)
(with-eval-after-load 'nxml-mode
  (set-face-foreground 'nxml-element-local-name "gold1")
  (defvaralias 'nxml-child-indent 'tab-width))
;;; Because XML is hard to read.
(add-hook 'nxml-mode-hook 'turn-on-tab-width-to-4)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Finalization

;;; Don't let `customize' clutter my config.
(setq custom-file
      (if (boundp 'server-socket-dir)
          (expand-file-name "custom.el" server-socket-dir)
        (expand-file-name (format "emacs-custom-%s.el" (user-uid)) temporary-file-directory)))
(load custom-file t)

;;; Disable debug now we are done with init.
(setq debug-on-error nil)

;;; Local config. You can use it to set system specific variables, such as the
;;; external web browser or the geographical coordinates:
;;
;; (setq calendar-latitude 20.2158)
;; (setq calendar-longitude 105.938)
(load "local" t)
