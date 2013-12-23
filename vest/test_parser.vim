" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! s:lexer(text)
	let reader = svss#char_reader#new(a:text)
	return svss#lexer#new(reader)
endfunction


Context Source.run()
	It parses color
		let lexer = s:lexer('rgb(180, 0.5, 50%)')
		let result = svss#parser#parse_color(lexer)
		ShouldEqual result.type(), 'color'
		ShouldEqual result.space(), 'rgb'
		ShouldEqual len(result.components()), 3

		let lexer = s:lexer('hsl(180, 0.5, 50%)')
		let result = svss#parser#parse_color(lexer)
		ShouldEqual result.type(), 'color'
		ShouldEqual result.space(), 'hsl'
		ShouldEqual len(result.components()), 3
	End

	It parses declaration
		let lexer = s:lexer('ctermbg: 123;')
		let result = svss#parser#parse_declaration(lexer)
		ShouldEqual result.property(), 'ctermbg'
		let value = result.value()
		ShouldEqual value.type(), 'number'
		ShouldEqual value.value(), '123'
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
		ShouldEqual result.value().type(), 'color'

		let lexer = s:lexer('$foo: $bar;')
		let result = svss#parser#parse_definition(lexer)
		ShouldEqual result.value().type(), 'variable'
	End
End


Fin


let &cpo = s:save_cpo
unlet s:save_cpo
