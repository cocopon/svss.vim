" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


let s:method_names = [
			\ 	'apply',
			\ ]


function! svss#template#new(lines, pre_marker, post_marker)
	let template = {}
	let template.lines_ = a:lines
	let template.pre_ = a:pre_marker
	let template.post_ = a:post_marker

	call svss#util#class#setup_methods(
				\ template,
				\ 'svss#template',
				\ s:method_names)

	return template
endfunction


function! svss#template#apply(data) dict
	let result = copy(self.lines_)

	for key in keys(a:data)
		let value = a:data[key]

		let len = len(result)
		let i = len - 1

		if type(value) == type([])
			let marker = '^' . self.pre_ . key . self.post_ . '$'

			while i >= 0
				if result[i] =~# marker
					for line in value
						call insert(result, line, i - len)
					endfor
					call remove(result, i - len)
				endif
				let i -= 1
			endwhile
		else
			let marker = self.pre_ . key . self.post_

			while i >= 0
				let result[i] = substitute(result[i], marker, value, 'g')
				let i -= 1
			endwhile
		endif

		unlet value
	endfor

	return result
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
