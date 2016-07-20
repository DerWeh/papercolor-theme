" Theme: PaperColor
" Author: Nguyen Nguyen <NLKNguyen@MSN.com>
" License: MIT
" Origin: http://github.com/NLKNguyen/papercolor-theme.git
"
" Improvised from the theme 'Tomorrow'

hi clear
syntax reset
let g:colors_name = "PaperColor"

" Helper Functions: {{{
" Returns an approximate grey index for the given grey level
fun s:grey_number(x)
  if &t_Co == 88
    if a:x < 23
      return 0
    elseif a:x < 69
      return 1
    elseif a:x < 103
      return 2
    elseif a:x < 127
      return 3
    elseif a:x < 150
      return 4
    elseif a:x < 173
      return 5
    elseif a:x < 196
      return 6
    elseif a:x < 219
      return 7
    elseif a:x < 243
      return 8
    else
      return 9
    endif
  else
    if a:x < 14
      return 0
    else
      let l:n = (a:x - 8) / 10
      let l:m = (a:x - 8) % 10
      if l:m < 5
        return l:n
      else
        return l:n + 1
      endif
    endif
  endif
endfun

" Returns the actual grey level represented by the grey index
fun s:grey_level(n)
  if &t_Co == 88
    if a:n == 0
      return 0
    elseif a:n == 1
      return 46
    elseif a:n == 2
      return 92
    elseif a:n == 3
      return 115
    elseif a:n == 4
      return 139
    elseif a:n == 5
      return 162
    elseif a:n == 6
      return 185
    elseif a:n == 7
      return 208
    elseif a:n == 8
      return 231
    else
      return 255
    endif
  else
    if a:n == 0
      return 0
    else
      return 8 + (a:n * 10)
    endif
  endif
endfun

" Returns the palette index for the given grey index
fun s:grey_colour(n)
  if &t_Co == 88
    if a:n == 0
      return 16
    elseif a:n == 9
      return 79
    else
      return 79 + a:n
    endif
  else
    if a:n == 0
      return 16
    elseif a:n == 25
      return 231
    else
      return 231 + a:n
    endif
  endif
endfun

" Returns an approximate colour index for the given colour level
fun s:rgb_number(x)
  if &t_Co == 88
    if a:x < 69
      return 0
    elseif a:x < 172
      return 1
    elseif a:x < 230
      return 2
    else
      return 3
    endif
  else
    if a:x < 75
      return 0
    else
      let l:n = (a:x - 55) / 40
      let l:m = (a:x - 55) % 40
      if l:m < 20
        return l:n
      else
        return l:n + 1
      endif
    endif
  endif
endfun

" Returns the actual colour level for the given colour index
fun s:rgb_level(n)
  if &t_Co == 88
    if a:n == 0
      return 0
    elseif a:n == 1
      return 139
    elseif a:n == 2
      return 205
    else
      return 255
    endif
  else
    if a:n == 0
      return 0
    else
      return 55 + (a:n * 40)
    endif
  endif
endfun

" Returns the palette index for the given R/G/B colour indices
fun s:rgb_colour(x, y, z)
  if &t_Co == 88
    return 16 + (a:x * 16) + (a:y * 4) + a:z
  else
    return 16 + (a:x * 36) + (a:y * 6) + a:z
  endif
endfun

" Returns the palette index to approximate the given R/G/B colour levels
fun s:colour(r, g, b)
  " Get the closest grey
  let l:gx = s:grey_number(a:r)
  let l:gy = s:grey_number(a:g)
  let l:gz = s:grey_number(a:b)

  " Get the closest colour
  let l:x = s:rgb_number(a:r)
  let l:y = s:rgb_number(a:g)
  let l:z = s:rgb_number(a:b)

  if l:gx == l:gy && l:gy == l:gz
    " There are two possibilities
    let l:dgr = s:grey_level(l:gx) - a:r
    let l:dgg = s:grey_level(l:gy) - a:g
    let l:dgb = s:grey_level(l:gz) - a:b
    let l:dgrey = (l:dgr * l:dgr) + (l:dgg * l:dgg) + (l:dgb * l:dgb)
    let l:dr = s:rgb_level(l:gx) - a:r
    let l:dg = s:rgb_level(l:gy) - a:g
    let l:db = s:rgb_level(l:gz) - a:b
    let l:drgb = (l:dr * l:dr) + (l:dg * l:dg) + (l:db * l:db)
    if l:dgrey < l:drgb
      " Use the grey
      return s:grey_colour(l:gx)
    else
      " Use the colour
      return s:rgb_colour(l:x, l:y, l:z)
    endif
  else
    " Only one possibility
    return s:rgb_colour(l:x, l:y, l:z)
  endif
endfun

" Returns the palette index to approximate the '#rrggbb' hex string
fun s:rgb(rgb)
  let l:r = ("0x" . strpart(a:rgb, 1, 2)) + 0
  let l:g = ("0x" . strpart(a:rgb, 3, 2)) + 0
  let l:b = ("0x" . strpart(a:rgb, 5, 2)) + 0

  return s:colour(l:r, l:g, l:b)
endfun

" Sets the highlighting for the given group
fun s:HL(group, fg, bg, attr)
  let l:command = "hi " . a:group

  if s:use_gui_color  " GUI VIM

    if !empty(a:fg)
      let l:command .= " guifg=" . a:fg[0] " use the 1st item in the array
    endif
    if !empty(a:bg)
      let l:command .= " guibg=" . a:bg[0]
    endif
    if a:attr != ""
      let l:command .= " gui=" . a:attr
    endif

  elseif s:use_256_color " 256-color Terminal

    if !empty(a:fg)
      let l:command .= " ctermfg=" . a:fg[-2] " use the 2nd before the last
    endif
    if !empty(a:bg)
      let l:command .= " ctermbg=" . a:bg[-2]
    endif
    if a:attr != ""
      let l:command .= " cterm=" . a:attr
    endif

  else " 16-color Terminal

    if !empty(a:fg)
      let l:command .= " ctermfg=" . a:fg[-1] " use the last item in the array
    endif
    if !empty(a:bg)
      let l:command .= " ctermbg=" . a:bg[-1]
    endif
    if a:attr != ""
      let l:command .= " cterm=" . a:attr
    endif

  endif

  exec l:command
endfun

fun s:Load_Settings_Override(custom)
  if has_key(a:custom, 'cursorline')
    let s:cursorline = [a:custom['cursorline'], '' . s:rgb(a:custom['cursorline'])]
  endif
  if has_key(a:custom, 'background')
    let s:background = [a:custom['background'], '' . s:rgb(a:custom['background'])]
  endif
  if has_key(a:custom, 'matchparen')
    let s:matchparen = [a:custom['matchparen'], '' . s:rgb(a:custom['matchparen'])]
  endif
  if has_key(a:custom, 'comment')
    let s:comment = [a:custom['comment'], '' . s:rgb(a:custom['comment'])]
  endif
endfun
" }}}

" THEMES: {{{

let s:themes = {}

let s:themes['papercolor'] = {
      \   'maintainer' : 'Nguyen Nguyen<NLKNguyen@MSN.com>',
      \   'description' : ' ... '
      \ }

