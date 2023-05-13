;; {{ global keymaps
(define-key global-map (kbd "C-x C-c") 'delete-frame)
(define-key global-map (kbd "C-x M") 'manual-entry)
(define-key global-map (kbd "M-`") 'other-frame)
(define-key global-map (kbd "C-c c") 'org-capture)
(define-key global-map (kbd "C-c l") 'org-store-link)
(define-key global-map (kbd "C-c t") 'org-mark-ring-goto)
(define-key global-map (kbd "M-v") 'paste-from-x-clipboard)
(define-key global-map (kbd "C-c a") 'org-agenda)
(define-key global-map (kbd "C-c l") 'org-store-link)
(define-key global-map (kbd "C-x C-g") 'aboabo/hydra-git-gutter/body)

;; (evil-define-key 'normal 'magit-blame-mode-map "q" #'magit-blame-quit)

(general-define-key
 :states 'normal
 :keymaps 'magit-blame-mode-map
 "q" #'magit-blame-quit)

(general-define-key
 :states 'normal
 :keymaps 'go-mode-map
 :prefix ","
 "fb" 'gofmt)

(general-define-key
 :states 'insert
 :prefix "C-;"
 ";" 'ace-pinyin-jump-char-2)

(general-define-key
 :keymaps 'image-mode-map
 "q" #'quit-window)

(my-comma-leader-def
  "cc" 'clipetty-kill-ring-save
  "cd" 'copy-relative-path-in-project
  "dc" 'godoc-at-point
  "dg" 'deadgrep
  "dk" 'deadgrep-kill-all-buffers
  "fb" 'clang-format-buffer
  "mb" 'magit-blame
  "mk" 'compile
  "gr" 'lsp-find-references
  "gt" 'phye/goto-definition-at-point
  "ha" 'show-ifdefs
  "hb" 'hs-hide-block
  "hd" 'hide-ifdef-block
  "hl" 'hs-hide-level
  "ho" 'hs-show-block
  "hs" 'show-ifdef-block
  "id" 'find-file-in-current-directory
  "il" 'org-insert-link
  "ls" 'highlight-symbol
  "oc" 'cfw:open-org-calendar
  "ol" 'org-open-at-point
  "ov" 'jao-toggle-selective-display
  "sl" 'org-store-link
  "tt" 'shell-pop
  "xb" 'ivy-switch-buffer
  "xc" 'suspend-frame
  "xd" 'find-file-in-cpp-module
  "xe" 'exit-recursive-edit
  "xg" 'magit-status)

(my-space-leader-def
  "fd" 'delete-frame
  "fn" 'phye/select-next-frame
  "fp" 'phye/select-previous-frame
  "fr" 'set-frame-name
  "fs" 'select-frame-by-name
  "fo" 'find-file-other-frame
  "ff" 'phye/toggle-last-frame
  "ft" 'my-toggle-full-window
  "nn" 'highlight-symbol-next
  "pp" 'highlight-symbol-prev
  "rt" 'my-random-favorite-color-theme
  "hh" 'my-random-healthy-color-theme
  "pc" 'popper-cycle
  "pl" 'popper-toggle-latest
  )
;; }}

;; {{ mini buffer edit
(general-define-key
 :keymaps 'minibuffer-mode-map
 "C-a" 'move-beginning-of-line
 "C-e" 'move-end-of-line
 "C-w" 'evil-delete-backward-word)

(defun phye/ivy-mode-hook ()
  (general-define-key
   :keymaps 'ivy-minibuffer-map
   "C-w" 'evil-delete-backward-word))
(add-hook 'ivy-mode-hook 'phye/ivy-mode-hook)
;; }}

(provide 'phye-init-key)
