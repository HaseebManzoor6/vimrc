" Remap a few keys for Windows behavior
source $VIMRUNTIME/mswin.vim
behave mswin

" Mouse behavior
set mouse=a

" Persist global variables whose names are all caps
set viminfo=!,'100,<50,s10,h,rA:,rB:

" --- Settings ---
"  Line numbers
set number
" Enable full gui colors in terminal
set termguicolors
" Split below by default
set splitbelow

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
    autocmd VimEnter * let &background=g:BACKGROUND
    autocmd VimEnter * execute "colorscheme " . g:COLORSCHEME_NAME
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

" -- Custom --
"source C:\Users\hasee\AppData\Local\nvim\scripts\snippetst.vim



" --- Functions ---

" -- Statusline Function --
function UpdateStatusline()
    " colors:
    " Try to grab from colorscheme, in file
    " autoload/myStatusLine/colorscheme.vim
    execute "call myStatusLine#".g:colors_name."#SetColors()"
    " Default to monochrome black/white if not given by colorscheme
    "   Use autoload to provide them.
    if hlID("StatusName") == 0 " if color doesnt exist
        hi StatusName guifg=#000000 guibg=#FFFFFF
    endif
    if hlID("StatusBar") == 0
        hi StatusBar guifg=#FFFFFF guibg=#000000
    endif
    if hlID("StatusType") == 0
        hi StatusType guifg=#000000 guibg=#AAAAAA
    endif

    "let fg1=synIDattr(synIDtrans(hlID("StatusLine")),"fg")
    "let bg1=synIDattr(synIDtrans(hlID("StatusLine")),"bg")
    "execute "hi Status1 guifg=".bg1." guibg=".fg1

    " Statusline
    " color
    set statusline=%#StatusName#\ 
    " filename
    set statusline+=%t\ 
    " color
    set statusline+=%#StatusType#
    " filetype
    set statusline+=\ %Y\ 
    " color
    set statusline+=%#StatusBar#
    " left align..
    set statusline+=\ \%=
    " [row%,col]
    set statusline+=\[\%p\%%\,\%c\]\ 
    " line count
    set statusline+=%L\ Lines\ 

    " make always visible
    set laststatus=2
endfunction

" -- Autorun Script :P --
function Autorun()
	let ft=&filetype

	" ==# is Case-sensitive compare. == behavior can be changed, keep things explicit.
	if ft ==# 'python'
		w
		T py %
	elseif ft ==# 'html'
		w
		!"C:\Program Files\Mozilla Firefox\firefox.exe" %:p
	elseif ft ==# 'cpp' || ft ==# 'c' || ft ==# 'make'
		w
		T "mingw32-make.exe"
	elseif ft ==# 'dosbatch'
        w
        !%
    elseif ft ==# 'rust'
        w
        T cargo run
    elseif ft ==# 'plaintex' || ft ==# 'tex'
        w
        !pdflatex %:p
        execute "!" . expand("%:p:r") . ".pdf"
    else
        echo "You didn't write a script for this filetype :("
	endif
endfunction



" --- Templates ---
" Templates for new files. Make sure the template files exist!
let templatedir = "C:/Users/hasee/AppData/Local/nvim/templates"
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
