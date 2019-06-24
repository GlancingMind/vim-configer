let s:save_cpo = &cpo
set cpo&vim

augroup Configer_CreatePathWhenNotExists
    autocmd!
    execute 'autocmd! BufWritePre '.g:Configer_DefaultStoragePath.'/**
                \ call s:CreatePath(expand("<afile>:p:h"))'
augroup END

function! s:CreatePath(path)
    echomsg 'creating path: '.a:path
    if exists('*mkdir')
        call mkdir(a:path, 'p')
    else
        echoerr 'this system does not support mkdir()'
    endif
endfunction

function! s:IsAbsolutePath(path)
    return nr2char(strgetchar(a:path, 0)) ==? '/'
endfunction

"find each directory in storage that lays in my path and have a vimrc
function! s:GetAllConfigsOnInConfigPath(config)
    let l:paths = []
    let l:path = ''
    "skip last as it is the config file and not a directory
    for l:pathsegment in split(a:config, '/')[:-2]
        "TODO maybe use append?
        let l:path .= l:pathsegment.'/'
        "check if vimrc is readable config or a directory with vimrc as name
        if filereadable(l:path.g:Configer_ConfigFilename)
            call add(l:paths, l:path.g:Configer_ConfigFilename)
        endif
    endfor
    return l:paths
endfunction

function! s:ResolvePathToStorage(config, storage)
    "need cwd when path is relative to distinguish relative from absolut paths
    let l:cwd = s:IsAbsolutePath(a:config) ? '' : getcwd()
    return resolve(a:storage.'/'.l:cwd.'/'.a:config)
endfunction

" ====    PUBLIC FUNCTIONS    ====

function! Configer#GetConfig(...)
    let l:config = get(a:, 1, g:Configer_DefaultLookupPath)
    let l:storage = get(a:, 2, g:Configer_DefaultStoragePath)
    let l:configname = g:Configer_ConfigFilename
    return s:ResolvePathToStorage(l:config, l:storage).'/'.l:configname
endfunction

function! Configer#ListConfigsInStorage(...)
    let l:storage = get(a:, 1, g:Configer_DefaultStoragePath)
    let l:configname = g:Configer_ConfigFilename
    let l:configs = getcompletion(l:storage.'/**/'.l:configname, 'file')
    return filter(l:configs, 'filereadable(v:val)')
endfunction

function! Configer#Load(...)
    let l:config = get(a:, 1, g:Configer_DefaultLookupPath)
    let l:storage = get(a:, 2, g:Configer_DefaultStoragePath)
    let l:config = Configer#GetConfig(l:config, l:storage)
    for l:config in s:GetAllConfigsOnInConfigPath(l:config)
        echomsg 'Loading:   '.l:config
        "TODO need to call :source, maybe save settings via save_cpo beforehand
        "should only source configs which are diffrent from previous sources
        "source l:config
        echomsg 'Loaded:    '.l:config
    endfor
endfunction

"TODO source resource only relevant configs

" ====  TEST FUNCTIONS  ====

"function! Configer#TestMapPath()
"    "use assert_equal
"    let l:paths = [ './', '/app', 'app', './../app', './//app/../..//blub/./hello////', '/../../app', '../app', '%', '']
"    for l:path in l:paths
"        echomsg 'giv: '.l:path
"        echomsg 'got: '.Configer#GetConfig(l:path, g:Configer_DefaultStoragePath)
"    endfor
"endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
