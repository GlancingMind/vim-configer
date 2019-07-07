let s:save_cpo = &cpo
set cpo&vim

function! Configer#Setup()
    function! Blub()
        echomsg 'hello world'
    endfunction

    au! BufEnter * call Blub()

    echomsg 'sourcing'
                \ 'this'
                \ 'multiline string'

    setlocal nonumber
endfunction

function! s:SaveConfig(path)
    let l:settings = getline(0, '$')
    let l:config = Config#Load(g:Configer_DefaultStorage.'/'.g:Configer_ConfigFilename)
    doautocmd BufWritePre
    call l:config.Save(l:settings, a:path)
    set nomodified
    doautocmd BufWritePost
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

function! Configer#ConfigEdit()
    let l:config = Config#Load(g:Configer_DefaultStorage.'/'.g:Configer_ConfigFilename)
    let l:path = expand('%:h').'.'.g:Configer_ConfigFilename
    let l:settings = l:config.GetSettings(l:path)
    execute 'edit '.l:path
    normal! ggdG
    call append(0, s:RemoveTrailingEmptyLines(l:settings))
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
    setlocal bufhidden=hide
    setlocal filetype=vim
    execute 'au! BufWriteCmd <buffer> call s:SaveConfig("'.l:path.'")'
    "on deleting this config buffer, wipe it instead to prevent user from
    "switching via alternate file as this would reveal an empty buffer!
    au! BufDelete <buffer> silent! $bwipeout
endfunction

function! Configer#ApplyConfig()
    let l:path = g:Configer_DefaultStorage.'/'.g:Configer_ConfigFilename
    call s:Apply(l:path)
    "on config save, reapply
    call s:SetupReload(l:path)
endfunction

function! s:Apply(path)
    "echomsg 'apply '.a:path
    let l:config = Config#Load(a:path)
    let l:path = expand('%:h').'.'.g:Configer_ConfigFilename
    let l:settings = l:config.GetSettings(l:path)
    "let l:settings = filter(l:config.GetSettings(l:path), '!empty(v:val)')
    "let l:settings = join(l:config.GetSettings(l:path), ' | ')
    "echomsg l:settings
    "execute l:settings
    "TODO create a unlisted hidden config buffer and use bufdo to call source
    "on this config buffer from current buffer
    "let l:settings = s:RemoveTrailingEmptyLines(l:settings)
    "let l:bnr = bufnr(l:path, 1)
    "execute appendbufline(l:bnr, 0,'echomsg hello world')
    "execute l:bnr.'bufdo setlocal buftype=nowrite'
    "execute l:bnr.'bufdo source expand("%")'
endfunction

function! s:SetupReload(path)
    "TODO need this to be buffer local!
    execute 'augroup configer-reload
                \| au! BufWritePost '.a:path.' call s:Apply()
                \| augroup END'
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
