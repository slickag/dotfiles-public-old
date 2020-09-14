unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
[[ -e ~/.ssh/id_rsa ]] && POWERLEVEL9K_LEFT_PROMPT_ELEMENTS+=(my_git_dir vcs)
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS+=(newline prompt_char)

POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time background_jobs context)
(( $+commands[nordvpn] )) && POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS+=(nordvpn)
(( P9K_SSH             )) && POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS+=(time)

POWERLEVEL9K_MODE=ascii
POWERLEVEL9K_ICON_PADDING=none
POWERLEVEL9K_BACKGROUND=
POWERLEVEL9K_ICON_BEFORE_CONTENT=true
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=
typeset -g POWERLEVEL9K_MULTILINE_{FIRST,NEWLINE,LAST}_PROMPT_{PREFIX,SUFFIX}=

typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='>'
typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='<'
typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='V'
typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIOWR_CONTENT_EXPANSION='^'
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=2
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=1

POWERLEVEL9K_DIR_FOREGROUND=4
POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
POWERLEVEL9K_SHORTEN_DELIMITER=
POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=4
POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=4
POWERLEVEL9K_DIR_ANCHOR_BOLD=false
POWERLEVEL9K_SHORTEN_FOLDER_MARKER=.git
POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
POWERLEVEL9K_DIR_MAX_LENGTH=80
POWERLEVEL9K_DIR_SHOW_WRITABLE=v2
POWERLEVEL9K_DIR_CLASSES=()