let s:themes['papercolor'].dark = {
      \     'palette' : {
      \       'color00' : ['#262626', '234'],
      \       'color01' : ['#df0000', '100'], 
      \       'color02' : ['#5faf00', '70'],
      \       'color03' : ['#dfaf5f', '179'], 
      \       'color04' : ['#303030', '235'],
      \       'color05' : ['#578787', '29'], 
      \       'color06' : ['#df875f', '173'], 
      \       'color07' : ['#d0d0d0', '251'], 
      \       'color08' : ['#8a8a8a', '244'], 
      \       'color09' : ['#5faf5f', '71'],
      \       'color10' : ['#afdf00', '148'],
      \       'color11' : ['#af87df', '140'], 
      \       'color12' : ['#444444', '237'], 
      \       'color13' : ['#ff5faf', '205'],
      \       'color14' : ['#00afaf', '37'], 
      \       'color15' : ['#5fafdf', '74'],
      \       'color16' : ['#dfaf00', '178'],
      \       'color17' : ['#af8787', '138'],
      \       'cursor_fg' : ['#262626', '234'],
      \       'cursor_bg' : ['#d0d0d0', '251'],
      \       'cursorcolumn' : ['#303030', '235'],
      \       'cursorlinenr_fg' : ['#ffff00', '226'],
      \       'cursorlinenr_bg' : ['#262626', '234'],
      \       'popupmenu_fg' : ['#d0d0d0', '251'],
      \       'popupmenu_bg' : ['#3a3a3a', '236'],
      \       'search_fg' : ['#000000', '16'],
      \       'search_bg' : ['#00875f', '29'],
      \       'linenumber_fg' : ['#585858', '240'],
      \       'linenumber_bg' : ['#262626', '234'],
      \       'vertsplit_fg' : ['#5f8787', '66'],
      \       'vertsplit_bg' : ['#262626', '234'],
      \       'statusline_active_fg' : ['#262626', '234'],
      \       'statusline_active_bg' : ['#5f8787', '66'],
      \       'statusline_inactive_fg' : ['#c6c6c6', '250'],
      \       'statusline_inactive_bg' : ['#444444', '237'],
      \       'todo_fg' : ['#ff8700', '208'],
      \       'todo_bg' : ['#262626', '234'],
      \       'error_fg' : ['#262626', '234'],
      \       'error_bg' : ['#5f0000', '52'],
      \       'matchparen_bg' : ['#4e4e4e', '239'],
      \       'matchparen_fg' : ['#d0d0d0', '251'],
      \       'visual_fg' : ['#000000', '16'],
      \       'visual_bg' : ['#8787af', '103'],
      \       'folded_fg' : ['#afdf00', '148'],
      \       'folded_bg' : ['#444444', '237'],
      \       'wildmenu_fg': ['#262626', '234'],
      \       'wildmenu_bg': ['#afdf00', '148'],
      \       'tabline_bg':          ['#3a3a3a', '235'],
      \       'tabline_active_fg':   ['#1c1c1c', '233'],
      \       'tabline_active_bg':   ['#00afaf', '37'],
      \       'tabline_inactive_fg': ['#c6c6c6', '250'],
      \       'tabline_inactive_bg': ['#585858', '240'],
      \       'spellbad':   ['#5f0000', '52'],
      \       'spellcap':   ['#5f005f', '53'],
      \       'spellrare':  ['#005f00', '22'],
      \       'spelllocal': ['#00005f', '17'],
      \       'diffadd_fg':    ['#000000', '16'],
      \       'diffadd_bg':    ['#5faf00', '70'],
      \       'diffdelete_fg': ['#000000', '16'],
      \       'diffdelete_bg': ['#5f0000', '52'],
      \       'difftext_fg':   ['#000000', '16'],
      \       'difftext_bg':   ['#ffdf5f', '221'],
      \       'diffchange_fg': ['#000000', '16'],
      \       'diffchange_bg': ['#dfaf00', '178']
      \     }
      \   }

" }}}

" Get Selected Theme: {{{
let s:selected_theme = s:themes['papercolor'] " default
if exists("g:PaperColor_Theme") && has_key(s:themes, tolower(g:PaperColor_Theme))
  let s:selected_theme = s:themes[g:PaperColor_Theme]
endif
" }}}

" Get Theme Variant: either dark or light  {{{
let s:is_dark=(&background == 'dark')

if s:is_dark 
  if has_key(s:selected_theme, 'dark') 
    let s:palette = s:selected_theme['dark'].palette
  else " in case the theme only provides the other variant
    let s:palette = s:selected_theme['light'].palette
  endif

else " is light background
  if has_key(s:selected_theme, 'light') 
    let s:palette = s:selected_theme['light'].palette
  else " in case the theme only provides the other variant
    let s:palette = s:selected_theme['dark'].palette
  endif
endif
" }}}

" Identify Which Color Set To Use: GUI, 256, or 16 {{{
let s:use_gui_color = has("gui_running") " TODO: or nvim true color in terminal
let s:use_256_color = (&t_Co == 256)
let s:use_16_color = !s:use_gui_color && !s:use_256_color
" }}}

let s:bold = "bold"
let s:italic = "italic"
" Handle Preprocessing For Current Color Set If Necessary: {{{
if s:use_gui_color
  " TODO: if require auto-gui-color coversion
elseif s:use_256_color
  " TODO: if require auto-256-color coversion
else " if s:use_16_color
  set t_Co=8  " by some reason t_Co==16 doesn't use terminal color palette
  let s:bold = ""
  " let s:palette = {} " disregard color palette for GUI or 256-color
endif
" }}}

" if s:use256
"   let s:has_256_support = get(s:theme_variant, '256-support', 'no')
"   for [next_key, next_val] in items(s:theme_variant.palette)
"     let result = process(next_val)
"     echo 'Result for ' next_key ' is ' result
"   endfor
" endif

" COLOR VARIABLES: {{{
" Array format [<GUI COLOR/HEX >, <256-Base>, <16-Base>]
" 16-Base is terminal's native color palette that can be alternated through
" the terminal settings. The 16-color names are according to `:h cterm-colors`
" Use 16: targetcolor[-1]
" Use 256: targetcolor[-2] " GUI can be omitted
" Use GUI: targetcolor[0] " 256 can be ommitted

" BASIC COLORS:
" color00-15 are required by all themes.
" These are also how the terminal color palette for the target theme should be.
" See README for theme design guideline
"
" An example format of the below variable's value: ['#262626', '234', 'Black']
" Where the 1st value is HEX color for GUI Vim, 2nd value is for 256-color terminal,
" and the color name on the right is for 16-color terminal (the actual terminal colors
" can be different from what the color names suggest). See :h cterm-colors
" 
" Depending on the provided color palette and current Vim, the 1st and 2nd
" parameter might not exist, for example, on 16-color terminal, the variables below 
" only store the color names to use the terminal color palette which is the only
" thing available therefore no need for GUI-color or 256-color.
let s:background   = get(s:palette, 'color00') + ['Black']
let s:negative     = get(s:palette, 'color01') + ['DarkRed']
let s:positive     = get(s:palette, 'color02') + ['DarkGreen']
let s:olive        = get(s:palette, 'color03') + ['DarkYellow']
let s:cursorline   = get(s:palette, 'color04') + ['DarkBlue']
let s:highlight_bg = get(s:palette, 'color05') + ['DarkMagenta']
let s:navy         = get(s:palette, 'color06') + ['DarkCyan']
let s:foreground   = get(s:palette, 'color07') + ['LightGray']

let s:comment      = get(s:palette, 'color08') + ['DarkGray']
let s:red          = get(s:palette, 'color09') + ['LightRed']
let s:pink         = get(s:palette, 'color10') + ['LightGreen']
let s:purple       = get(s:palette, 'color11') + ['LightYellow']
let s:nontext      = get(s:palette, 'color12') + ['LightBlue']
let s:orange       = get(s:palette, 'color13') + ['LightMagenta']
let s:blue         = get(s:palette, 'color14') + ['LightCyan']
let s:aqua         = get(s:palette, 'color15') + ['White']

let s:green        = get(s:palette, 'color16', get(s:palette, 'color13')) + ['LightMagenta']
let s:wine         = get(s:palette, 'color17', get(s:palette, 'color11')) + ['LightYellow']

" echo s:aqua

" EXTENDED COLORS:
" From here on, all colors are optional and must have default values (3rd parameter of the 
" `get` command) that point to the above basic colors in case the target theme doesn't 
" provide the extended colors. The default values should be reasonably sensible. 
" The terminal color must be provided also.


" LineNumber: when set number
let s:linenumber_fg  = get(s:palette, 'linenumber_fg', get(s:palette, 'color08')) + ['DarkGray']
let s:linenumber_bg  = get(s:palette, 'linenumber_bg', get(s:palette, 'color00')) + ['Black']

" Vertical Split: when there are more than 1 window side by side, ex: <C-W><C-V>
let s:vertsplit_fg = get(s:palette, 'vertsplit_fg', get(s:palette, 'color07')) + ['DarkMagenta']
let s:vertsplit_bg = get(s:palette, 'vertsplit_bg', get(s:palette, 'color00')) + ['Black']

" Statusline: when set status=2
let s:statusline_active_fg   = get(s:palette, 'statusline_active_fg', get(s:palette, 'color00')) + ['Black']
let s:statusline_active_bg   = get(s:palette, 'statusline_active_bg', get(s:palette, 'color07')) + ['DarkMagenta']
let s:statusline_inactive_fg = get(s:palette, 'statusline_inactive_fg', get(s:palette, 'color07')) + ['LightGray']
let s:statusline_inactive_bg = get(s:palette, 'statusline_inactive_bg', get(s:palette, 'color00')) + ['LightBlue']

" Cursor: in normal mode
let s:cursor_fg = get(s:palette, 'cursor_fg', get(s:palette, 'color00')) + ['Black']
let s:cursor_bg = get(s:palette, 'cursor_bg', get(s:palette, 'color07')) + ['LightGray']

" CursorColumn: when set cursorcolumn
let s:cursorcolumn = get(s:palette, 'cursorcolumn', get(s:palette, 'color01')) + ['DarkBlue']

" CursorLine Number: when set cursorline number
let s:cursorlinenr_fg = get(s:palette, 'cursorlinenr_fg', get(s:palette, 'color15')) + ['White']
let s:cursorlinenr_bg = get(s:palette, 'cursorlinenr_bg', get(s:palette, 'color00')) + ['Black']

