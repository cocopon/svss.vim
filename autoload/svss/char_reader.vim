" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


let s:method_names = [
			\ 	'is_eof',
			\ 	'lnum',
			\ 	'read',
			\ 	'unread',
			\ ]


function! svss#char_reader#new(text) abort
	let reader = {}
	let reader.text_ = a:text
	let reader.pos_ = 0
	let reader.len_ = strlen(a:text)
	let reader.lnum_ = 1

	call svss#util#class#setup_methods(
				\ reader,
				\ 'svss#char_reader',
				\ s:method_names)

	return reader
endfunction


function! svss#char_reader#is_eof() abort dict
	return self.pos_ >= self.len_
endfunction


function! svss#char_reader#lnum() abort dict
	return self.lnum_
endfunction


function! svss#char_reader#read() abort dict
	if self.is_eof()
		return ''
	endif

	let result = self.text_[self.pos_]
	if result ==? "\n"
		let self.lnum_ += 1
	endif

	let self.pos_ += 1

	return result
endfunction


function! svss#char_reader#unread() abort dict
	if self.pos_ <= 0
		throw 'Cannot unread a character'
	endif

	if self.text_[self.pos_ - 1] ==# "\n"
		let self.lnum_ -= 1
	endif
	let self.pos_ -= 1
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
