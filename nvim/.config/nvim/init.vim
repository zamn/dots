"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

filetype off
set number

" Install vim-plug if missing
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall
endif

call plug#begin('~/.local/share/nvim/plugged')

Plug 'junegunn/vim-easy-align'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'w0rp/ale'

"liuchengxu/eleline.vim
Plug 'bling/vim-airline'

Plug 'fatih/vim-go'

Plug 'neoclide/coc.nvim', {'branch': 'release'}

" This should be after coc.nvim since that sets up yarn for us
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & yarn install'  }

Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-dispatch'

Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
Plug 'othree/yajs.vim'

Plug 'jparise/vim-graphql'

Plug 'moll/vim-node'

Plug 'HerringtonDarkholme/yats.vim'

Plug 'scrooloose/nerdtree'

Plug 'liuchengxu/vista.vim'

Plug 'raimondi/delimitmate'

Plug 'tpope/vim-commentary'

Plug 'romainl/vim-qf'

" go into file = gf, <c-w>gf (new tab), <c-w>f (new split)

" UndotreeToggle
Plug 'mbbill/undotree'

" Tag file management
Plug 'xolox/vim-misc'

"Plug 'ludovicchabant/vim-gutentags'

" GIIIIIT
Plug 'tpope/vim-fugitive'
Plug 'shumphrey/fugitive-gitlab.vim'
Plug 'gregsexton/gitv', {'on': ['Gitv']}

call plug#end()

if !empty(glob('$HOME/.config/nvim/gitlab.vim'))
  source $HOME/.config/nvim/gitlab.vim
endif

function! NearestMethodOrFunction() abort
  return get(b:, 'vista_nearest_method_or_function', '')
endfunction

set statusline+=%{NearestMethodOrFunction()}

" Error and warning signs.
let g:ale_sign_error = '⤫'
let g:ale_sign_warning = '⚠'

" CTRL-W < Decrease current window width by N (default 1).
" CTRL-W > Increase current window width by N (default 1).
let g:NERDTreeWinSize=35
map <F2> :NERDTreeToggle<CR>

let g:ale_linters = {
\   'javascript': ['eslint'],
\   'typescript': ['tslint'],
\}

" Enable integration with airline.
let g:airline#extensions#ale#enabled = 1

let g:airline#extensions#tabline#formatter = 'unique_tail'

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_tab_nr = 1
let g:airline#extensions#tabline#tab_nr_type= 2
let g:airline#extensions#tabline#show_tab_type = 1

let g:ale_lint_on_text_changed = 'never'

" use <tab> for trigger completion and navigate to next complete item
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

nnoremap <c-p> :Files<cr>

" Zoom / Restore window.
function! s:ZoomToggle() abort
  if exists('t:zoomed') && t:zoomed
    execute t:zoom_winrestcmd
    let t:zoomed = 0
  else
    let t:zoom_winrestcmd = winrestcmd()
    resize
    vertical resize
    let t:zoomed = 1
  endif
endfunction
command! ZoomToggle call s:ZoomToggle()

let g:rbpt_colorpairs = [
    \ ['brown',       'RoyalBlue3'],
    \ ['Darkblue',    'SeaGreen3'],
    \ ['darkgray',    'DarkOrchid3'],
    \ ['darkgreen',   'firebrick3'],
    \ ['darkcyan',    'RoyalBlue3'],
    \ ['darkred',     'SeaGreen3'],
    \ ['darkmagenta', 'DarkOrchid3'],
    \ ['brown',       'firebrick3'],
    \ ['gray',        'RoyalBlue3'],
    \ ['black',       'SeaGreen3'],
    \ ['darkmagenta', 'DarkOrchid3'],
    \ ['Darkblue',    'firebrick3'],
    \ ['darkgreen',   'RoyalBlue3'],
    \ ['darkcyan',    'SeaGreen3'],
    \ ['darkred',     'DarkOrchid3'],
    \ ['red',         'firebrick3'],
  \ ]

" airline Font Fix
let g:airline_powerline_fonts = 1

set history=1000
set undolevels=1000
set title

set completeopt-=preview

" Might want this need to investigate more
" Set local dir to vim file dir
" set autochdir

" Enable filetype plugins
filetype plugin on
filetype indent on

setlocal indentkeys+=0.

" With a map leader it's possible to do extra key combinations
" like <leader>w saves the current file
let mapleader = " "
let g:maplocalleader = " "
let g:mapleader = " "

