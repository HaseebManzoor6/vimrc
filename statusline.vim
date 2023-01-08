" -- Statusline Function --

" set always visible
set laststatus=2

augroup statusline_setup
    autocmd VimEnter,ColorScheme * call GetSLColors()
    if has('nvim')
        autocmd BufEnter,TermOpen,WinEnter * call SetSL()
    else
        autocmd BufEnter,TerminalOpen,WinEnter * call SetSL()
    endif
    autocmd WinLeave * call SetSLInactive()
augroup END

" StatusLine display for search pattern
function SearchDisplay()
    if @/==""
        return ""
    endif
    let sc = searchcount()
    return "/".@/." (".sc["current"]."/".sc["total"].") "
endfunction

function GetSLColors()
    " colors:
    " Default to monochrome black/white
    hi StatusName guifg=#000000 guibg=#FFFFFF
    hi StatusBar guifg=#FFFFFF guibg=#000000
    hi StatusType guifg=#000000 guibg=#AAAAAA
    " Try to grab from colorscheme, in file autoload/myStatusLine/colorscheme.vim
    " load file and check if function exists first
    execute 'runtime autoload/myStatusLine/'.g:colors_name.'.vim'
    if exists('*myStatusLine#'.g:colors_name.'#SetColors')
        execute 'call myStatusLine#'.g:colors_name.'#SetColors()'
    endif
endfunction

function SetSL()
    if &buftype ==# 'terminal'
        call SetSLTerminal()
    else
        call SetSLFile()
    endif
endfunction

function SetSLInactive()
    if &buftype ==# 'terminal'
        call SetSLTerminalInactive()
    else
        call SetSLFileInactive()
    endif
endfunction

function SetSLFile()
    " Statusline
    " color
    setlocal statusline=%#StatusName#\ 
    " filename
    setlocal statusline+=%t\ 
    " color
    setlocal statusline+=%#StatusType#
    " filetype
    setlocal statusline+=\ %Y\ 
    " color
    setlocal statusline+=%#StatusBar#
    " left align..
    setlocal statusline+=\ \%=
    " search query
    setlocal statusline+=%{SearchDisplay()}
    " [row%,col]
    setlocal statusline+=\[\%p\%%\,\%c\]\ 
    " line count
    setlocal statusline+=%L\ Lines\ 
endfunction


function SetSLFileInactive()
    " Statusline
    " color
    setlocal statusline=%#StatusLineNC#\ 
    " filename
    setlocal statusline+=%t\ 
    " filetype
    setlocal statusline+=\ %Y\ 
    " left align..
    setlocal statusline+=\ \%=
    " [row%,col]
    setlocal statusline+=\[\%p\%%\,\%c\]\ 
    " line count
    setlocal statusline+=%L\ Lines\ 
endfunction

function SetSLTerminal()
    " color
    setlocal statusline=%#StatusName#\ 
    " filename
    setlocal statusline+=%t\ 
    " left align...
    setlocal statusline+=%=
    " search query
    setlocal statusline+=%{SearchDisplay()}
endfunction

function SetSLTerminalInactive()
    " color
    setlocal statusline=%#StatusLineNC#\ 
    " filename
    setlocal statusline+=%t\ 
endfunction
