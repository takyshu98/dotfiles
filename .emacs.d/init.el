;;;;
;;;; @flie  ~/.emacs.d/init.el
;;;; @brief GNU Emacs configuration file (for version 24.5+)
;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 環境変数の設定
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; 文字コードの設定
(set-language-environment "Japanese")
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-buffer-file-coding-system 'utf-8)

;; Mac OS Xの場合のファイル名の設定
(when (eq system-type 'darwin)
  (require 'ucs-normalize)
  (set-file-name-coding-system 'utf-8-hfs)
  (setq locale-coding-system 'utf-8-hfs))

;; Windowsの場合のファイル名の設定
(when (eq window-system 'w32)
  (set-file-name-coding-system 'cp932)
    (setq locale-coding-system 'cp932))

;; Emacs 23より前のバージョンを利用する場合は
;; user-emacs-directory変数が未定義のため次の設定を追加
(when (< emacs-major-version 23)
  (defvar user-emacs-directory "~/.emacs.d/"))

;; load-path を追加する関数を定義
(defun add-to-load-path (&rest paths)
  (let (path)
    (dolist (path paths paths)
      (let ((default-directory
	      (expand-file-name (concat user-emacs-directory path))))
	(add-to-list 'load-path default-directory)
	(if (fboundp 'normal-top-level-add-subdirs-to-load-path)
	    (normal-top-level-add-subdirs-to-load-path))))))

;; 引数のディレクトリとそのサブディレクトリをload-pathに追加
(add-to-load-path "elisp" "conf")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; フレームに関する設定
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ターミナル以外はツールバー、スクロールバーを非表示
(when window-system
  ;; tool-barを非表示
  (tool-bar-mode 0)
  ;; scroll-barを非表示
  (scroll-bar-mode 0))

;; CocoaEmacs以外はメニューバーを非表示
(unless (eq window-system 'ns)
  ;; menu-barを非表示
    (menu-bar-mode 0))

;; タイトルバーにファイルのフルパスを表示
(setq frame-title-format "%f")

;; モードラインに列番号を表示
(column-number-mode t)
;; モードラインにファイルサイズを表示
(size-indication-mode t)
;; モードラインにリージョン内の行数と文字数をモードラインに表示する（範囲指定時のみ）
;; http://d.hatena.ne.jp/sonota88/20110224/1298557375
(defun count-lines-and-chars ()
    (if mark-active
        (format "%d lines,%d chars "
            (count-lines (region-beginning) (region-end))
                (- (region-end) (region-beginning)))
	;; これだとエコーエリアがチラつく
	;;(count-lines-region (region-beginning) (region-end))
      ""))

(add-to-list 'default-mode-line-format
   '(:eval (count-lines-and-chars)))

;; バッファに行番号を常に表示する
(global-linum-mode t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 表示・装飾の設定
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; 表示テーマの設定
;; emacs-color-theme-solarized
;; https://github.com/sellout/emacs-color-theme-solarized#all-versions
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/emacs-color-theme-solarized")
(load-theme 'solarized t)
(set-frame-parameter nil 'background-mode 'dark)
(set-terminal-parameter nil 'background-mode 'dark)
(enable-theme 'solarized)

;; バッファの行番号の表示形式
(setq linum-format "%4d ")

;; 対応する括弧を表示させる
;; (show-paren-mode 1)

;; カーソル行をハイライト
(require 'hl-line)
;;; hl-lineを無効にするメジャーモードを指定する
(defvar global-hl-line-timer-exclude-modes '(todotxt-mode))
(defun global-hl-line-timer-function ()
  (unless (memq major-mode global-hl-line-timer-exclude-modes)
    (global-hl-line-unhighlight-all)
    (let ((global-hl-line-mode t))
      (global-hl-line-highlight))))
(setq global-hl-line-timer
      (run-with-idle-timer 0.03 t 'global-hl-line-timer-function))
;; (cancel-timer global-hl-line-timer)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 起動・終了・復元の設定
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; inhibit loading "default.el" at startup
(setq inhibit-default-init t)
;; 起動メッセージを非表示
(setq inhibit-startup-screen t)

;; 終了時に自動保存ファイルを削除
(setq delete-auto-save-files t)

;; バックアップファイルの作成を抑止
(setq backup-inhibited nil)
;; オートセーブファイルの作成を抑止
(setq auto-save-default nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 編集の設定
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; バッファ末尾に余計な改行コードを防ぐ
(setq next-line-add-newlines nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; キーバインドの設定
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; 応答入力文字を省略
(defalias 'yes-or-no-p 'y-or-n-p)

;; スクロールの移動ポイントを先頭・末尾まで許可
(setq scroll-error-top-bottom t)

;; C-hを<backspace>として利用する
(define-key global-map (kbd "C-h") 'backward-delete-char)
(define-key global-map (kbd "C-\\") 'ignore)

;; 折り返しトグルコマンド
(define-key global-map (kbd "C-c l") 'toggle-truncate-lines)

;; ¥の代わりに\を入力
(global-set-key [?¥] [?\\])

;; C-tでウィンドウを切り替える
;; 初期値はtranspose-chars
(define-key global-map (kbd "C-t") 'other-window)

;; C-kを行削除に切り替える
;(define-key global-map (kbd "C-k") ' kill-whole-line)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; パッケージ管理
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'package)
;; パッケージの配置先を任意の場所へ変更
(setq package-user-dir "~/share/dotfiles/.emacs.d/elisp")
;; MELPAを追加
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; MELPA-stableを追加
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
;; Marmaladeを追加
;; (add-to-list 'package-archives  '("marmalade" . "http://marmalade-repo.org/packages/") t)
;; Orgを追加
;; (add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)
;; 初期化
(package-initialize)

;; 導入パッケージ群
(package-install 'auto-complete)
;;(package-install 'color-theme-sanityinc-solarized)
(package-install 'sequential-command)
(package-install 'smooth-scroll)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; auto-complete
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require `auto-complete-config)
(global-auto-complete-mode 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Gauche-mode (Lisp/Scheme)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq process-coding-system-alist
      (cons '("gosh" utf-8 . utf-8) process-coding-system-alist))
(setq scheme-program-name "/usr/local/bin/gosh -i")

(autoload 'scheme-mode "cmuscheme" "Major mode for Scheme." t)
(autoload 'run-scheme "cmuscheme" "Run an inferior Scheme process." t)

(defun scheme-other-window ()
  "Run Gauche on other window"
  (interactive)
  (split-window-horizontally (/ (frame-width) 2))
  (let ((buf-name (buffer-name (current-buffer))))
    (scheme-mode)
    (switch-to-buffer-other-window
     (get-buffer-create "*scheme*"))
    (run-scheme scheme-program-name)
    (switch-to-buffer-other-window
     (get-buffer-create buf-name))))

(define-key global-map (kbd "C-c G") 'scheme-other-window)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; rainbow-delimiters
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'rainbow-delimiters)
(add-hook 'prog-mode-hook 'rainbow-delimiters-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; sequential-command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; 同じコマンドを連続実行した時の振舞いを変更する
;; ex) C-a C-a で先頭へ
;;     C-e C-e で末尾へ
(require `sequential-command-config)
(sequential-command-setup-keys)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; smooth-scroll
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'smooth-scroll)
(smooth-scroll-mode t)
;; 縦方向のスクロール行数を変更する。
(setq smooth-scroll/vscroll-step-size 4)
;; 横方向のスクロール行数を変更する。
(setq smooth-scroll/hscroll-step-size 4)

