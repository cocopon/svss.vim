" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! s:lexer(text)
	let reader = svss#char_reader#new(a:text)
	return svss#lexer#new(reader)
endfunction


Context Source.run()
	It lexes ruleset
		let lexer = s:lexer('selector {prop: "hello";}')
		let expected_tokens = [
					\ 	{'type': 'word', 'text': 'selector'},
					\ 	{'type': 'symbol', 'text': '{'},
					\ 	{'type': 'word', 'text': 'prop'},
					\ 	{'type': 'symbol', 'text': ':'},
					\ 	{'type': 'string', 'text': 'hello'},
					\ 	{'type': 'symbol', 'text': ';'},
					\ 	{'type': 'symbol', 'text': '}'},
					\ ]

		for expected in expected_tokens
			let actual = lexer.next_token()
			ShouldEqual actual.type, expected.type, 'hello'
			ShouldEqual actual.text, expected.text
		endfor

		Should !lexer.has_next()
		Should empty(lexer.next_token())
	End

	It unreads token
		let lexer = s:lexer('selector {prop: "hello";}')
		let t1 = lexer.next_token()
		let t2 = lexer.next_token()

		call lexer.unread()
		let t3 = lexer.next_token()
		call lexer.unread()
		ShouldEqual t2.type, t3.type
		ShouldEqual t2.text, t3.text

		call lexer.unread()
		let t4 = lexer.next_token()
		ShouldEqual t1.type, t4.type
		ShouldEqual t1.text, t4.text
	End

	It lexes number
		let lexer = s:lexer('123')
		let token = lexer.next_token()
		ShouldEqual token.type, 'number'
		ShouldEqual token.text, '123'

		" Float value
		let lexer = s:lexer('3.1416')
		let token = lexer.next_token()
		ShouldEqual token.type, 'number'
		ShouldEqual token.text, '3.1416'

		" Percent value
		let lexer = s:lexer('120%')
		let token = lexer.next_token()
		ShouldEqual token.type, 'number'
		ShouldEqual token.text, '120%'
	End

	It lexes string
		" Double quoted literal
		let lexer = s:lexer('"hello, world"')
		let token = lexer.next_token()
		ShouldEqual token.type, 'string'
		ShouldEqual token.text, 'hello, world'

		" Single quoted literal
		let lexer = s:lexer('''hello, world''')
		let token = lexer.next_token()
		ShouldEqual token.type, 'string'
		ShouldEqual token.text, 'hello, world'

		" Double quote in the single quoted literal
		let lexer = s:lexer('''hello " world''')
		let token = lexer.next_token()
		ShouldEqual token.type, 'string'
		ShouldEqual token.text, 'hello " world'

		" Escaped double quote in the double quoted literal
		let lexer = s:lexer('"hello \" world"')
		let token = lexer.next_token()
		ShouldEqual token.type, 'string'
		ShouldEqual token.text, 'hello " world'

		" Escaped backshash
		let lexer = s:lexer('"hello \\ world"')
		let token = lexer.next_token()
		ShouldEqual token.type, 'string'
		ShouldEqual token.text, 'hello \ world'

		" Ineffective escape
		let lexer = s:lexer('"hello \abc world"')
		let token = lexer.next_token()
		ShouldEqual token.type, 'string'
		ShouldEqual token.text, 'hello abc world'
	End
End


Fin


let &cpo = s:save_cpo
unlet s:save_cpo
