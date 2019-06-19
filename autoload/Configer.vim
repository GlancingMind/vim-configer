"TODO
"when user hase a relative storage path, don't use an absolute path for conf
"only when user stores vimconf outside of project use absolute paths
"e.g. vimconf/home/sascha/workspace/.../autoload -> vimconf/autoload
"
"Store config in global setting or local setting dir
"global means absolute config path
"local means relative to nearest vimconf directory which is mostly cwd for
"projects
"
"Define multiple Storage directories to look for e.g. cwd, in root,...
"Give an option to disable this behaviour
"
"Create function like checkpath e.g. checkproject

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

function! s:StripFilename(path)
    return filereadable(a:path) ? fnamemodify(a:path, ':h') : a:path
endfunction

" ====    PUBLIC FUNCTIONS    ====

function! Configer#GetConfig(...)
    let l:storage = get(a:, 1, g:Configer_DefaultStoragePath)
    let l:config = get(a:, 2, g:Configer_DefaultLookupPath)
    let l:configname = g:Configer_ConfigFilename
    "need cwd when path is relative to distinguish relative from absolut paths
    let l:cwd = s:IsAbsolutePath(l:config) ? '' : getcwd()
    return resolve(l:storage.'/'.l:cwd.'/'.l:config.'/'.l:configname)
endfunction

" ====  TEST FUNCTIONS  ====

function! Configer#TestMapPath()
    "use assert_equal
    let l:paths = [ './', '/app', 'app', './../app', './//app/../..//blub/./hello////', '/../../app', '../app', '%', '']
    for l:path in l:paths
        echomsg 'giv: '.l:path
        echomsg 'got: '.Configer#GetConfig(g:Configer_DefaultStoragePath, l:path)
    endfor
endfunction
