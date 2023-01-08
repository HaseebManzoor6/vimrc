function myStatusLine#gruvbox#SetColors()
    if &bg ==# 'dark'
        hi StatusName guibg=#fb4934 guifg=bg
        hi StatusType guibg=#fabd2f guifg=bg
        hi StatusBar guibg=#3c3836 guifg=#fbf1c7
    elseif &bg ==# 'light'
        hi StatusName guibg=#fb4934 guifg=bg
        hi StatusType guibg=#c57614 guifg=bg
        hi StatusBar guibg=#ebdbb2 guifg=#282828
    endif
endfunction