" Popup Menu: when <C-X><C-N> for autocomplete
let s:popupmenu_fg = get(s:palette, 'popupmenu_fg', get(s:palette, 'color07')) + ['LightGray']
let s:popupmenu_bg = get(s:palette, 'popupmenu_bg', get(s:palette, 'color01')) + ['DarkBlue']

" Search: ex: when * on a word
let s:highlight_fg = get(s:palette, 'search_fg', get(s:palette, 'color00')) + ['Black']
" let s:highlight_fg = get(s:palette, 'search_fg', get(s:palette, 'color00')) + ['LightGray']
let s:highlight_bg = get(s:palette, 'search_bg', get(s:palette, 'color05')) + ['LightGray']

" Todo: ex: TODO
let s:todo_fg    = get(s:palette, 'todo_fg', get(s:palette, 'color05')) + ['LightYellow']
let s:todo_bg    = get(s:palette, 'todo_bg', get(s:palette, 'color00')) + ['Black']

" Error: ex: turn spell on and have invalid words
let s:error_fg      = get(s:palette, 'error_fg', get(s:palette, 'color00')) + ['Black']
let s:error_bg      = get(s:palette, 'error_bg', get(s:palette, 'color04')) + ['DarkRed']

" Match Parenthesis: selecting an opening/closing pair and the other one will be highlighted
let s:matchparen_fg = get(s:palette, 'matchparen_fg', get(s:palette, 'color00')) + ['Black']
let s:matchparen_bg = get(s:palette, 'matchparen_bg', get(s:palette, 'color05')) + ['DarkMagenta']

" Visual:
let s:visual_bg = get(s:palette, 'visual_fg', get(s:palette, 'color00')) + ['LightGray']
let s:visual_fg = get(s:palette, 'visual_bg', get(s:palette, 'color07')) + ['Black']

" Folded:
let s:folded_fg = get(s:palette, 'folded_fg', get(s:palette, 'color00')) + ['Black']
let s:folded_bg = get(s:palette, 'folded_bg', get(s:palette, 'color03')) + ['DarkCyan']

" WildMenu: Autocomplete command, ex: :color <tab><tab> 
let s:wildmenu_fg  = get(s:palette, 'wildmenu_fg', get(s:palette, 'color00')) + ['Black']
let s:wildmenu_bg  = get(s:palette, 'wildmenu_bg', get(s:palette, 'color06')) + ['LightGray']

" Spelling: when spell on and there are spelling problems like this for example: papercolor. a vim color scheme
let s:spellbad   = get(s:palette, 'spellbad', get(s:palette, 'color04')) + ['DarkRed']
let s:spellcap   = get(s:palette, 'spellcap', get(s:palette, 'color05')) + ['DarkMagenta']
let s:spellrare  = get(s:palette, 'spellrare', get(s:palette, 'color06')) + ['DarkYellow']
let s:spelllocal = get(s:palette, 'spelllocal', get(s:palette, 'color01')) + ['DarkBlue']

" Diff:
let s:diffadd_fg    = get(s:palette, 'spelllocal', get(s:palette, 'color00')) + ['Black']
let s:diffadd_bg    = get(s:palette, 'spelllocal', get(s:palette, 'color02')) + ['DarkGreen']

let s:diffdelete_fg = get(s:palette, 'spelllocal', get(s:palette, 'color00')) + ['Black']
let s:diffdelete_bg = get(s:palette, 'spelllocal', get(s:palette, 'color04')) + ['DarkRed']

let s:difftext_fg   = get(s:palette, 'spelllocal', get(s:palette, 'color00')) + ['Black']
let s:difftext_bg   = get(s:palette, 'spelllocal', get(s:palette, 'color06')) + ['DarkYellow']

let s:diffchange_fg = get(s:palette, 'spelllocal', get(s:palette, 'color00')) + ['Black']
let s:diffchange_bg = get(s:palette, 'spelllocal', get(s:palette, 'color14')) + ['LightYellow']

" Tabline: when having tabs, ex: :tabnew
let s:tabline_bg          = get(s:palette, 'tabline_bg', get(s:palette, 'color00')) + ['Black']
let s:tabline_active_fg   = get(s:palette, 'tabline_active_fg', get(s:palette, 'color07')) + ['Black']
let s:tabline_active_bg   = get(s:palette, 'tabline_active_bg', get(s:palette, 'color05')) + ['DarkMagenta']
let s:tabline_inactive_fg = get(s:palette, 'tabline_inactive_fg', get(s:palette, 'color07')) + ['LightGray']
let s:tabline_inactive_bg = get(s:palette, 'tabline_inactive_bg', get(s:palette, 'color12')) + ['LightBlue']

" Plugin: BufTabLine https://github.com/ap/vim-buftabline
let s:buftabline_bg          = get(s:palette, 'buftabline_bg', get(s:palette, 'color00')) + ['Black']
let s:buftabline_current_fg  = get(s:palette, 'buftabline_current_fg', get(s:palette, 'color07')) + ['LightGray']
let s:buftabline_current_bg  = get(s:palette, 'buftabline_current_bg', get(s:palette, 'color05')) + ['DarkMagenta']
let s:buftabline_active_fg   = get(s:palette, 'buftabline_active_fg', get(s:palette, 'color07')) + ['LightGray']
let s:buftabline_active_bg   = get(s:palette, 'buftabline_active_bg', get(s:palette, 'color12')) + ['LightBlue']
let s:buftabline_inactive_fg = get(s:palette, 'buftabline_inactive_fg', get(s:palette, 'color07')) + ['LightGray']
let s:buftabline_inactive_bg = get(s:palette, 'buftabline_inactive_bg', get(s:palette, 'color00')) + ['Black']
" }}}

" SYNTAX HIGHLIGHTING: {{{

call s:HL("Normal", s:foreground, s:background, "")

" Switching between dark & light variant through `set background`
" https://github.com/NLKNguyen/papercolor-theme/pull/20
if s:is_dark " DARK VARIANT
  set background=dark
else " LIGHT VARIANT
  set background=light
endif

call s:HL("Cursor", s:cursor_fg, s:cursor_bg, "")
call s:HL("NonText", s:nontext, "", "")
call s:HL("SpecialKey", s:nontext, "", "")
call s:HL("Search", s:highlight_fg, s:highlight_bg, "")
call s:HL("LineNr", s:linenumber_fg, s:linenumber_bg, "")

call s:HL("StatusLine", s:statusline_active_bg, s:statusline_active_fg, "")
call s:HL("StatusLineNC", s:statusline_inactive_bg, s:statusline_inactive_fg, "")

call s:HL("VertSplit", s:vertsplit_fg, s:vertsplit_bg, "none")

call s:HL("Visual", s:visual_bg, s:visual_fg, "")
call s:HL("Directory", s:blue, "", "")
call s:HL("ModeMsg", s:olive, "", "")
call s:HL("MoreMsg", s:olive, "", "")
call s:HL("Question", s:olive, "", "")
call s:HL("WarningMsg", s:pink, "", "")
call s:HL("MatchParen", s:matchparen_fg, s:matchparen_bg, "")
call s:HL("Folded", s:folded_fg, s:folded_bg, "")
call s:HL("FoldColumn", "", s:background, "")
call s:HL("WildMenu", s:wildmenu_fg, s:wildmenu_bg, s:bold)

if version >= 700
  call s:HL("CursorLine", "", s:cursorline, "none")
  call s:HL("CursorLineNr", s:cursorlinenr_fg, s:cursorlinenr_bg, "none")
  call s:HL("CursorColumn", "", s:cursorcolumn, "none")
  call s:HL("PMenu", s:popupmenu_fg, s:popupmenu_bg, "none")
  call s:HL("PMenuSel", s:popupmenu_fg, s:popupmenu_bg, "reverse")
  call s:HL("SignColumn", s:green, s:background, "none")
end
if version >= 703
  call s:HL("ColorColumn", "", s:cursorcolumn, "none")
end

call s:HL("TabLine", s:tabline_inactive_fg, s:tabline_inactive_bg, "None")
call s:HL("TabLineFill", "", s:tabline_bg, "None")
call s:HL("TabLineSel", s:tabline_active_fg, s:tabline_active_bg, "None")

call s:HL("BufTabLineCurrent", s:buftabline_current_fg, s:buftabline_current_bg, "None")
call s:HL("BufTabLineActive", s:buftabline_active_fg, s:buftabline_active_bg, "None")
call s:HL("BufTabLineHidden", s:buftabline_inactive_fg, s:buftabline_inactive_bg, "None")
call s:HL("BufTabLineFill", "", s:buftabline_bg, "None")

" Standard Group Highlighting:
call s:HL("Comment", s:comment, "", "")

call s:HL("Constant", s:orange, "", "")
call s:HL("String", s:olive, "", "")
call s:HL("Character", s:olive, "", "")
call s:HL("Number", s:orange, "", "")
call s:HL("Boolean", s:green, "", s:bold)
call s:HL("Float", s:orange, "", "")