" Golang stuff
autocmd BufWritePre *.go :call CocAction('runCommand', 'editor.action.organizeImport')

" :W sudo saves the file
" (useful for handling the permission-denied error)
" command Ws w !sudo tee % > /dev/null

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Ignore compiled files
set wildignore=*.o,*~,*.pyc
if has("win16") || has("win32")
    set wildignore+=*/.hg/*,*/.svn/*,*/.DS_Store
else
    set wildignore+=.hg\*,.svn\*
endif

" Height of the command bar
set cmdheight=2

" Use mouse to scroll
set mouse=a

" A buffer becomes hidden when it is abandoned
set hidden

" Let us jump files using gi
set path+=**

set whichwrap+=<,>,h,l

" Ignore case when searching
set ignorecase

" Don't redraw while executing macros (good performance config)
set lazyredraw

" For regular expressions turn magic on
set magic

" Show matching brackets when text indicator is over them
set showmatch
" How many tenths of a second to blink when matching brackets
set mat=2

" auto load new file changes
set autoread
au FocusGained * :checktime

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" Add a bit extra margin to the left
set foldcolumn=1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable syntax highlighting
syntax enable

" Enable 256 colors in vim (regardless of terminal or gui)
set t_Co=256

" Vim will infinitely wait for succeeding actions
set notimeout
set ttimeout

" Set extra options when running in GUI mode
if has("gui_running")
    set guioptions-=T
    set guioptions-=e
    set t_Co=256
    set guitablabel=%M\ %t
endif

" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8

" Use Unix as the standard file type
set ffs=unix,dos,mac

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Files, backups and undo
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Turn backup off, since most stuff is in SVN, git et.c anyway...
set nobackup
set nowb
set noswapfile

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use spaces instead of tabs
set expandtab

" 1 tab == 2 spaces
set shiftwidth=4
set tabstop=4

" Linebreak on 500 characters
set lbr
set tw=500

set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines

""""""""""""""""""""""""""""""
" => Visual mode related
""""""""""""""""""""""""""""""
" Visual mode pressing * or # searches for the current selection
" Super useful! From an idea by Michael Naumann
vnoremap <silent> * :call VisualSelection('f', '')<CR>
vnoremap <silent> # :call VisualSelection('b', '')<CR>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Moving around, tabs, windows and buffers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Treat long lines as break lines (useful when moving around in them)
map j gj
map k gk

" Code exploring
" map <C-t> <C-[>
map <F3> :Vista!!<CR>

" Folds on folds on folds
set foldmethod=syntax
set nofoldenable
set foldlevel=50
" za,zc,zo - zA, zC, zO
"map <leader>ft za<cr>

nmap <leader>td <Plug>(coc-definition)
nmap <leader>ttd <Plug>(coc-type-definition)
nmap <leader>ti <Plug>(coc-implementation)
nmap <leader>tr <Plug>(coc-references)

nmap <leader>ec :call EditCompiledVersion()<CR>

nmap <leader>mt :execute "Dispatch ./node_modules/.bin/mocha --require source-map-support/register --recursive --exit " . GetCompiledVersion()<CR>

hi CocErrorFloat ctermfg=white guifg=white ctermbg=brown
hi CocInfoFloat ctermfg=darkblue guifg=darkblue
hi CocWarningFloat ctermfg=brown guifg=brown

hi Pmenu ctermbg=gray guibg=gray ctermfg=black guifg=black
hi PmenuSel ctermbg=darkgray guibg=darkgray ctermfg=black guifg=black
"hi link Pmenu PmenuSel
hi link Pmenu PmenuSbar
hi link Pmenu PmenuThumb

" Disable highlight when <leader><cr> is pressed
map <silent> <leader><cr> :noh<cr>

" Smart way to move between windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" Close all the buffers
map <leader>ba :1,1000 bd!<cr>

map <leader>r :so $MYVIMRC<cr>

" Useful mappings for managing tabs
map <leader>tn :tabnext<cr>
map <leader>tp :tabprev<cr>
map <leader>tc :tabnew<cr>

" Useful mappings for managing buffers
map <leader>bn :bn<cr>
map <leader>bp :bp<cr>
" Close the current buffer
map <leader>bd :Bclose<cr>

" Specify the behavior when switching between buffers
try
  set switchbuf=useopen,usetab,newtab
  set stal=2
