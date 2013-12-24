" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! s:lexer(text)
	let reader = svss#char_reader#new(a:text)
	return svss#lexer#new(reader)
endfunction


Context Source.run()
	It parses declaration
		let lexer = s:lexer('ctermbg: 123;')
		let result = svss#parser#parse_declaration(lexer)
		ShouldEqual result.property(), 'ctermbg'
		let value = result.value()
		ShouldEqual value.type(), 'number'
		ShouldEqual value.value(), '123'

		unlet lexer result value
	End

	It parses rule
		let lexer = s:lexer('Comment {ctermbg: 127; ctermfg: 255;}')
		let result = svss#parser#parse_rule(lexer)
		let selectors = result.selectors()
		ShouldEqual len(selectors), 1
		ShouldEqual selectors[0], 'Comment'
		let decls = result.declarations()
		ShouldEqual len(decls), 2
		ShouldEqual decls[0].property(), 'ctermbg'
		ShouldEqual decls[0].value().value(), '127'
		ShouldEqual decls[1].property(), 'ctermfg'
		ShouldEqual decls[1].value().value(), '255'

		let lexer = s:lexer('Error, ErrorMsg {ctermbg: 127;}')
		let result = svss#parser#parse_rule(lexer)
		let selectors = result.selectors()
		ShouldEqual len(selectors), 2
		ShouldEqual selectors[0], 'Error'
		ShouldEqual selectors[1], 'ErrorMsg'

		unlet lexer result selectors decls
	End

	It parses definition
		let lexer = s:lexer('$foo: 123;')
		let result = svss#parser#parse_definition(lexer)
		ShouldEqual result.type(), 'definition'
		ShouldEqual result.name(), 'foo'
		let value = result.value()
		ShouldEqual value.type(), 'number'
		ShouldEqual value.value(), '123'

		let lexer = s:lexer('$foo: hsl(0, 0, 0);')
		let result = svss#parser#parse_definition(lexer)
		ShouldEqual result.value().type(), 'function'

		let lexer = s:lexer('$foo: $bar;')
		let result = svss#parser#parse_definition(lexer)
		ShouldEqual result.value().type(), 'variable'

		unlet lexer result value
	End

	It parses function
		let lexer = s:lexer('func("a", "b", "c")')
		let result = svss#parser#parse_function(lexer)
		ShouldEqual result.type(), 'function'
		ShouldEqual result.name(), 'func'
		let args = result.arguments()
		ShouldEqual len(args), 3
		ShouldEqual args[0].value(), 'a'
		ShouldEqual args[1].value(), 'b'
		ShouldEqual args[2].value(), 'c'

		let lexer = s:lexer('func("a", "b", $foo: "c", $bar: "d")')
		let result = svss#parser#parse_function(lexer)
		ShouldEqual result.type(), 'function'
		ShouldEqual result.name(), 'func'
		let args = result.arguments()
		ShouldEqual len(args), 2
		ShouldEqual args[0].value(), 'a'
		ShouldEqual args[1].value(), 'b'
		let opt_args = result.opt_arguments()
		ShouldEqual len(opt_args), 2
		ShouldEqual opt_args['foo'].value(), 'c'
		ShouldEqual opt_args['bar'].value(), 'd'

		unlet lexer result args opt_args
	End

	It parses value
		" number
		let lexer = s:lexer('-3.1416')
		let result = svss#parser#parse_value(lexer)
		ShouldEqual result.type(), 'number'

		" variable
		let lexer = s:lexer('$foobar')
		let result = svss#parser#parse_value(lexer)
		ShouldEqual result.type(), 'variable'

		" string
		let lexer = s:lexer('"hello, world"')
		let result = svss#parser#parse_value(lexer)
		ShouldEqual result.type(), 'string'

		" color
		let lexer = s:lexer('#112233')
		let result = svss#parser#parse_value(lexer)
		ShouldEqual result.type(), 'color'

		unlet lexer result
	End
End


Fin


let &cpo = s:save_cpo
unlet s:save_cpo