call s:HL("Identifier", s:navy, "", "")
call s:HL("Function", s:foreground, "", "")

call s:HL("Statement", s:pink, "", "none")
call s:HL("Conditional", s:purple, "", s:bold)
call s:HL("Repeat", s:purple, "", s:bold)
call s:HL("Label", s:blue, "", "")
call s:HL("Operator", s:aqua, "", "none")
call s:HL("Keyword", s:blue, "", "")
call s:HL("Exception", s:red, "", "")

call s:HL("PreProc", s:blue, "", "")
call s:HL("Include", s:red, "", "")
call s:HL("Define", s:blue, "", "")
call s:HL("Macro", s:blue, "", "")
call s:HL("PreCondit", s:aqua, "", "")

call s:HL("Type", s:pink, "", s:bold)
call s:HL("StorageClass", s:navy, "", s:bold)
call s:HL("Structure", s:blue, "", s:bold)
call s:HL("Typedef", s:pink, "", s:bold)

call s:HL("Special", s:foreground, "", "")
call s:HL("SpecialChar", s:foreground, "", "")
call s:HL("Tag", s:green, "", "")
call s:HL("Delimiter",s:aqua, "", "")
call s:HL("SpecialComment", s:comment, "", s:bold)
call s:HL("Debug", s:orange, "", "")

"call s:HL("Ignore", "666666", "", "")

call s:HL("Error", s:error_fg, s:error_bg, "")
call s:HL("Todo", s:todo_fg, s:todo_bg, s:bold)

call s:HL("Title", s:comment, "", "")
call s:HL("Global", s:blue, "", "")


" Extension {{{
" VimL Highlighting
call s:HL("vimCommand", s:pink, "", "")
call s:HL("vimVar", s:navy, "", "")
call s:HL("vimFuncKey", s:pink, "", "")
call s:HL("vimFunction", s:blue, "", s:bold)
call s:HL("vimNotFunc", s:pink, "", "")
call s:HL("vimMap", s:red, "", "")
call s:HL("vimAutoEvent", s:aqua, "", s:bold)
call s:HL("vimMapModKey", s:aqua, "", "")
call s:HL("vimFuncName", s:purple, "", "")
call s:HL("vimIsCommand", s:foreground, "", "")
call s:HL("vimFuncVar", s:aqua, "", "")
call s:HL("vimLet", s:red, "", "")
call s:HL("vimMapRhsExtend", s:foreground, "", "")
call s:HL("vimCommentTitle", s:comment, "", s:bold)
call s:HL("vimBracket", s:aqua, "", "")
call s:HL("vimParenSep", s:aqua, "", "")
call s:HL("vimNotation", s:aqua, "", "")
call s:HL("vimOper", s:foreground, "", "")
call s:HL("vimOperParen", s:foreground, "", "")
call s:HL("vimSynType", s:purple, "", "")
call s:HL("vimSynReg", s:pink, "", "none")
call s:HL("vimSynKeyRegion", s:green, "", "")
call s:HL("vimSynRegOpt", s:blue, "", "")
call s:HL("vimSynMtchOpt", s:blue, "", "")
call s:HL("vimSynContains", s:pink, "", "")
call s:HL("vimGroupName", s:foreground, "", "")
call s:HL("vimGroupList", s:foreground, "", "")
call s:HL("vimHiGroup", s:foreground, "", "")
call s:HL("vimGroup", s:navy, "", s:bold)

" Makefile Highlighting
call s:HL("makeIdent", s:blue, "", "")
call s:HL("makeSpecTarget", s:olive, "", "")
call s:HL("makeTarget", s:red, "", "")
call s:HL("makeStatement", s:aqua, "", s:bold)
call s:HL("makeCommands", s:foreground, "", "")
call s:HL("makeSpecial", s:orange, "", s:bold)

" CMake Highlighting
call s:HL("cmakeStatement", s:pink, "", "")
call s:HL("cmakeArguments", s:foreground, "", "")
call s:HL("cmakeVariableValue", s:blue, "", "")
call s:HL("cmakeOperators", s:red, "", "")

" C Highlighting
call s:HL("cType", s:pink, "", s:bold)
call s:HL("cFormat", s:olive, "", "")
call s:HL("cStorageClass", s:navy, "", s:bold)

call s:HL("cBoolean", s:green, "", "")
call s:HL("cCharacter", s:olive, "", "")
call s:HL("cConstant", s:green, "", s:bold)
call s:HL("cConditional", s:purple, "", s:bold)
call s:HL("cSpecial", s:olive, "", s:bold)
call s:HL("cDefine", s:blue, "", "")
call s:HL("cNumber", s:orange, "", "")
call s:HL("cPreCondit", s:aqua, "", "")
call s:HL("cRepeat", s:purple, "", s:bold)
call s:HL("cLabel",s:aqua, "", "")
" call s:HL("cAnsiFunction",s:aqua, "", s:bold)
" call s:HL("cAnsiName",s:pink, "", "")
call s:HL("cDelimiter",s:blue, "", "")
" call s:HL("cBraces",s:foreground, "", "")
" call s:HL("cIdentifier",s:blue, s:pink, "")
" call s:HL("cSemiColon","", s:blue, "")
call s:HL("cOperator",s:aqua, "", "")
" call s:HL("cStatement",s:pink, "", "")
call s:HL("cFunction", s:foreground, "", "")
" call s:HL("cTodo", s:comment, "", s:bold)
" call s:HL("cStructure", s:blue, "", s:bold)
call s:HL("cCustomParen", s:foreground, "", "")
" call s:HL("cCustomFunc", s:foreground, "", "")
" call s:HL("cUserFunction",s:blue, "", s:bold)
call s:HL("cOctalZero", s:purple, "", s:bold)

" CPP highlighting
call s:HL("cppBoolean", s:navy, "", "")
call s:HL("cppSTLnamespace", s:purple, "", "")
call s:HL("cppSTLconstant", s:foreground, "", "")
call s:HL("cppSTLtype", s:foreground, "", "")
call s:HL("cppSTLexception", s:pink, "", "")
call s:HL("cppSTLfunctional", s:foreground, "", s:bold)
call s:HL("cppSTLiterator", s:foreground, "", s:bold)
" call s:HL("cppSTLfunction", s:aqua, "", s:bold)
call s:HL("cppExceptions", s:red, "", "")
call s:HL("cppStatement", s:blue, "", "")
call s:HL("cppStorageClass", s:navy, "", s:bold)
call s:HL("cppAccess",s:blue, "", "")
" call s:HL("cppSTL",s:blue, "", "")


" Lex highlighting
call s:HL("lexCFunctions", s:foreground, "", "")
call s:HL("lexAbbrv", s:purple, "", "")
call s:HL("lexAbbrvRegExp", s:aqua, "", "")
call s:HL("lexAbbrvComment", s:comment, "", "")
call s:HL("lexBrace", s:navy, "", "")
call s:HL("lexPat", s:aqua, "", "")
call s:HL("lexPatComment", s:comment, "", "")
call s:HL("lexPatTag", s:orange, "", "")
" call s:HL("lexPatBlock", s:foreground, "", s:bold)
call s:HL("lexSlashQuote", s:foreground, "", "")
call s:HL("lexSep", s:foreground, "", "")
call s:HL("lexStartState", s:orange, "", "")
call s:HL("lexPatTagZone", s:olive, "", s:bold)
call s:HL("lexMorePat", s:olive, "", s:bold)
call s:HL("lexOptions", s:olive, "", s:bold)
call s:HL("lexPatString", s:olive, "", "")

" Yacc highlighting
call s:HL("yaccNonterminal", s:navy, "", "")
call s:HL("yaccDelim", s:orange, "", "")
call s:HL("yaccInitKey", s:aqua, "", "")
call s:HL("yaccInit", s:navy, "", "")
call s:HL("yaccKey", s:purple, "", "")
call s:HL("yaccVar", s:aqua, "", "")

" NASM highlighting
call s:HL("nasmStdInstruction", s:navy, "", "")
call s:HL("nasmGen08Register", s:aqua, "", "")
call s:HL("nasmGen16Register", s:aqua, "", "")
call s:HL("nasmGen32Register", s:aqua, "", "")
call s:HL("nasmGen64Register", s:aqua, "", "")
call s:HL("nasmHexNumber", s:purple, "", "")
call s:HL("nasmStorage", s:aqua, "", s:bold)
call s:HL("nasmLabel", s:pink, "", "")
call s:HL("nasmDirective", s:blue, "", s:bold)
call s:HL("nasmLocalLabel", s:orange, "", "")

