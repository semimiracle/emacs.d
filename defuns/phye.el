(defun insert-src-in-orgmode (lang)
  "Insert src prefix and postfix for LANG in OrgMode"
  (interactive "sChoose your language: ")
  (newline)
  (indent-for-tab-command)
  (insert "#+begin_src " lang "\n")
  (indent-for-tab-command)
  (save-excursion
    (insert "#+end_src"))
  (org-edit-special)
  )

(add-hook 'text-mode-hook 'turn-on-auto-fill)
(cd "~/ws/OrgNotes/")

(setq-default evil-escape-key-sequence "jk")
