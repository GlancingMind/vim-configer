"TODO
"when user hase a relative storage path, don't use an absolute path for conf
"only when user stores vimconf outside of project use absolute pathes
"e.g. vimconf/home/sascha/workspace/.../autoload -> vimconf/autoload
"Give an option to disable this behaviour

augroup Configer_CreatePathWhenNotExists
    autocmd!
    execute 'autocmd! BufWritePre '.g:Configer_ConfigStoragePath.'/**
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

function! s:IsFile(path)
    return nr2char(strgetchar(a:path, strchars(a:path))) !=? '/'
endfunction

function! s:StripFilename(path)
    return filereadable(a:path) ? fnamemodify(a:path, ':h') : a:path
endfunction

" ====    PUBLIC FUNCTIONS    ====

function! Configer#GetConfig(path)
    let l:storage = expand(g:Configer_ConfigStoragePath)
    let l:cwd = s:IsAbsolutePath(a:path) ? '' : getcwd().'/'
    "if a:path is empty use users preferred option e.g. getcwd() or %
    let l:path = expand(empty(a:path) ? g:Configer_DefaultLookupPath : a:path)
    let l:path = s:IsFile(l:path) ? s:StripFilename(l:path) : l:path
    return l:storage.resolve(l:cwd.l:path.'/'.g:Configer_ConfigFilename)
endfunction

" ====  TEST FUNCTIONS  ====

function! Configer#TestMapPath()
    "use assert_equal
    let l:pathes = [ './', '/app', 'app', './../app', './//app/../..//blub/./hello////', '/../../app', '../app', '%', '']
    for l:path in l:pathes
        echomsg 'giv: '.l:path
        echomsg 'got: '.Configer#GetConfig(l:path)
    endfor
endfunction
