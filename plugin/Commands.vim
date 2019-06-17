
command! -complete=dir -nargs=* ConfigerEditConfig
            \ call Configer#EditConfig(<q-args>)
