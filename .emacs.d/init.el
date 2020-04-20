;;; init.el --- Koekelas' Emacs configuration -*- lexical-binding: t; -*-

;;; Commentary:

;; Koekelas' Emacs configuration.

;;; Code:

;;; Garbage collector
;; Increasing cons threshold makes garbage collection more efficient
;; and decreasing it makes garbage collection less noticeable, i.e.,
;; cons threshold is a tradeoff between the runtime of the garbage
;; collector and the responsiveness of Emacs. Increase cons threshold
;; during initialization.
(setq gc-cons-threshold (* (expt 1024 2) 128)) ; In bytes
;; Once initialized, gcmh kicks in

;;; nsm - Network security manager
(require 'nsm)

(setq network-security-level 'high)

;;; package - Package manager
(require 'package)

(defun koek-pkg/ensure (package-name)
  "Ensure package PACKAGE-NAME is installed.
PACKAGE-NAME is a symbol."
  (unless (package-installed-p package-name)
    (package-install package-name)))

(let ((archives '(("gnu"   . "https://elpa.gnu.org/packages/")
                  ("melpa" . "https://melpa.org/packages/")
                  ("org"   . "https://orgmode.org/elpa/"))))
  ;; HTTPS locations require GnuTLS to be available
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
(setq package-enable-at-startup nil)
(unless package-archive-contents
  (package-refresh-contents))

;;; no-littering - Normalize configuration and data paths packages
(koek-pkg/ensure 'no-littering)
(require 'no-littering)

;;; use-package - Package configuration macro
(koek-pkg/ensure 'use-package)
(koek-pkg/ensure 'delight)              ; Optional dependency

;;; org - Notes, to-do lists and project planning
;; Installing latest org after loading builtin org breaks org. Install
;; latest org before loading literate configuration.
(koek-pkg/ensure 'org-plus-contrib)
;; org is configured elsewhere

;;; cus-edit - Configuration interface
(setq custom-file (no-littering-expand-var-file-name "custom.el"))
(load custom-file 'no-error)

;;; Literate configuration
;; directory-files returns a sorted list, i.e., 00-*.org is loaded
;; before 10-*.org, 10-*.org before 20-*.org, etc.
(mapc #'org-babel-load-file
      (directory-files user-emacs-directory 'full (rx ".org" line-end)))

;;; init.el ends here
