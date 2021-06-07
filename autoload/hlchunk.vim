" [new, new] 代表 signcolumn 列1 列2 都优先用 hlchunk 的sign, old表示优先用原来就在的sign
" 预设主题列表 let g:hlchunk_theme = 1
" 1 sign_texts: ['╭─', '│ ', '╰>'], [start, middle, end] = [ [new, new], [old, new], [new, new] ]
" 2 sign_texts: ['╭─', '│ ', '╰>'], [start, middle, end] = [ [old, new], [old, new], [old, new] ]
" 3 sign_texts: ['╭─', '│ ', '╰>'], [start, middle, end] = [ [new, new], [new, new], [new, new] ]

" 4 sign_texts: ['│ ', '│ ', '│ '], [start, middle, end] = [ [new, old], [new, old], [new, old] ]
" 5 sign_texts: ['│ ', '│ ', '│ '], [start, middle, end] = [ [new, old], [old, old], [new, old] ]

" 6 sign_texts: [' │', ' │', ' │'], [start, middle, end] = [ [old, new], [old, new], [old, new] ]
" 7 sign_texts: [' │', ' │', ' │'], [start, middle, end] = [ [old, old], [old, new], [old, old] ]

" 8 sign_texts: ['╭ ', '│ ', '╰ '], [start, middle, end] = [ [new, old], [new, old], [new, old] ]
" 9 sign_texts: ['╭ ', '│ ', '╰ '], [start, middle, end] = [ [new, old], [old, old], [new, old] ]

" 10 sign_texts: [' ╭', ' │', ' ╰'], [start, middle, end] = [ [old, new], [old, new], [old, new] ]
" 11 sign_texts: [' ╭', ' │', ' ╰'], [start, middle, end] = [ [old, old], [old, new], [old, old] ]

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

    let [beg, end] = s:getpairpos()
    if beg == end | return | endif
    if beg == 0 || end == 0 | return | endif

    " 避免渲染行数过长造成的卡顿 - 只渲染屏幕展示行+-10行的区域
    let [startl, endl] = end - beg > 100
        \ ? [max([beg, line('w0') - 10]), min([end, line('w$') + 10])]
        \ : [beg, end]
    for idx in range(startl, endl)
        let new_sign_info = s:get_new_sign_info(a:bufnr, beg, end, idx)
        call sign_define('IndentLineSign'.idx, {'text': new_sign_info[0], 'texthl': new_sign_info[1]})
        call sign_place(a:id, '', 'IndentLineSign'.idx, a:bufnr, {'lnum': idx, 'priority': s:priority})
    endfor
endf

func! s:getpairpos() " [int, int]
    let c = getline('.')[col('.') - 1]
    let l:beg = searchpair('{', '', '}', 'znWb' . (c == '{' ? 'c' : ''))
    let l:end = searchpair('{', '', '}', 'znW' . (c == '}' ? 'c' : ''))
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
" usenew: bool[4] 起止位置[bool, bool], 中间位置[bool, bool]
" position: 0beg 1middle 2end
" return char[2]
func! s:get_new_sign_text(new, old, usenew, position)
    let [new, old] = [a:new[a:position], a:old]
    let text = ''
    if a:position != 1 " 起止位置
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