" GAS highlighting
call s:HL("gasSymbol", s:pink, "", "")
call s:HL("gasDirective", s:blue, "", s:bold)
call s:HL("gasOpcode_386_Base", s:navy, "", "")
call s:HL("gasDecimalNumber", s:purple, "", "")
call s:HL("gasSymbolRef", s:pink, "", "")
call s:HL("gasRegisterX86", s:blue, "", "")
call s:HL("gasOpcode_P6_Base", s:navy, "", "")
call s:HL("gasDirectiveStore", s:foreground, "", s:bold)

" MIPS highlighting
call s:HL("mipsInstruction", s:pink, "", "")
call s:HL("mipsRegister", s:navy, "", "")
call s:HL("mipsLabel", s:aqua, "", s:bold)
call s:HL("mipsDirective", s:purple, "", s:bold)

" Shell/Bash highlighting
call s:HL("bashStatement", s:foreground, "", s:bold)
call s:HL("shDerefVar", s:aqua, "", s:bold)
call s:HL("shDerefSimple", s:aqua, "", "")
call s:HL("shFunction", s:orange, "", s:bold)
call s:HL("shStatement", s:foreground, "", "")
call s:HL("shLoop", s:purple, "", s:bold)
call s:HL("shQuote", s:olive, "", "")
call s:HL("shCaseEsac", s:aqua, "", s:bold)
call s:HL("shSnglCase", s:purple, "", "none")
call s:HL("shFunctionOne", s:navy, "", "")
call s:HL("shCase", s:navy, "", "")
call s:HL("shSetList", s:navy, "", "")
" @see Dockerfile Highlighting section for more sh*

" HTML Highlighting
call s:HL("htmlTitle", s:green, "", s:bold)
call s:HL("htmlH1", s:green, "", s:bold)
call s:HL("htmlH2", s:aqua, "", s:bold)
call s:HL("htmlH3", s:purple, "", s:bold)
call s:HL("htmlH4", s:orange, "", s:bold)
call s:HL("htmlTag", s:comment, "", "")
call s:HL("htmlTagName", s:wine, "", "")
call s:HL("htmlArg", s:pink, "", "")
call s:HL("htmlEndTag", s:comment, "", "")
call s:HL("htmlString", s:blue, "", "")
call s:HL("htmlScriptTag", s:comment, "", "")
call s:HL("htmlBold", s:foreground, "", s:bold)
call s:HL("htmlItalic", s:comment, "", s:bold)
call s:HL("htmlBoldItalic", s:navy, "", s:bold)
" call s:HL("htmlLink", s:blue, "", s:bold)
call s:HL("htmlTagN", s:wine, "", s:bold)
call s:HL("htmlSpecialTagName", s:wine, "", "")
call s:HL("htmlComment", s:comment, "", "")
call s:HL("htmlCommentPart", s:comment, "", "")

" CSS Highlighting
call s:HL("cssIdentifier", s:pink, "", "")
call s:HL("cssPositioningProp", s:foreground, "", "")
call s:HL("cssNoise", s:foreground, "", "")
call s:HL("cssBoxProp", s:foreground, "", "")
call s:HL("cssTableAttr", s:purple, "", "")
call s:HL("cssPositioningAttr", s:navy, "", "")
call s:HL("cssValueLength", s:orange, "", "")
call s:HL("cssFunctionName", s:blue, "", "")
call s:HL("cssUnitDecorators", s:aqua, "", "")
call s:HL("cssColor", s:blue, "", s:bold)
call s:HL("cssBraces", s:pink, "", "")
call s:HL("cssBackgroundProp", s:foreground, "", "")
call s:HL("cssTextProp", s:foreground, "", "")
call s:HL("cssDimensionProp", s:foreground, "", "")
call s:HL("cssClassName", s:pink, "", "")

" Markdown Highlighting
call s:HL("markdownHeadingRule", s:pink, "", s:bold)
call s:HL("markdownH1", s:pink, "", s:bold)
call s:HL("markdownH2", s:orange, "", s:bold)
call s:HL("markdownBlockquote", s:pink, "", "")
call s:HL("markdownCodeBlock", s:olive, "", "")
call s:HL("markdownCode", s:olive, "", "")
call s:HL("markdownLink", s:blue, "", s:bold)
call s:HL("markdownUrl", s:blue, "", "")
call s:HL("markdownLinkText", s:pink, "", "")
call s:HL("markdownLinkTextDelimiter", s:purple, "", "")
call s:HL("markdownLinkDelimiter", s:purple, "", "")
call s:HL("markdownCodeDelimiter", s:blue, "", "")

call s:HL("mkdCode", s:olive, "", "none")
call s:HL("mkdLink", s:blue, "", s:bold)
call s:HL("mkdURL", s:comment, "", "none")
call s:HL("mkdString", s:foreground, "", "none")
call s:HL("mkdBlockQuote", s:foreground, s:popupmenu_bg, "none")
call s:HL("mkdLinkTitle", s:pink, "", "none")
call s:HL("mkdDelimiter", s:aqua, "", "")
call s:HL("mkdRule", s:pink, "", "")

" reStructuredText Highlighting
call s:HL("rstSections", s:pink, "", s:bold)
call s:HL("rstDelimiter", s:pink, "", s:bold)
call s:HL("rstExplicitMarkup", s:pink, "", s:bold)
call s:HL("rstDirective", s:blue, "", "")
call s:HL("rstHyperlinkTarget", s:green, "", "")
call s:HL("rstExDirective", s:foreground, "", "")
call s:HL("rstInlineLiteral", s:olive, "", "")
call s:HL("rstInterpretedTextOrHyperlinkReference", s:blue, "", "")

" Python Highlighting
call s:HL("pythonImport", s:pink, "", s:bold)
call s:HL("pythonExceptions", s:red, "", "")
call s:HL("pythonException", s:purple, "", s:bold)
call s:HL("pythonInclude", s:red, "", "")
call s:HL("pythonStatement", s:pink, "", "")
call s:HL("pythonConditional", s:purple, "", s:bold)
call s:HL("pythonRepeat", s:purple, "", s:bold)
call s:HL("pythonFunction", s:aqua, "", s:bold)
call s:HL("pythonPreCondit", s:purple, "", "")
call s:HL("pythonExClass", s:orange, "", "")
call s:HL("pythonOperator", s:purple, "", s:bold)
call s:HL("pythonBuiltin", s:foreground, "", "")
call s:HL("pythonDecorator", s:orange, "", "")

call s:HL("pythonString", s:olive, "", "")
call s:HL("pythonEscape", s:olive, "", s:bold)
call s:HL("pythonStrFormatting", s:olive, "", s:bold)

call s:HL("pythonBoolean", s:green, "", s:bold)
call s:HL("pythonExClass", s:red, "", "")
call s:HL("pythonBytesEscape", s:olive, "", s:bold)
call s:HL("pythonDottedName", s:purple, "", "")
call s:HL("pythonStrFormat", s:foreground, "", "")
call s:HL("pythonBuiltinFunc", s:foreground, "", "")
call s:HL("pythonBuiltinObj", s:foreground, "", "")

" Java Highlighting
call s:HL("javaExternal", s:pink, "", "")
call s:HL("javaAnnotation", s:orange, "", "")
call s:HL("javaTypedef", s:aqua, "", "")
call s:HL("javaClassDecl", s:aqua, "", s:bold)
call s:HL("javaScopeDecl", s:blue, "", s:bold)
call s:HL("javaStorageClass", s:navy, "", s:bold)
call s:HL("javaBoolean", s:green, "", s:bold)
call s:HL("javaConstant", s:blue, "", "")
call s:HL("javaCommentTitle", s:wine, "", "")
call s:HL("javaDocTags", s:aqua, "", "")
call s:HL("javaDocComment", s:comment, "", "")
call s:HL("javaDocParam", s:foreground, "", "")
call s:HL("javaStatement", s:pink, "", "")
 
" JavaScript Highlighting
call s:HL("javaScriptBraces", s:blue, "", "")
call s:HL("javaScriptParens", s:blue, "", "")
call s:HL("javaScriptIdentifier", s:pink, "", "")
call s:HL("javaScriptFunction", s:blue, "", s:bold)
call s:HL("javaScriptConditional", s:purple, "", s:bold)
call s:HL("javaScriptRepeat", s:purple, "", s:bold)
call s:HL("javaScriptBoolean", s:green, "", s:bold)
call s:HL("javaScriptNumber", s:orange, "", "")
call s:HL("javaScriptMember", s:navy, "", "")
call s:HL("javaScriptReserved", s:navy, "", "")
call s:HL("javascriptNull", s:comment, "", s:bold)
call s:HL("javascriptGlobal", s:foreground, "", "")
call s:HL("javascriptStatement", s:pink, "", "")
call s:HL("javaScriptMessage", s:foreground, "", "")
call s:HL("javaScriptMember", s:foreground, "", "")

" @target https://github.com/pangloss/vim-javascript
call s:HL("jsFuncParens", s:blue, "", "")
call s:HL("jsFuncBraces", s:blue, "", "")
call s:HL("jsParens", s:blue, "", "")
call s:HL("jsBraces", s:blue, "", "")
call s:HL("jsNoise", s:blue, "", "")

