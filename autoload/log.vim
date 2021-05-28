let s:hlchunk_log_file = get(g:, 'hlchunk_log_file', '/tmp/hlchunk.log')

func! log#enable()
	let g:chunk_hl_log_disabled = 0
endf

func! log#disable()
	let g:chunk_hl_log_disabled = 1
endf

func! s:writefile(...) abort
	if !empty(trim(get(g:, 'hlchunk_log_file', '')))
		call writefile([strftime("[%H:%M]"). join(a:000, ' ')], 
					\ s:hlchunk_log_file, 'a')
	endif
endf

func! log#func_begin(file_name, fun_name, slnum, arg) abort
	return [reltime(), a:file_name, a:fun_name, a:slnum, a:arg]
endf

func! log#func_end(begin, return, ...) abort
	let l:info = join(a:000, '')
    call s:writefile(
        \ printf('%s(%s-%s)', a:begin[1], a:begin[3], a:begin[2]), 
        \ printf('{用时:%s}', trim(reltimestr(reltime(a:begin[0])))))
	call s:writefile('	', printf('{参数:%s}', a:begin[4]))
	call s:writefile('	', printf('{返回:%s}', a:return))
	if !empty(l:info)
		call s:writefile('	', l:info)
	endif
endf

func! s:clear_screen()
	for idx in range(10)
		call writefile([''], s:hlchunk_log_file, 'a')
	endfor
endf

func! log#program_begin()
	call s:clear_screen()
	call s:writefile('-------开始运行-------')
	return [reltime()]
endf

func! log#program_end(begin)
	call s:writefile('-------结束运行-------') 
	call s:writefile('用时：'. trim(reltimestr(reltime(a:begin[0]))))
endf
