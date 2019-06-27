if exists('g:Loaded_Configer')
    finish
endif
let g:Loaded_Configer = 1

let s:save_cpo = &cpo
set cpo&vim


"   ==== SETTINGS

let g:Configer_DefaultStorageGlob = get(g:, 'Configer_ConfigStoragePath', 'vimconfig')

let g:Configer_DefaultLookupPath = get(g:, 'Configer_DefaultLookupPath', expand('%:h'))

let g:Configer_ConfigFilename = get(g:, 'Configer_ConfigFilename', 'vimrc')


"   ==== COMMANDS

command! -complete=dir -nargs=* ConfigerEditConfig call Configer#ConfigEdit(<f-args>)

let &cpo = s:save_cpo
unlet s:save_cpo
