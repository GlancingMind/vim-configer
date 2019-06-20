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

" ====    PUBLIC FUNCTIONS    ====

function! Configer#GetConfig(...)
    let l:config = get(a:, 1, g:Configer_DefaultLookupPath)
    let l:storage = get(a:, 2, g:Configer_DefaultStoragePath)
    let l:configname = g:Configer_ConfigFilename
    "need cwd when path is relative to distinguish relative from absolut paths
    let l:cwd = s:IsAbsolutePath(l:config) ? '' : getcwd()
    return resolve(l:storage.'/'.l:cwd.'/'.l:config.'/'.l:configname)
endfunction

function! Configer#ListConfigsInStorage(...)
    let l:storage = get(a:, 1, g:Configer_DefaultStoragePath)
    let l:configname = g:Configer_ConfigFilename
    let l:configs = getcompletion(l:storage.'/**/'.l:configname, 'file')
    return filter(l:configs, 'filereadable(v:val)')
endfunction

"TODO need to call :source, maybe save settings via save_cpo beforehand?
function! Configer#Load(...)
    let l:config = get(a:, 1, g:Configer_DefaultLookupPath)
    let l:storage = get(a:, 2, g:Configer_DefaultStoragePath)
    let l:config = Configer#GetConfig(l:config, l:storage)
    for l:config in s:GetAllConfigsOnInConfigPath(l:config)
        echomsg 'Loading:   '.l:config
        "should only source configs which are diffrent from previous sources
        "source l:config
        echomsg 'Loaded:    '.l:config
    endfor
endfunction

"create a project indicator file for given directory in storage to mark this
"directory as a project root
function! Configer#DefineDirAsProject(dir)
    let l:indicatorfile = a:dir.'/'.g:Configer_ProjectIndicatorFilename
    echomsg l:indicatorfile
    call writefile([''], l:indicatorfile, 's')
endfunction

"TODO could create an export function which saves configs to new directory or
"symlinks projectroot in config storage to project
"TODO save a file with project cwds in storage -> makes it possible to recalc
"paths
function! Configer#Import(storage)
    "determine new project cwd
    "determine old project cwd
    "copy old projectfiles and hierarchy into new cwd
endfunction

" ====  TEST FUNCTIONS  ====

"function! Configer#TestMapPath()
"    "use assert_equal
"    let l:paths = [ './', '/app', 'app', './../app', './//app/../..//blub/./hello////', '/../../app', '../app', '%', '']
"    for l:path in l:paths
"        echomsg 'giv: '.l:path
"        echomsg 'got: '.Configer#GetConfig(l:path, g:Configer_DefaultStoragePath)
"    endfor
"endfunction
