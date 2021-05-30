

func theme#basic_style2#init()
	hi def IndentLineSign ctermfg=255
	call sign_detector#run('{', '', '}')
	augroup HlChunk
		autocmd!
		autocmd User SelfSignChanged call s:self_sign_changed(['╭─', '│ ', '╰>'])
		autocmd User OtherSignHidden call s:other_sign_hidden(['╭─', '│ ', '╰>'])
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

func s:other_sign_hidden(token)
	if b:sd_line == b:sd_range[0]
		call sign_detector#place(a:token[0], b:sd_sign_defined.texthl)
	elseif b:sd_line == b:sd_range[1]
		call sign_detector#place(a:token[2], b:sd_sign_defined.texthl)
	else
		call sign_detector#place(b:sd_sign_defined.text, b:sd_sign_defined.texthl)
	endif
endfunction
