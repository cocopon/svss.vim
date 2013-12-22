" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


command! -nargs=0 SvssSource call svss#source()
command! -nargs=? -complete=file SvssCompileBuffer call svss#compile_buffer(<f-args>)
command! -nargs=0 SvssScan call svss#scan()

" For color scheme development
command! -nargs=0 SvssDevInspect call svss#dev#inspect()


let &cpo = s:save_cpo
unlet s:save_cpo
