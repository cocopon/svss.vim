" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! s:empty_ruleset()
	return svss#ruleset#new([], [], [])
endfunction


Context Source.run()
	It instanciate number
		let ruleset = s:empty_ruleset()

		let num = svss#value#number#new('123')
		let result = num.evaluate(ruleset)
		ShouldEqual result, 123.0

		let num = svss#value#number#new('-456')
		let result = num.evaluate(ruleset)
		ShouldEqual result, -456.0

		let num = svss#value#number#new('+789')
		let result = num.evaluate(ruleset)
		ShouldEqual result, 789.0

		let num = svss#value#number#new('3.1416')
		let result = num.evaluate(ruleset)
		ShouldEqual result, 3.1416

		unlet ruleset num result
	End
End


Fin


let &cpo = s:save_cpo
unlet s:save_cpo
