" 1 sign_texts: ['╭─', '│ ', '╰>'], 起始位置 = [new, new], 中间位置 = [old, new], old: 优先用老的 new: 优先用新的
" 2 sign_texts: ['╭─', '│ ', '╰>'], 起始位置 = [old, new], 中间位置 = [old, new], old: 优先用老的 new: 优先用新的
" 3 sign_texts: ['╭─', '│ ', '╰>'], 起始位置 = [new, new], 中间位置 = [new, new], old: 优先用老的 new: 优先用新的

" 4 sign_texts: ['│ ', '│ ', '│ '], 起始位置 = [new, old], 中间位置 = [new, old], old: 优先用老的 new: 优先用新的
" 5 sign_texts: ['│ ', '│ ', '│ '], 起始位置 = [new, old], 中间位置 = [old, old], old: 优先用老的 new: 优先用新的

" 6 sign_texts: [' │', ' │', ' │'], 起始位置 = [old, new], 中间位置 = [old, new], old: 优先用老的 new: 优先用新的
" 7 sign_texts: [' │', ' │', ' │'], 起始位置 = [old, old], 中间位置 = [old, new], old: 优先用老的 new: 优先用新的

" 8 sign_texts: ['╭ ', '│ ', '╰ '], 起始位置 = [new, old], 中间位置 = [new, old], old: 优先用老的 new: 优先用新的
" 9 sign_texts: ['╭ ', '│ ', '╰ '], 起始位置 = [new, old], 中间位置 = [old, old], old: 优先用老的 new: 优先用新的

" 10 sign_texts: [' ╭', ' │', ' ╰'], 起始位置 = [old, new], 中间位置 = [old, new], old: 优先用老的 new: 优先用新的
" 11 sign_texts: [' ╭', ' │', ' ╰'], 起始位置 = [old, old], 中间位置 = [old, new], old: 优先用老的 new: 优先用新的

let s:priority = get(g:, 'hlchunk_priority', 90)
let s:theme = get(g:, 'hlchunk_theme', 1)
let s:preset_themes = [
            \   { 'sign_texts': ['╭─', '│ ', '╰>'], 'usenew': [1, 1, 0, 1] },
            \   { 'sign_texts': ['╭─', '│ ', '╰>'], 'usenew': [0, 1, 0, 1] },
            \   { 'sign_texts': ['╭─', '│ ', '╰>'], 'usenew': [1, 1, 1, 1] },
            \   { 'sign_texts': ['│ ', '│ ', '│ '], 'usenew': [1, 0, 1, 0] },
            \   { 'sign_texts': ['│ ', '│ ', '│ '], 'usenew': [1, 0, 0, 0] },
            \   { 'sign_texts': [' │', ' │', ' │'], 'usenew': [0, 1, 0, 1] },
            \   { 'sign_texts': [' │', ' │', ' │'], 'usenew': [0, 0, 0, 1] },
            \   { 'sign_texts': ['╭ ', '│ ', '╰ '], 'usenew': [1, 0, 1, 0] },
            \   { 'sign_texts': ['╭ ', '│ ', '╰ '], 'usenew': [1, 0, 0, 0] },
            \   { 'sign_texts': [' ╭', ' │', ' ╰'], 'usenew': [0, 1, 0, 1] },
            \   { 'sign_texts': [' ╭', ' │', ' ╰'], 'usenew': [0, 0, 0, 1] }
            \ ]
let s:run_theme = exists('g:hlchunk_theme_byuser') ? g:hlchunk_theme_byuser : s:preset_themes[s:theme - 1]

" 入口func
func! hlchunk#hl_chunk(bufnr, id)
    call sign_unplace('*', {'buffer' : a:bufnr, 'id' : a:id})

    let [beg, end] = s:searchpairpos('{', '', '}')
    if beg == end | return | endif
    if beg == 0 || end == 0 | return | endif

    for idx in range(beg, end)
        let new_sign_info = s:get_new_sign_info(a:bufnr, beg, end, idx)
        call sign_define('IndentLineSign'.idx, {'text': new_sign_info[0], 'texthl': new_sign_info[1]})
        call sign_place(a:id, '', 'IndentLineSign'.idx, a:bufnr, {'lnum': idx, 'priority': s:priority})
    endfor
endf

func! s:searchpairpos_aux(start, middle, end, flags)
    return searchpairpos(a:start, a:middle, a:end, a:flags,
        \"synIDattr(synID(line('.'), col('.'), 0), 'name') =~? '" .
        \'string\|cppRainbow_lv\d_r\d\|comment' .
        \"'")[0]
endf

func! s:searchpairpos(start, middle, end) " [int, int]
    let c = getline('.')[col('.') - 1]
    if c == a:start
        let ssign = ['zcnWb', 'znW']
    elseif c == a:end
        let ssign = ['znWb', 'zcnW']
    else
        let ssign = ['znWb', 'znW']
    endif
    let l:beg = s:searchpairpos_aux('{', '', '}', ssign[0])
    let l:end = s:searchpairpos_aux('{', '', '}', ssign[1])
    return [beg, end]
endf

func! s:get_old_sign_info(bufnr, line) " [text texthl] || []
    let signs = sign_getplaced(a:bufnr, {'group':'*', 'lnum':a:line})[0].signs
    if empty(signs) | return [] | endif
    call sort(signs, {v1, v2->v1.priority < v2.priority})
    let hl_info = sign_getdefined(signs[0].name)
    return [trim(hl_info[0].text, ' '), hl_info[0].texthl]
endf

func! s:get_new_sign_info(bufnr, beg, end, idx) " [text texthl]
    let hl_info = s:get_old_sign_info(a:bufnr, a:idx)
    let position = a:idx == a:beg ? 0 :
                 \ a:idx == a:end ? 2 :
                 \ 1
    let texthl = !empty(hl_info) ? hl_info[1] : 'IndentLineSign'
    let text = s:get_new_sign_text(
        \ s:run_theme.sign_texts,
        \ !empty(hl_info) ? s:get_old_sign_text(hl_info[0]) : '  ',
        \ s:run_theme.usenew,
        \ position)
    return [text, texthl]
endf

" old: char[*]
" return char[2]
func! s:get_old_sign_text(old)
    let [o1, o2] = [strcharpart(a:old, 0, 1), strcharpart(a:old, 1, 1)]
    return (len(o1) ? o1 : ' ') . (len(o2) ? o2 : ' ')
endf

" new: char[2][3]
" old: char[2]
" usenew: bool[4] 起始位置[bool, bool], 中间位置[bool, bool]
" position: 0beg 1middle 2end
" return char[2]
func! s:get_new_sign_text(new, old, usenew, position)
    let [new, old] = [a:new[a:position], a:old]
    let text = ''
    if a:position != 1 " 起始位置
        let text .= a:usenew[0] ? s:get_first_bypart(new, old, 0) : s:get_first_bypart(old, new, 0)
        let text .= a:usenew[1] ? s:get_first_bypart(new, old, 1) : s:get_first_bypart(old, new, 1)
    else " 中间位置
        let text .= a:usenew[2] ? s:get_first_bypart(new, old, 0) : s:get_first_bypart(old, new, 0)
        let text .= a:usenew[3] ? s:get_first_bypart(new, old, 1) : s:get_first_bypart(old, new, 1)
    endif
    return text
endf

" first: char[2]
" second: char[2]
" part: 0 | 1
" return char[1]
func! s:get_first_bypart(first, second, part)
    let first = strcharpart(a:first, a:part, 1)
    if first != ' '
        return first
    endif
    let second = strcharpart(a:second, a:part, 1)
    return second != ' ' ? second : ' '
endf
