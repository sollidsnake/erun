;(defcustom erun:external-terminal )
(defvar erun:terminal "mate-terminal")

(defcustom erun:use-external-terminal nil
  "whether external terminal or not"
  :type 'boolean)

(defvar erun:elisp-function-name nil)

(defvar erun:cpp-error-buffer "erun-cpp-error")
(defvar erun:c-links ())

(defvar erun:python-function 'python-shell-send-buffer)

(defun erun:run-elisp-function ()
  (interactive)
  (funcall erun:elisp-function-name))

(defun erun:get-file-name-without-extension (file-path)
  "Return the file name without extension"
  (setq-local erun:splited (split-string file-path "/")) ; make the path a list
  (setq-local erun:number (safe-length erun:splited))         ; count
  (setq-local file (concat (nth (- erun:number 1) erun:splited))) ; get file name and extension
  (prin1-to-string file)
  )

(defun erun:get-executable-name (-file-name)
  (setq-local file
              (nth 0 (split-string -file-name "\\.")))   ; get file name without extension
  (prin1-to-string file)
  )

(defun erun:execute-using-terminal (cmd)
  (shell-command-to-string
   (concat erun:terminal " -e \"bash -c '" cmd "; read;'\""))

  ;; (message (concat erun:terminal " -e \"bash -c '" cmd "; read;'\""))
  )

(defun erun()                           ; awesomeness!!!
  "Check out the current major mode and run/eval the code!"
  (interactive)
  (cond
   ((string-equal major-mode "emacs-lisp-mode")
    (eval-buffer))

   ;; ((string-equal major-mode "python-mode")
    ;; (erun:execute-using-terminal (concat "python " buffer-file-name)))

   ((string-equal major-mode "python-mode")
    (if erun:use-external-terminal
        (erun:execute-using-terminal (concat "python " buffer-file-name))
      (funcall erun:python-function)))

   ((string-equal major-mode "php-mode")
    (erun:execute-using-terminal (concat "php " buffer-file-name)))

   ((string-equal major-mode "web-mode")
    (erun:execute-using-terminal (concat "php " buffer-file-name)))

   ((string-equal major-mode "java-mode")
    (eclim-run-class))

   ((string-equal major-mode "c++-mode")
    (progn
      (save-buffer)
      (setq-local file-name (erun:get-file-name-without-extension(buffer-file-name)))
      (setq-local executable-name (erun:get-executable-name file-name))
      (setq executable-name (replace-regexp-in-string "\\\\" "" executable-name))
      (setq executable-name (replace-regexp-in-string "\"" "" executable-name))
      (setq output (shell-command-to-string
                    (concat "g++ " file-name " -o" executable-name "")))

      (if (string-match "error:" output) ; check for compilation error
          (progn
            ;(setq -buf (frame-selected-window))
            (switch-to-buffer-other-window erun:cpp-error-buffer)
            (erase-buffer)
            (insert output)
            (other-window 1)
            )

        (shell-command (concat erun:terminal " -e \"bash -c './" executable-name "; read;' \" > /dev/null 2>&1" )))
      ;(message output)
      )
   ))
)

(provide 'erun)
