" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


let s:method_names = [
			\ 	'next_token',
			\ 	'parse',
			\ 	'parse_color_',
			\ 	'parse_declaration_',
			\ 	'parse_declaration_value_',
			\ 	'parse_definition_',
			\ 	'parse_directive_',
			\ 	'parse_expression_',
			\ 	'parse_internal_',
			\ 	'parse_rule_',
			\ ]


function! svss#parser#new()
	let parser = {}

	call svss#util#class#setup_methods(
				\ parser,
				\ 'svss#parser',
				\ s:method_names)

	return parser
endfunction


function! svss#parser#parse_expression_() dict
	let token = self.next_token()

	if token.type ==# 'number'
		let result = svss#number#new(token.text)
	elseif token.type ==# 'variable'
		let result = svss#variable#new(token.text)
	elseif s:is_color(token)
		call self.lexer_.unread()
		let result = self.parse_color_()
	else
		throw printf('Unexpected type: %s',
					\ token.type)
	endif
	return result
endfunction


function! svss#parser#parse_color_() dict
	let space = self.next_token()

	let token = self.next_token()
	if !s:is_token(token, 'symbol', '(')
		throw 'Missing open brace of the color'
	endif

	let comps = []
	while self.lexer_.has_next()
		let expr = self.parse_expression_()
		if empty(expr)
			throw 'Expression is empty'
		endif
		call add(comps, expr)

		let token = self.next_token()
		if s:is_token(token, 'symbol', ')')
			break
		endif
		if !s:is_token(token, 'symbol', ',')
			throw 'Missing separator of color components'
		endif
	endwhile

	return svss#color#new(space.text, comps)
endfunction


function! svss#parser#parse_declaration_value_() dict
	let result = self.parse_expression_()

	let token = self.next_token()
	if !s:is_token(token, 'symbol', ';')
		throw 'Missing trailing semicolon of the declaration'
	endif

	return result
endfunction


function! svss#parser#parse_declaration_() dict
	let property = self.next_token().text

	let separator = self.next_token()
	if !s:is_token(separator, 'symbol', ':')
		throw 'Missing declaration separator'
	endif

	let value = self.parse_declaration_value_()

	return svss#declaration#new(property, value)
endfunction


function! svss#parser#parse_rule_() dict
	let selector = self.next_token().text

	let brace = self.next_token()
	if !s:is_token(brace, 'symbol', '{')
		throw 'Missing open brace of the rule'
	endif

	let decls = []
	while self.lexer_.has_next()
		let token = self.next_token()
		if s:is_token(token, 'symbol', '}')
			break
		endif

		call self.lexer_.unread()
		call add(decls, self.parse_declaration_())
	endwhile

	return svss#rule#new(selector, decls)
endfunction


function! svss#parser#parse_definition_() dict
	let name = self.next_token().text

	let token = self.next_token()
	if !s:is_token(token, 'symbol', ':')
		throw 'Missing definition separator'
	endif

	let value = self.parse_expression_()

	let token = self.next_token()
	if !s:is_token(token, 'symbol', ';')
		throw 'Missing trailing semicolon of the definition'
	endif

	return svss#definition#new(name, value)
endfunction


function! svss#parser#parse_directive_() dict
	let name = self.next_token().text

	try
		let parser_name = printf('svss#parser#directive#%s',
					\ name)
		let result = function(parser_name)(self)
	catch /:E117:/
		" E117: Unknown function
		throw printf('Directive parser not found: %s',
					\ name)
	endtry

	let token = self.next_token()
	if !s:is_token(token, 'symbol', ';')
		throw 'Missing trailing semicolon of the directive'
	endif
	
	return result
endfunction


function! svss#parser#next_token() dict
	let lexer = self.lexer_
	if !lexer.has_next()
		throw 'Unexpected EOF'
	endif

	return lexer.next_token()
endfunction


function! svss#parser#parse_internal_(text) dict
	let reader = svss#char_reader#new(a:text)
	let self.lexer_ = svss#lexer#new(reader)
	let rules = []
	let definitions = []
	let directives = []

	while self.lexer_.has_next()
		let token = self.next_token()
		call self.lexer_.unread()

		if token.type ==# 'word'
			call add(rules, self.parse_rule_())
		elseif token.type ==# 'variable'
			call add(definitions, self.parse_definition_())
		elseif token.type ==# 'directive'
			call add(directives, self.parse_directive_())
		else
			throw printf('Unexpected token type: %s', token.type)
		endif
	endwhile

	return svss#ruleset#new(rules, definitions, directives)
endfunction


function! svss#parser#parse(text) dict
	if get(g:, 'svss_debug', 0)
		return self.parse_internal_(a:text)
	endif

	try
		return self.parse_internal_(a:text)
	catch
		throw printf('L%d: Parse error: %s',
					\ self.lexer_.lnum(), v:exception)
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
