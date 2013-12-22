" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


let s:quickbrown = 'The quick brown fox jumps over the lazy dog.'


Context Source.run()
	It reads characters
		let reader = svss#char_reader#new(s:quickbrown)
		ShouldEqual reader.read(), 'T'
		ShouldEqual reader.read(), 'h'
		ShouldEqual reader.read(), 'e'
	End

	It should be eof
		let reader = svss#char_reader#new(s:quickbrown)
		let len = len(s:quickbrown)
		let i = 0

		while i < len
			ShouldNot reader.is_eof()
			ShouldNot empty(reader.read())
			let i += 1
		endwhile

		Should reader.is_eof()
		Should empty(reader.read())

		call reader.unread()
		ShouldNot reader.is_eof()
		ShouldNot empty(reader.read())

		Should reader.is_eof()
		Should empty(reader.read())
	End

	It unreads characters
		let reader = svss#char_reader#new(s:quickbrown)
		call reader.read()
		call reader.read()
		call reader.read()
		call reader.unread()
		call reader.unread()
		call reader.unread()
		ShouldEqual reader.read(), 'T'
		ShouldEqual reader.read(), 'h'
		ShouldEqual reader.read(), 'e'
	End
End


Fin


let &cpo = s:save_cpo
unlet s:save_cpo
