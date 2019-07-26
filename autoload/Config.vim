let s:Configs = []

function! s:ExtractSettingsFromApplyFunction(config)
    let l:funcdef = execute('function a:config.Apply', 'silent!')
    echomsg l:funcdef
    let l:funcbody = split(l:funcdef, '\n')[1:-2]
    "strip linenumbers and indention from settings -> returning 'settings'
    return map(l:funcbody, 'substitute(v:val, "\\d\\s*", "", "")')
endfunction

function! s:GetSettings(config)
    return get(a:config, 'settings', s:ExtractSettingsFromApplyFunction(a:config))
endfunction

function! s:Serialize(configs)
    if empty(a:configs)
        return []
    endif
    let l:serialized = []
    let l:id = 0
    for l:config in a:configs
        let l:serializedConfig = '{
                    \"glob": "'.l:config.glob.'",
                    \"Apply": funcref("s:Config'.l:id.'")
                    \}'
        let l:serialized += ['function! s:Config'.l:id.'()']
                    \+ s:GetSettings(l:config)
                    \+ ['endfunction']
                    \+ ['call Config#Register('.l:serializedConfig.')']
        let l:id += 1
    endfor
    return l:serialized
endfunction

function! Config#Register(config)
    "add config or override settings when config is already registered
    let l:config = Config#GetConfigWithGlob(a:config.glob)
    if empty(l:config)
        call add(s:Configs, a:config)
    else
        let l:config.settings = s:GetSettings(a:config)
    endif
endfunction

function! Config#New(glob, settings)
    return {'glob': resolve(a:glob), 'settings': a:settings}
endfunction

function! Config#GetConfigWithGlob(glob)
    return get(filter(copy(s:Configs), 'v:val.glob ==# resolve(a:glob)'), 0, {})
endfunction

function! Config#List()
    for l:config in s:Configs
        echomsg l:config
    endfor
endfunction

function! Config#Load()
    let s:Configs = []
    source config.vim
endfunction

function! s:OnSaveConfig(glob)
    "update settings of current edited config
    let l:settings = getline(0, '$')
    call Config#Register(Config#New(a:glob, l:settings))

    "From here on, serialize all settings and write back to file
    "ignore configs containing no settings
    let l:configs = filter(s:Configs, '!empty(join(s:GetSettings(v:val)))')
    let l:serialized = s:Serialize(l:configs)
    if !empty(l:serialized)
        doautocmd BufWritePre
        call writefile(l:serialized, 'config.vim')
        doautocmd BufWritePost
    endif
    set nomodified
endfunction

function! Config#Edit(...)
    let l:glob = resolve(get(a:, 1, g:Configer_EditConfigDefaultGlob))
    let l:settings = s:GetSettings(Config#GetConfigWithGlob(l:glob))
    execute 'edit' l:glob.'-vimconfig'
    normal! ggdG
    call append(0, l:settings)
    normal gg
    "clear undo history to prevent user from undo append(0, l:settings)
    "see :h clear-undo
    let l:old_undolevels = &undolevels
    setlocal undolevels=-1
    execute "normal a \<BS>\<Esc>"
    let &undolevels = l:old_undolevels
    execute 'setlocal statusline=Edit\ config\ for:\ '.l:glob
    setlocal nomodified
    setlocal noswapfile
    setlocal buftype=acwrite
    setlocal bufhidden=hide
    setlocal filetype=vim
    execute 'au! BufWriteCmd <buffer> call s:OnSaveConfig("'.l:glob.'")'
    "on deleting this config buffer, wipe it instead to prevent user from
    "switching via alternate file as this would reveal an empty buffer!
    au! BufDelete <buffer> silent! $bwipeout
endfunction

function! Config#Checkpath()
    for l:config in s:Configs
        if empty(glob(l:config.glob, '', 1))
            echomsg l:config.glob
        endif
    endfor
endfunction

function! Config#ApplysForPath(config, path)
    return a:path =~# glob2regpat(a:config.glob)
endfunction

function! Config#GetConfigsForPath(path)
    return filter(copy(s:Configs), 'Config#ApplysForPath(v:val, a:path)')
endfunction

function! Config#GetAllConfigsAlongPath(path)
    let l:configs = Config#GetConfigsForPath(a:path)
    let l:parent = fnamemodify(resolve(a:path), ':h')
    if a:path ==# l:parent
        return l:configs
    endif
    return l:configs + Config#GetAllConfigsAlongPath(l:parent)
endfunction

function! Config#GetAbsolutePathDepth(path)
    return len(split(fnamemodify(resolve(a:path), ':p'), '/'))
endfunction

"TODO works only for path with common base
function! s:Compare(c1, c2)
    if a:c1.glob ==# a:c2.glob
        return 0
    endif

    if filereadable(a:c1.glob)
        return 1
    elseif filereadable(a:c2.glob)
        return -1
    endif
    "if types are the same
    let l:depth1 = Config#GetAbsolutePathDepth(a:c1.glob)
    let l:depth2 = Config#GetAbsolutePathDepth(a:c2.glob)
    return l:depth1 - l:depth2
endfunction

function! Config#ApplyAllConfigsAlongPath(path)
    for l:config in sort(Config#GetAllConfigsAlongPath(a:path), 's:Compare')
        try
            call l:config.Apply()
        catch
            let l:ln = substitute(v:throwpoint, '.*\D\(\d\+\).*', '\1', "")
            echohl ErrorMsg
            echomsg 'Error in config:' l:config.glob 'at line:' l:ln
            "print error without Vim(global):
            echomsg join(split(v:exception, ':')[1:], ':')
            echohl None
        endtry
    endfor
endfunction

