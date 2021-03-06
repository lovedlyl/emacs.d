;;; init-ui.el --- 主题theme配置
;; Author:Claudio <3261958605@qq.com>
;; Created: 2017
;;; Commentary:
;;; Code:

;; 修改默认UI配置 ;;;;;;;;;;;;;;;;;;;;;;;;

;; 定制*scratch*页面显示信息
;; 参考地址：http://stackoverflow.com/questions/1498258/how-do-i-change-the-scratch-message-in-emacs
;; http://stackoverflow.com/questions/35278613/how-to-use-unix-login-user-names-in-emacs-lisp-config
(setq initial-scratch-message
	  (concat ";; 你好，"
			  (capitalize user-login-name)
			  "！Emacs ♥ 你：\n\n"))

;; (setq Info-history-skip-intermediate-nodes nil)

;;关闭菜单、工具和滚动条
(tool-bar-mode -1)
(scroll-bar-mode -1)
(menu-bar-mode -1)
(setq inhibit-splash-screen t)
;;(global-linum-mode t)

;; 状态栏显示修改
;; 启用显示当前列数
(column-number-mode)
;; 显示时间
(display-time-mode)

;; 显示电池
;; (display-battery-mode)

;; 只在图像界面中有作用，在命令行中时，默认与命令行的光标保持一致。
;;改变光标样式，显示为单竖线。
(setq-default cursor-type 'bar)
;; 光标一直闪烁
(setq-default blink-cursor-blinks 0)

;;开启时全屏显示，只有在图形界中才有效
;; 命令行中由命令行本身控制。
(when (display-graphic-p)
  (setq initial-frame-alist
		'((top . 0) (left . 0) (width . 100) (height . 20))))

;;高亮当前行
(global-hl-line-mode t)

;;高亮匹配括号
(show-paren-mode)

;; tab的宽度
(setq-default tab-width 4)
(setq-default indent-tabs-mode nil)

;; 关闭警告声
(setq visible-bell nil)
(setq ring-bell-function 'ignore)

;; 主题应用 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package color-theme-sanityinc-tomorrow
  :disabled t
  :config
  (add-hook 'after-init-hook #'color-theme-sanityinc-tomorrow-day))

;;Solarized主题有点奇葩，一般加载主题使用的就是(load-theme 'xxx)，为啥会这样？
;; 好像不能在命令行中正确显示？？？
(use-package solarized-theme
  :if (display-graphic-p)
  ;; :demand t
  :config
  (deftheme solarized-dark "The dark variant of the Solarized colour theme")
  (create-solarized-theme 'dark 'solarized-dark)
  (provide-theme 'solarized-dark)
  )

;;使用zenburn主题主要是为了兼容非图像界面使用问题
;; zenburn-them -- zenbutn主题
(use-package zenburn-theme
  :if (not (display-graphic-p))
  :demand t
  :config
  (load-theme 'zenburn t)
  ;; 设置当前行的颜色。使用zenburn主题后，命令行环境下高亮当前行的解决办法。
  ;; 参考地址：http://stackoverflow.com/questions/2718189/emacshighlight-the-current-line-by-underline-it
  (set-face-attribute hl-line-face nil  :background "black")
  )

;; 改变当前行高亮样式
(set-face-attribute font-lock-function-name-face nil :bold t :italic t)

;; 将背景设置为透明
;; (set-background-color "ARGBBB000000")
;; powerline -- 模式栏目使用powerline

;; (use-package powerline
;;   :demand t
;;   :config
;;   (powerline-default-theme))

(provide 'init-ui)
;;; init-ui.el ends here
