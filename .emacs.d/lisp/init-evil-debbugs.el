;;; Evil+Debbugs

(evil-set-initial-state 'debbugs-gnu-mode 'motion)

(evil-define-key 'motion debbugs-gnu-mode-map
  (kbd "TAB") 'forward-button
  (kbd "<backtab>") 'backward-button
  (kbd "RET") 'debbugs-gnu-select-report
  (kbd "SPC") 'scroll-up-command
  "\M-sf" 'debbugs-gnu-narrow-to-status
  "gB" 'debbugs-gnu-show-blocking-reports
  "c" 'debbugs-gnu-send-control-message
  "r" 'debbugs-gnu-show-all-blocking-reports
  "S" 'tabulated-list-sort
  "gb" 'debbugs-gnu-show-blocked-by-reports
  "d" 'debbugs-gnu-display-status
  "gr" 'debbugs-gnu-rescan
  "q" 'quit-window
  "s" 'debbugs-gnu-toggle-sort
  "i" 'debbugs-gnu-toggle-tag
  "o" 'debbugs-gnu-widen
  "x" 'debbugs-gnu-toggle-suppress)

(provide 'init-evil-debbugs)
