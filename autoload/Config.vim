let s:Configs = []

function! s:Serialize(configs)
    if empty(a:configs)
        return []
    endif
    let l:serialized = []
    let l:id = 0
    for l:config in a:configs
        let l:serializedConfig = '{
                    \"path": "'.l:config.path.'",
                    \"Apply": funcref("s:Config'.l:id.'"),
                    \"settings": s:lines[s:start+1:expand("<slnum>")-3]
                    \}'
        let l:serialized += ['let s:start = expand("<slnum>")']
                    \+ ['function! s:Config'.l:id.'()']
                    \+ l:config.settings
                    \+ ['endfunction']
                    \+ ['call Config#Register('.l:serializedConfig.')']
        let l:id += 1
    endfor
    return ['let s:lines = readfile(expand("<sfile>"))']
            \+  l:serialized
            \+  ['unlet s:start', 'unlet s:lines']
endfunction

function! Config#Register(config)
    "add config or override when already registered
    let l:config = Config#GetConfigByPath(a:config.path)
    if empty(l:config)
        call add(s:Configs, a:config)
    else
        let l:config.settings = a:config.settings
    endif
endfunction

function! Config#New(path, settings)
    return {'path': a:path, 'settings': a:settings}
endfunction

function! Config#GetConfigByPath(path)
    return get(filter(copy(s:Configs), 'v:val.path ==# a:path'), 0, {})
endfunction

function! Config#List()
    for l:config in s:Configs
        echomsg l:config
    endfor
endfunction

function! Config#Load()
    source config.vim
endfunction

function! s:OnSaveConfig(path)
    "update settings of current edited config
    let l:settings = getline(0, '$')
    call Config#Register(Config#New(a:path, l:settings))

    "From here on, serialize all settings and write back to file
    "ignore configs containing no settings
    let l:configs = filter(s:Configs, '!empty(join(v:val.settings))')
    let l:serialized = s:Serialize(l:configs)
    if !empty(l:serialized)
        doautocmd BufWritePre
        call writefile(l:serialized, 'config.vim')
        doautocmd BufWritePost
    endif
    set nomodified
endfunction

function! Config#Edit(...)
    let l:path = get(a:, 1, g:Configer_EditConfigDefaultPath)
    let l:settings = get(Config#GetConfigByPath(l:path), 'settings', [])
    execute 'edit' l:path.'-vimconfig'
    normal! ggdG
    call append(0, l:settings)
    normal gg
    "clear undo history to prevent user from undo append(0, l:settings)
    "see :h clear-undo
    let l:old_undolevels = &undolevels
    setlocal undolevels=-1
    execute "normal a \<BS>\<Esc>"
    let &undolevels = l:old_undolevels
    execute 'setlocal statusline=Edit\ config\ for:\ '.l:path
    setlocal nomodified
    setlocal noswapfile
    setlocal buftype=acwrite
    setlocal bufhidden=hide
    setlocal filetype=vim
    execute 'au! BufWriteCmd <buffer> call s:OnSaveConfig("'.l:path.'")'
    "on deleting this config buffer, wipe it instead to prevent user from
    "switching via alternate file as this would reveal an empty buffer!
    au! BufDelete <buffer> silent! $bwipeout
endfunction

