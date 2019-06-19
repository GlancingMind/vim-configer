
"TODO use default storage globes which will list all storages options in order
"of lookup e.g. %, cwd, root,...
let g:Configer_DefaultStoragePath = get(g:, 'Configer_ConfigStoragePath', 'vimconfig')

let g:Configer_ConfigStorageUseAbsolutePathes = get(g:, 'Configer_ConfigStorageUseAbsolutePathes', 1)

let g:Configer_ConfigFilename = get(g:, 'Configer_ConfigGlobes', 'vimrc')

let g:Configer_DefaultLookupPath = get(g:, 'Configer_DefaultLookupPath', '.')

