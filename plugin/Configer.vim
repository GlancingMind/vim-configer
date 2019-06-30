if exists('g:Loaded_Configer')
    finish
endif
let g:Loaded_Configer = 1

let s:save_cpo = &cpo
set cpo&vim

"   ==== SETTINGS

let g:Configer_DefaultStorage = get(g:, 'Configer_ConfigStoragePath', 'vimconfig')

"let g:Configer_DefaultLookupPath = expand('%:h')

let g:Configer_ConfigFilename = get(g:, 'Configer_ConfigFilename', fnamemodify(getcwd(), ':t'))

"   ==== COMMANDS

command! -complete=dir -nargs=* ConfigerEditConfig call Configer#ConfigEdit(<f-args>)

"   ==== AUTOCMDS

"TODO need autocmd for reloading and applying new settings to existing buffers

augroup vim-configer
    autocmd!
    "This parses the config even on switching
    "au! BufEnter * call Configer#ApplyConfig()
    "with this we source less, which is gread when settings are bound to buffer
    au! BufReadPre * call Configer#ApplyConfig()
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo
