

func theme#basic_style1#init()
	hi def IndentLineSign ctermfg=205 cterm=bold
	call sign_detector#run('{', '', '}')
	augroup HlChunk
		autocmd!
		autocmd User SelfSignChanged call s:self_sign_changed(['╭─', '│ ', '╰>'])
	augroup END
endf

function! s:self_sign_changed(token)
	if b:sd_line == b:sd_range[0]
		call sign_detector#place(a:token[0], 'IndentLineSign')
	elseif b:sd_line == b:sd_range[1]
		call sign_detector#place(a:token[2], 'IndentLineSign')
	else
		call sign_detector#place(a:token[1], 'IndentLineSign')
	endif
endfunction
