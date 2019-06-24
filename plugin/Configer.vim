if exists('g:Loaded_Configer')
    finish
endif
let g:Loaded_Configer = 1

let s:save_cpo = &cpo
set cpo&vim


"   ==== SETTINGS

let g:Configer_DefaultStoragePath = get(g:, 'Configer_ConfigStoragePath', 'vimconfig')

let g:Configer_ConfigStorageUseAbsolutePathes = get(g:, 'Configer_ConfigStorageUseAbsolutePathes', 1)

let g:Configer_ConfigFilename = get(g:, 'Configer_ConfigGlobes', 'vimrc')

let g:Configer_DefaultLookupPath = get(g:, 'Configer_DefaultLookupPath', expand('%:p:h'))


"   ==== COMMANDS

"TODO use ! to create path and without to select only existing ones
"or complete directories and configs
command! -complete=dir -nargs=* ConfigerEditConfig
            \ execute 'edit' Configer#GetConfig(<f-args>)

let &cpo = s:save_cpo
unlet s:save_cpo
