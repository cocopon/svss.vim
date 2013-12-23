" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! svss#parser#parse_color(lexer)
	let space = svss#parser#next_token(a:lexer)

	let token = svss#parser#next_token(a:lexer)
	if !s:is_token(token, 'symbol', '(')
		throw 'Missing open brace of the color'
	endif

	let comps = []
	while a:lexer.has_next()
		let expr = svss#parser#parse_expression(a:lexer)
		if empty(expr)
			throw 'Expression is empty'
		endif
		call add(comps, expr)

		let token = svss#parser#next_token(a:lexer)
		if s:is_token(token, 'symbol', ')')
			break
		endif
		if !s:is_token(token, 'symbol', ',')
			throw 'Missing separator of color components'
		endif
	endwhile

	return svss#color#new(space.text, comps)
endfunction


function! svss#parser#parse_expression(lexer)
	let token = svss#parser#next_token(a:lexer)

	if token.type ==# 'number'
		let result = svss#number#new(token.text)
	elseif token.type ==# 'variable'
		let result = svss#variable#new(token.text)
	elseif s:is_color(token)
		call a:lexer.unread()
		let result = svss#parser#parse_color(a:lexer)
	else
		throw printf('Unexpected type: %s',
					\ token.type)
	endif
	return result
endfunction


function! svss#parser#parse_declaration_value(lexer)
	let result = svss#parser#parse_expression(a:lexer)

	let token = svss#parser#next_token(a:lexer)
	if !s:is_token(token, 'symbol', ';')
		throw 'Missing trailing semicolon of the declaration'
	endif

	return result
endfunction


function! svss#parser#parse_declaration(lexer)
	let property = svss#parser#next_token(a:lexer).text

	let separator = svss#parser#next_token(a:lexer)
	if !s:is_token(separator, 'symbol', ':')
		throw 'Missing declaration separator'
	endif

	let value = svss#parser#parse_declaration_value(a:lexer)

	return svss#declaration#new(property, value)
endfunction


function! svss#parser#parse_rule(lexer)
	let selector = svss#parser#next_token(a:lexer).text

	let brace = svss#parser#next_token(a:lexer)
	if !s:is_token(brace, 'symbol', '{')
		throw 'Missing open brace of the rule'
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

	return svss#rule#new(selector, decls)
endfunction


function! svss#parser#parse_definition(lexer)
	let name = svss#parser#next_token(a:lexer).text

	let token = svss#parser#next_token(a:lexer)
	if !s:is_token(token, 'symbol', ':')
		throw 'Missing definition separator'
	endif

	let value = svss#parser#parse_expression(a:lexer)

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


function! s:is_token(token, type, text)
	return a:token.type ==# a:type && a:token.text ==# a:text
endfunction


function! s:is_color(token)
	return a:token.text ==# 'rgb' || a:token.text ==# 'hsl'
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
