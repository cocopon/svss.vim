" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! svss#decompiler#directive#name(directive) abort
	return s:decompile_single_value(a:directive)
endfunction


function! svss#decompiler#directive#background(directive) abort
	return s:decompile_single_value(a:directive)
endfunction


function! svss#decompiler#directive#maintainer(directive) abort
	return s:decompile_single_value(a:directive)
endfunction


function! svss#decompiler#directive#license(directive) abort
	return s:decompile_single_value(a:directive)
endfunction


function! svss#decompiler#directive#link(directive) abort
	let from = svss#decompiler#value(a:directive.argument(0))
	let to = svss#decompiler#value(a:directive.argument(1))
	return printf('@link %s to %s;',
				\ from,
				\ to)
endfunction


function! s:decompile_single_value(directive) abort
	return printf('@%s %s;',
				\ a:directive.name(),
				\ svss#decompiler#value(a:directive.argument(0)))
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
