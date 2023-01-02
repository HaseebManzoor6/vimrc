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
