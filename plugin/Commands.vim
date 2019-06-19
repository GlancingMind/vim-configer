
"TODO use ! to create path and without to select only existing ones
"or complete directories and configs
command! -complete=dir -nargs=* ConfigerEditConfig
            \ execute 'edit' Configer#GetConfig(<f-args>)

