;;; init-modes.el --- 所有自定义的major和minor modes的入口文件
;; Author:Claudio <3261958605@qq.com>
;; Created: 2017
;;; Commentary:
;;; Code:
(message "加载自定义major和minor modes...")

(claudio/require-init-files
 init-minor-modes
 init-major-modes
 )

(provide 'init-modes)
;;; init-modes.el ends here
