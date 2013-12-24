" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! svss#parser#parse_function(lexer)
	let args = []
	let opt_args = {}

	let name = svss#parser#next_token(a:lexer).text

	let token = svss#parser#next_token(a:lexer)
	if !s:is_token(token, 'symbol', '(')
		throw printf('Missing open parenthesis of function: %s',
					\ name)
	endif

	while a:lexer.has_next()
		let first_token = svss#parser#next_token(a:lexer)
		let second_token = svss#parser#next_token(a:lexer)
		if first_token.type == 'variable'
					\ && s:is_token(second_token, 'symbol', ':')
			" Named argument
			let opt_args[first_token.text] = svss#parser#parse_value(a:lexer)
		else
			call a:lexer.unread()
			call a:lexer.unread()
			call add(args, svss#parser#parse_value(a:lexer))
		endif

		let token = svss#parser#next_token(a:lexer)
		if !s:is_token(token, 'symbol', ',')
			call a:lexer.unread()
			break
		endif
	endwhile

	let token = svss#parser#next_token(a:lexer)
	if !s:is_token(token, 'symbol', ')')
		throw printf('Missing closed parenthesis of function: %s',
					\ name)
	endif

	return svss#function#new(name, args, opt_args)
endfunction


function! svss#parser#parse_value(lexer)
	let token = svss#parser#next_token(a:lexer)

	if token.type ==# 'number'
		let result = svss#value#number#new(token.text)
	elseif token.type ==# 'variable'
		let result = svss#value#variable#new(token.text)
	elseif token.type ==# 'string'
		let result = svss#value#string#new(token.text)
	elseif token.type ==# 'color'
		let result = svss#value#color#new('rgb', svss#color#split(token.text))
	elseif s:is_function(token)
		call a:lexer.unread()
		let result = svss#parser#parse_function(a:lexer)
	else
		throw printf('Unexpected type: %s, %s',
					\ token.type, token.text)
	endif
	return result
endfunction


function! svss#parser#parse_declaration(lexer)
	let property = svss#parser#next_token(a:lexer).text

	let separator = svss#parser#next_token(a:lexer)
	if !s:is_token(separator, 'symbol', ':')
		throw 'Missing declaration separator'
	endif

	let value = svss#parser#parse_value(a:lexer)

	let token = svss#parser#next_token(a:lexer)
	if !s:is_token(token, 'symbol', ';')
		throw 'Missing trailing semicolon of the declaration'
	endif

	return svss#declaration#new(property, value)
endfunction


function! svss#parser#parse_rule(lexer)
	let selectors = []
	while a:lexer.has_next()
		call add(selectors, svss#parser#next_token(a:lexer).text)

		let token = svss#parser#next_token(a:lexer)
		if s:is_token(token, 'symbol', '{')
			break
		endif

		if !s:is_token(token, 'symbol', ',')
			throw printf('Invalid token: %s',
						\ string(token))
		endif
	endwhile

	if empty(selectors)
		throw 'No selector'
	endif

	let decls = []
	while a:lexer.has_next()
		let token = svss#parser#next_token(a:lexer)
		if s:is_token(token, 'symbol', '}')
			break
		endif

		call a:lexer.unread()
		call add(decls, svss#parser#parse_declaration(a:lexer))
	endwhile

	return svss#rule#new(selectors, decls)
endfunction


function! svss#parser#parse_definition(lexer)
	let name = svss#parser#next_token(a:lexer).text

	let token = svss#parser#next_token(a:lexer)
	if !s:is_token(token, 'symbol', ':')
		throw 'Missing definition separator'
	endif

	let value = svss#parser#parse_value(a:lexer)

	let token = svss#parser#next_token(a:lexer)
	if !s:is_token(token, 'symbol', ';')
		throw 'Missing trailing semicolon of the definition'
	endif

	return svss#definition#new(name, value)
endfunction


function! svss#parser#parse_directive(lexer)
	let name = svss#parser#next_token(a:lexer).text

	try
		let parser_name = printf('svss#parser#directive#%s',
					\ name)
		let result = function(parser_name)(a:lexer)
	catch /:E117:/
		" E117: Unknown function
		throw printf('Directive parser not found: %s',
					\ name)
	endtry

	let token = svss#parser#next_token(a:lexer)
	if !s:is_token(token, 'symbol', ';')
		throw 'Missing trailing semicolon of the directive'
	endif
	
	return result
endfunction


function! svss#parser#next_token(lexer)
	if !a:lexer.has_next()
		throw 'Unexpected EOF'
	endif

	return a:lexer.next_token()
endfunction


function! svss#parser#parse_internal_(lexer)
	let rules = []
	let definitions = []
	let directives = []

	while a:lexer.has_next()
		let token = svss#parser#next_token(a:lexer)
		call a:lexer.unread()

		if token.type ==# 'word'
			call add(rules, svss#parser#parse_rule(a:lexer))
		elseif token.type ==# 'variable'
			call add(definitions, svss#parser#parse_definition(a:lexer))
		elseif token.type ==# 'directive'
			call add(directives, svss#parser#parse_directive(a:lexer))
		else
			throw printf('Unexpected token type: %s', token.type)
		endif
	endwhile

	return svss#ruleset#new(rules, definitions, directives)
endfunction


function! svss#parser#parse(text)
	let reader = svss#char_reader#new(a:text)
	let lexer = svss#lexer#new(reader)

	if get(g:, 'svss_debug', 0)
		return svss#parser#parse_internal_(lexer)
	endif

	try
		return svss#parser#parse_internal_(lexer)
	catch
		throw printf('L%d: Parse error: %s',
					\ lexer.lnum(), v:exception)
	endtry
endfunction


" private {{{
function! s:is_token(token, type, text)
	return a:token.type ==# a:type && a:token.text ==# a:text
endfunction


function! s:is_function(token)
	return svss#function#exists(a:token.text)
endfunction
" }}}


let &cpo = s:save_cpo
unlet s:save_cpo
