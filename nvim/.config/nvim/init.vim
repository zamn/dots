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

lua<<EOF
vim.o.termguicolors = false
vim.api.nvim_set_hl(0, 'FloatBorder', { link = 'WinSeparator' })
vim.api.nvim_set_hl(0, 'NormalFloat', { link = 'Pmenu' })

require("typescript-tools").setup {
  settings = {
    -- spawn additional tsserver instance to calculate diagnostics on it
    separate_diagnostic_server = true,
    -- "change"|"insert_leave" determine when the client asks the server about diagnostic
    publish_diagnostic_on = "insert_leave",
    -- array of strings("fix_all"|"add_missing_imports"|"remove_unused"|
    -- "remove_unused_imports"|"organize_imports") -- or string "all"
    -- to include all supported code actions
    -- specify commands exposed as code_actions
    expose_as_code_action = {},
    -- specify a list of plugins to load by tsserver, e.g., for support `styled-components`
    -- (see 💅 `styled-components` support section)
    tsserver_plugins = {},
    -- this value is passed to: https://nodejs.org/api/cli.html#--max-old-space-sizesize-in-megabytes
    -- memory limit in megabytes or "auto"(basically no limit)
    tsserver_max_memory = 12000,
    -- described below
    tsserver_format_options = {},
    tsserver_file_preferences = {
      importModuleSpecifierPreference = "relative"
    },
    -- locale of all tsserver messages, supported locales you can find here:
    -- https://github.com/microsoft/TypeScript/blob/3c221fc086be52b19801f6e8d82596d04607ede6/src/compiler/utilitiesPublic.ts#L620
    tsserver_locale = "en",
    -- mirror of VSCode's `typescript.suggest.completeFunctionCalls`
    complete_function_calls = false,
    include_completions_with_insert_text = true,
    -- CodeLens
    -- WARNING: Experimental feature also in VSCode, because it might hit performance of server.
    -- possible values: ("off"|"all"|"implementations_only"|"references_only")
    code_lens = "off",
    -- by default code lenses are displayed on all referencable values and for some of you it can
    -- be too much this option reduce count of them by removing member references from lenses
    disable_member_code_lens = true,
    -- JSXCloseTag
    -- WARNING: it is disabled by default (maybe you configuration or distro already uses nvim-ts-autotag,
    -- that maybe have a conflict if enable this feature. )
    jsx_close_tag = {
        enable = false,
        filetypes = { "javascriptreact", "typescriptreact" },
    }
  },
}

-- Set up nvim-cmp.
local cmp = require('cmp')
local luasnip = require('luasnip')

luasnip.filetype_extend("javascript", { "javascriptreact" })
luasnip.filetype_extend("typescript", { "typescriptreact" })

cmp.setup({
  preselect = cmp.PreselectMode.Item,
  completion = {
    completeopt = "menu,menuone,noinsert",
    autocomplete = {
      cmp.TriggerEvent.TextChanged,
      cmp.TriggerEvent.InsertEnter,
    },
  },
  performance = {
    max_view_entries = 20,
    debounce = 150,
  },
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = 'nvim_lsp_signature_help', },
    { name = "path" },
    { name = "crates" },
    {
      name = "buffer",
      keyword_length = 4,
      max_item_count = 10,
      option = {
        get_bufnrs = function()
          local buf = vim.api.nvim_get_current_buf()
          local byte_size = vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
          if byte_size > 1024 * 1024 then
            return {}
          end
          return { buf }
        end,
        indexing_interval = 1000,
      },
    },
  }),
  mapping = cmp.mapping.preset.insert({
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  }),
  experimental = {
    ghost_text = true,
  },
})

require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    javascript = { "prettierd", "prettier", stop_after_first = true },
    typescript = { "prettierd", "prettier", stop_after_first = true },
    javascriptreact = { "prettierd", "prettier", stop_after_first = true },
    typescriptreact = { "prettierd", "prettier", stop_after_first = true },
  },
})

require('lspconfig')['typescript-tools'].setup({
  capabilities = require('cmp_nvim_lsp').default_capabilities()
})

require("trouble").setup()

EOF

if !empty(glob('$HOME/.config/nvim/gitlab.vim'))
  source $HOME/.config/nvim/gitlab.vim
endif

if !empty(glob('$HOME/.config/nvim/remote-vim.vim'))
  source $HOME/.config/nvim/remote-vim.vim
endif

function! NearestMethodOrFunction() abort
  return get(b:, 'vista_nearest_method_or_function', '')
endfunction

set statusline+=%{NearestMethodOrFunction()}

function! HasPlug(name) abort
  return has_key(g:plugs, a:name)
endfunction

if HasPlug('indent-blankline.nvim')
    autocmd VimEnter * call Setup_ibl()
endif

function! Setup_ibl() abort
lua<<EOF
require("ibl").setup()
EOF
endfunction

" Fix clipboard over ssh 4gud
" TODO: This breaks if display is bork
"
" let $SSH_CONNECTION = system('echo $SSH_CONNECTION')
" let g:clipboard = {
"    \   'name': 'ssh clipboard',
"    \   'copy': {
"    \      '+': ['bash', 'copy-over-ssh.sh'],
"    \      '*': ['bash', 'copy-over-ssh.sh'],
"    \    },
"    \   'paste': {
"    \      '+': ['xclip', '-select', 'clipboard', '-o'],
"    \      '*': ['xclip', '-select', 'clipboard', '-o'],
"    \   }
"    \ }


lua<<EOF
vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = require('vim.ui.clipboard.osc52').copy '+',
    ['*'] = require('vim.ui.clipboard.osc52').copy '*',
  },
  paste = {
    ['+'] = require('vim.ui.clipboard.osc52').paste '+',
    ['*'] = require('vim.ui.clipboard.osc52').paste '*',
  },
}
EOF

" CTRL-W < Decrease current window width by N (default 1).
" CTRL-W > Increase current window width by N (default 1).
let g:NERDTreeWinSize=35
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


nnoremap <c-p> :Files<cr>

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

" Formatter
nmap <leader>p :lua require("conform").format()<CR>

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
