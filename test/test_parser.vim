" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


let s:parser = themis#suite('parser')
let s:assert = themis#helper('assert')


function! s:lexer(text)
	let reader = svss#char_reader#new(a:text)
	return svss#lexer#new(reader)
endfunction


function! s:parser.parses_declaration() abort
	let lexer = s:lexer('ctermbg: 123;')
	let result = svss#parser#parse_declaration(lexer)
	call s:assert.equals(result.property(), 'ctermbg')
	let value = result.value()
	call s:assert.equals(value.type(), 'number')
	call s:assert.equals(value.value(), '123')

	unlet lexer result value
endfunction


function! s:parser.parses_rule() abort
	let lexer = s:lexer('Comment {ctermbg: 127; ctermfg: 255;}')
	let result = svss#parser#parse_rule(lexer)
	let selectors = result.selectors()
	call s:assert.equals(len(selectors), 1)
	call s:assert.equals(selectors[0], 'Comment')
	let decls = result.declarations()
	call s:assert.equals(len(decls), 2)
	call s:assert.equals(decls[0].property(), 'ctermbg')
	call s:assert.equals(decls[0].value().value(), '127')
	call s:assert.equals(decls[1].property(), 'ctermfg')
	call s:assert.equals(decls[1].value().value(), '255')

	let lexer = s:lexer('Error, ErrorMsg {ctermbg: 127;}')
	let result = svss#parser#parse_rule(lexer)
	let selectors = result.selectors()
	call s:assert.equals(len(selectors), 2)
	call s:assert.equals(selectors[0], 'Error')
	call s:assert.equals(selectors[1], 'ErrorMsg')

	unlet lexer result selectors decls
endfunction


function! s:parser.parses_definition() abort
	let lexer = s:lexer('$foo: 123;')
	let result = svss#parser#parse_definition(lexer)
	call s:assert.equals(result.type(), 'definition')
	call s:assert.equals(result.name(), 'foo')
	let value = result.value()
	call s:assert.equals(value.type(), 'number')
	call s:assert.equals(value.value(), '123')

	let lexer = s:lexer('$foo: hsl(0, 0, 0);')
	let result = svss#parser#parse_definition(lexer)
	call s:assert.equals(result.value().type(), 'function')

	let lexer = s:lexer('$foo: $bar;')
	let result = svss#parser#parse_definition(lexer)
	call s:assert.equals(result.value().type(), 'variable')

	unlet lexer result value
endfunction


function! s:parser.parses_function() abort
	let lexer = s:lexer('func("a", "b", "c")')
	let result = svss#parser#parse_function(lexer)
	call s:assert.equals(result.type(), 'function')
	call s:assert.equals(result.name(), 'func')
	let args = result.arguments()
	call s:assert.equals(len(args), 3)
	call s:assert.equals(args[0].value(), 'a')
	call s:assert.equals(args[1].value(), 'b')
	call s:assert.equals(args[2].value(), 'c')

	let lexer = s:lexer('func("a", "b", $foo: "c", $bar: "d")')
	let result = svss#parser#parse_function(lexer)
	call s:assert.equals(result.type(), 'function')
	call s:assert.equals(result.name(), 'func')
	let args = result.arguments()
	call s:assert.equals(len(args), 2)
	call s:assert.equals(args[0].value(), 'a')
	call s:assert.equals(args[1].value(), 'b')
	let opt_args = result.opt_arguments()
	call s:assert.equals(len(opt_args), 2)
	call s:assert.equals(opt_args['foo'].value(), 'c')
	call s:assert.equals(opt_args['bar'].value(), 'd')

	unlet lexer result args opt_args
endfunction


function! s:parser.parses_value() abort
	" number
	let lexer = s:lexer('-3.1416')
	let result = svss#parser#parse_value(lexer)
	call s:assert.equals(result.type(), 'number')

	" variable
	let lexer = s:lexer('$foobar')
	let result = svss#parser#parse_value(lexer)
	call s:assert.equals(result.type(), 'variable')

	" string
	let lexer = s:lexer('"hello, world"')
	let result = svss#parser#parse_value(lexer)
	call s:assert.equals(result.type(), 'string')

	" color
	let lexer = s:lexer('#112233')
	let result = svss#parser#parse_value(lexer)
	call s:assert.equals(result.type(), 'color')
	let comps = result.components()
	call s:assert.equals(comps[0].value(), 0x11)
	call s:assert.equals(comps[1].value(), 0x22)
	call s:assert.equals(comps[2].value(), 0x33)

	" list
	let lexer = s:lexer('bold, italic, reverse;')
	let result = svss#parser#parse_value(lexer)
	call s:assert.equals(result.type(), 'list')
	let items = result.items()
	call s:assert.equals(len(items), 3)
	call s:assert.equals(items[0].name(), 'bold')
	call s:assert.equals(items[1].name(), 'italic')
	call s:assert.equals(items[2].name(), 'reverse')

	unlet lexer result items
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
