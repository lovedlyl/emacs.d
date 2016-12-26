;;; init-org.el --- org配置
;;; Commentary:
;;; Code:
;;org-mode -- YES

(my/use-package
 (:req org
       :keys (("C-c t" (lambda()
			 (interactive)
			 (org-agenda nil "t"))
	       "获取所有日程事项")
	      ("C-c C-d" (lambda()
			   (interactive)
			   (org-capture nil "d"))
	       "新建日常事项")
	      
	      ))
 (setq org-src-fontify-natively t)	;代码块语法高亮

 ;;设置org agenda的默认文件夹
 (setq
  org-directory "~/.emacs.d/org/" ;;org的默认文件夹
  my/org-agenda-directory (concat org-directory "agenda/")
  org-agenda-files (list my/org-agenda-directory));;org agenda 的文件夹

 ;;设置capture
 (setq org-agenda-skip-scheduled-if-done t)
 (setq org-capture-templates
       '(("j" "生活安排(Journal)" entry (file+headline (concat my/org-agenda-directory "生活安排.org") "生活安排")
	  "* TODO %? %T")
	 ("d" "每日安排(Daily)" entry (file+headline (concat my/org-agenda-directory "每日安排.org") "每日安排")
	  "* TODO %? %T")
	 ("s" "学习安排(Study)" entry (file+headline (concat my/org-agenda-directory "学习安排.org") "学习安排")
	  "* TODO %?\n %t \n %a")))

 )

;; org-pomodoro -- 番茄工作坊
(my/use-package
 (:pkg org-pomodoro :require-p nil)
 (setq org-pomodoro-format "剩余时间~%s") ;显示格式
 )

(provide 'init-org)
;;; init-org.el ends here