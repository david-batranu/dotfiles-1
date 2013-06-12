;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MODES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;==============================================================================
;; Automode (Mode recognition)
;;==============================================================================

;; rc files support
(setq auto-mode-alist (append '(("rc\\'" . sh-mode)) auto-mode-alist))

;; Shell support
;; We do not put 'sh' only because it could get messy. Emacs knows it anyway.
(setq auto-mode-alist
      (append
       '(("\\(bash\\'\\|zsh\\'\\|csh\\'\\|tcsh\\'\\|ksh\\'\\)" . sh-mode))
       auto-mode-alist))

;; Read Matlab files in Octave mode.
(setq auto-mode-alist (append '(("\\.m\\'" . octave-mode)) auto-mode-alist))

;; Read pl files in prolog mode.
;; WARNING: this extension is shared with Perl.
;; (setq auto-mode-alist (append '(("\\.pl\\'" . prolog-mode)) auto-mode-alist))

;; Mutt support.
(setq auto-mode-alist (append '(("/tmp/mutt.*" . mail-mode)) auto-mode-alist))

;; Arch Linux PKGBUILD.
(setq auto-mode-alist (append '(("PKGBUILD" . sh-mode)) auto-mode-alist))

;; README files.
(setq auto-mode-alist (append '(("README" . text-mode)) auto-mode-alist))

;; Lex/Flex + Yacc/Bison mode fallback to c-mode.
(setq auto-mode-alist (append '(("\\.l\\'" . c-mode)) auto-mode-alist))
(setq auto-mode-alist (append '(("\\.yy?\\'" . c-mode)) auto-mode-alist))

;; Subtitles support.
(setq auto-mode-alist (append '(("\\.srt\\'" . text-mode)) auto-mode-alist))

;; Git commit meessages.
(setq auto-mode-alist (append '(("COMMIT_EDITMSG\\'" . conf-mode)) auto-mode-alist))

;;==============================================================================
;; Auto-Insert
;;==============================================================================

;; autoinsert C/C++ header
(define-auto-insert
  (cons "\\.\\([Hh]\\|hh\\|hpp\\)\\'" "My C / C++ header")
  '(nil
    "/" (make-string 79 ?*) "\n"
    " * @file " (file-name-nondirectory buffer-file-name) "\n"
    " * @date \n"
    " * @brief \n"
    " *\n"
    " " (make-string 78 ?*) "/\n\n"
    (let* ((noext (substring buffer-file-name 0 (match-beginning 0)))
           (nopath (file-name-nondirectory noext))
           (ident (concat (upcase nopath) "_H")))
      (concat "#ifndef " ident "\n"
              "#define " ident  " 1\n\n\n"
              "\n\n#endif // " ident "\n"))
    ))

;; auto insert C/C++
(define-auto-insert
  (cons "\\.\\([Cc]\\|cc\\|cpp\\)\\'" "My C++ implementation")
  '(nil
    "/" (make-string 79 ?*) "\n"
    " * @file " (file-name-nondirectory buffer-file-name) "\n"
    " * @date \n"
    " * @brief \n"
    " *\n"
    " " (make-string 78 ?*) "/\n\n"
    (let* ((noext (substring buffer-file-name 0 (match-beginning 0)))
           (nopath (file-name-nondirectory noext))
           (ident (concat nopath ".h")))
      (if (file-exists-p ident)
          (concat "#include \"" ident "\"\n")))
    ))

;; auto insert LaTeX Article
(define-auto-insert
  (cons "\\.\\(tex\\)\\'" "My LaTeX implementation")
  '(nil
    (make-string 80 ?%) "\n"
    "\\documentclass[11pt]{article}\n"
    "\\usepackage[utf8]{inputenc}\n"
    "\\usepackage[T1]{fontenc}\n"
    "% \\usepackage{lmodern}\n"
    (make-string 80 ?%) "\n"

    "\\title{Title}\n"
    "\\author{\\textsc{P.~Neidhardt}}\n"
    ))

;;==============================================================================
;; TeX and LaTeX
;;==============================================================================

;; I find the default tex-mode and AucTeX quite disappointing. I'm using custom
;; functions for everything.

(defcustom tex-my-viewer "zathura --fork -s -x \"emacsclient --eval '(progn (switch-to-buffer  (file-name-nondirectory \"'\"'\"%{input}\"'\"'\")) (goto-line %{line}))'\""
  "PDF Viewer for TeX documents. You may want to fork the viewer
so that it detects when the same document is launched twice, and
persists when Emacs gets closed.

Simple command:

  zathura --fork

We can use

  emacsclient --eval '(progn (switch-to-buffer  (file-name-nondirectory \"%{input}\")) (goto-line %{line}))'

to reverse-search a pdf using SyncTeX. Note that the quotes and
double-quotes matter and must be escaped appropriately."
  :safe 'stringp)

(defcustom tex-my-compiler nil
  "[Local variable]

This is the name of the executable called upon TeX compilations.
Examples: pdftex, pdflatex, xetex, xelatex, luatex, lualatex...

If value is nil, the compiler will be tex-my-default-compiler for
TeX mode, and latex-my-default-compiler for LaTeX mode."
  :safe 'stringp)

(defcustom tex-my-masterfile nil
  "[Local variable]

The file that should be compiled."
  :safe 'stringp)

(defcustom tex-my-default-compiler "pdftex"
  "Default compiler for TeX mode. Used if tex-my-compiler is
empty."
  :safe 'stringp)

(defcustom latex-my-default-compiler "pdflatex"
  "Default compiler for LaTeX mode. Used if tex-my-compiler is
empty."
  :safe 'stringp)

(defcustom tex-my-compiler-options "-file-line-error-style -interaction nonstopmode -synctex=1"
  "The options to the tex compiler. Options are set between the
compiler name and the file name.

Interesting options:

* -file-line-error-style: change the style of error report to
   display file name and line first.

* -halt-on-error: default.

* -interaction <mode>: like -halt-on-error, you can set the way
   the compilers behave on errors. Possible values for <mode> are
   'batchmode', 'errorstopmode', 'nonstopmode' and 'scrollmode'.

* -shell-escape: allow the use of \write18{<external command>}
   from within TeX documents. This is a potential security issue.

* -synctex=1: enable SyncTeX support.

You may use file local variable for convenience:

% -*- tex-my-compiler-options: \"-shell-escape\"

Note that -shell-escape can also be toggled with universal
argument."
  :safe 'stringp)

(defcustom tex-my-startcommands ""
  "You can call a TeX compiler upon a string instead of a file.
This is actually useful if you want to customize your
compilation.

If this variable is not an empty string, the mandatory \" is
prepended and \\input\" is appended, so that the target file gets
read; otherwise the TeX compiler would stop there.

You may use it to act on the process, like the default behaviour:
  \\nonstopmode
which will continue the process whenever an error is
encountered. There is an command-line argument for that on most
compilers, that is is rarely useful.

If you use a color theme, or any conditional variable inside your
document, you may define it here:
  \\def\\myvar{mycontent}"
  :safe 'stringp)

(defun tex-my-compile ()
  "Use compile to process your TeX-based document. Use a prefix
argument to call the compiler along the '-shell-escape'
option. This will enable the use of '\write18{<external
command>}' from within TeX documents, which need to allow
external application to be called from TeX.

This may be useful for some features like GnuPlot support with TikZ.

WARNING: the -shell-escape option is a potential security issue."
  (interactive)
  (let (
        ;; Set compiler to be tex-my-compiler if not empty, or a default
        ;; compiler otherwise.
        (local-compiler
         (if (not tex-my-compiler)
             (cond
              ((string= "latex-mode" major-mode) latex-my-default-compiler)
              ((string= "plain-tex-mode" major-mode) tex-my-default-compiler)
              (t   (message "Warning: unknown major mode. Trying pdftex.") "pdftex"))
           tex-my-compiler))

        ;; Master file
        (local-master
         (if (not tex-my-masterfile)
             buffer-file-name
           tex-my-masterfile))

        ;; If tex-my-startcommands has some content, we make sure it is a string
        ;; that loads the file.
        (local-start-cmd
         (if (not (string= "" tex-my-startcommands))
             (concat "\"" tex-my-startcommands "\\input\"")))

        ;; Support of prefix argument to toggle -shell-escape.
        (local-shell-escape
         (if (equal current-prefix-arg '(4)) "-shell-escape" "")))

    (let (
          ;; Final command
          (local-compile-command
           (concat local-compiler " "  local-shell-escape " " tex-my-compiler-options " " local-start-cmd " \"" local-master "\"")))

      ;; (message local-compile-command) ;; Debug only.
      (save-buffer)
      (setq compilation-scroll-output t)
      (compile local-compile-command)

      ;; If no user interaction for 2 seconds, hide the compilation window.
      (sit-for 2)
      (delete-windows-on "*compilation*"))))


(defcustom tex-my-extension-list '("aux" "glg" "glo" "gls" "idx" "ilg" "ind" "lof" "log" "nav" "out" "snm" "synctex" "synctex.gz" "tns" "toc" "xdy")
  "List of known TeX exentsions. This list is used by 'tex-clean to purge all matching files."
  :safe 'listp)

(defun tex-clean ()
  "Remove all TeX temporary files. This command should be safe,
but there is no warranty."
  (interactive)
  (let (
        ;; Master file.
        (local-master
         (if (not tex-my-masterfile)
             buffer-file-name
           tex-my-masterfile)))

    (let (
          ;; File name without extension.
          (file
           (replace-regexp-in-string "tex" "" (file-name-nondirectory local-master))))

      ;; Concatate file name to list.
      (mapcar
       ;; Delete file if exist
       (lambda (argfile) (interactive)
         (when (and (file-exists-p argfile) (file-writable-p argfile))
           (delete-file argfile)
           (message "[%s] deleted." argfile)))
       (mapcar
        ;; Concat file name with extensions.
        (lambda (arg) (interactive) (concat file arg))
        tex-my-extension-list)))))

(defun tex-pdf-compress ()
  "PDF compressions might really strip down the PDF size. The
compression depends on the fonts used. Do not use this command if
your document embeds raster graphics."
  (interactive)
  (let (
        ;; Master file.
        (local-master
         (if (not tex-my-masterfile)
             buffer-file-name
           tex-my-masterfile)))

    (let (
          ;; Temp compressed file.
          (file-temp
           (concat (make-temp-name (concat "/tmp/" (file-name-nondirectory local-master))) ".pdf"))

          ;; File name with PDF extension.
          (file
           (replace-regexp-in-string "tex" "pdf" (file-name-nondirectory local-master))))

      (when (and (file-exists-p file) (file-writable-p file))
        (shell-command
         (concat  "gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=\"" file-temp "\" \"" file "\""))
        (rename-file file-temp file t)
        ))))

(defun tex-pdf-view ()
  "Call a PDF viewer for current buffer file. File name should be
properly escaped with double-quotes in case it has spaces."
  (interactive)
  (let (
        ;; Master file.
        (local-master
         (if (not tex-my-masterfile)
             buffer-file-name
           tex-my-masterfile)))

    (shell-command
     (concat tex-my-viewer
             " \""
             (replace-regexp-in-string "\.tex$" "\.pdf" (file-name-nondirectory local-master))
             "\" &" ))
    (delete-windows-on "*Async Shell Command*")))

(add-hook
 'tex-mode-hook
 (lambda ()
   (dolist (key '("\C-c\C-f" "\C-c\C-b"))
     (local-unset-key key))
   (local-set-key (kbd "C-c C-c") 'tex-my-compile)
   (local-set-key (kbd "C-c C-v") 'tex-pdf-view) ))

;;==============================================================================
;; HTML
;;==============================================================================

(add-hook 'html-mode-hook
          (lambda ()
            (turn-off-auto-fill)
            (toggle-truncate-lines)))

;;==============================================================================
;; C-mode
;;==============================================================================
(require 'compile)

;; Identation style
(setq c-default-style "linux" c-basic-offset 4)

(defcustom c-compile-ldflags ""
  "[Local variable] Custom linker flags for C compilation."
  :safe 'stringp)

(defun c-compile ()
  (interactive)
  (progn
    (unless (or (file-exists-p "Makefile") (file-exists-p "makefile") (file-exists-p "GNUMakefile"))
      (set (make-local-variable 'compile-command)
           ;; Emulate make's .c.o implicit pattern rule, but with
           ;; different defaults for the CC, CPPFLAGS, and CFLAGS
           ;; variables:
           ;;   $(CC) -c -o $@ $(CPPFLAGS) $(CFLAGS) $<
           ;; (setq compile-command
           (let
               ((file (file-name-nondirectory buffer-file-name)))
             (format "%s -o %s %s %s %s %s"
                     (or (getenv "CC") "gcc")
                     (file-name-sans-extension file)
                     (or (getenv "CPPFLAGS") "-DDEBUG=9")
                     (or (getenv "CFLAGS") "-ansi -pedantic -std=c99 -Wall -Wextra -Wshadow -g3 -O0")
                     (or (getenv "LDFLAGS") c-compile-ldflags)
                     file))))
    (compile compile-command)))

(add-hook
 'c-mode-hook
 (lambda ()
   (local-set-key (kbd "C-c C-c") 'c-compile)
   (local-set-key (kbd "M-TAB") 'semantic-complete-analyze-inline)
   ;; (local-set-key "." 'semantic-complete-self-insert) ; This is a bit slow.
   ;; (local-set-key ">" 'semantic-complete-self-insert)
   ))

;;==============================================================================
;; C++-mode
;;==============================================================================
(require 'compile)

;; TODO: test this!
;; (defun vlad-cc-style()
;;   (c-set-style "linux")
;;   (c-set-offset 'innamespace '0)
;;   (c-set-offset 'inextern-lang '0)
;;   (c-set-offset 'inline-open '0)
;;   (c-set-offset 'label '*)
;;   (c-set-offset 'case-label '*)
;;   (c-set-offset 'access-label '/)
;;   (setq c-basic-offset 4)
;;   (setq tab-width 4)
;;   (setq indent-tabs-mode nil)
;; )

;; (add-hook 'c++-mode-hook 'vlad-cc-style)

(defcustom c++-compile-ldflags ""
  "[Local variable] Custom linker flags for C compilation."
  :safe 'stringp)

(defun c++-compile ()
  (interactive)
  (progn
    (unless (or (file-exists-p "Makefile") (file-exists-p "makefile") (file-exists-p "GNUMakefile"))
      (set (make-local-variable 'compile-command)
           ;; Emulate make's .c.o implicit pattern rule, but with
           ;; different defaults for the CC, CPPFLAGS, and CFLAGS
           ;; variables:
           ;;   $(CC) -c -o $@ $(CPPFLAGS) $(CFLAGS) $<
           ;; (setq compile-command
           (let
               ((file (file-name-nondirectory buffer-file-name)))
             (format "%s -o %s %s %s %s %s"
                     (or (getenv "CXX") "g++")
                     (file-name-sans-extension file)
                     (or (getenv "CPPFLAGS") "-DDEBUG=9")
                     (or (getenv "CFLAGS") "-Wall -Wextra -Wshadow -g3 -O0")
                     (or (getenv "LDFLAGS") c++-compile-ldflags)
                     file))))
    (compile compile-command)))

(add-hook
 'c++-mode-hook
 (lambda ()
   (local-set-key (kbd "C-c C-c") 'c++-compile)
   (local-set-key (kbd "M-TAB") 'semantic-complete-analyze-inline)))

;;==============================================================================
;; Common LISP
;;==============================================================================
(setq inferior-lisp-program "clisp")

;;==============================================================================
;; Python
;;==============================================================================

(defcustom python-compiler "python"
  "Python compiler."
  :safe 'stringp)

(add-hook
 'python-mode-hook
 (lambda ()
   (defun python-compile ()
     "Use compile to run python programs."
     (interactive)
     (compile (concat python-compiler " \"" buffer-file-name "\""))
     )
   (setq compilation-scroll-output t)
   (local-set-key "\C-c\C-c" 'python-compile)
   ))

;; Doc lookup. Requires the python.info file to be installed. See
;; https://bitbucket.org/jonwaltman/pydoc-info/.
(add-to-list 'load-path "~/path/to/pydoc-info")
(require 'pydoc-info nil t)

;;==============================================================================
;; Flymake
;;==============================================================================

;; Flymake has a bug that prevents menu from spawning in a console. We redefine
;; the function to spawn the error message in the mini-buffer.

;; (defun flymake-display-err-message-for-current-line ()
;;   "Display a message with errors/warnings for current line if it
;; has errors and/or warnings."
;;   (interactive)
;;   (let* ((line-no             (flymake-current-line-no))
;;          (line-err-info-list  (nth 0 (flymake-find-err-info flymake-err-info line-no)))
;;          (menu-data           (flymake-make-err-menu-data line-no line-err-info-list)))
;;     (if menu-data
;;         (let ((messages))
;;           (push (concat (car menu-data) ":") messages)
;;           (dolist (error-or-warning (cadr menu-data))
;;             (push (car error-or-warning) messages))
;;           (message "%s" (mapconcat #'identity (reverse messages) "\n"))))))

;; (global-set-key (kbd "<f10>")
;;   'flymake-display-err-message-for-current-line)

;;==============================================================================
;; Ediff
;;==============================================================================

;; TODO: does not seem to work.
;; (add-hook
;;  'ediff-mode-hook
;;  (lambda ()
;;    (setq ediff-merge-split-window-function 'split-window-horizontally)
;; ))

;;==============================================================================
;; Shell
;;==============================================================================

;; Indent comments.
(setq sh-indent-comment t)

;;==============================================================================
;; GLSL
;;==============================================================================

(autoload 'glsl-mode "glsl-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.vert\\'" . glsl-mode))
(add-to-list 'auto-mode-alist '("\\.frag\\'" . glsl-mode))

;;==============================================================================
;; Texinfo
;;==============================================================================

(defcustom texinfo-my-viewer "zathura --fork"
  "PDF Viewer for Texinfo documents. You may want to fork the viewer
so that it detects when the same document is launched twice, and
persists when Emacs gets closed."
  :safe 'stringp)

(defcustom texinfo-my-masterfile nil
  "[Local variable]

The file that should be compiled."
  :safe 'stringp)

(defun texinfo-my-compile ()
  "Use compile to process your Texinfo document."
  (interactive)
  (let
      ;; Master file
      ( (local-master
         (if (not texinfo-my-masterfile)
             buffer-file-name
           texinfo-my-masterfile)))

    (let
        ;; Final command
        ( (local-compile-command
           (concat  "texi2pdf -b \"" local-master "\"")))

      (message local-compile-command) ;; Debug only.
      (save-buffer)
      (setq compilation-scroll-output t)
      (compile local-compile-command)

      ;; If no user interaction for 2 seconds, hide the compilation window.
      (sit-for 2)
      (delete-windows-on "*compilation*"))))


(defcustom texinfo-my-extension-list '("aux" "cp" "cps" "fn" "ky" "log" "pg" "toc" "tp" "vr" "vrs")
  "List of known Texinfo exentsions. This list is used by 'texinfo-clean to purge all matching files."
  :safe 'listp)

(defun texinfo-clean ()
  "Remove all Texinfo temporary files. This command should be safe,
but there is no warranty."
  (interactive)
  (let
      ;; Master file.
      ((local-master
        (if (not texinfo-my-masterfile)
            buffer-file-name
          texinfo-my-masterfile)))

    (let
        ;; File name without extension.
        ((file
          (replace-regexp-in-string "texi" "" (file-name-nondirectory local-master))))

      ;; Concatate file name to list.
      (mapcar
       ;; Delete file if exist
       (lambda (argfile) (interactive)
         (when (and (file-exists-p argfile) (file-writable-p argfile))
           (delete-file argfile)
           (message "[%s] deleted." argfile)))
       (mapcar
        ;; Concat file name with extensions.
        (lambda (arg) (interactive) (concat file arg))
        texinfo-my-extension-list)))))

(defun texinfo-pdf-view ()
  "Call a PDF viewer for current buffer file. File name should be
properly escaped with double-quotes in case it has spaces."
  (interactive)
  (let
      ;; Master file.
      ((local-master
        (if (not texinfo-my-masterfile)
            buffer-file-name
          texinfo-my-masterfile)))

    (shell-command
     (concat texinfo-my-viewer
             " \""
             (replace-regexp-in-string "\.texi$" "\.pdf" (file-name-nondirectory local-master))
             "\" &" ))
    (delete-windows-on "*Async Shell Command*")))

(defun texinfo-my-menu-update ()
  "Update texinfo node menu automatically."
  (interactive)
  (let
      ;; Master file.
      ((local-master
        (if (not texinfo-my-masterfile)
            buffer-file-name
          texinfo-my-masterfile)))

    (texinfo-multiple-files-update local-master t 8)))

(add-hook
 'texinfo-mode-hook
 (lambda ()
   (setq fill-column 80)
   (setq compilation-scroll-output t)
   (local-set-key (kbd "C-c C-b") 'texinfo-my-menu-update)
   (local-set-key (kbd "C-c C-v") 'texinfo-pdf-view)
   (local-set-key "\C-c\C-t\C-b" 'texinfo-my-compile)))

;;==============================================================================
;; Org mode
;;==============================================================================

;; PDFs visited in Org-mode are opened in Evince (and not in the default choice)
(eval-after-load "org"
  '(progn
     ;; Change .pdf association directly within the alist
     (setcdr (assoc "\\.pdf\\'" org-file-apps) "zathura --fork %s")))

;;==============================================================================
;; Qt semantic support
;;==============================================================================

;; Qt base directory, meaning the directory where the 'Qt' directory can be found.
;; Adapt accordingly.
(setq qt4-base-dir "/usr/include/qt4")
(setq qt4-gui-dir (concat qt4-base-dir "/QtGui"))
(semantic-add-system-include qt4-base-dir 'c++-mode)
(semantic-add-system-include qt4-gui-dir 'c++-mode)
(add-to-list 'auto-mode-alist (cons qt4-base-dir 'c++-mode))
(add-hook
 'c++-mode-hook
 (lambda ()
   (add-to-list 'semantic-lex-c-preprocessor-symbol-file (concat qt4-base-dir "/Qt/qconfig.h"))
   (add-to-list 'semantic-lex-c-preprocessor-symbol-file (concat qt4-base-dir "/Qt/qconfig-large.h"))
   (add-to-list 'semantic-lex-c-preprocessor-symbol-file (concat qt4-base-dir "/Qt/qglobal.h"))))