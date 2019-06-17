augroup Configer_CreatePathWhenNotExists
    autocmd!
    execute 'autocmd! BufWritePre '.g:Configer_ConfigLookupPath.'/**
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

"TODO does this this work on windows too?
function! s:IsAbsolutePath(path)
    return nr2char(strgetchar(a:path, 0)) ==? '/'
endfunction

function! Configer#MapPath(path)
    "let l:file = substitute(l:file, '/\+\.\=/\+', '/', 'g')
    "let l:file = fnamemodify(expand(l:file), ':p')
    let l:storage = expand('./test/')
    if s:IsAbsolutePath(a:path)
        let l:combined = l:storage.a:path
    else
        "no absolute path given. Remove leading ./ as ./ won't be extended
        "for non exsisting directories, so append cwd manually
        let l:combined = l:storage.getcwd().'/'.substitute(a:path, '^\./', '', '')
    endif
    echomsg 'giv: '.a:path
    echomsg 'com: '.l:combined
    "replace all occurences of './', '//' and  '/./' with /
    "///, ///.//, /./; ./, .///
    return substitute(l:combined, '/\+\.\=/\+', '/', 'g')
endfunction

"TODO
"maybe improve regex for combined?
"create function ConstructAbsolutePath() -- create abspath even when not exists
"call ConstructAbsolutePath for root and project dir and concat them

function! Configer#TestMapPath()
    "use assert_equal
    let l:pathes = [ './', '/app', 'app', './../app', './//app/../..//blub/./hello////']
    for l:path in l:pathes
        echomsg 'sub: '.Configer#MapPath(l:path)
    endfor
endfunction

function! Configer#TestAbsPath()
    echomsg s:IsAbsolutePath('app')
    echomsg s:IsAbsolutePath('./app')
    echomsg s:IsAbsolutePath('/app')
endfunction

function! Configer#EditConfig(path)
    if empty(a:path)
        echomsg 'empty path'
        let l:path = expand('%:.:h')
    else
        echomsg 'given path'
        let l:path = expand(a:path.':.:h')
    endif
    let l:config = g:Configer_ConfigLookupPath.'/'.l:path.'/'.g:Configer_ConfigFilename
    "if filereadable(a:path)
    "    let l:config = a:path
    "endif
    echomsg l:config
    execute 'edit' l:config
endfunction
