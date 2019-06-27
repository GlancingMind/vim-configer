let s:save_cpo = &cpo
set cpo&vim
"TODO configfiles shall be named after their project directory, if multiple
"if a configfile with the same or another name must exists, vimgrep always
"greps for rootpath for matching

execute 'au! BufWriteCmd *.'.g:Configer_ConfigFilename.' call s:SaveConfig()'

function! s:SaveConfig()
    echomsg 'saving config'
    let l:settings = getline(0, '$')
    let l:config = Config#Load(s:GetConfigPath())
    let l:config.Save(l:settings, g:Configer_DefaultLookupPath)
    set nomodified
endfunction

function! s:GetConfigPath(...)
    "let l:config = get(a:, 1, g:Configer_DefaultLookupPath)
    "let l:storage = get(a:, 2, g:Configer_DefaultStoragePath)

    let l:storage = g:Configer_DefaultStorageGlob
    let l:configfile = fnamemodify(getcwd(), ':t')
    let l:config = Config#Load(l:storage.'/'.l:configfile)
    "TODO replace concat with glob() function!
    return l:storage.'/'.g:Configer_ConfigFilename
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
    let l:config = Config#Load(s:GetConfigPath())
    let l:dir = expand('%:h')
    let l:settings = l:config.GetSettings(l:dir)
    call s:RemoveTrailingEmptyLines(l:settings)
    "open buffer and put settings into buffer
    execute 'edit '.l:dir.'.'.g:Configer_ConfigFilename
    normal! ggdG
    setlocal filetype=vim
    call append(0, l:settings)
    normal gg
    set nomodified
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
