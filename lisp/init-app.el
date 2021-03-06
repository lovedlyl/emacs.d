;;; init-app.el --- 自动安装系统依赖程序
;; Author: Claudio <3261958605@qq.com>
;; Created: 2017-04-05 13:50:16
;;; Commentary:
;; 依赖于emacs25！！！
;; 在emacs24.5中，Tramp提示输入密码时会卡顿.
;; 有时会报错：Couldn’t find local shell prompt for /bin/sh
;; 没弄清原因，删除.emacs.desktop文件重启后好像能解决
;;; Code:

;; 设置shell程序的解释路径
(setq shell-file-name "/bin/bash")

;; 如果有新进程，不询问。方便使用apt命令安装程序时，执行pip3安装程序
;; 参考地址：http://stackoverflow.com/questions/6895155/multiple-asynchronous-shell-commands-in-emacs-dired
(advice-add #'async-shell-command :after
            (lambda(&rest _r)
              (let ((b-name "*Async Shell Command*"))
                (when (get-buffer b-name)
                  (with-current-buffer b-name
                    (rename-uniquely))))))

(defvar *claudio/app-ensure-all-sys-apps-installed-p* nil
  "是否保证所有以来的程序都自动安装.
由于pip3 --list命令执行速度很慢，claudio/app-installed-p函数也会很慢。
确保所有依赖程序的情况下，可将此值设为nil，提高启动速度."
  )

(defvar *claudio/app-apps-tobe-installed-by-apt* nil
  "需要在系统上使用apt安装的程序.")

(defvar *claudio/app-apps-tobe-installed-by-pip* nil
  "需要在系统上使用pip安装的程序.")

(defun claudio/app-installed-p(app)
  "系统是否安装APP.
使用execute-find函数只能找到可执行程度。有时不能确定程序是否安装python-jedi和使用pip安装的jedi.
pip3 list执行速度很慢，所以对于没安装的程序，此函数会很耗时."
  ;; (message "Debug：检查 %s 是否安装." app)
  (or
   ;; 可执行程序
   (executable-find app)
   ;; 非可执行程序
   (let ((command (format "dpkg --list | awk '{print $2}' | grep ^%s$" app)))
     (not (claudio/util-string-empty-p (shell-command-to-string command))))
   ;; ;; 或者是pip3安装程序，如jedi
   (let ((command (format "pip3 list --format=columns --disable-pip-version-check | awk '{print $1}' | grep ^%s$" app)))
     (not (claudio/util-string-empty-p (shell-command-to-string command))))))

;; (claudio/app-installed-p "which")
;; (claudio/app-installed-p "silversearcher-ag")
;; (claudio/app-installed-p "jedi")
;; (claudio/app-installed-p "pylint3")
;; (claudio/app-installed-p "isort")

;; 不清楚为何要使用  (let ((default-directory "/sudo::/")
;; 参考自：https://lists.gnu.org/archive/html/emacs-orgmode/2013-02/msg00354.html
;; 和：http://emacs.stackexchange.com/questions/29555/how-to-run-sudo-commands-using-shell-command
(defun claudio/app-install(app &optional use-pip)
  "属于sudo命令安装APP. sudo apt install APP.
如果参数USE-PIP为non-nil，则使用pip3安装."
  (let ((default-directory "/sudo::/")
        (command
         (if use-pip "pip3" "apt-get --assume-yes")))
    (async-shell-command (format "%s install %s" command app))
    ;; (start-process-shell-command command "XXX" "install" app)
    (message "系统正在执行sudo %s install %s 命令，可能会造成卡顿." command app)))

;; (claudio/app-install "jedi" t)

(cl-defun claudio/app-may-tobe-installed(app &key manual use-pip)
  "确保系统上安装程序APP.
如果manual为non-nil，表示需手动安装的程序，如果没安装，只是提醒。如lantern.
如果变量*claudio/ensure-all-sys-app-installed-p*为non-nil，则直接安装.
如果为nil，则只是警告。
如果USE-PIP为non-nil，则使用pip安装"
  (when (and *claudio/app-ensure-all-sys-apps-installed-p*
             (not (claudio/app-installed-p app)))
    (if *claudio/app-ensure-all-sys-apps-installed-p*
        (cond (manual (message "需在系统上手动安装%s，才能确保功能完全." app))
              (use-pip (add-to-list '*claudio/app-apps-tobe-installed-by-pip* app))
              ;; ....其他安装方式放这里
              (t (add-to-list '*claudio/app-apps-tobe-installed-by-apt* app)))
      (warn "需在系统上安装 %s 才能保证此配置正常运行。" app))))

(when *claudio/app-ensure-all-sys-apps-installed-p*
  (add-hook 'after-init-hook
            (lambda()
              "使用apt安装系统程序."
              ;; 使用sudo apt 安装的程序
              (when *claudio/app-apps-tobe-installed-by-apt*
                (claudio/app-install (claudio/util-list2string *claudio/app-apps-tobe-installed-by-apt*)))
              )
            t)

  (add-hook 'after-init-hook
            (lambda()
              "使用pip3安装程序."
              ;; 确保安装pip3
              (unless (claudio/app-installed-p "python3-pip")
                (claudio/app-install "python3-pip"))
              ;; 使用sudo pip3安装的程序
              (when *claudio/app-apps-tobe-installed-by-pip*
                (claudio/app-install (claudio/util-list2string *claudio/app-apps-tobe-installed-by-pip*) t)))
            t)
  )

(provide 'init-app)
;;; init-app.el ends here
