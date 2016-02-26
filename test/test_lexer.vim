" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


let s:lexer = themis#suite('lexer')
let s:assert = themis#helper('assert')


function! s:lexer(text)
	let reader = svss#char_reader#new(a:text)
	return svss#lexer#new(reader)
endfunction


function! s:lexer.lexes_ruleset() abort
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
		call s:assert.equals(actual.type, expected.type)
		call s:assert.equals(actual.text, expected.text)
	endfor

	call s:assert.true(!lexer.has_next())
	call s:assert.true(empty(lexer.next_token()))

	unlet lexer expected_tokens actual
endfunction


function! s:lexer.unreads_token() abort
	let lexer = s:lexer('selector {prop: "hello";}')
	let t1 = lexer.next_token()
	let t2 = lexer.next_token()

	call lexer.unread()
	let t3 = lexer.next_token()
	call lexer.unread()
	call s:assert.equals(t2.type, t3.type)
	call s:assert.equals(t2.text, t3.text)

	call lexer.unread()
	let t4 = lexer.next_token()
	call s:assert.equals(t1.type, t4.type)
	call s:assert.equals(t1.text, t4.text)

	unlet lexer t1 t2 t3 t4
endfunction


function! s:lexer.lexes_number()
	let lexer = s:lexer('123')
	let token = lexer.next_token()
	call s:assert.equals(token.type, 'number')
	call s:assert.equals(token.text, '123')

	" Signed number
	let lexer = s:lexer('-123')
	let token = lexer.next_token()
	call s:assert.equals(token.type, 'number')
	call s:assert.equals(token.text, '-123')
	let lexer = s:lexer('+123')
	let token = lexer.next_token()
	call s:assert.equals(token.type, 'number')
	call s:assert.equals(token.text, '+123')

	" Float value
	let lexer = s:lexer('3.1416')
	let token = lexer.next_token()
	call s:assert.equals(token.type, 'number')
	call s:assert.equals(token.text, '3.1416')

	" Percent value
	let lexer = s:lexer('120%')
	let token = lexer.next_token()
	call s:assert.equals(token.type, 'number')
	call s:assert.equals(token.text, '120%')

	unlet lexer token
endfunction


function! s:lexer.lexes_string() abort
	" Double quoted literal
	let lexer = s:lexer('"hello, world"')
	let token = lexer.next_token()
	call s:assert.equals(token.type, 'string')
	call s:assert.equals(token.text, 'hello, world')

	" Single quoted literal
	let lexer = s:lexer('''hello, world''')
	let token = lexer.next_token()
	call s:assert.equals(token.type, 'string')
	call s:assert.equals(token.text, 'hello, world')

	" Double quote in the single quoted literal
	let lexer = s:lexer('''hello " world''')
	let token = lexer.next_token()
	call s:assert.equals(token.type, 'string')
	call s:assert.equals(token.text, 'hello " world')

	" Escaped double quote in the double quoted literal
	let lexer = s:lexer('"hello \" world"')
	let token = lexer.next_token()
	call s:assert.equals(token.type, 'string')
	call s:assert.equals(token.text, 'hello " world')

	" Escaped backshash
	let lexer = s:lexer('"hello \\ world"')
	let token = lexer.next_token()
	call s:assert.equals(token.type, 'string')
	call s:assert.equals(token.text, 'hello \ world')

	" Ineffective escape
	let lexer = s:lexer('"hello \abc world"')
	let token = lexer.next_token()
	call s:assert.equals(token.type, 'string')
	call s:assert.equals(token.text, 'hello abc world')

	unlet lexer token
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
