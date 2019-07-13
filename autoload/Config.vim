let s:Configs = {}

function! Config#Register(config)
    let l:paths = a:config.paths
    unlet a:config.paths
    for l:path in l:paths
        call extend(s:Configs, {l:path: a:config})
    endfor
endfunction

function! s:Serialize(config)
    let l:name = a:config.name
    let l:paths = a:config.paths
    let l:settings = a:config.settings
    let l:config = '{
                \"name": "'.l:name.'",
                \"paths": '.string(l:paths).',
                \"Apply": funcref("s:'.l:name.'"),
                \"settings": s:lines[s:start+1:expand("<slnum>")-3]
                \}'
    return ['let s:lines = readfile(expand("<sfile>"))']
                \+ ['let s:start = expand("<slnum>")']
                \+ ['function! s:'.l:name.'()'] + l:settings + ['endfunction']
                \+ ['call Config#Register('.l:config.')']
                \+ ['unlet s:start', 'unlet s:lines']
endfunction

function! Config#Load()
    source config.vim
endfunction

function! Config#Save()
    let l:configs = [
                \{
                    \'name': 'beep',
                    \'paths': ['/hello/beep', '/wonder/ful/world'],
                    \'settings': ['echomsg "hello"']
                \}, {
                    \'name': 'blub',
                    \'paths': ['autoload'],
                    \'settings': ['echomsg "world"']
                \}]
    let l:serialized = []
    for l:config in l:configs
        let l:serialized += s:Serialize(l:config)
    endfor
    call writefile(l:serialized, 'config.vim')
endfunction

function! Config#Edit(...)
    let l:path = get(a:, 1, g:Configer_EditConfigDefaultPath)
    echomsg l:path
    let l:settings = get(get(s:Configs, l:path, {}), 'settings', [])
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
    "on deleting this config buffer, wipe it instead to prevent user from
    "switching via alternate file as this would reveal an empty buffer!
    au! BufDelete <buffer> silent! $bwipeout
endfunction

