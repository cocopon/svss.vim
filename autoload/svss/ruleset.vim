" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


let s:method_names = [
			\ 	'definitions',
			\ 	'directives',
			\ 	'find_directives',
			\ 	'rules',
			\ 	'variable_value',
			\ 	'vim',
			\ ]


function! svss#ruleset#new(rules, definitions, directives)
	let ruleset = {}
	let ruleset.rules_ = a:rules
	let ruleset.defs_ = a:definitions
	let ruleset.directives_ = a:directives

	call svss#util#class#setup_methods(
				\ ruleset,
				\ 'svss#ruleset',
				\ s:method_names)

	return ruleset
endfunction


function! svss#ruleset#rules() dict
	return self.rules_
endfunction


function! svss#ruleset#definitions() dict
	return self.defs_
endfunction


function! svss#ruleset#directives() dict
	return self.directives_
endfunction


function! svss#ruleset#vim() dict
	let lines = []
	for rule in self.rules_
		call add(lines, rule.vim())
	endfor

	return lines
endfunction


function! svss#ruleset#variable_value(name) dict
	for def in self.defs_
		if def.name() ==# a:name
			return def.value()
		endif
	endfor

	throw printf('Variable definition not found: %s',
				\ a:name)
endfunction


function! svss#ruleset#find_directives(name) dict
	let directives = copy(self.directives_)
	return filter(directives, 'v:val.name() ==# a:name')
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
