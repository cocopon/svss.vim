" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! svss#parser#directive#template(lexer)
	return s:parse_single_text('template', a:lexer)
endfunction


function! svss#parser#directive#name(lexer)
	return s:parse_single_text('name', a:lexer)
endfunction


function! svss#parser#directive#background(lexer)
	return s:parse_single_text('background', a:lexer)
endfunction


function! svss#parser#directive#maintainer(lexer)
	return s:parse_single_text('maintainer', a:lexer)
endfunction


function! svss#parser#directive#license(lexer)
	return s:parse_single_text('license', a:lexer)
endfunction


function! svss#parser#directive#link(lexer)
	let from = svss#parser#next_token(a:lexer)

	let token = svss#parser#next_token(a:lexer)
	if token.type !=# 'word' || token.text !=# 'to'
		throw 'Invalid syntax in the link directive'
	endif

	let to = svss#parser#next_token(a:lexer)

	return svss#directive#new('link', [from.text, to.text])
endfunction


function! s:parse_single_text(name, lexer)
	let token = svss#parser#next_token(a:lexer)
	return svss#directive#new(a:name, [token.text])
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
