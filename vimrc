" Remap a few keys for Windows behavior
source $VIMRUNTIME/mswin.vim
behave mswin

" Mouse behavior
set mouse=a

" Persist global variables whose names are all caps
set viminfo=!,'100,<50,s10,h,rA:,rB:

" run command script
runtime runcmd.vim

" --- Settings ---
"  Line numbers
set number
" Enable full gui colors in terminal
set termguicolors
" Split below by default
set splitbelow
" backspace over everything
set backspace=indent,eol,start
" search highlighting
set incsearch
set hlsearch

augroup new_window_autocfg
    " on startup - hack to fix weird resizing in CMD
    "    Problem occurs if you run vim from fullscreened CMD
    if has('win32') && &term ==# 'win32'
        autocmd GUIEnter * simalt \<CR>
    endif
    " No line numbers in (terminal inside vim)
    if has('nvim')
        autocmd TermOpen * setlocal nonumber norelativenumber
    else
        autocmd TerminalOpen * setlocal nonumber norelativenumber
    endif
    " make help windows open vertically
    autocmd FileType help wincmd L
augroup END

" tab key => 4 spaces
set expandtab
set tabstop=4
set shiftwidth=4
retab
" Syntax highlighting
syntax enable
filetype plugin indent on " needed by Rust syntax highlighting
" Default latex type (see :help tex_flavor)
let g:tex_flavor = "latex"



" --- Persist light/dark and colorscheme ---

augroup persistcolors
    " load on vim startup
    autocmd VimEnter * silent let &background=g:BACKGROUND
    autocmd VimEnter * silent execute "colorscheme " . g:COLORSCHEME_NAME
    " save on exit
    autocmd VimLeavePre * let g:BACKGROUND=&background
    autocmd VimLeavePre * let g:COLORSCHEME_NAME = g:colors_name
augroup END

" --- Visual Settings ---
augroup visual_cfg_after_colorschemes
    "  Less italics (overriding colorscheme)
    autocmd VimEnter * hi Number cterm=NONE gui=NONE
    " Constant is linked to string, boolean, etc literals
    autocmd VimEnter * hi Constant cterm=NONE gui=NONE
augroup END


" statusline script
"   Note that this should be loaded AFTER setting the colorscheme, as it needs to setup
"   colors based on the colorscheme
runtime statusline.vim



" --- Commands ---
" Theme Commands
command Dark :set bg=dark
command Light :set bg=light

" cd Here Shortcut
command Here :cd %:p:h

" terminal
" -nargs=* => any # of args
" command -nargs=* T :sp res 15 term <args>
" -complete=file_in_path => tab autocompletion type
command -nargs=* -complete=file_in_path T :term <args>

" Clear search
command CL :let @/=""

" Quick make/load session
command MS :mks! ~\session.vim
command LS :source ~\session.vim

" Autorun
command P :call Autorun()



" --- Shortcuts ---
"  Terminal : Shift+Esc => NORMAL mode (like outside of terminal)
":tnoremap <S-Esc> <C-w><C-S-n>



" --- Plugins ---

"  -- Vim-Plug --
call plug#begin()

" -- language support --
" Rust syntax highlighting
Plug 'rust-lang/rust.vim'

" -- Themes --
Plug 'drewtempelmeyer/palenight.vim'

call plug#end()

" --- Templates ---
" Templates for new files. Make sure the template files exist!
let templatedir=$HOME."\\vimfiles\\templates"
augroup templates
    autocmd BufNewFile *.* call LoadTemplate(templatedir)
augroup END

" modified from https://vim.fandom.com/wiki/Use_eval_to_create_dynamic_templates
function LoadTemplate(template_dir)
    " the template file for the current file's extension type
    let template = a:template_dir."/template\.".expand("%:e")
    if filereadable(template)
        silent execute "0r ".template
        " have vim evaluate anything in [VIM_EVAL] ... [END_EVAL]
        %substitute#\[VIM_EVAL\]\(.\{-\}\)\[END_EVAL\]#\=eval(submatch(1))#ge
        "^ In the entire file...                        ^ replace with: eval(...)
        "           ^  pattern to replace, contained between delimeter #
    endif
endfunction

" ----- FROM DEFAULT VIMRC: diff function -----

" Use the internal diff if available.
" Otherwise use the special 'diffexpr' for Windows.
if &diffopt !~# 'internal'
  set diffexpr=MyDiff()
endif
function MyDiff()
  let opt = '-a --binary '
  if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
  if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
  let arg1 = v:fname_in
  if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
  let arg1 = substitute(arg1, '!', '\!', 'g')
  let arg2 = v:fname_new
  if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
  let arg2 = substitute(arg2, '!', '\!', 'g')
  let arg3 = v:fname_out
  if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
  let arg3 = substitute(arg3, '!', '\!', 'g')
  if $VIMRUNTIME =~ ' '
    if &sh =~ '\<cmd'
      if empty(&shellxquote)
        let l:shxq_sav = ''
        set shellxquote&
      endif
      let cmd = '"' . $VIMRUNTIME . '\diff"'
    else
      let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
    endif
  else
    let cmd = $VIMRUNTIME . '\diff'
  endif
  let cmd = substitute(cmd, '!', '\!', 'g')
  silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3
  if exists('l:shxq_sav')
    let &shellxquote=l:shxq_sav
  endif
endfunction
