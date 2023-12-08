(setq zsh-program (string-trim (shell-command-to-string "which zsh")))
(setq my-term-program zsh-program)
(set-language-environment "utf-8")

;; quick pop shell
(use-package shell-pop
  :ensure t
  :defer t
  :config
  (setq shell-pop-shell-type '("ansi-term" "*ansi-term*" (lambda nil (ansi-term shell-pop-term-shell))))
  (setq shell-pop-term-shell zsh-program)
  ;; need to do this manually or not picked up by `shell-pop'
  (shell-pop--set-shell-type 'shell-pop-shell-type shell-pop-shell-type))

;; code annotation
(use-package annotate
  :ensure t
  :defer t
  :custom
  (annotate-summary-ask-query t)
  (annotate-file "~/.data/annotations"))

;; company
;; (with-eval-after-load 'company-ispell
;;   (setq company-ispell-available nil))
;; (use-package company
;;   :custom
;;   (company-echo-delay 0)                          ; remove annoying blinking
;;   :config
;;   (setq company-backends (delete 'company-semantic company-backends))
;;   (setq company-backends (delete 'company-clang company-backends))
;;   (cons 'company-capf company-backends)
;;   (setq company-backends (cl-remove-duplicates company-backends))) ; start autocompletion only after typin)


(setq phye/general-ignore-directories
  '(
    "build"
    "duiqi"
    "data"
    "pack"
    "cache"
    ;; "model"
    "lib"
    "third_path"
    "cc_tool"
    "netcapture/proto"
    "crm_client/dm_nlp_svrs/nlp_structured_msg_svr/client/proto"
    ))

;; counsel
(with-eval-after-load 'counsel-etags
  (setq counsel-etags-debug t)
  (setq counsel-etags-ignore-directories (append phye/general-ignore-directories counsel-etags-ignore-directories))
  (add-to-list 'counsel-etags-ignore-filenames "*_pb2.py")
  (add-to-list 'counsel-etags-ignore-filenames "*.pb.h")
  (add-to-list 'counsel-etags-ignore-filenames "*.pb.cc"))

;; ediff
(defvar previous-theme nil "previous theme before ediff for backup")
(defun phye/ediff-startup-hook ()
  (setq previous-theme (car custom-enabled-themes))
  (load-theme 'doom-gruvbox t))
(defun phye/ediff-cleanup-hook ()
  "ediff cleanup"
  (load-theme previous-theme t)
  (winner-undo))
(defun phye/ediff-quit-hook ()
  "kill all ediff opened buffers"
  (kill-buffer ediff-buffer-A)
  (kill-buffer ediff-buffer-B)
  (kill-buffer ediff-buffer-C))
(add-hook 'ediff-startup-hook #'phye/ediff-startup-hook)
(add-hook 'ediff-cleanup-hook #'phye/ediff-cleanup-hook)
(add-hook 'ediff-quit-hook #'phye/ediff-quit-hook)

;; projectile-mode, multiple projects
;; (use-package projectile
;;   :ensure t
;;   :defer t
;;   ;; :bind (("C-c x" . projectile-command-map))
;;   :config
;;   (projectile-mode +1)
;;   (define-key projectile-mode-map (kbd "C-c x") 'projectile-command-map)
;;   (setq projectile-indexing-method 'hybrid)
;;   (setq projectile-globally-ignored-directories
;;         (append phye/general-ignore-directories projectile-globally-ignored-directories))
;;   (add-to-list 'projectile-globally-ignored-file-suffixes "pb.cc")
;;   (add-to-list 'projectile-globally-ignored-file-suffixes "pb.h")
;;   (add-to-list 'projectile-globally-ignored-file-suffixes "py")
;;   (add-to-list 'projectile-globally-ignored-file-suffixes "pyc"))

;; log
(defun phye/view-log-with-color ()
  (interactive)
  (ansi-color-apply-on-region (point-min) (point-max)))

;; python
(setq elpy-rpc-python-command (string-trim (shell-command-to-string "which python3")))

(with-eval-after-load 'find-file-in-project
  (add-to-list 'ffip-prune-patterns "*/build")
  (add-to-list 'ffip-prune-patterns "*/rpm_build")
  (add-to-list 'ffip-prune-patterns "*/cc_tool")
  (add-to-list 'ffip-prune-patterns "*/qci_files")
  (add-to-list 'ffip-ignore-filenames "*.pb.cc")
  (add-to-list 'ffip-ignore-filenames "*.pb.h")
  (add-to-list 'ffip-ignore-filenames "*_pb2.py")
  )

(with-eval-after-load 'rg
  (define-key rg-mode-map (kbd "n") 'rg-next-file)
  (define-key rg-mode-map (kbd "p") 'rg-prev-file)
  )

(use-package tree-sitter
  :ensure t
  :defer t)

(use-package tree-sitter-langs
  :ensure t
  :defer t
  :after (tree-sitter))

(defun phye/goto-definition-at-point ()
  "my mode-aware go to definition"
  (interactive)
  (if (string= major-mode "go-mode")
      (xref-find-definitions (symbol-at-point))
    (counsel-etags-find-tag-at-point)))

(with-eval-after-load 'eldoc-mode
  (setq eldoc-idle-delay 5))

(add-hook 'go-mode-hook 'eglot-ensure)

;; general prog-mode-hook
(defun phye/prog-mode-hook ()
  (interactive)
  "phye's prog mode hook"
  (turn-on-auto-fill)
  (hs-minor-mode)
  (hl-todo-mode 1)
  (subword-mode)
  (ws-butler-mode -1)                   ; disable auto white space removal
  ;; (phye/set-electric-pair-inhibit-predicate)
  (setq my-disable-lazyflymake t)
  (set-fill-column 100))
(add-hook 'prog-mode-hook 'phye/prog-mode-hook 90)

(provide 'phye-init-prog)