" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


let s:method_names = [
			\ 	'has_next',
			\ 	'lnum',
			\ 	'next_token',
			\ 	'read_chars_',
			\ 	'read_color_',
			\ 	'read_comment_',
			\ 	'read_directive_',
			\ 	'read_newline_',
			\ 	'read_number_',
			\ 	'read_string_',
			\ 	'read_symbol_',
			\ 	'read_variable_',
			\ 	'read_whitespace_',
			\ 	'read_word_',
			\ 	'token_type_',
			\ 	'unread',
			\ ]
let s:non_significant_tokens = [
			\ 	'comment',
			\ 	'newline',
			\ 	'whitespace',
			\ ]
let s:buffer_size = 10
let s:pattern_number = '[0-9.%+-]'
let s:pattern_string_quote = '\(''\|"\)'
let s:pattern_word = '[[:alnum:]_-]'
let s:pattern_whitespace = '\s'
let s:pattern_newline = '\n'
let s:color_prefix = '#'
let s:directive_prefix = '@'
let s:variable_prefix = '$'
let s:comment_first_ch = '/'
let s:comment_second_ch = '/'


function! svss#lexer#new(char_reader) abort
	let lexer = {}
	let lexer.reader_ = a:char_reader
	let lexer.buffer_ = []
	let lexer.pos_ = 0

	call svss#util#class#setup_methods(
				\ lexer,
				\ 'svss#lexer',
				\ s:method_names)

	return lexer
endfunction


function! svss#lexer#has_next() abort dict
	if self.pos_ < -1
		return 1
	endif

	let has_next = !empty(self.next_token())
	if has_next
		call self.unread()
	endif

	return has_next
endfunction


function! svss#lexer#lnum() abort dict
	return self.reader_.lnum()
endfunction


function! svss#lexer#read_chars_(pattern) abort dict
	let text = ''
	while 1
		let ch = self.reader_.read()
		if empty(ch)
			break
		endif

		if ch !~# a:pattern
			call self.reader_.unread()
			break
		endif
		let text .= ch
	endwhile
	return text
endfunction


function! svss#lexer#read_number_() abort dict
	return s:token('number', self.read_chars_(s:pattern_number))
endfunction


function! svss#lexer#read_word_() abort dict
	return s:token('word', self.read_chars_(s:pattern_word))
endfunction


function! svss#lexer#read_symbol_() abort dict
	return s:token('symbol', self.reader_.read())
endfunction


function! svss#lexer#read_whitespace_() abort dict
	return s:token('whitespace', self.read_chars_(s:pattern_whitespace))
endfunction


function! svss#lexer#read_newline_() abort dict
	return s:token('newline', self.read_chars_(s:pattern_newline))
endfunction


function! svss#lexer#read_variable_() abort dict
	" Skip prefix '$'
	call self.reader_.read()

	return s:token('variable', self.read_chars_(s:pattern_word))
endfunction


function! svss#lexer#read_directive_() abort dict
	" Skip prefix '@'
	call self.reader_.read()

	return s:token('directive', self.read_chars_(s:pattern_word))
endfunction


function! svss#lexer#read_string_() abort dict
	let reader = self.reader_
	let quote = reader.read()
	let text = ''
	let escaped = 0

	while !reader.is_eof()
		let ch = reader.read()

		if escaped
			let text .= ch
			let escaped = 0
		else
			if ch ==# '\'
				let escaped = 1
			elseif ch ==# quote
				break
			else
				let text .= ch
			endif
		endif
	endwhile

	return s:token('string', text)
endfunction


function! svss#lexer#read_comment_() abort dict
	let reader = self.reader_
	let text = ''

	while !reader.is_eof()
		let ch = reader.read()
		if ch =~# s:pattern_newline
			break
		endif

		let text .= ch
	endwhile

	return s:token('comment', text)
endfunction


function! svss#lexer#read_color_() abort dict
	let reader = self.reader_
	let text = ''

	while !reader.is_eof()
		let ch = reader.read()
		if ch !~# '[0-9a-f]'
			break
		endif

		let text .= ch
	endwhile

	return s:token('color', text)
endfunction


function! svss#lexer#next_token() abort dict
	if self.pos_ <= -1
		let result = self.buffer_[self.pos_]
		let self.pos_ += 1
		return result
	endif

	while 1
		let token_type = self.token_type_()
		if empty(token_type)
			break
		endif

		let read_method = printf('read_%s_', token_type)
		if !has_key(self, read_method)
			throw printf('Unexpected token type: %s',
						\ token_type)
		endif

		" Skip non-significant tokens
		if index(s:non_significant_tokens, token_type) >= 0
			call self[read_method]()
			continue
		endif

		let result = self[read_method]()
		call add(self.buffer_, result)

		let over_size = len(self.buffer_) - s:buffer_size
		if over_size > 0
			call remove(self.buffer_, 0, over_size)
		endif

		return result
	endwhile

	return {}
endfunction


function! svss#lexer#token_type_() abort dict
	let ch = self.reader_.read()
	if empty(ch)
		return ''
	endif

	if ch =~# s:pattern_number
		let type = 'number'
	elseif ch =~# s:pattern_word
		let type = 'word'
	elseif ch =~# s:pattern_whitespace
		let type = 'whitespace'
	elseif ch =~# s:pattern_newline
		let type = 'newline'
	elseif ch =~# s:pattern_string_quote
		let type = 'string'
	elseif ch ==# s:variable_prefix
		let type = 'variable'
	elseif ch ==# s:directive_prefix
		let type = 'directive'
	elseif ch ==# s:color_prefix
		let type = 'color'
	elseif ch ==# s:comment_first_ch
		let next_ch = self.reader_.read()
		let type = (next_ch ==# s:comment_second_ch)
					\ ? 'comment'
					\ : 'symbol'
		call self.reader_.unread()
	else
		let type = 'symbol'
	endif

	call self.reader_.unread()

	return type
endfunction


function! svss#lexer#unread() abort dict
	if self.pos_ < -len(self.buffer_)
		throw 'lexer: Cannot unread'
	endif

	let self.pos_ = (self.pos_ == 0)
				\ ? -1
				\ : self.pos_ - 1
endfunction


function! s:token(type, text) abort
	return {
				\ 	'type': a:type,
				\ 	'text': a:text,
				\ }
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
