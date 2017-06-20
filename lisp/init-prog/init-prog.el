;;; init-prog.el -- 编程语言综合配置
;; Author:Claudio <3261958605@qq.com>
;; Created: 2017
;;; Commentary:
;;; Code:

(claudio/require-init-files
 init-elisp
 init-html
 init-js
 init-json
 init-markdown
 init-golang
 init-python
 init-clang
 init-org
 init-bash
 init-nasm
 )

;; multi-term -- 方便打开命令行
(use-package multi-term
  :config
  (setq multi-term-program "/bin/bash")

  ;; 将新建命令行窗口放在垂直方向
  (advice-add 'multi-term :after
              (lambda(&rest _r)
                (split-window-below)
                (windmove-up)))

  :bind (("M-!" . multi-term)))

;; 保存后，如果为可执行脚本文件，修改其文件属性，使可执行
(add-hook 'prog-mode-hook
          (lambda()
            "使脚本可执行."
            (add-hook 'after-save-hook #'executable-make-buffer-file-executable-if-script-p
                      nil t)))

(add-hook 'prog-mode-hook 'subword-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 自动执行当前文件
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar *claudio/prog-run-current-file-suffix-map*
  '((".php" . "php '%s'")
    (".pl" . "perl '%s'")
    (".go" . "go run '%s'")
    (".c" . "gcc -o a.out '%s' ; [[ -e 'a.out' ]] && ./a.out ; [[ -e 'a.out' ]] && rm a.out")
    (".py" . "python3.5 '%s'")
    (".sh" . "bash '%s'"))
  "可自动执行的文件后缀和自动执行命令映射表.")

(defvar *claudio/prog-run-current-file-modes*
  (remove-if (lambda(elem) (listp elem))
             (mapcar (lambda(pair)
                       (cdr (assoc-if (lambda(key) (string-match-p key (car pair))) auto-mode-alist)))
                     *claudio/prog-run-current-file-suffix-map*))
  "可自动执行当前文件的主模式名.")

(defun claudio/prog-run-current-file()
  "执行当前脚本。"
  (interactive)
  (let* ((file-name (buffer-file-name))
         file-suffix prog-name cmd-str)

    ;; 通过文件名构建命令
    (when file-name
      (setq file-suffix (file-name-extension file-name t)
            prog-name (cdr (assoc file-suffix  *claudio/prog-run-current-file-suffix-map*)))
      (when prog-name
        (setq cmd-str (format prog-name file-name))))

    ;; (message cmd-str)
    ;; 根据不同条件执行
    (cond ((not file-name) (message "文件不存在！"))
          (prog-name
           (async-shell-command cmd-str (format "*%s%s脚本运行结果*"  (file-name-base file-name) file-suffix)))
          (t (message "不支持 %s 文件运行！" file-suffix)))))

(dolist (mode *claudio/prog-run-current-file-modes*)
  (add-hook (claudio/util-mode-name-2-hook-name mode)
            (lambda()
              (add-hook 'after-save-hook
                        (lambda()
                          (when current-prefix-arg
                            (claudio/prog-run-current-file)))
                        t t))))

(add-hook 'emacs-lisp-mode-hook
          (lambda()
            (add-hook 'after-save-hook
                      (lambda()
                        (when current-prefix-arg
                          (load (file-name-sans-extension (buffer-file-name)))))
                      t t)))

(provide 'init-prog)
;;; init-prog.el ends here
