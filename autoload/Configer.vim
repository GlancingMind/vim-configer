let s:save_cpo = &cpo
set cpo&vim
"TODO configfiles shall be named after their project directory, if multiple
"if a configfile with the same or another name must exists, vimgrep always
"greps for rootpath for matching

function! s:SaveConfig(path)
    let l:settings = getline(0, '$')
    let l:config = Config#Load(g:Configer_DefaultStorage.'/'.g:Configer_ConfigFilename)
    call l:config.Save(l:settings, a:path)
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

function! s:RemoveTrailingEmptyLinesFromBuffer()
    while empty(line('$'))
        echomsg 'delete trailing line'
        execute line('$').' delete _'
    endwhile
endfunction

" ====    PUBLIC FUNCTIONS    ====

function! Configer#ConfigEdit(...)
    let l:config = Config#Load(g:Configer_DefaultStorage.'/'.g:Configer_ConfigFilename)
    let l:path = expand('%:h').'.'.g:Configer_ConfigFilename
    let l:settings = l:config.GetSettings(l:path)
    execute 'edit '.l:path
    normal! ggdG
    call append(0, l:settings)
    call s:RemoveTrailingEmptyLinesFromBuffer()
    normal gg
    "clear undo history to prevent user from undo append(0, l:settings)
    "see :h clear-undo
    let l:old_undolevels = &undolevels
    setlocal undolevels=-1
    execute "normal a \<BS>\<Esc>"
    let &undolevels = l:old_undolevels
    setlocal nomodified
    setlocal noswapfile
    setlocal buftype=acwrite
    setlocal filetype=vim
    execute 'au! BufWriteCmd <buffer> call s:SaveConfig("'.l:path.'")'
endfunction

function! Configer#ApplyConfig()
    let l:config = Config#Load(g:Configer_DefaultStorage.'/'.g:Configer_ConfigFilename)
    let l:path = expand('%:h').'.'.g:Configer_ConfigFilename
    for l:setting in l:config.GetSettings(l:path)
        execute l:setting
    endfor
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
