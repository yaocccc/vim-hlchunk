hi IndentLineSign ctermfg=248
let s:timerid = -1
let s:delay = get(g:, 'hlchunk_time_delay', 50)
let s:hlchunk_files = get(g:, 'hlchunk_files', '*.ts,*.js,*.json,*.go,*.c')
let [b:hlbeg, b:hlend] = [0, 0]

exec('au CursorMoved,CursorMovedI,TextChanged,TextChangedI,TextChangedP ' .. s:hlchunk_files ..  ' call <SID>hlchunk()')
exec('au TextChanged,TextChangedI,TextChangedP ' .. s:hlchunk_files .. ' let [b:hlbeg, b:hlend] = [0, 0]')

func s:hlchunk()
    if [b:hlbeg, b:hlend] != [0, 0] && line('.') > b:hlbeg && line('.') < b:hlend
        return
    endif
    call timer_stop(s:timerid)
    let s:timerid = timer_start(s:delay, 'hlchunk#hl_chunk', {'repeat': 1})
endf
