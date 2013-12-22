" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! svss#parser#directive#name(parser)
	return s:parse_single_text('name', a:parser)
endfunction


function! svss#parser#directive#background(parser)
	return s:parse_single_text('background', a:parser)
endfunction


function! svss#parser#directive#maintainer(parser)
	return s:parse_single_text('maintainer', a:parser)
endfunction


function! svss#parser#directive#license(parser)
	return s:parse_single_text('license', a:parser)
endfunction


function! svss#parser#directive#link(parser)
	let from = a:parser.next_token()

	let token = a:parser.next_token()
	if token.type !=# 'word' || token.text !=# 'to'
		throw 'Invalid syntax in the link directive'
	endif

	let to = a:parser.next_token()

	return svss#directive#new('link', [from.text, to.text])
endfunction


function! s:parse_single_text(name, parser)
	let token = a:parser.next_token()
	return svss#directive#new(a:name, [token.text])
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