" Json Highlighting
" @target https://github.com/elzr/vim-json
call s:HL("jsonKeyword", s:blue, "", "")
call s:HL("jsonString", s:olive, "", "")
call s:HL("jsonQuote", s:comment, "", "")
call s:HL("jsonNoise", s:foreground, "", "")
call s:HL("jsonKeywordMatch", s:foreground, "", "")
call s:HL("jsonBraces", s:foreground, "", "")
call s:HL("jsonNumber", s:orange, "", "")
call s:HL("jsonNull", s:purple, "", s:bold)
call s:HL("jsonBoolean", s:green, "", s:bold)
call s:HL("jsonCommentError", s:pink, s:background , "")

" Go Highlighting
call s:HL("goDirective", s:red, "", "")
call s:HL("goDeclaration", s:blue, "", s:bold)
call s:HL("goStatement", s:pink, "", "")
call s:HL("goConditional", s:purple, "", s:bold)
call s:HL("goConstants", s:orange, "", "")
call s:HL("goFunction", s:orange, "", "")
" call s:HL("goTodo", s:comment, "", s:bold)
call s:HL("goDeclType", s:blue, "", "")
call s:HL("goBuiltins", s:purple, "", "")

" Systemtap Highlighting
" call s:HL("stapBlock", s:comment, "", "none")
call s:HL("stapComment", s:comment, "", "none")
call s:HL("stapProbe", s:aqua, "", s:bold)
call s:HL("stapStat", s:navy, "", s:bold)
call s:HL("stapFunc", s:foreground, "", "")
call s:HL("stapString", s:olive, "", "")
call s:HL("stapTarget", s:navy, "", "")
call s:HL("stapStatement", s:pink, "", "")
call s:HL("stapType", s:pink, "", s:bold)
call s:HL("stapSharpBang", s:comment, "", "")
call s:HL("stapDeclaration", s:pink, "", "")
call s:HL("stapCMacro", s:blue, "", "")

" DTrace Highlighting
call s:HL("dtraceProbe", s:blue, "", "")
call s:HL("dtracePredicate", s:purple, "", s:bold)
call s:HL("dtraceComment", s:comment, "", "")
call s:HL("dtraceFunction", s:foreground, "", "")
call s:HL("dtraceAggregatingFunction", s:blue, "", s:bold)
call s:HL("dtraceStatement", s:navy, "", s:bold)
call s:HL("dtraceIdentifier", s:pink, "", "")
call s:HL("dtraceOption", s:pink, "", "")
call s:HL("dtraceConstant", s:orange, "", "")
call s:HL("dtraceType", s:pink, "", s:bold)

" PlantUML Highlighting
call s:HL("plantumlPreProc", s:orange, "", s:bold)
call s:HL("plantumlDirectedOrVerticalArrowRL", s:pink, "", "")
call s:HL("plantumlDirectedOrVerticalArrowLR", s:pink, "", "")
call s:HL("plantumlString", s:olive, "", "")
call s:HL("plantumlActivityThing", s:purple, "", "")
call s:HL("plantumlText", s:navy, "", "")
call s:HL("plantumlClassPublic", s:olive, "", s:bold)
call s:HL("plantumlClassPrivate", s:red, "", "")
call s:HL("plantumlColonLine", s:orange, "", "")
call s:HL("plantumlClass", s:navy, "", "")
call s:HL("plantumlHorizontalArrow", s:pink, "", "")
call s:HL("plantumlTypeKeyword", s:blue, "", s:bold)
call s:HL("plantumlKeyword", s:pink, "", s:bold)

call s:HL("plantumlType", s:blue, "", s:bold)
call s:HL("plantumlBlock", s:pink, "", s:bold)
call s:HL("plantumlPreposition", s:orange, "", "")
call s:HL("plantumlLayout", s:blue, "", s:bold)
call s:HL("plantumlNote", s:orange, "", "")
call s:HL("plantumlLifecycle", s:aqua, "", "")
call s:HL("plantumlParticipant", s:foreground, "", s:bold)


" Haskell Highlighting
call s:HL("haskellType", s:aqua, "", s:bold)
call s:HL("haskellIdentifier", s:orange, "", s:bold)
call s:HL("haskellOperators", s:pink, "", "")
call s:HL("haskellWhere", s:foreground, "", s:bold)
call s:HL("haskellDelimiter", s:aqua, "", "")
call s:HL("haskellImportKeywords", s:pink, "", "")
call s:HL("haskellStatement", s:purple, "", s:bold)


" SQL/MySQL Highlighting
call s:HL("sqlStatement", s:pink, "", s:bold)
call s:HL("sqlType", s:blue, "", s:bold)
call s:HL("sqlKeyword", s:pink, "", "")
call s:HL("sqlOperator", s:aqua, "", "")
call s:HL("sqlSpecial", s:green, "", s:bold)

call s:HL("mysqlVariable", s:olive, "", s:bold)
call s:HL("mysqlType", s:blue, "", s:bold)
call s:HL("mysqlKeyword", s:pink, "", "")
call s:HL("mysqlOperator", s:aqua, "", "")
call s:HL("mysqlSpecial", s:green, "", s:bold)


" Octave/MATLAB Highlighting
call s:HL("octaveVariable", s:foreground, "", "")
call s:HL("octaveDelimiter", s:pink, "", "")
call s:HL("octaveQueryVar", s:foreground, "", "")
call s:HL("octaveSemicolon", s:purple, "", "")
call s:HL("octaveFunction", s:navy, "", "")
call s:HL("octaveSetVar", s:blue, "", "")
call s:HL("octaveUserVar", s:foreground, "", "")
call s:HL("octaveArithmeticOperator", s:aqua, "", "")
call s:HL("octaveBeginKeyword", s:purple, "", s:bold)
call s:HL("octaveElseKeyword", s:purple, "", s:bold)
call s:HL("octaveEndKeyword", s:purple, "", s:bold)
call s:HL("octaveStatement", s:pink, "", "")

" Ruby Highlighting
call s:HL("rubyModule", s:navy, "", s:bold)
call s:HL("rubyClass", s:pink, "", s:bold)
call s:HL("rubyPseudoVariable", s:comment, "", s:bold)
call s:HL("rubyKeyword", s:pink, "", "")
call s:HL("rubyInstanceVariable", s:purple, "", "")
call s:HL("rubyFunction", s:foreground, "", s:bold)
call s:HL("rubyDefine", s:pink, "", "")
call s:HL("rubySymbol", s:aqua, "", "")
call s:HL("rubyConstant", s:blue, "", "")
call s:HL("rubyAccess", s:navy, "", "")
call s:HL("rubyAttribute", s:green, "", "")
call s:HL("rubyInclude", s:red, "", "")
call s:HL("rubyLocalVariableOrMethod", s:orange, "", "")
call s:HL("rubyCurlyBlock", s:foreground, "", "")
call s:HL("rubyCurlyBlockDelimiter", s:aqua, "", "")
call s:HL("rubyArrayDelimiter", s:aqua, "", "")
call s:HL("rubyStringDelimiter", s:olive, "", "")
call s:HL("rubyInterpolationDelimiter", s:orange, "", "")
call s:HL("rubyConditional", s:purple, "", s:bold)
call s:HL("rubyRepeat", s:purple, "", s:bold)
call s:HL("rubyControl", s:purple, "", s:bold)
call s:HL("rubyException", s:purple, "", s:bold)
call s:HL("rubyExceptional", s:purple, "", s:bold)
call s:HL("rubyBoolean", s:green, "", s:bold)

" Fortran Highlighting
call s:HL("fortranUnitHeader", s:foreground, "", s:bold)
call s:HL("fortranType", s:pink, "", s:bold)
call s:HL("fortranStructure", s:blue, "", s:bold)
call s:HL("fortranStorageClass", s:navy, "", s:bold)
call s:HL("fortranStorageClassR", s:navy, "", s:bold)
call s:HL("fortranKeyword", s:pink, "", "")
call s:HL("fortranReadWrite", s:blue, "", "")
call s:HL("fortranIO", s:navy, "", "")

" R Highlighting
call s:HL("rType", s:blue, "", "")
call s:HL("rArrow", s:pink, "", "")
call s:HL("rDollar", s:blue, "", "")

" XXD Highlighting
call s:HL("xxdAddress", s:navy, "", "")
call s:HL("xxdSep", s:pink, "", "")
call s:HL("xxdAscii", s:pink, "", "")
call s:HL("xxdDot", s:aqua, "", "")

