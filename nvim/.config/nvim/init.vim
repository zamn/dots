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
Plug 'nvim-mini/mini.icons'
Plug 'ibhagwan/fzf-lua'

"liuchengxu/eleline.vim
Plug 'bling/vim-airline'

Plug 'fatih/vim-go'

Plug 'lervag/vimtex'

" LSP stuff
Plug 'nvim-lua/plenary.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'pmizio/typescript-tools.nvim'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-nvim-lsp-signature-help'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'

Plug 'nikvdp/ejs-syntax'

Plug 'folke/trouble.nvim'

" Formatter
Plug 'stevearc/conform.nvim'

"DB Viewer
Plug 'tpope/vim-dadbod'
Plug 'kristijanhusak/vim-dadbod-ui'
Plug 'kristijanhusak/vim-dadbod-completion' "Optional

Plug 'iamcco/markdown-preview.nvim', { 'do': ':call mkdp#util#install()', 'for': 'markdown' }

Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'

Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
Plug 'othree/yajs.vim'

Plug 'jparise/vim-graphql'

Plug 'moll/vim-node'

Plug 'prisma/vim-prisma'

" FIGURE OUT
" Plug 'zbirenbaum/copilot.lua'
" Plug 'nvim-lua/plenary.nvim'
" Plug 'CopilotC-Nvim/CopilotChat.nvim', { 'branch': 'canary' }


" Plug 'github/copilot.vim'

Plug 'HerringtonDarkholme/yats.vim'

Plug 'scrooloose/nerdtree'

Plug 'liuchengxu/vista.vim'

Plug 'raimondi/delimitmate'

Plug 'tpope/vim-commentary'

Plug 'lukas-reineke/indent-blankline.nvim'

Plug 'romainl/vim-qf'

" Matching blocks
" Plug 'tmhedberg/matchit'

" go into file = gf, <c-w>gf (new tab), <c-w>f (new split)

" UndotreeToggle
Plug 'mbbill/undotree'

" Tag file management
Plug 'xolox/vim-misc'

"Plug 'ludovicchabant/vim-gutentags'

" GIIIIIT
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'shumphrey/fugitive-gitlab.vim'
Plug 'gregsexton/gitv', {'on': ['Gitv']}

Plug 'hashivim/vim-terraform'

Plug 'chriskempson/base16-vim'

call plug#end()

" Reverting to old vim colorscheme
" colorscheme vim
" autocmd ColorScheme vim
let base16colorspace=256  " Access colors present in 256 colorspace
" colorscheme vim
colorscheme base16-default-dark

" CTRL-W < Decrease current window width by N (default 1).
" CTRL-W > Increase current window width by N (default 1).
let g:NERDTreeWinSize=35
let g:NERDTreeShowHidden=1
map <F2> :NERDTreeToggle<CR>

let g:airline#extensions#tabline#formatter = 'unique_tail'

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_tab_nr = 1
let g:airline#extensions#tabline#tab_nr_type= 2
let g:airline#extensions#tabline#show_tab_type = 1

" use <tab> for trigger completion and navigate to next complete item
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

" MarkdownPreview plugin, set port so we can forward it
" use a custom port to start server or random for empty
let g:mkdp_port = '1337'
let g:mkdp_echo_preview_url = 1

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction


" nnoremap <c-p> :lua require("fzf-lua").files({ fzf_opts = {['--color=dark --margin=1,1 --color=fg:15,bg:-1,hl:1,fg+:#ffffff,bg+:0,hl+:1 --color=info:0,pointer:12,marker:4,spinner:11,header:-1 --layout'] = 'reverse-list'} })<CR>


" Auto-create parent directories (except for URIs ://).
au BufWritePre,FileWritePre * if @% !~# '\(://\)' | call mkdir(expand('<afile>:p:h'), 'p') | endif

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
set encoding=utf-8

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


nmap <leader>td :lua vim.lsp.buf.definition()<CR>

nmap <leader>xx :Trouble diagnostics toggle<CR>

" hi Pmenu ctermbg=gray guibg=gray ctermfg=black guifg=black
" hi PmenuSel ctermbg=darkgray guibg=darkgray ctermfg=black guifg=black
"hi link Pmenu PmenuSel
" hi link Pmenu PmenuSbar
" hi link Pmenu PmenuThumb

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

" psql editing
au BufRead /tmp/psql.edit.* set syntax=sql

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

autocmd Syntax c,cpp,vim,xml,html,xhtml,perl,javascript,ruby,json normal zR

" The Silver Searcher
if executable('rg')
  " Use ag over grep
  set grepprg=rg
endif


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


" let me navigate errors via leader n/p

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

" Load local vim files
set exrc

lua require('configure')