function prompt_my_git_dir() {
  emulate -L zsh
  [[ -n $GIT_DIR ]] || return
  local repo=${GIT_DIR:t}
  [[ $repo == .git ]] && repo=${GIT_DIR:h:t}
  [[ $repo == .dotfiles-(public|private) ]] && repo=${repo#.dotfiles-}
  p10k segment -b 0 -f 3 -t %B${repo//\%/%%}%b
}

function my_git_formatter() {
  emulate -L zsh

  if [[ -n $P9K_CONTENT ]]; then
    typeset -g my_git_format=$P9K_CONTENT
    return
  fi

  if (( $1 )); then
    local       meta='%f'
    local      clean='%2F'
    local   modified='%3F'
    local  untracked='%4F'
    local conflicted='%1F'
  else
    local       meta='%f'
    local      clean='%f'
    local   modified='%f'
    local  untracked='%f'
    local conflicted='%f'
  fi

  local res
  local where
  if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
    res+="${clean}${(g::)POWERLEVEL9K_VCS_BRANCH_ICON}"
    where=${(V)VCS_STATUS_LOCAL_BRANCH}
  elif [[ -n $VCS_STATUS_TAG ]]; then
    res+="${meta}#"
    where=${(V)VCS_STATUS_TAG}
  fi

  (( $#where > 32 )) && where[13,-13]=".."
  res+="${clean}${where//\%/%%}"

  [[ -z $where ]] && res+="${meta}@${clean}${VCS_STATUS_COMMIT[1,8]}"

  if [[ -n ${VCS_STATUS_REMOTE_BRANCH:#$VCS_STATUS_LOCAL_BRANCH} ]]; then
    res+="${meta}:${clean}${(V)VCS_STATUS_REMOTE_BRANCH//\%/%%}"
  fi

  (( VCS_STATUS_COMMITS_BEHIND )) && res+=" ${clean}<${VCS_STATUS_COMMITS_BEHIND}"
  (( VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND )) && res+=" "
  (( VCS_STATUS_COMMITS_AHEAD  )) && res+="${clean}>${VCS_STATUS_COMMITS_AHEAD}"
  (( VCS_STATUS_PUSH_COMMITS_BEHIND )) && res+=" ${clean}<-${VCS_STATUS_PUSH_COMMITS_BEHIND}"
  (( VCS_STATUS_PUSH_COMMITS_AHEAD && !VCS_STATUS_PUSH_COMMITS_BEHIND )) && res+=" "
  (( VCS_STATUS_PUSH_COMMITS_AHEAD  )) && res+="${clean}->${VCS_STATUS_PUSH_COMMITS_AHEAD}"
  (( VCS_STATUS_STASHES        )) && res+=" ${clean}*${VCS_STATUS_STASHES}"
  [[ -n $VCS_STATUS_ACTION     ]] && res+=" ${conflicted}${VCS_STATUS_ACTION}"
  (( VCS_STATUS_NUM_CONFLICTED )) && res+=" ${conflicted}~${VCS_STATUS_NUM_CONFLICTED}"
  (( VCS_STATUS_NUM_STAGED     )) && res+=" ${modified}+${VCS_STATUS_NUM_STAGED}"
  (( VCS_STATUS_NUM_UNSTAGED   )) && res+=" ${modified}!${VCS_STATUS_NUM_UNSTAGED}"
  (( VCS_STATUS_NUM_UNTRACKED  )) && res+=" ${untracked}${(g::)POWERLEVEL9K_VCS_UNTRACKED_ICON}${VCS_STATUS_NUM_UNTRACKED}"
  (( VCS_STATUS_HAS_UNSTAGED == -1 )) && res+=" ${modified}-"

  typeset -g my_git_format=$res
}
functions -M my_git_formatter 2>/dev/null

POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true
POWERLEVEL9K_VCS_CONTENT_EXPANSION='${$((my_git_formatter(1)))+${my_git_format}}'
POWERLEVEL9K_VCS_LOADING_CONTENT_EXPANSION='${$((my_git_formatter(0)))+${my_git_format}}'
typeset -g POWERLEVEL9K_VCS_{STAGED,UNSTAGED,UNTRACKED,CONFLICTED,COMMITS_AHEAD,COMMITS_BEHIND}_MAX_NUM=-1
POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_EXPANSION=
POWERLEVEL9K_VCS_CLEAN_FOREGROUND=2
POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=2
POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=3

POWERLEVEL9K_STATUS_EXTENDED_STATES=true
POWERLEVEL9K_STATUS_VERBOSE_SIGNAME=false
typeset -g POWERLEVEL9K_STATUS_{OK,ERROR}=false
typeset -g POWERLEVEL9K_STATUS_{OK_PIPE,ERROR_PIPE,ERROR_SIGNAL}=true
typeset -g POWERLEVEL9K_STATUS_{OK,OK_PIPE}_FOREGROUND=2
typeset -g POWERLEVEL9K_STATUS_{ERROR,ERROR_PIPE,ERROR_SIGNAL}_FOREGROUND=1
typeset -g POWERLEVEL9K_STATUS_{OK,OK_PIPE}_VISUAL_IDENTIFIER_EXPANSION=
typeset -g POWERLEVEL9K_STATUS_{ERROR,ERROR_PIPE,ERROR_SIGNAL}_VISUAL_IDENTIFIER_EXPANSION=

POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=3
POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'
POWERLEVEL9K_COMMAND_EXECUTION_TIME_VISUAL_IDENTIFIER_EXPANSION=

POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE=false
POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=1

POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=1
POWERLEVEL9K_CONTEXT_FOREGROUND=7
POWERLEVEL9K_CONTEXT_ROOT_TEMPLATE='%B%n@%m'
POWERLEVEL9K_CONTEXT_TEMPLATE='%n@%m'
typeset -g POWERLEVEL9K_CONTEXT_{REMOTE,REMOTE_SUDO}_FOREGROUND=7
typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_{CONTENT,VISUAL_IDENTIFIER}_EXPANSION=
typeset -g POWERLEVEL9K_CONTEXT_{REMOTE,REMOTE_SUDO}_TEMPLATE=${${${Z4H_SSH#*:}//\%/%%}:-%m}

POWERLEVEL9K_NORDVPN_FOREGROUND=4
typeset -g POWERLEVEL9K_NORDVPN_{DISCONNECTED,CONNECTING,DISCONNECTING}_CONTENT_EXPANSION=
typeset -g POWERLEVEL9K_NORDVPN_{DISCONNECTED,CONNECTING,DISCONNECTING}_VISUAL_IDENTIFIER_EXPANSION=

POWERLEVEL9K_TIME_FOREGROUND=6
POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'
POWERLEVEL9K_TIME_VISUAL_IDENTIFIER_EXPANSION=

POWERLEVEL9K_TRANSIENT_PROMPT=always
POWERLEVEL9K_INSTANT_PROMPT=quiet
POWERLEVEL9K_DISABLE_HOT_RELOAD=true
POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}

ZLE_RPROMPT_INDENT=0

(( ! $+functions[p10k] )) || p10k reload