catch
endtry

" Return to last edit position when opening files (You want this!)
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif

" Remember info about open buffers on close
set viminfo^=%

""""""""""""""""""""""""""""""
" => Status line
""""""""""""""""""""""""""""""

" Format the status line
set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l
set statusline+=%#warningmsg#
set statusline+=%*

" Show number of matches for a search in status line
" set statusline+=\ %{g:matchnum}\ matches

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Editing mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Delete trailing white space on save, useful for Python and CoffeeScript ;)
func! DeleteTrailingWS()
  exe "normal mz"
  %s/\s\+$//ge
  exe "normal `z"
endfunc
autocmd BufWrite * :call DeleteTrailingWS()

" Git commit auto wrap
" autocmd Filetype gitcommit textwidth=72

noremap <Leader>f :exe "normal! gg=G``zz"<CR>

autocmd Syntax c,cpp,vim,xml,html,xhtml,perl,javascript,ruby,json normal zR

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => vimgrep searching and cope displaying
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" When you press gv you vimgrep after the selected text
vnoremap <silent> gv :call VisualSelection('gv', '')<CR>

" When you press <leader>r you can search and replace the selected text
vnoremap <silent> <leader>r :call VisualSelection('replace', '')<CR>

" The Silver Searcher
if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor
endif

" Do :help cope if you are unsure what cope is. It's super useful!
"
" When you search with vimgrep, display your results in cope by doing:
"   <leader>cc
"
" To go to the next search result do:
"   <leader>n
"
" To go to the previous search results do:
"   <leader>p
"
map <leader>cc :call QuickfixToggle()<cr>
map <leader>co ggVGy:tabnew<cr>:set syntax=qf<cr>pgg

let g:quickfix_is_open = 0

function! QuickfixToggle()
    if g:quickfix_is_open
        lclose
        let g:quickfix_is_open = 0
    else
        lopen
        let g:quickfix_is_open = 1
    endif
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Spell checking
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Pressing ,ss will toggle and untoggle spell checking
map <leader>ss :setlocal spell!<cr>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Misc
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Remove the Windows ^M - when the encodings gets messed up
noremap <Leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

" Quickly open a buffer for scripbble
map <leader>q :e ~/buffer<cr>

" Toggle paste mode on and off
map <leader>pp :setlocal paste!<cr>


" let me navigate errors via leader n/p
map <leader>n <Plug>(qf_qf_next)
map <leader>p <Plug>(qf_qf_previous)

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! CmdLine(str)
    exe "menu Foo.Bar :" . a:str
    emenu Foo.Bar
    unmenu Foo
endfunction

function! VisualSelection(direction, extra_filter) range
    let l:saved_reg = @"
    execute "normal! vgvy"

    let l:pattern = escape(@", '\\/.*$^~[]')
    let l:pattern = substitute(l:pattern, "\n$", "", "")

    if a:direction == 'b'
        execute "normal ?" . l:pattern . "^M"
    elseif a:direction == 'gv'
        call CmdLine("vimgrep " . '/'. l:pattern . '/' . ' **/*.' . a:extra_filter)
    elseif a:direction == 'replace'
        call CmdLine("%s" . '/'. l:pattern . '/')
    elseif a:direction == 'f'
        execute "normal /" . l:pattern . "^M"
    endif

    let @/ = l:pattern
    let @" = l:saved_reg
endfunction


" Returns true if paste mode is enabled
function! HasPaste()
    if &paste
        return 'PASTE MODE  '
    en
    return ''
endfunction

" Don't close window, when deleting a buffer
command! Bclose call <SID>BufcloseCloseIt()
function! <SID>BufcloseCloseIt()
   let l:currentBufNum = bufnr("%")
   let l:alternateBufNum = bufnr("#")

   if buflisted(l:alternateBufNum)
     buffer #
   else
     bnext
   endif

   if bufnr("%") == l:currentBufNum
     new
   endif

   if buflisted(l:currentBufNum)
     execute("bdelete! ".l:currentBufNum)
   endif
endfunction

function! EditCompiledVersion()
    execute("tabnew " . GetCompiledVersion())
endfunction

function! GetCompiledVersion()
    if &ft == "typescript"
        return "dist-server/" . expand("%:r") . ".js"
    else
        return "dist-server/" . expand("%:.")
    endif
endfunction

" Load local vim files
set exrc