" PHP Highlighting
call s:HL("phpIdentifier", s:foreground, "", "")
call s:HL("phpVarSelector", s:pink, "", "")
call s:HL("phpKeyword", s:blue, "", "")
call s:HL("phpRepeat", s:purple, "", s:bold)
call s:HL("phpConditional", s:purple, "", s:bold)
call s:HL("phpStatement", s:pink, "", "")
call s:HL("phpAssignByRef", s:aqua, "", s:bold)
call s:HL("phpSpecialFunction", s:blue, "", "")
call s:HL("phpFunctions", s:blue, "", "")
call s:HL("phpComparison", s:aqua, "", "")
call s:HL("phpBackslashSequences", s:olive, "", s:bold)
call s:HL("phpMemberSelector", s:blue, "", "")
call s:HL("phpStorageClass", s:purple, "", s:bold)
call s:HL("phpDefine", s:navy, "", "")

" Perl Highlighting
call s:HL("perlFiledescRead", s:green, "", "")
call s:HL("perlMatchStartEnd", s:pink, "", "")
call s:HL("perlStatementFlow", s:pink, "", "")
call s:HL("perlStatementStorage", s:pink, "", "")
call s:HL("perlFunction", s:pink, "", s:bold)
call s:HL("perlMethod", s:foreground, "", "")
call s:HL("perlStatementFiledesc", s:orange, "", "")
call s:HL("perlVarPlain", s:navy, "", "")
call s:HL("perlSharpBang", s:comment, "", "")
call s:HL("perlStatementInclude", s:aqua, "", s:bold)
call s:HL("perlStatementScalar", s:purple, "", "")
call s:HL("perlSubName", s:aqua, "", s:bold)
call s:HL("perlSpecialString", s:olive, "", s:bold)

" Pascal Highlighting
call s:HL("pascalType", s:pink, "", s:bold)
call s:HL("pascalStatement", s:blue, "", s:bold)
call s:HL("pascalPredefined", s:pink, "", "")
call s:HL("pascalFunction", s:foreground, "", "")
call s:HL("pascalStruct", s:navy, "", s:bold)
call s:HL("pascalOperator", s:aqua, "", s:bold)
call s:HL("pascalPreProc", s:green, "", "")
call s:HL("pascalAcces", s:navy, "", s:bold)

" Lua Highlighting
call s:HL("luaFunc", s:foreground, "", "")
call s:HL("luaIn", s:blue, "", s:bold)
call s:HL("luaFunction", s:pink, "", "")
call s:HL("luaStatement", s:blue, "", "")
call s:HL("luaRepeat", s:blue, "", s:bold)
call s:HL("luaCondStart", s:purple, "", s:bold)
call s:HL("luaTable", s:aqua, "", s:bold)
call s:HL("luaConstant", s:green, "", s:bold)
call s:HL("luaElse", s:purple, "", s:bold)
call s:HL("luaCondElseif", s:purple, "", s:bold)
call s:HL("luaCond", s:purple, "", s:bold)
call s:HL("luaCondEnd", s:purple, "", "")

" Clojure highlighting:
call s:HL("clojureConstant", s:blue, "", "")
call s:HL("clojureBoolean", s:orange, "", "")
call s:HL("clojureCharacter", s:olive, "", "")
call s:HL("clojureKeyword", s:pink, "", "")
call s:HL("clojureNumber", s:orange, "", "")
call s:HL("clojureString", s:olive, "", "")
call s:HL("clojureRegexp", s:purple, "", "")
call s:HL("clojureRegexpEscape", s:pink, "", "")
call s:HL("clojureParen", s:aqua, "", "")
call s:HL("clojureVariable", s:olive, "", "")
call s:HL("clojureCond", s:blue, "", "")
call s:HL("clojureDefine", s:blue, "", s:bold)
call s:HL("clojureException", s:red, "", "")
call s:HL("clojureFunc", s:navy, "", "")
call s:HL("clojureMacro", s:blue, "", "")
call s:HL("clojureRepeat", s:blue, "", "")
call s:HL("clojureSpecial", s:blue, "", s:bold)
call s:HL("clojureQuote", s:blue, "", "")
call s:HL("clojureUnquote", s:blue, "", "")
call s:HL("clojureMeta", s:blue, "", "")
call s:HL("clojureDeref", s:blue, "", "")
call s:HL("clojureAnonArg", s:blue, "", "")
call s:HL("clojureRepeat", s:blue, "", "")
call s:HL("clojureDispatch", s:aqua, "", "")

" Dockerfile Highlighting
" @target https://github.com/docker/docker/tree/master/contrib/syntax/vim
call s:HL("dockerfileKeyword", s:blue, "", "")
call s:HL("shDerefVar", s:purple, "", s:bold)
call s:HL("shOperator", s:aqua, "", "")
call s:HL("shOption", s:navy, "", "")
call s:HL("shLine", s:foreground, "", "")
call s:HL("shWrapLineOperator", s:pink, "", "")

" NGINX Highlighting
" @target https://github.com/evanmiller/nginx-vim-syntax
call s:HL("ngxDirectiveBlock", s:pink, "", s:bold)
call s:HL("ngxDirective", s:blue, "", "none")
call s:HL("ngxDirectiveImportant", s:blue, "", s:bold)
call s:HL("ngxString", s:olive, "", "")
call s:HL("ngxVariableString", s:purple, "", "")
call s:HL("ngxVariable", s:purple, "", "none")

" Yaml Highlighting
call s:HL("yamlBlockMappingKey", s:blue, "", "")
call s:HL("yamlKeyValueDelimiter", s:pink, "", "")
call s:HL("yamlBlockCollectionItemStart", s:pink, "", "")

" Qt QML Highlighting
call s:HL("qmlObjectLiteralType", s:pink, "", "")
call s:HL("qmlReserved", s:purple, "", "")
call s:HL("qmlBindingProperty", s:navy, "", "")
call s:HL("qmlType", s:navy, "", "")

" Dosini Highlighting
call s:HL("dosiniHeader", s:pink, "", "")
call s:HL("dosiniLabel", s:blue, "", "")

" Mail highlighting
call s:HL("mailHeaderKey", s:blue, "", "")
call s:HL("mailHeaderEmail", s:purple, "", "")
call s:HL("mailSubject", s:pink, "", "")
call s:HL("mailHeader", s:comment, "", "")
call s:HL("mailURL", s:aqua, "", "")
call s:HL("mailEmail", s:purple, "", "")
call s:HL("mailQuoted1", s:olive, "", "")
call s:HL("mailQuoted2", s:navy, "", "")

" XML Highlighting
call s:HL("xmlProcessingDelim", s:pink, "", "")
call s:HL("xmlString", s:olive, "", "")
call s:HL("xmlEqual", s:orange, "", "")
call s:HL("xmlAttrib", s:navy, "", "")
call s:HL("xmlAttribPunct", s:pink, "", "")
call s:HL("xmlTag", s:blue, "", "")
call s:HL("xmlTagName", s:blue, "", "")
call s:HL("xmlEndTag", s:blue, "", "")
call s:HL("xmlNamespace", s:orange, "", "")

" Exlixir Highlighting
" @target https://github.com/elixir-lang/vim-elixir
call s:HL("elixirAlias", s:blue, "", s:bold)
call s:HL("elixirAtom", s:navy, "", "")
call s:HL("elixirVariable", s:navy, "", "")
call s:HL("elixirUnusedVariable", s:comment, "", "")
call s:HL("elixirInclude", s:purple, "", "")
call s:HL("elixirStringDelimiter", s:olive, "", "")
call s:HL("elixirKeyword", s:purple, "", s:bold)
call s:HL("elixirFunctionDeclaration", s:foreground, "", s:bold)
call s:HL("elixirBlockDefinition", s:pink, "", "")
call s:HL("elixirDefine", s:pink, "", "")
call s:HL("elixirStructDefine", s:pink, "", "")
call s:HL("elixirPrivateDefine", s:pink, "", "")
call s:HL("elixirModuleDefine", s:pink, "", "")
call s:HL("elixirProtocolDefine", s:pink, "", "")
call s:HL("elixirImplDefine", s:pink, "", "")

" Erlang Highlighting
call s:HL("erlangBIF", s:purple, "", "bold,")
call s:HL("erlangBracket", s:pink, "", "")
call s:HL("erlangLocalFuncCall", s:foreground, "", "")
call s:HL("erlangVariable", s:foreground, "", "")
call s:HL("erlangAtom", s:navy, "", "")
call s:HL("erlangAttribute", s:blue, "", s:bold)
call s:HL("erlangRecordDef", s:blue, "", s:bold)
call s:HL("erlangRecord", s:blue, "", "")
call s:HL("erlangRightArrow", s:blue, "", s:bold)
call s:HL("erlangStringModifier", s:olive, "", s:bold)
call s:HL("erlangInclude", s:blue, "", s:bold)
call s:HL("erlangKeyword", s:pink, "", "")
call s:HL("erlangGlobalFuncCall", s:foreground, "", "")

