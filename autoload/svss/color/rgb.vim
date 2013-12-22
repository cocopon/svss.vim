" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! svss#color#rgb#to_rgb(comps)
	return a:comps
endfunction


function! svss#color#rgb#from_rgb(comps)
	return a:comps
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
