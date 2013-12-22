" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


let s:plugin_dir = expand('<sfile>:p:h')
let s:default_template_path = expand(s:plugin_dir . '/../data/template.txt')


" Global {{{
function! svss#compile_buffer(...)
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


function! svss#source()
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


function! svss#bufwrite()
	if get(g:, 'svss_auto_source', 0)
		call svss#source()
	end
endfunction


function! svss#scan()
	let ruleset = svss#scanner#scan()
	let lines = svss#decompiler#decompile(ruleset)
	call s:new_buffer(lines)
	set ft=svss
endfunction
" }}}


" Local {{{
function! s:parse(lines)
	let text = join(a:lines, "\n")
	let parser = svss#parser#new()
	return parser.parse(text)
endfunction


function! s:build_compiler()
	" TODO: Apply global options
	return svss#compiler#new()
endfunction


function! s:compile(lines)
	let template_path = get(g:, 'template', s:default_template_path)
	let lines = readfile(template_path)
	let template = svss#template#new(lines, '\${', '}')

	let ruleset = s:parse(a:lines)
	let compiler = s:build_compiler()
	let data = compiler.compile(ruleset)

	return template.apply(data)
endfunction


function! s:new_buffer(lines)
	new
	call append(0, a:lines)
	normal! Gdd
	set nomodified
	normal! gg
endfunction
" }}}


let &cpo = s:save_cpo
unlet s:save_cpo
