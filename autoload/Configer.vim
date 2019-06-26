let s:save_cpo = &cpo
set cpo&vim
"TODO configfiles shall be named after their project directory, if multiple
"if a configfile with the same or another name must exists, vimgrep always
"greps for rootpath for matching

"maybe use bufferlocal autocmd for write as file does not always exist
execute 'au! BufWriteCmd '.g:Configer_ConfigFilename.' call s:SaveConfig()'

function! s:SaveConfig()
    echomsg 'saving config'
    let l:lines = getline(0, '$')
    s:GetConfig().save(l:lines)
    set nomodified
endfunction

""TODO might not be needed anymore
"function! s:IsAbsolutePath(path)
"    return nr2char(strgetchar(a:path, 0)) ==? '/'
"endfunction
"
""TODO might not be needed anymore
"function! s:ResolvePathToStorage(config, storage)
"    "need cwd when path is relative to distinguish relative from absolut paths
"    let l:cwd = s:IsAbsolutePath(a:config) ? '' : getcwd()
"    return resolve(a:storage.'/'.l:cwd.'/'.a:config)
"endfunction

"TODO might need similar to GetCloses()
function! s:GetConfig(...)
    let l:config = get(a:, 1, g:Configer_DefaultLookupPath)
    let l:storage = get(a:, 2, g:Configer_DefaultStoragePath)
    return Config#Load(l:storage.'/'.g:Configer_ConfigFilename)
endfunction

" ====    PUBLIC FUNCTIONS    ====

function! Configer#ConfigEdit(...)
    "let l:config = s:GetConfig(a:)
    "TODO adjust paths for Load and GetSettings
    let l:config = Config#Load('testconfig')
    let l:settings = l:config.GetSettings('autoload')
    let l:path = expand('%:h').'.'.g:Configer_ConfigFilename
    "open buffer and put settings into buffer
    execute 'edit '.l:path
    normal! ggdG
    setlocal filetype=vim
    call append(0, l:settings)
    normal gg
    set nomodified
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
