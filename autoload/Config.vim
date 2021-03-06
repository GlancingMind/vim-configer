let s:Config = {
            \'root': '',
            \'id': ''
            \}

function! s:GetScriptNumber(scriptname)
    let l:scripts = split(execute('scriptnames'), "\n")
    let l:scriptname = fnamemodify(a:scriptname, ":~")
    let l:script = get(filter(l:scripts, 'v:val =~# "\\".l:scriptname."$"'), 0, "")
    return trim(get(split(l:script, ':'), 0, -1))
endfunction

function! s:ExtractFunctionName(func)
    let l:pattern = 'function\s<SNR>\d\+_\([[:alnum:]_]\+\)()'
    return substitute(a:func, l:pattern, '\1', '')
endfunction

function! s:Encode(string)
    return eval('"'.substitute(a:string, '[^[:alnum:]]', '_".char2nr("&")."_', 'g').'"')
endfunction

function! s:Decode(string)
    return eval('"'.substitute(a:string, '_\d\+_', '".nr2char("&"[1:-2])."', 'g').'"')
endfunction

function! Config#Load(path, ...)
    let l:force = get(a:, 1, 0)
    let l:self = copy(s:Config)
    let l:self.root = fnamemodify(a:path, ":p")
    let l:self.id = s:GetScriptNumber(l:self.root)
    if filereadable(l:self.root)
        if l:self.id == -1 || l:force == 1
            execute 'source '.l:self.root
        endif
    endif

    "setup autocmd for each config
    "using sort to force registration of autocmds according to their path
    "this will determine the execution order of the configs!
    "e.g. *.vim -> plugin/* -> plugin/Config.vim
    for l:config in sort(l:self.List())
        let l:funcName = '<SNR>'.self.id.'_'.s:Encode(l:config).'()'
        "define for each rule in config an autocmd under vim-configer augroup
        augroup vim-configer
        execute 'autocmd! vim-configer BufEnter' l:config 'call' l:funcName
    endfor
    return l:self
endfunction

function! s:Config.List() dict
    let l:functions = split(execute('function /'.self.id), '\n')
    return map(l:functions, 's:Decode(s:ExtractFunctionName(v:val))')
endfunction

function! s:Config.Serialize() dict
    let l:configs = []
                "\'if exists("s:ConfigLoaded")',
                "\'  finish',
                "\'endif',
                "\'let s:ConfigLoaded = 1']
    for l:config in self.List()
        let l:configs += ['function! s:'.s:Encode(l:config).'()']
                    \+ self.GetSettings(l:config)
                    \+ ['endfunction']
    endfor
    return l:configs
endfunction

function! s:Config.Unload(path) dict
    let l:path = resolve(a:path)
    for l:config in filter(self.List(), 'v:val ==# l:path')
        let l:funcName = '<SNR>'.self.id.'_'.s:Encode(l:config)
        "remove all autocmds for this config
        execute 'autocmd! vim-configer BufEnter' l:config
        "delete all functions for this config
        execute 'delfunction!' l:funcName
    endfor
endfunction

function! s:Config.Reload() dict
    for l:config in self.List()
        call self.Unload(l:config)
    endfor
    "force reload of config!
    call Config#Load(self.root, 1)
endfunction

function! s:Config.Save(path, settings) dict
    "enter new settings in vim
    call execute(join(['function! <SNR>'.self.id.'_'.s:Encode(a:path).'()']
                \+ a:settings
                \+ ['endfunction'], "\n"))
    "take all functions and write them back to file
    call writefile(self.Serialize(), self.root)
endfunction

function! s:Config.GetSettings(path) dict
    let l:fname = s:Encode(a:path)
    let l:funcdef = execute('function <SNR>'.self.id.'_'.l:fname, 'silent!')
    "strip header end footer of function
    let l:funcbody = split(l:funcdef, '\n')[1:-2]
    "strip linenumbers and indention from function
    return map(l:funcbody, 'substitute(v:val, "^\\d\*\\s*", "", "")')
endfunction

function! s:Config.Edit(path) dict
    let l:path = resolve(a:path)
    execute 'edit' l:path.'-vimconfig'
    normal! ggdG
    call append(0, self.GetSettings(l:path))
    "delete empty last line from append
    $delete _
    normal gg
    "clear undo history to prevent user from undo append(0, self.GetSettings())
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
    execute 'au! BufWriteCmd <buffer>
                \   call Config#Load("'.self.root.'").Save("'.l:path.'",getline(0, "$"))
                \|  set nomodified'
    "on deleting this config buffer, wipe it instead to prevent user from
    "switching via alternate file as this would reveal an empty buffer!
    au! BufDelete <buffer> silent! $bwipeout
endfunction
