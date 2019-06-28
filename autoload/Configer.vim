let s:save_cpo = &cpo
set cpo&vim
"TODO configfiles shall be named after their project directory, if multiple
"if a configfile with the same or another name must exists, vimgrep always
"greps for rootpath for matching

"TODO use bufferlocal autogroup
execute 'au! BufWriteCmd *.'.g:Configer_ConfigFilename.' call s:SaveConfig()'

function! s:SaveConfig()
    let l:settings = getline(0, '$')
    let l:config = Config#Load(g:Configer_DefaultStorage.'/'.g:Configer_ConfigFilename)
    call l:config.Save(l:settings, expand('%:h'))
    set nomodified
endfunction

function! s:RemoveTrailingEmptyLines(list)
    for l:item in reverse(a:list)
        if !empty(l:item)
            break
        endif
        call remove(a:list, index(a:list, l:item))
    endfor
    return a:list
endfunction

" ====    PUBLIC FUNCTIONS    ====

function! Configer#ConfigEdit(...)
    let l:config = Config#Load(g:Configer_DefaultStorage.'/'.g:Configer_ConfigFilename)
    let l:settings = l:config.GetSettings(expand('%:h'))
    call s:RemoveTrailingEmptyLines(l:settings)
    "open buffer and put settings into buffer
    execute 'edit '.expand('%:h').'.'.g:Configer_ConfigFilename
    normal! ggdG
    setlocal filetype=vim
    call append(0, l:settings)
    normal gg
    set nomodified
endfunction

function! Configer#ApplyConfig()
    let l:config = Config#Load(g:Configer_DefaultStorage.'/'.g:Configer_ConfigFilename)
    for l:setting in l:config.GetSettings(expand('%:h'))
        "TODO it seems that the same setting applies to all configs...
        "TODO settings are only working when they apply on startup
        echomsg l:setting
        execute l:setting
    endfor
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
