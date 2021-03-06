;;; LaTeX
;;; WARNING: This file is loaded from a hook.

;;; TODO: `beginning-of-defun'/`end-of-defun' should go to next section.

;;; We use the TeX setup.
(require 'init-tex)
(require 'latex-pretty-symbols nil t)

;;; Since current buffer is a LaTeX one, we can use `local-set-key'.
(local-set-keys
 "C-c m" 'latex-article
 "C-c C-a" 'latex-insert-table
 "C-c C-c" 'latex-smallcaps
 "C-c C-e" 'latex-emph
 "C-c C-l" 'latex-slanted
 "C-c C-s" 'latex-insert-section
 "C-c C-u" 'latex-superscript
 "C-c l" 'latex-lstinline
 "C-c o" 'latex-orgtbl
 "C-c u" 'latex-package
 "M-RET" 'latex-itemize)

;;; Needs dvipng.
;;; With TeXlive, the following packages are needed: psnfss, symbol, zapfding
(when (and (executable-find "dvipng") (require 'latex-math-preview nil t))
  (setq latex-math-preview-cache-directory-for-insertion
        (concat emacs-cache-folder "latex-math-preview-cache"))
  (local-set-key (kbd "C-c p") 'latex-math-preview-expression)
  (local-set-key (kbd "C-c j") 'latex-math-preview-insert-symbol)
  (local-set-key (kbd "C-c C-j") 'latex-math-preview-last-symbol-again)
  ;; Any color package should be filtered out as they will have unexpected impact on coloring.
  (add-to-list 'latex-math-preview-usepackage-filter-alist '("color")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Functions

(defun latex-itemize ()
  "Itemize current line or lines in region.
Prepend \\item to the beginning of the lines if not already
there, otherwise insert it on next line. If region, surround it
by an {itemize} environment."
  (interactive)
  (let (min max)
    (if (not (use-region-p))
        (if (string-match "\\item" (buffer-substring-no-properties (line-beginning-position) (line-end-position)))
            (progn
              (goto-char (line-end-position))
              (newline)
              (insert "\\item "))
          (goto-char (line-beginning-position))
          (insert "\\item")
          (just-one-space))
      ;; On region:
      (let ((end-marker (set-marker (make-marker) (region-end))))
        (goto-char (region-beginning))
        (goto-char (line-beginning-position))
        (insert "\\begin{itemize}")
        (newline-and-indent)
        (while (and (< (line-beginning-position) end-marker) (not (eobp)))
          (insert "\\item")
          (just-one-space)
          (indent-according-to-mode)
          (forward-line))
        (insert "\\end{itemize}")
        (newline-and-indent)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; LaTeX setup

(setq latex-block-default "itemize")
(setq latex-block-names '("listing" "align" "align*" "Bmatrix" "Vmatrix" "bmatrix" "matrix" "pmatrix" "smallmatrix" "vmatrix"))

(dolist (block '("listing" "verbatim" "verbatim*"))
  (add-to-list 'latex-block-body-alist `(,block nil '(delete-horizontal-space t) _)))

(defun latex-set-compiler ()
  (set (make-local-variable 'tex-extension-list)
       '("aux" "bbl" "blg" "glg" "glo" "gls" "idx" "ilg" "ind" "lof" "log" "maf" "mt" "mtc" "nav" "out" "snm" "synctex" "synctex.gz" "tns" "toc" "xdy"))
  (set (make-local-variable 'tex-command) "pdflatex")
  ;; Need to reset the compiler because we changed tex-command, order matters.
  (tex-set-compiler))

;;; For some unknown reasons, `skeleton-end-hook' is set to nil in tex-mode.
(dolist (fun '(latex-set-compiler turn-on-orgtbl turn-on-skeleton-markers))
  ;; Since this file is loaded from `latex-mode-hook', these functions will not
  ;; be applied to the current buffer. We do it manually.
  (funcall fun)
  (add-hook 'latex-mode-hook fun))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Skeletons

(define-skeleton latex-emph "Insert emph." nil "\\emph{" @ _ "}" @)
(define-skeleton latex-slanted "Insert slanted text." nil "\\textsl{" @ _ "}" @)
(define-skeleton latex-smallcaps "Insert smallcaps text." nil "\\textsc{" @ _ "}" @)
(define-skeleton latex-superscript "Insert supercript text." nil "\\textsuperscript{" @ _ "}" @)
(define-skeleton latex-package "Use package." "Package: " \n "\\usepackage[" @ "]{" @ _ "}" \n @)

(defvar latex-section-default "section")
(defvar latex-section-names
  '("part" "part*" "chapter" "chapter*" "section*" "subsection" "subsection*"
    "subsubsection" "subsubsection*" "paragraph" "paragraph*" "subparagraph" "subparagraph*")
  "Standard LaTeX section names.")

(define-skeleton latex-insert-section
  "Insert section at point.
Puts point to section title. Section are auto-completed from
`latex-section-names'."
  (let ((choice (completing-read (format "LaTeX section name [%s]: "
                                         latex-section-default)
                                 latex-section-names
                                 nil nil nil nil latex-section-default)))
    (setq latex-section-default choice)
    (unless (member choice latex-section-names)
      ;; Remember new block names for later completion.
      (push choice latex-section-names))
    choice)
  \n "\\" str "{" @ _ "}" @)

(defvar latex-table-default "tabular")
(defvar latex-table-names
  '("tabular" "tabu" "tabular*" "tabularx" "tabulary" "longtabu")
  "Standard LaTeX table names.")

(define-skeleton latex-insert-table
  "Create a table at point.
The table type is any value found in `latex-table-names'."
  (let ((choice (completing-read (format "LaTeX table type [%s]: "
                                         latex-table-default)
                                 latex-table-names
                                 nil nil nil nil latex-table-default)))
    (setq latex-table-default choice)
    (unless (member choice latex-table-names)
      ;; Remember new block names for later completion.
      (push choice latex-table-names))
    choice)
  '(require 'functions)
  \n "\\begin{center}" > \n
  "\\begin{" str "}{"
  '(setq v1 (skeleton-read "Format: " "ll"))
  v1 "}" > \n
  '(setq v2 (count-occurences "[a-z]" v1))
  @ (mapconcat 'identity (split-string (make-string v2 ?&) "" t) " ") " \\\\" \n
    @ _ "\\\\" \n
      "\\end{" str "}" > \n
      "\\end{center}" > \n @)

;;; TODO: implement orgtbl directly with latex tables and remove this skel.
(define-skeleton latex-orgtbl
  "Insert orgtbl skel."
  "Table name: "
  > "\\begin{center}" \n
  "% BEGIN RECEIVE ORGTBL " str \n
  "% END RECEIVE ORGTBL " str \n
  "\\end{center}" > \n
  "\\begin{comment}" \n
  "#+ORGTBL: SEND " str " orgtbl-to-latex" \n
  "| " @ _ " |" \n
  "%$" \n
  "\\end{comment}" > \n @)

(define-skeleton latex-lstinline
  "Insert inline listing." nil
  "\\lstinline @" @ _ "@" @)

(define-skeleton latex-graphics
  "Insert centered picture."
  nil
  > "\\begin{center}" \n
  "\\includegraphics[width=" @ (skeleton-read "Width: " "\\linewidth") "]{" @ _ "}" \n
  "\\end{center}" > \n @)

(define-skeleton latex-article
  "Insert article template."
  nil
  > "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\\documentclass[10pt,a4paper]{article}
\\usepackage[utf8]{inputenc}
\\usepackage[T1]{fontenc}
\\usepackage{lmodern}
\\usepackage{marvosym}
\\usepackage{textcomp}
\\DeclareUnicodeCharacter{20AC}{\\EUR{}}
\\DeclareUnicodeCharacter{2260}{\\neq}
\\DeclareUnicodeCharacter{2264}{\\leq}
\\DeclareUnicodeCharacter{2265}{\\geq}
\\DeclareUnicodeCharacter{22C5}{\\cdot}
\\DeclareUnicodeCharacter{A0}{~}
\\DeclareUnicodeCharacter{B1}{\\pm}
\\DeclareUnicodeCharacter{D7}{\\times}

%%=============================================================================
%% Packages

\\usepackage{amsmath,amssymb,amsfonts}
% \\usepackage{comment}
\\usepackage{geometry}
% \\usepackage{graphicx}
% \\usepackage{lipsum}
% \\usepackage{needspace}
\\usepackage[svgnames]{xcolor}
\\usepackage{xspace}

%%=============================================================================
%% Properties

\\title{" @ (skeleton-read "Title: " "Title") "}
\\author{" @ (skeleton-read "Author: " "P.~\\textsc{Neidhardt}") "}

\\makeatletter
\\let\\thetitle\\@title
\\let\\theauthor\\@author
\\let\\thedate\\@date
\\makeatother" \n

'(setq latex-setup-list '(latex-preamble-aliases latex-preamble-tables latex-preamble-listing))
'(while (and latex-setup-list
             (= (read-key (concat "Insert " (symbol-name (car latex-setup-list)) "? (y)")) ?y))
   (newline-and-indent)
   (funcall (pop latex-setup-list))
   (newline-and-indent))
\n
"%%=============================================================================
%% Babel (load near the end before 'hyperref')
\\usepackage[english]{babel}
%\\iflanguage{french}{
%}{"
"%% Narrow items" \n
"%\\newlength{\\wideitemsep}" \n
"%\\setlength{\\wideitemsep}{.5\\itemsep}" \n
"%\\addtolength{\\wideitemsep}{-7pt}" \n
"%\\let\\olditem\\item" \n
"%\\renewcommand{\\item}{\\setlength{\\itemsep}{\\wideitemsep}\\olditem}"\n
"%}" > \n
"
%%=============================================================================
%% Formatting

% \\usepackage{parskip}
% \\setlength{\\parindent}{15pt}
% \\setlength{\\parskip}{5pt plus 4pt}

% \\renewcommand{\\thefigure}{\\arabic{section}.\\arabic{figure}}
\\renewcommand{\\arraystretch}{1.4}
% \\renewcommand{\\familydefault}{\\sfdefault}

%% Header
% \\usepackage{fancyhdr}
% \\setlength{\\headheight}{15.2pt}
% \\pagestyle{fancy}
% \\lhead{\\thetitle}
% \\rhead{\\theauthor}" > \n
"
%%==============================================================================
%% Hyperref (load last)
\\usepackage[]{hyperref}
\\hypersetup{"
"colorlinks=true," \n
"citecolor=DarkRed," \n
"linkcolor=DarkRed," \n
"linktoc=page," \n
"urlcolor=blue," \n
"}" > \n
"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\\begin{document}

\\maketitle
\\vfill
\\thispagestyle{empty}

\\tableofcontents
\\clearpage" \n
> @ _ \n \n
"%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\\end{document}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
" \n)

(define-skeleton latex-preamble-aliases
  "Insert setup template."
  nil
  > "%%=============================================================================
%% Aliases

\\let\\latexbak\\LaTeX
\\renewcommand{\\LaTeX}{\\textrm{\\latexbak}\\xspace}

\\let\\texbak\\TeX
\\renewcommand{\\TeX}{\\textrm{\\texbak}\\xspace}

\\def\\unix{\\textsc{Unix}\\xspace}
\\def\\ie{\\textsl{i.e.}\\xspace}
\\def\\eg{\\textsl{e.g.}\\xspace}" \n)

(define-skeleton latex-preamble-tables
  "Insert setup template."
  nil
  > "%%==============================================================================
%% Tables

\\usepackage{longtable}
\\usepackage{tabu}" \n)

(define-skeleton latex-preamble-graphics
  "Insert setup template."
  nil
  > "%%==============================================================================
%% Graphics

\\usepackage{tikz}

\\newcommand{\\fancybox}[1]{" \n
"\\begin{tikzpicture}" \n
"\\node[draw,rounded corners]{#1};" \n
"\\end{tikzpicture}" > \n
"}" > \n)

(define-skeleton latex-preamble-listing
  "Insert listing setup template."
  ;; WARNING: we need to put a '-' at the very end so that the cursor will end
  ;; there. Otherwise it will be placed at the beginning. This is due to some
  ;; unicode or escape characters in the literate array, which `skeleton-insert'
  ;; does not seem to parse correctly.
  nil
  > "%%=============================================================================
%% Listings

\\usepackage{listings}

%% Source code.
\\lstdefinestyle{custom}{" \n
"% numbers=left," \n
"belowcaptionskip=1\\baselineskip," \n
"breaklines=true," \n
"frame=L," \n
"xleftmargin=\\parindent," \n
"% framexleftmargin=\\parindent," \n
"language=C," \n
"showstringspaces=false," \n
"basicstyle=\\footnotesize\\ttfamily," \n
"keywordstyle=\\bfseries\\color{green!40!black}," \n
"commentstyle=\\itshape\\color{purple!40!black}," \n
"identifierstyle=\\color{blue}," \n
"stringstyle=\\color{orange}," \n
"numberstyle=\\ttfamily," \n
"}" > \n
"
\\lstset{escapechar=,style=custom," \n
"literate=" \n
"{á}{{\\'a}}1 {é}{{\\'e}}1 {í}{{\\'i}}1 {ó}{{\\'o}}1 {ú}{{\\'u}}1" \n
"{Á}{{\\'A}}1 {É}{{\\'E}}1 {Í}{{\\'I}}1 {Ó}{{\\'O}}1 {Ú}{{\\'U}}1" \n
"{à}{{\\`a}}1 {è}{{\\'e}}1 {ì}{{\\`i}}1 {ò}{{\\`o}}1 {ù}{{\\`u}}1" \n
"{À}{{\\`A}}1 {È}{{\\'E}}1 {Ì}{{\\`I}}1 {Ò}{{\\`O}}1 {Ù}{{\\`U}}1" \n
"{ä}{{\\\"a}}1 {ë}{{\\\"e}}1 {ï}{{\\\"i}}1 {ö}{{\\\"o}}1 {ü}{{\\\"u}}1" \n
"{Ä}{{\\\"A}}1 {Ë}{{\\\"E}}1 {Ï}{{\\\"I}}1 {Ö}{{\\\"O}}1 {Ü}{{\\\"U}}1" \n
"{â}{{\\^a}}1 {ê}{{\\^e}}1 {î}{{\\^i}}1 {ô}{{\\^o}}1 {û}{{\\^u}}1" \n
"{Â}{{\\^A}}1 {Ê}{{\\^E}}1 {Î}{{\\^I}}1 {Ô}{{\\^O}}1 {Û}{{\\^U}}1" \n
"{œ}{{\\oe}}1 {Œ}{{\\OE}}1 {æ}{{\\ae}}1 {Æ}{{\\AE}}1 {ß}{{\\ss}}1" \n
"{ç}{{\\c c}}1 {Ç}{{\\c C}}1 {ø}{{\\o}}1 {å}{{\\r a}}1 {Å}{{\\r A}}1" \n
"{€}{{\\EUR}}1 {£}{{\\pounds}}1" \n
"}" > \n
"
\\newcommand{\\includecode}[2][custom]{" \n
"\\lstinputlisting[caption=#2, escapechar=, style=#1]{#2}}" \n
"\\let\\verbatim\\relax%" \n
"\\lstnewenvironment{verbatim}[1][]{\\lstset{style=custom}}{}%" > \n -)

(provide 'init-latex)
