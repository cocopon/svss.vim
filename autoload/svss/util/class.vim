" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! svss#util#class#setup_methods(instance, namespace, methods)
	for method in a:methods
		let a:instance[method] = function(join([a:namespace, method], '#'))
	endfor
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