" Cucumber Highlighting
call s:HL("cucumberFeature", s:blue, "", s:bold)
call s:HL("cucumberBackground", s:pink, "", s:bold)
call s:HL("cucumberScenario", s:pink, "", s:bold)
call s:HL("cucumberGiven", s:orange, "", "")
call s:HL("cucumberGivenAnd", s:blue, "", "")
call s:HL("cucumberThen", s:orange, "", "")
call s:HL("cucumberThenAnd", s:blue, "", "")
call s:HL("cucumberWhen", s:purple, "", s:bold)
call s:HL("cucumberScenarioOutline", s:pink, "", s:bold)
call s:HL("cucumberExamples", s:aqua, "", "")
call s:HL("cucumberTags", s:aqua, "", "")
call s:HL("cucumberPlaceholder", s:aqua, "", "")
" }}}

" Plugin: Netrw
call s:HL("netrwVersion", s:red, "", "")
call s:HL("netrwList", s:pink, "", "")
call s:HL("netrwHidePat", s:olive, "", "")
call s:HL("netrwQuickHelp", s:blue, "", "")
call s:HL("netrwHelpCmd", s:blue, "", "")
call s:HL("netrwDir", s:aqua, "", s:bold)
call s:HL("netrwClassify", s:pink, "", "")
call s:HL("netrwExe", s:green, "", "")
call s:HL("netrwSuffixes", s:comment, "", "")
call s:HL("netrwTreeBar", s:linenumber_fg, "", "")

" Plugin: NERDTree
call s:HL("NERDTreeUp", s:comment, "", "")
call s:HL("NERDTreeHelpCommand", s:pink, "", "")
call s:HL("NERDTreeHelpTitle", s:blue, "", s:bold)
call s:HL("NERDTreeHelpKey", s:pink, "", "")
call s:HL("NERDTreeHelp", s:foreground, "", "")
call s:HL("NERDTreeToggleOff", s:red, "", "")
call s:HL("NERDTreeToggleOn", s:green, "", "")
call s:HL("NERDTreeDir", s:blue, "", s:bold)
call s:HL("NERDTreeDirSlash", s:pink, "", "")
call s:HL("NERDTreeFile", s:foreground, "", "")
call s:HL("NERDTreeExecFile", s:green, "", "")
call s:HL("NERDTreeOpenable", s:pink, "", s:bold)
call s:HL("NERDTreeClosable", s:pink, "", "")

" Plugin: Tagbar
call s:HL("TagbarHelpTitle", s:blue, "", s:bold)
call s:HL("TagbarHelp", s:foreground, "", "")
call s:HL("TagbarKind", s:pink, "", "")
call s:HL("TagbarSignature", s:aqua, "", "")

" Plugin: Vimdiff
call s:HL("DiffAdd",    s:diffadd_fg,    s:diffadd_bg,    "none")
call s:HL("DiffChange", s:diffchange_fg, s:diffchange_bg, "none")
call s:HL("DiffDelete", s:diffdelete_fg, s:diffdelete_bg, "none")
call s:HL("DiffText",   s:difftext_fg,   s:difftext_bg,   "none")

" Plugin: AGit
call s:HL("agitStatAdded", s:diffadd_fg, "", "")
call s:HL("agitStatRemoved", s:diffdelete_fg, "", "")

call s:HL("agitDiffAdd", s:diffadd_fg, "", "")
call s:HL("agitDiffRemove", s:diffdelete_fg, "", "")

call s:HL("agitDiffHeader", s:pink, "", "")
call s:HL("agitDiff", s:foreground, "", "")

call s:HL("agitDiffIndex", s:purple, "", "")
call s:HL("agitDiffFileName", s:aqua, "", "")

call s:HL("agitLog", s:foreground, "", "")
call s:HL("agitAuthorMark", s:olive, "", "")

call s:HL("agitDateMark", s:comment, "", "")

call s:HL("agitHeaderLabel", s:aqua, "", "")

call s:HL("agitHead", s:olive, "", "")
call s:HL("agitHeader", s:olive, "", "")

" Plugin: Spell Checking
call s:HL("SpellBad",   s:foreground, s:spellbad,   "")
call s:HL("SpellCap",   s:foreground, s:spellcap,   "")
call s:HL("SpellRare",  s:foreground, s:spellrare,  "")
call s:HL("SpellLocal", s:foreground, s:spelllocal, "")

" Plugin: Indent Guides
call s:HL("IndentGuidesOdd", "", s:background, "")
call s:HL("IndentGuidesEven", "", s:cursorline, "")

" Plugin: Startify
call s:HL("StartifyFile", s:blue, "", s:bold)
call s:HL("StartifyNumber", s:orange, "", "")
call s:HL("StartifyHeader", s:comment, "", "")
call s:HL("StartifySection", s:pink, "", "")
call s:HL("StartifyPath", s:foreground, "", "")
call s:HL("StartifySlash", s:navy, "", "")
call s:HL("StartifyBracket", s:aqua, "", "")
call s:HL("StartifySpecial", s:aqua, "", "")

"=====================================================================
" SYNTAX HIGHLIGHTING CODE BELOW THIS LINE ISN'T TESTED FOR THIS THEME
"=====================================================================


" " CoffeeScript Highlighting
" call s:HL("coffeeRepeat", s:purple, "", "")
" call s:HL("coffeeConditional", s:purple, "", "")
" call s:HL("coffeeKeyword", s:purple, "", "")
" call s:HL("coffeeObject", s:yellow, "", "")


" " ShowMarks Highlighting
" call s:HL("ShowMarksHLl", s:orange, s:background, "none")
" call s:HL("ShowMarksHLo", s:purple, s:background, "none")
" call s:HL("ShowMarksHLu", s:yellow, s:background, "none")
" call s:HL("ShowMarksHLm", s:aqua, s:background, "none")





" " Scala "highlighting
" call s:HL("scalaKeyword", s:purple, "", "")
" call s:HL("scalaKeywordModifier", s:purple, "", "")
" call s:HL("scalaOperator", s:blue, "", "")
" call s:HL("scalaPackage", s:pink, "", "")
" call s:HL("scalaFqn", s:foreground, "", "")
" call s:HL("scalaFqnSet", s:foreground, "", "")
" call s:HL("scalaImport", s:purple, "", "")
" call s:HL("scalaBoolean", s:orange, "", "")
" call s:HL("scalaDef", s:purple, "", "")
" call s:HL("scalaVal", s:purple, "", "")
" call s:HL("scalaVar", s:aqua, "", "")
" call s:HL("scalaClass", s:purple, "", "")
" call s:HL("scalaObject", s:purple, "", "")
" call s:HL("scalaTrait", s:purple, "", "")
" call s:HL("scalaDefName", s:blue, "", "")
" call s:HL("scalaValName", s:foreground, "", "")
" call s:HL("scalaVarName", s:foreground, "", "")
" call s:HL("scalaClassName", s:foreground, "", "")
" call s:HL("scalaType", s:yellow, "", "")
" call s:HL("scalaTypeSpecializer", s:yellow, "", "")
" call s:HL("scalaAnnotation", s:orange, "", "")
" call s:HL("scalaNumber", s:orange, "", "")
" call s:HL("scalaDefSpecializer", s:yellow, "", "")
" call s:HL("scalaClassSpecializer", s:yellow, "", "")
" call s:HL("scalaBackTick", s:olive, "", "")
" call s:HL("scalaRoot", s:foreground, "", "")
" call s:HL("scalaMethodCall", s:blue, "", "")
" call s:HL("scalaCaseType", s:yellow, "", "")
" call s:HL("scalaLineComment", s:comment, "", "")
" call s:HL("scalaComment", s:comment, "", "")
" call s:HL("scalaDocComment", s:comment, "", "")
" call s:HL("scalaDocTags", s:comment, "", "")
" call s:HL("scalaEmptyString", s:olive, "", "")
" call s:HL("scalaMultiLineString", s:olive, "", "")
" call s:HL("scalaUnicode", s:orange, "", "")
" call s:HL("scalaString", s:olive, "", "")
" call s:HL("scalaStringEscape", s:olive, "", "")
" call s:HL("scalaSymbol", s:orange, "", "")
" call s:HL("scalaChar", s:orange, "", "")
" call s:HL("scalaXml", s:olive, "", "")
" call s:HL("scalaConstructorSpecializer", s:yellow, "", "")
" call s:HL("scalaBackTick", s:blue, "", "")

" Git
call s:HL("diffAdded", s:olive, "", "")
call s:HL("diffRemoved", s:pink, "", "")
" call s:HL("gitcommitSummary", "", "", s:bold)

" }}}

" Delete Helper Functions: {{{
delf s:Load_Settings_Override
delf s:HL
delf s:rgb
delf s:colour
delf s:rgb_colour
delf s:rgb_level
delf s:rgb_number
delf s:grey_colour
delf s:grey_level
delf s:grey_number
" }}}
" vim: fdm=marker
