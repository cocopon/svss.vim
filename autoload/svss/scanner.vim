" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


let s:value_types = {
			\ 	'ctermbg': 'raw',
			\ 	'ctermfg': 'raw',
			\ 	'guibg': 'color',
			\ 	'guifg': 'color',
			\ 	'guisp': 'color',
			\ }
" TODO: Support following attributes?:
" - cterm
" - font
" - gui
" - term


function! svss#scanner#scan()
	let entries = colorswatch#source#all#collect()

	let rules = []
	let directives = []

	call add(directives, s:string_directive('name', g:colors_name))
	call add(directives, s:string_directive('maintainer', 'MAINTAINER'))
	call add(directives, s:string_directive('license', 'LICENSE'))
	call add(directives, svss#directive#new('background', [&background]))

	for entry in entries
		if entry.has_link()
			let from = entry.get_name()
			let to = entry.get_link()
			call add(directives, s:link_directive(from, to))
		else
			let name = entry.get_name()
			let attrs = entry.get_attrs()
			call add(rules, s:rule(name, attrs))
		endif
	endfor

	return svss#ruleset#new(rules, [], directives)
endfunction


function! s:rule(name, attrs)
	let declarations = []
	for key in keys(a:attrs)
		let value = s:scan_declaration_value(key, a:attrs[key])
		if empty(value)
			unlet value
			continue
		endif

		let declaration = svss#declaration#new(key, value)
		call add(declarations, declaration)
		unlet value
	endfor

	return svss#rule#new([a:name], declarations)
endfunction


function! s:scan_declaration_value(property, raw_value)
	let type = get(s:value_types, a:property, '')
	if empty(type)
		return ''
	endif

	try
		let scanner_name = printf('svss#scanner#scan_%s', type)
		let value = function(scanner_name)(a:raw_value)
		return value
	catch /:E117:/
		" E117: Unknown function
		throw printf('Unsupported value type: %s',
					\ type)
	endtry
endfunction


function! svss#scanner#scan_raw(raw_value)
	return a:raw_value
endfunction


function! svss#scanner#scan_color(raw_value)
	let comps = svss#util#color#split(a:raw_value)
	return empty(comps)
				\ ? a:raw_value
				\ : svss#value#color#new('rgb', comps)
endfunction


function! s:string_directive(name, string)
	let args = [svss#value#string#new(a:string)]
	return svss#directive#new(a:name, args)
endfunction


function! s:link_directive(from, to)
	let args = [a:from, a:to]
	return svss#directive#new('link', args)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
