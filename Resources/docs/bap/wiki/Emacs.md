Setting up Emacs
===============

There is a new initiative in the community -- `user-setup` package, I
personally didn't try it, but on a first glance it looks pretty nice
and prominent. You can try it yourself on your risk, and actually I'm
encouraging everyone to do this, but here I will share my setup, as it
is what I've tested personally. But, maybe later we will rewrite this 
page to `user-setup`.

## Dependencies

Our setup will depend on three packages:
* Tuareg - major mode for editing OCaml source code;
* Merlin - Tuareg minor mode that adds incremental compilation,
intellisense-like completion, and other neat stuff;
* ocp-indent - external indentation program that knows OCaml very well
  in comparison with the default tuaregs indentation engine that is
  just a set of regular expressions.

To install them from OPAM use:

```shell
opam install tuareg merlin ocp-indent
```

You will also need `auto-complete` mode for EMacs, available in elpa
and melpa. To enable this (and also marmalade) you need the following
at the start of your `.emacs`:

```lisp
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")
                         ("melpa" . "http://melpa.milkbox.net/packages/")))
(package-initialize)
```

After this issue `M-x package-list-packages` and find out
`company` package with the latest version, and install it.

## Main configuration file

After everything is ready, you can store the following in `ocaml.el`,
put it into your emacs search path, and load in `.emacs` with
`(require 'ocaml)` instruction. (Of course, you can just copy-paste
this directly into your `.emacs`, but I prefer to keep it clean).

```lisp
(defun opam-path (path)
  (let ((opam-share-dir
         (shell-command-to-string
          "echo -n `opam var share`")))
    (concat opam-share-dir "/" path)))

(add-to-list 'load-path (opam-path "emacs/site-lisp"))

;; comment out the following two lines if you would like to use tuareg from melpa
(add-to-list 'load-path (opam-path "tuareg"))
(load "tuareg-site-file")

(require 'ocp-indent)
(require 'merlin)
(require 'company)
(add-to-list 'company-backends 'merlin-company-backend)
(add-hook 'merlin-mode-hook 'company-mode)

(define-key merlin-mode-map (kbd "C-c TAB") 'company-complete)
(define-key merlin-mode-map (kbd "C-c C-d") 'merlin-document)
(define-key merlin-mode-map (kbd "C-c d") 'merlin-destruct)


(setq merlin-completion-with-doc t)
(setq merlin-use-auto-complete-mode nil)
(setq tuareg-font-lock-symbols t)
(setq merlin-command 'opam)
(setq merlin-locate-preference 'mli)

(defun change-symbol (x y)
  (setcdr (assq x tuareg-font-lock-symbols-alist) y))

(defun ocp-indent-buffer ()
  (interactive)
  (save-excursion
    (mark-whole-buffer)
    (ocp-indent-region (region-beginning)
                       (region-end))))

(add-hook 'tuareg-mode-hook
          (lambda ()
            (merlin-mode)
            (local-set-key (kbd "C-c c") 'recompile)
            (local-set-key (kbd "C-c C-c") 'recompile)
            (auto-fill-mode)
            (tuareg-make-indentation-regexps)
            (add-hook 'before-save-hook 'ocp-indent-buffer nil t)))

(defun opam-env ()
  (interactive nil)
  (dolist (var
           (car (read-from-string
                 (shell-command-to-string "opam env --sexp"))))
    (setenv (car var) (cadr var))))

(provide 'ocaml)
```

## Configuring Merlin

Merlin should work out of box, but it only knows vanilla OCaml by
default. So, we need to teach him to use BAP and Core_kernel. Merlin
is pretty clever, so it won't take to much time, you just need to
create `.merlin` file in the project root, and describe what libraries are you using and
how you structured your project. Something like this should work:

```
PKG core_kernel
PKG bap
PKG ocamlgraph

B _build
FLG -short-paths
FLG -w -4-33-40-41-42-43-34-44
```

Note that Merlin is already configured for `bap-plugins` and `bap` repositories.
If your're working in this repositories and you want to add some options to your 
subproject, like adding new package or flag, then create a `.merlin` file in your
folder and add `REC` line into it, this will automatically include parent `.merlin`,
e.g.,

```
REC
PKG cmdliner
```

Sometimes Merlin gets very confused, especially when after you've made 
`opam update`. In that case it can be healed by killing him and
starting from scratch with `M-x merlin-restart-process` command.

## Extras

### Using Helm

If you prefer helm then the following three lines will greatly improve your experience with OCaml,
```
(add-hook 'merlin-mode-hook 'merlin-use-merlin-imenu)

(define-key merlin-mode-map (kbd "C-c TAB") 'helm-company)
(define-key merlin-mode-map (kbd "C-c i") 'helm-imenu)
(define-key merlin-mode-map (kbd "C-c I") 'helm-imenu-in-all-buffers)
```

Also, for project-wise search and file opening, which is OCaml-specific, so it is good to place it in your .emacs file, you can add the following,
```
(global-set-key (kbd "C-x b") 'helm-buffers-list)
(global-set-key (kbd "C-x p") 'helm-browse-project)
(global-set-key (kbd "C-x l") 'helm-grep-do-git-grep)
(global-set-key (kbd "C-x a") 'helm-do-grep-ag)
```

The last one requires the `ag`, which could be installed with `sudo apt install silversearcher-ag` on an Ubuntu machine. 

## Setting the project directory

To make the bap root folder (or any other project root folder) the default folder, so that different search and file opening functions will start from the top of your project, add the `.dir-locals.el` file to the root of BAP, with the following contents,
```
((nil . ((default-directory . "<path-to-the-root>"))))
```

The path to the root has to be absolute, e.g., `"~/bap"` and be a literal string, otherwise emacs will complain about unsafe variables. 
