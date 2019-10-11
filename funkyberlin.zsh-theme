# Shout out to the makers of the bureau theme - This is heavily inspired by them.
# (https://github.com/robbyrussell/oh-my-zsh/blob/master/themes/bureau.zsh-theme)

ZSH_THEME_NVM_PROMPT_PREFIX="%B⬡%b "
ZSH_THEME_NVM_PROMPT_SUFFIX=""

ZSH_THEME_GIT_PROMPT_PREFIX="[git%{$reset_color%}%{$FG[176]%} "
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}]"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$FG[154]%}✓%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$FG[154]%}▴%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$FG[196]%}▾%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_STAGED="%{$FG[154]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$FG[202]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[red]%}●%{$reset_color%}"

git_branch () {
  ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
  echo "${ref#refs/heads/}"
}

git_status() {
  _STATUS=""

  # check status of files
  _INDEX=$(command git status --porcelain 2> /dev/null)
  if [[ -n "$_INDEX" ]]; then
    if $(echo "$_INDEX" | command grep -q '^[AMRD]. '); then
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_STAGED"
    fi
    if $(echo "$_INDEX" | command grep -q '^.[MTD] '); then
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNSTAGED"
    fi
    if $(echo "$_INDEX" | command grep -q -E '^\?\? '); then
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNTRACKED"
    fi
    if $(echo "$_INDEX" | command grep -q '^UU '); then
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNMERGED"
    fi
  else
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_CLEAN"
  fi

  # check status of local repository
  _INDEX=$(command git status --porcelain -b 2> /dev/null)
  if $(echo "$_INDEX" | command grep -q '^## .*ahead'); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_AHEAD"
  fi
  if $(echo "$_INDEX" | command grep -q '^## .*behind'); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_BEHIND"
  fi
  if $(echo "$_INDEX" | command grep -q '^## .*diverged'); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_DIVERGED"
  fi

  if $(command git rev-parse --verify refs/stash &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_STASHED"
  fi

  echo $_STATUS
}

git_prompt () {
  local _branch=$(git_branch)
  local _status=$(git_status)
  local _result=""
  if [[ "${_branch}x" != "x" ]]; then
    _result="$ZSH_THEME_GIT_PROMPT_PREFIX$_branch"
    if [[ "${_status}x" != "x" ]]; then
      _result="$_result $_status"
    fi
    _result="$_result$ZSH_THEME_GIT_PROMPT_SUFFIX"
  fi
  echo $_result
}

_PATH="$fg[yellow]%~$reset_color"

if [[ $EUID -eq 0 ]]; then
  _USERNAME="%{$fg_bold[red]%}%n"
  _LIBERTY="%{$fg[red]%}#"
else
  _USERNAME="%{$fg_bold[blue]%}%n"
  _LIBERTY="%{$fg[green]%}$"
fi
_USERNAME="$_USERNAME%{$reset_color%}@%m"
_LIBERTY="$_LIBERTY%{$reset_color%}"



_TOP="$_USERNAME $_PATH"
_BOTTOM="%* > $_LIBERTY "



berlin_precmd () {
  print
  _VERSIONCTRL="$(git_prompt)$(nvm_prompt_info)"
  print -P "$_TOP $_VERSIONCTRL"
}

PROMPT="$_BOTTOM"


autoload -U add-zsh-hook
add-zsh-hook precmd berlin_precmd

