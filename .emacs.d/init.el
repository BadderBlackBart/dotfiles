;;; init.el --- Koekelas' Emacs configuration -*- lexical-binding: t; -*-

;;; Commentary:

;; Koekelas' Emacs configuration.

;;; Code:

;;; Garbage collector
;; Increasing cons threshold makes garbage collection more efficient,
;; decreasing it makes garbage collection less noticeable. Increase
;; cons threshold during initialization so Emacs starts fast.
(fset 'koek/reset-gc-cons-threshold
      (let ((cons-threshold gc-cons-threshold))
        (lambda ()
          "Reset `gc-cons-threshold' to its original value."
          (setq gc-cons-threshold cons-threshold))))

(declare-function koek/reset-gc-cons-threshold "init")

(setq gc-cons-threshold (* gc-cons-threshold 128))
(add-hook 'after-init-hook #'koek/reset-gc-cons-threshold)

;;; package - Package manager
(require 'package)

(defun koek-pkg/ensure (package-name)
  "Ensure package PACKAGE-NAME is installed.
PACKAGE-NAME is a symbol."
  (unless (package-installed-p package-name)
    (package-install package-name)))

(let ((archives
       '(("gnu"   . "https://elpa.gnu.org/packages/")
         ("melpa" . "https://melpa.org/packages/")
         ("org"   . "http://orgmode.org/elpa/"))))
  ;; HTTPS locations require GnuTLS
  (unless (gnutls-available-p)
    (setq archives
          (mapcar (pcase-lambda (`(,id . ,location))
                    (setq location
                          (replace-regexp-in-string (rx line-start "https")
                                                    "http" location))
                    (cons id location))
                  archives)))
  (setq package-archives archives))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;;; no-littering - Normalize configuration and data paths packages
(koek-pkg/ensure 'no-littering)
(require 'no-littering)

;;; use-package - Package configuration macro
(koek-pkg/ensure 'use-package)

;;; org - Notes, to-do lists and project planning
;; Installing latest org after loading builtin org breaks org. Install
;; latest org before loading literate configuration.
(koek-pkg/ensure 'org-plus-contrib)
;; org is configured elsewhere.

;;; cus-edit - Configuration interface
(setq custom-file (no-littering-expand-var-file-name "custom.el"))
(load custom-file 'no-error)

;;; Literate configuration
;; directory-files returns a sorted list so 00-*.org loads before
;; 10-*.org, 10-*.org before 20-*.org, 20-*.org before 30-*.org, etc.
(mapc #'org-babel-load-file
      (directory-files user-emacs-directory 'full "\\.org$"))

;;; init.el ends here
