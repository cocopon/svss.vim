" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


let s:plugin_dir = expand('<sfile>:p:h')
let s:default_template_path = expand(s:plugin_dir . '/../data/template.txt')


" Global {{{
function! svss#compile_buffer(...) abort
	let lines = getline(1, '$')
	let result = s:compile(lines)

	if a:0 == 0
		call s:new_buffer(result)
		set ft=vim
	else
		let path = expand(a:1)
		call writefile(result, path)
	endif
endfunction


function! svss#source() abort
	let lines = getline(1, '$')
	let ruleset = s:parse(lines)
	let compiler = s:build_compiler()
	let data = compiler.compile(ruleset)

	" Reset all highlighting first
	hi clear

	for cmd in data.highlights
		execute cmd
	endfor
endfunction


function! svss#bufwrite() abort
	if get(g:, 'svss_auto_source', 0)
		call svss#source()
	end
endfunction


function! svss#scan() abort
	let ruleset = svss#scanner#scan()
	let lines = svss#decompiler#decompile(ruleset)
	call s:new_buffer(lines)
	set ft=svss
endfunction
" }}}


" Local {{{
function! s:parse(lines) abort
	let text = join(a:lines, "\n")
	return svss#parser#parse(text)
endfunction


function! s:build_compiler() abort
	" TODO: Apply global options
	return svss#compiler#new()
endfunction


function! s:compile(lines) abort
	let ruleset = s:parse(a:lines)
	let compiler = s:build_compiler()
	let data = compiler.compile(ruleset)

	let template_path = has_key(data, 'template')
				\ ? join([expand('%:p:h'), data.template], '/')
				\ : s:default_template_path
	let lines = readfile(template_path)
	let template = svss#template#new(lines, '\${', '}')

	return template.apply(data)
endfunction


function! s:new_buffer(lines) abort
	new
	call append(0, a:lines)
	normal! Gdd
	set nomodified
	normal! gg
endfunction
" }}}


let &cpo = s:save_cpo
unlet s:save_cpo
