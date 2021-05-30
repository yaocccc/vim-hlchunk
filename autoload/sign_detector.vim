let g:sign_detector#default_priority = 99
let g:sign_detector#id = 999

let s:sign_back_define  = {
			\ 'id': g:sign_detector#id, 
			\ 'name': 'SignDetectorBack',
			\ 'group': 'SignDetectorBackGroup',
			\ 'priority': g:sign_detector#default_priority + 1
			\}
let s:sign_front_define = {
			\ 'id': g:sign_detector#id, 
			\ 'name': 'SignDetectorFront',
			\ 'group': 'SignDetectorFrontGroup',
			\ 'priority': g:sign_detector#default_priority + 2
			\}

function! sign_detector#place(text, texthl)
	if exists('s:place_flag') && s:place_flag == 0
		let id       = s:sign_back_define.id
		let name     = s:sign_back_define.name
		let group    = s:sign_back_define.group
		let priority = s:sign_back_define.priority
	elseif exists('s:place_flag') && s:place_flag == 1
		let id       = s:sign_front_define.id
		let name     = s:sign_front_define.name
		let group    = s:sign_front_define.group
		let priority = s:sign_front_define.priority
	endif
	call sign_define(name. b:sd_line, {'text': a:text, 'texthl': a:texthl})
	call sign_place(id, group, name. b:sd_line, bufnr(), 
				\ {'lnum': b:sd_line, 'priority': priority})
endfunction

function! SignDetectTask(start, middle, end, timer)
	let l:bufnr = bufnr()
	let [beg, end] = s:searchpairpos(a:start, a:middle, a:end)
	let l:signs = sign_getplaced(l:bufnr, {'group':'*'})[0].signs
	let l:filter_self_signs = printf('\v^(%s|%s)\d+$', 
				\ s:sign_back_define.name, s:sign_front_define.name)
	let l:signs = filter(signs, {->v:val.name !~ l:filter_self_signs})
	let l:signs = filter(l:signs, {->v:val.lnum >= beg && v:val.lnum <= end})

	if [beg, end] != getbufvar(l:bufnr, 'sd_range', [0, 0])
		let b:sd_range = [beg, end]
		call sign_unplace(s:sign_back_define.group, {'buffer': l:bufnr})
		if [beg, end] == [0, 0] | return | endif
		let s:place_flag = 0
		for line in range(beg, end)
			let b:sd_line = line
			doautocmd User SelfSignChanged
		endfor
	endif

	let l:signs_for_ver = getbufvar(l:bufnr, 'signs_for_ver', [])
	if l:signs != l:signs_for_ver
		call setbufvar(l:bufnr, 'signs_for_ver', deepcopy(l:signs))
		call sign_unplace(s:sign_front_define.group, {'buffer': l:bufnr})
		let s:place_flag = 1
		for sign_hidden in s:filter_low_priority(l:signs)
			let b:sd_range = [beg, end]
			let b:sd_sign = sign_hidden
			let b:sd_sign_defined = sign_getdefined(sign_hidden.name)[0]
			let b:sd_line = sign_hidden.lnum
			doautocmd User OtherSignHidden
		endfor
	endif
endfunction






function! sign_detector#run(start, middle, end)
	let s:timer = timer_start(get(g:, 'sign_detector_time_delay', 100), 
				\ function('SignDetectTask', [a:start, a:middle, a:end]), 
				\ {'repeat': -1})
endfunction

function! sign_detector#stop()
	call timer_stop(s:timer)
endfunction

func! s:searchpairpos_aux(start, middle, end, flags)
    return searchpairpos(a:start, a:middle, a:end, a:flags,
        \"synIDattr(synID(line('.'), col('.'), 0), 'name') =~? '" .
        \'string\|cppRainbow_lv\d_r\d\|comment' .
        \"'")[0]
endf

func! s:searchpairpos(start, middle, end)
    let c = getline('.')[col('.') - 1]
    if c == a:start
        let ssign = ['zcnWb', 'znW']
    elseif c == a:end
        let ssign = ['znWb', 'zcnW']
    else
        let ssign = ['znWb', 'znW']
    endif
		let l:beg = s:searchpairpos_aux(a:start, a:middle, a:end, ssign[0])
		let l:end = s:searchpairpos_aux(a:start, a:middle, a:end, ssign[1])

		return [beg, end]
endf

function! s:calc_sign_differences(src, dst)
	let dst_signs = deepcopy(a:dst)
	for src_sign in a:src
		call filter(dst_signs, {->[v:val.lnum, v:val.name, v:val.group] 
					\ !=[src_sign.lnum, src_sign.name, src_sign.group]})
	endfor
	return dst_signs
endfunction

"过滤优先级低的Sign
function! s:filter_low_priority(signs)
	if empty(a:signs) | return [] | endif
	let l:signs = sort(deepcopy(a:signs), {v1, v2->v1.lnum > v2.lnum})
	let result = [l:signs[0]]
	for idx in range(1, len(l:signs)-1)
		if l:signs[idx].lnum == result[-1].lnum
			if l:signs[idx].priority > result[-1].priority
				let result[-1] = l:signs[idx]
			endif
			continue
		endif
		call add(result, l:signs[idx])
	endfor
	return result
endfunction
