" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


let s:char_reader = themis#suite('char_reader')
let s:assert = themis#helper('assert')
let s:quickbrown = 'The quick brown fox jumps over the lazy dog.'


function! s:char_reader.reads_characters() abort
	let reader = svss#char_reader#new(s:quickbrown)
	call s:assert.equals(reader.read(), 'T')
	call s:assert.equals(reader.read(), 'h')
	call s:assert.equals(reader.read(), 'e')
endfunction


function! s:char_reader.should_be_eof() abort
	let reader = svss#char_reader#new(s:quickbrown)
	let len = len(s:quickbrown)
	let i = 0

	while i < len
		call s:assert.false(reader.is_eof())
		call s:assert.false(empty(reader.read()))
		let i += 1
	endwhile

	call s:assert.true(reader.is_eof())
	call s:assert.true(empty(reader.read()))

	call reader.unread()
	call s:assert.false(reader.is_eof())
	call s:assert.false(empty(reader.read()))

	call s:assert.true(reader.is_eof())
	call s:assert.true(empty(reader.read()))
endfunction


function! s:char_reader.unreads_characters() abort
	let reader = svss#char_reader#new(s:quickbrown)
	call reader.read()
	call reader.read()
	call reader.read()
	call reader.unread()
	call reader.unread()
	call reader.unread()
	call s:assert.equals(reader.read(), 'T')
	call s:assert.equals(reader.read(), 'h')
	call s:assert.equals(reader.read(), 'e')
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
