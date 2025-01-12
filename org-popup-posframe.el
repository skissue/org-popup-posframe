;;; org-popup-posframe.el --- Show org mode popup buffers in posframe -*- lexical-binding: t; -*-

;; Copyright (C) Aaron Lee

;; Author: Aaron Lee <Aaron__Lee_@outlook.com>
;; SPDX-License-Identifier: GPL-3.0-or-later
;; Homepage: https://github.com/A7R7/org-popup-posframe
;; Keywords: convenience, outlines, org
;; Version: 0.0.1
;; Package-Requires: ((emacs "28.1") (posframe "1.4.2"))

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Display org mode popup buffers in posframe
;; Supported popup buffers:
;; - org-attach
;; - org-capture
;; - org-export-dispatch
;; - org-insert-link
;; - org-insert-structure-template
;; - org-todo

;;; Code:

;;;; Requirements

(require 'posframe)
(require 'org)

;;;; Customs & Faces

(defconst org-popup-posframe-handler-customize-type
  '(radio
    (function-item posframe-poshandler-frame-center)
    (function-item posframe-poshandler-frame-top-center)
    (function-item posframe-poshandler-frame-top-left-corner)
    (function-item posframe-poshandler-frame-top-right-corner)
    (function-item posframe-poshandler-frame-top-left-or-right-other-corner)
    (function-item posframe-poshandler-frame-bottom-center)
    (function-item posframe-poshandler-frame-bottom-left-corner)
    (function-item posframe-poshandler-frame-bottom-right-corner)
    (function-item posframe-poshandler-window-center)
    (function-item posframe-poshandler-window-top-center)
    (function-item posframe-poshandler-window-top-left-corner)
    (function-item posframe-poshandler-window-top-right-corner)
    (function-item posframe-poshandler-window-bottom-center)
    (function-item posframe-poshandler-window-bottom-left-corner)
    (function-item posframe-poshandler-window-bottom-right-corner)
    (function-item posframe-poshandler-point-top-left-corner)
    (function-item posframe-poshandler-point-bottom-left-corner)
    (function-item posframe-poshandler-point-bottom-left-corner-upward)
    (function-item posframe-poshandler-point-window-center)
    (function-item posframe-poshandler-point-frame-center)
    (function :tag "Custom Handler"))
  "Customize type for posframe handler variables.")

(defgroup org-popup-posframe nil
  "Show org mode popup buffers in posframe."
  :group 'org-popup-posframe
  :prefix "org-popup-posframe")

(defcustom org-popup-posframe-org-attach t
  "Show `org-attach' buffer in posframe."
  :type 'boolean)

(defcustom org-popup-posframe-org-capture t
  "Show `org-capture' buffer in posframe."
  :type 'boolean)

(defcustom org-popup-posframe-org-export-dispatch t
  "Show `org-export-dispatch' buffer in posframe."
  :type 'boolean)

(defcustom org-popup-posframe-org-insert-link t
  "Show `org-insert-link' buffer in posframe."
  :type 'boolean)

(defcustom org-popup-posframe-org-insert-structure-template t
  "Show `org-insert-structure-template' buffer in posframe."
  :type 'boolean)

(defcustom org-popup-posframe-org-set-tags-command t
  "Show `org-set-tags-command' buffer in posframe."
  :type 'boolean)

(defcustom org-popup-posframe-org-todo t
  "Show `org-todo' buffer in posframe."
  :type 'boolean)


(defcustom org-popup-posframe-font nil
  "The font used by org-popup-posframe."
  :type 'string)

(defcustom org-popup-posframe-org-attach-poshandler
  #'posframe-poshandler-window-bottom-right-corner
  "The posframe poshandler of `org-attach'."
  :type org-popup-posframe-handler-customize-type)

(defcustom org-popup-posframe-org-export-dispatch-poshandler
  #'posframe-poshandler-window-bottom-right-corner
  "The posframe poshandler of `org-export-dispatch'."
  :type org-popup-posframe-handler-customize-type)

(defcustom org-popup-posframe-org-capture-poshandler
  #'posframe-poshandler-window-bottom-right-corner
  "The posframe poshandler of org-insert."
  :type org-popup-posframe-handler-customize-type)

(defcustom org-popup-posframe-org-insert-link-poshandler
  #'posframe-poshandler-window-bottom-right-corner
  "The posframe poshandler of `org-insert-structure-template'."
  :type org-popup-posframe-handler-customize-type)

(defcustom org-popup-posframe-org-insert-structure-template-poshandler
  #'posframe-poshandler-point-1
  "The posframe poshandler of `org-insert-structure-template'."
  :type org-popup-posframe-handler-customize-type)

(defcustom org-popup-posframe-org-todo-poshandler
  #'posframe-poshandler-point-1
  "The posframe poshandler of `org-todo'."
  :type org-popup-posframe-handler-customize-type)

(defcustom org-popup-posframe-org-set-tags-command-poshandler
  #'posframe-poshandler-point-1
  "The posframe poshandler of `org-set-tags-command'."
  :type org-popup-posframe-handler-customize-type)

(defcustom org-popup-posframe-min-width 0
  "The width of org-popup-min-posframe."
  :type 'number)

(defcustom org-popup-posframe-min-height 0
  "The height of org-popup-min-posframe."
  :type 'number)

(defcustom org-popup-posframe-border-width 1
  "The border width used by org-popup-posframe.
When 0, no border is showed."
  :type 'number)

(defcustom org-popup-posframe-parameters nil
  "The frame parameters used by org-popup-posframe."
  :type 'string)

(defface org-popup-posframe
  '((t (:inherit default)))
  "Face used by the org-popup-posframe.")

(defface org-popup-posframe-border
  '((t (:inherit default :background "gray50")))
  "Face used by the org-popup-posframe's border.")



;;;; Functions

(defun org-popup-posframe--show-buffer (buffer poshandler)
  "Show BUFFER in a posframe, use POSHANDLER to handle it."
  (when (posframe-workable-p)
    (posframe-show buffer
		   :position (point)
		   :poshandler poshandler
		   :font org-popup-posframe-font
		   :background-color (face-attribute 'org-popup-posframe :background nil t)
		   :foreground-color (face-attribute 'org-popup-posframe :foreground nil t)
		   :min-width org-popup-posframe-min-width
		   :min-height org-popup-posframe-min-height
		   :internal-border-width org-popup-posframe-border-width
		   :internal-border-color (face-attribute 'org-popup-posframe-border :background nil t)
		   :override-parameters org-popup-posframe-parameters)))


(defun org-popup-posframe--org-attach-advice (func)
  "Posframe-enabling advice for `org-attach' (FUNC)."
  (let ((original-buffer (current-buffer))
        (buffer (get-buffer-create "*Org Attach*")))
    (unwind-protect
        (cl-letf (;; set buffer to "*Org Attach*"
                  ((symbol-function 'switch-to-buffer-other-window) #'set-buffer)
                  ((symbol-function 'org-fit-window-to-buffer)
                   (lambda (a)
                     (ignore a)
                     ;; set buffer back
                     (set-buffer original-buffer)
                     ;; posframe show
                     (org-popup-posframe--show-buffer
                      buffer
                      org-popup-posframe-org-attach-poshandler))))
          (funcall-interactively func))
      (kill-buffer buffer))))


(defun org-popup-posframe--org-export--dispatch-ui-advice (func options first-key expertp)
  (let ((buffer (get-buffer-create "*Org Export Dispatcher*")))
    (cl-letf (((symbol-function 'org-fit-window-to-buffer)
               (lambda ()
                 ;; posframe show
                 (org-popup-posframe--show-buffer
                  buffer
                  org-popup-posframe-org-export-dispatch-poshandler))))
      (funcall-interactively func options first-key expertp))))


(defvar org-popup-posframe--org-mks-poshandler nil)
(defun org-popup-posframe--org-mks-advice (func table title &optional prompt specials)
  (let ((original-buffer (current-buffer))
        (buffer (get-buffer-create "*Org Select*")))
    (cl-letf (;; set buffer to "*Org Select*"
              ((symbol-function 'switch-to-buffer-other-window) #'set-buffer)
              ((symbol-function 'org-fit-window-to-buffer)
               (lambda ()
                 ;; set buffer back
                 (set-buffer original-buffer)
                 ;; posframe show
                 (org-popup-posframe--show-buffer
                  buffer
                  org-popup-posframe--org-mks-poshandler))))
      (funcall-interactively func table title prompt specials))))


(defun org-popup-posframe--org-capture-advice (func &optional goto keys)
  (setq org-popup-posframe--org-mks-poshandler
        org-popup-posframe-org-capture-poshandler)
  (advice-add 'org-mks :around
              #'org-popup-posframe--org-mks-advice)
  (unwind-protect
      (funcall-interactively func goto keys)
    (advice-remove 'org-mks
                 #'org-popup-posframe--org-mks-advice)))


(defun org-popup-posframe--org-insert-structure-template-mks-advice (func)
  (setq org-popup-posframe--org-mks-poshandler
        org-popup-posframe-org-insert-structure-template-poshandler)
  (advice-add 'org-mks :around
              #'org-popup-posframe--org-mks-advice)
  (unwind-protect
      (funcall-interactively func)
    (advice-remove 'org-mks
                   #'org-popup-posframe--org-mks-advice)))

(defun org-popup-posframe--org-fast-tag-selection-advice
    (func current-tags inherited-tags tag-table &optional todo-table)
  ;; TODO: simplier implementation
  (let ((original-buffer (current-buffer))
        (buffer (get-buffer-create " *Org tags*")))
    (fset 'original-set-window-buffer (symbol-function 'set-window-buffer))
    (unwind-protect
        (cl-letf* (((symbol-function 'delete-other-windows) #'ignore)
                   ((symbol-function 'split-window-vertically) #'ignore)
                   ((symbol-function 'set-window-buffer) #'ignore)
                   ;; set buffer to " *Org tags*"
                   ((symbol-function 'switch-to-buffer-other-window) #'set-buffer)
                   ((symbol-function 'org-fit-window-to-buffer)
                    (lambda ()
                      ;; set buffer back
                      (set-buffer original-buffer)
                      (cl-letf (((symbol-function 'set-window-buffer)
                                 ;; avoid set-window-buffer redefinition
                                 #'original-set-window-buffer))
                        ;; posframe show
                        (org-popup-posframe--show-buffer
                         buffer
                         org-popup-posframe-org-todo-poshandler))
                      ;; set buffer back to " *Org tags*"
                      ;; so org-fast-tag-insert can work
                      (set-buffer buffer))))
          (funcall-interactively func
                                 current-tags inherited-tags tag-table todo-table))
      (when buffer (kill-buffer buffer)))))


(defun org-popup-posframe--org-fast-todo-selection-advice (func &optional current-todo-keyword)
  ;; TODO: simplier implementation
  (let ((original-buffer (current-buffer))
        (buffer (get-buffer-create " *Org todo*")))
    (fset 'original-set-window-buffer (symbol-function 'set-window-buffer))
    (unwind-protect
        (cl-letf* (((symbol-function 'delete-other-windows) #'ignore)
                   ((symbol-function 'split-window-vertically) #'ignore)
                   ((symbol-function 'set-window-buffer) #'ignore)
                   ;; set buffer to " *Org todo*"
                   ((symbol-function 'switch-to-buffer-other-window) #'set-buffer)
                   ((symbol-function 'org-fit-window-to-buffer)
                    (lambda ()
                      ;; set buffer back
                      (set-buffer original-buffer)
                      (cl-letf (((symbol-function 'set-window-buffer)
                                 ;; avoid set-window-buffer redefinition
                                 #'original-set-window-buffer))
                        ;; posframe show
                        (org-popup-posframe--show-buffer
                         buffer
                         org-popup-posframe-org-todo-poshandler)))))
          (funcall-interactively func current-todo-keyword))
      (when buffer (kill-buffer buffer)))))


(defun org-popup-posframe--org-insert-link-advice
    (func &optional COMPLETE-FILE LINK-LOCATION DESCRIPTION)
  (let ((buffer (get-buffer-create "*Org Links*")))
    (cl-letf (((symbol-function 'switch-to-buffer-other-window) #'ignore)
              ((symbol-function 'org-format-prompt)
               (lambda (PROMPT DEFAULT &rest FORMAT-ARGS)
                 (org-popup-posframe--show-buffer
                  buffer
                  org-popup-posframe-org-insert-link-poshandler)
                 (format-prompt PROMPT DEFAULT FORMAT-ARGS))))
      (funcall func COMPLETE-FILE LINK-LOCATION DESCRIPTION))))


;;;###autoload
(define-minor-mode org-popup-posframe-mode
  "Show `org-mode' popup buffers in posframe."
  :group 'org-popup-posframe
  :global t
  :lighter nil
  (if org-popup-posframe-mode
      (progn
        (if org-popup-posframe-org-attach
            (advice-add 'org-attach :around
                        #'org-popup-posframe--org-attach-advice))
        (if org-popup-posframe-org-capture
            (advice-add 'org-capture :around
                        #'org-popup-posframe--org-capture-advice))
        (if org-popup-posframe-org-export-dispatch
            (advice-add 'org-export--dispatch-ui :around
                        #'org-popup-posframe--org-export--dispatch-ui-advice))
        (if org-popup-posframe-org-insert-structure-template
            (advice-add 'org--insert-structure-template-mks :around
                        #'org-popup-posframe--org-insert-structure-template-mks-advice))
        (if org-popup-posframe-org-set-tags-command
            (advice-add 'org-fast-tag-selection :around
                        #'org-popup-posframe--org-fast-tag-selection-advice))
        (if org-popup-posframe-org-todo
            (advice-add 'org-fast-todo-selection :around
                        #'org-popup-posframe--org-fast-todo-selection-advice))
        (if org-popup-posframe-org-insert-link
            (advice-add 'org-insert-link :around
                        #'org-popup-posframe--org-insert-link-advice)))
    (advice-remove 'org-attach
                   #'org-popup-posframe--org-attach-advice)
    (advice-remove 'org-capture
                   #'org-popup-posframe--org-capture-advice)
    (advice-remove 'org-export--dispatch-ui
                   #'org-popup-posframe--org-export--dispatch-ui-advice)
    (advice-remove 'org--insert-structure-template-mks
                   #'org-popup-posframe--org-insert-structure-template-mks-advice)
    (advice-remove 'org-fast-todo-selection
                   #'org-popup-posframe--org-fast-todo-selection-advice)
    (advice-remove 'org-insert-link
                   #'org-popup-posframe--org-insert-link-advice)))

(provide 'org-popup-posframe)

;; Local Variables:
;; coding: utf-8-unix
;; End:

;;; org-popup-posframe.el ends here
