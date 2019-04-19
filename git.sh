#!/usr/bin/env bash

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${SCRIPT_PATH}/colors.sh

# ascii art :)
function __presentation
{
  echo " _____     ______     __   __      __  __     ______   __     __         ______"
  echo "/\  __-.  /\  ___\   /\ \ / /     /\ \/\ \   /\__  _\ /\ \   /\ \       /\  ___\\"
  echo "\ \ \/\ \ \ \  __\   \ \ \'/      \ \ \_\ \  \/_/\ \/ \ \ \  \ \ \____  \ \___  \\"
  echo " \ \____-  \ \_____\  \ \__|       \ \_____\    \ \_\  \ \_\  \ \_____\  \/\_____\\"
  echo "  \/____/   \/_____/   \/_/         \/_____/     \/_/   \/_/   \/_____/   \/_____/"

  green "# ${1}"
}

# perform log commit command
function commit()
{
  __presentation "commit"

  if [[ ! -d .git ]]; then
    red "## This folder is not a working tree"
    return
  fi

  # check if repo is empty
  if [[ ! "$(git branch -vv)" ]];then
    red "## No branches available"
    _red "## Create the first commit? [y/n] $ "
    read -n 1 READ_START
    echo ""
    if [[ ${READ_START} = "y" ]]; then
      git commit -m "[init] Just init the repo" --allow-empty >/dev/null 2>&1
    else
      return
    fi
  fi

  MODIFIED=$(git status --short)
  if [[ ! ${MODIFIED} ]]; then
    red "## No changes available"
    return
  fi

  # get modified files
  COMMIT_FILES_OPTIONS=($(git ls-files --others --exclude-standard --modified))
  # check if repo is empty
  COMMIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
  # start COMMIT_FILES_CHOSEN as empty array
  COMMIT_FILES_CHOSEN=()
  # start selected file with EMPTY
  SELECTED_FILE="EMPTY"
  # start index with 0
  INDEX=0
  # flag control to select all
  SELECT_ALL=0

  # while the user select a file
  while [[ "${SELECTED_FILE}" ]]; do
    # show menu (COMMIT_FILES_OPTIONS and COMMIT_FILES_CHOSEN are used as global)
    __commitMenu

    yellow "# Enter the file number in the list to toggle selection"
    yellow "# [separate with ',' when more than 9 options]"
    _yellow "# [type enter with empty to go ahead] $ "

    # if there is more than 10 files will be necessary type enter
    if (( ${#COMMIT_FILES_OPTIONS[@]} > 10 )); then
       read SELECTED_FILE
    # otherwise the value will be picked up automatically after typing
    else
      read -n 1 SELECTED_FILE
    fi

    echo ""

    # stop selection if the value entered is empty
    if [[ ! "${SELECTED_FILE}" ]]; then
      break
    fi

    # stop selection if the value entered is 0
    if [[ "${SELECTED_FILE}" = "0" ]]; then
      SELECT_ALL=1
      break
    fi

    # scroll through the selected files input to apply the option that came from the menu
    while IFS=',' read -ra ITEM; do
      for i in "${ITEM[@]}"; do
        INDEX=${i}

        # test if selected option is valid
        ((INDEX--))
        if (( INDEX < 0 || INDEX >= ${#COMMIT_FILES_OPTIONS[@]} )); then
          # show a message of invalid input
          red "  ~> Invalid option: ${SELECTED_FILE}"
          continue
        fi

        # if the option is already selected...
        if [[ "${COMMIT_FILES_CHOSEN[INDEX]}" ]]; then
          # ...unselected the option
          COMMIT_FILES_CHOSEN[INDEX]=""
          continue
        fi
        # select the option
        COMMIT_FILES_CHOSEN[INDEX]="x"
      done
     # apply the SELECTED_FILE to for
     done <<< "${SELECTED_FILE}"
  done

  # if SELECT_ALL was selected...
  if [[ "${SELECT_ALL}" = 1 ]]; then
    # ...clear the selection
    SELECT_ALL=0
    # ...scroll through all file options...
    for i in ${!COMMIT_FILES_OPTIONS[@]}; do
      # ...and select each one
      COMMIT_FILES_CHOSEN[i]="x"
    done
  fi

  yellow "# Log"
  # scroll through all file options
  for i in ${!COMMIT_FILES_OPTIONS[@]}; do
    # if is not selected ignore
    if [[ ! "${COMMIT_FILES_CHOSEN[i]}" ]]; then
      continue;
    fi
    # else perform git add command
    MUTE=$(git add ${COMMIT_FILES_OPTIONS[i]})
  done

  # get the git changes to create a log with the changes in commit
  COMMIT_CHANGES=$(git diff --cached --name-only)
  # convert the changes in an array
  ADDED=(${COMMIT_CHANGES})
  # if there is no changes...
  if [[ ! "$ADDED" ]]; then
    # ...abort commit
    red "## No changes available to perform a commit"
    return
  fi

  # default log message
  message="  ~> nothing of anything"
  # scroll through the added files in git
  for i in ${!ADDED[@]}; do
    # show message with the name of file listed to be in commit
    cyan "  ~> git add ${ADDED[i]}"
    # reset the default log message
    message=""
  done
  # show the default log message
  cyan "$message"

  yellow "# Commit type (use the numbers for the options listed below)"
  yellow "# [if the option you entered is not in the list, the 'feature' option will be used] "
  _yellow "# 1:feature, 2:fix, 3:review, 4:doc, 5:test, 6:devops, 7:merge or 8:finish $ "
  read -n 1 READ_COMMIT_TYPE
  # get commit type
  case ${READ_COMMIT_TYPE} in
    2)
      COMMIT_TYPE="fix"
    ;;
    3)
      COMMIT_TYPE="review"
    ;;
    4)
      COMMIT_TYPE="doc"
    ;;
    5)
      COMMIT_TYPE="test"
    ;;
    6)
      COMMIT_TYPE="devops"
    ;;
    7)
      COMMIT_TYPE="merge"
    ;;
    8)
      COMMIT_TYPE="finish"
    ;;
    *)
      COMMIT_TYPE="feature"
    ;;
  esac
  if [[ ${READ_COMMIT_TYPE} ]]; then
    echo ""
  fi
  cyan "  ~> selected type: ${COMMIT_TYPE}"

  # initialize message of commit
  COMMIT_MESSAGE=""
  # repeat until get a message
  until [[ "${COMMIT_MESSAGE}" ]]
  do
    _yellow "# Commit message $ "
    read COMMIT_MESSAGE
    # validate message
    if [[ ! ${COMMIT_MESSAGE} ]]; then
      red "## Message is required"
    fi
  done

  # init commit reference with the branch name
  COMMIT_REFERENCE=$(echo $(basename ${COMMIT_BRANCH}) | tr a-z A-Z)
  yellow "# Related issue"
  yellow "# [enter the ID of issue]"
  _yellow "# [if empty will use the branch name as reference in commit] $ "

  # read commit related info
  read COMMIT_RELATED
  # if commit related was entered...
  if [[ ${COMMIT_RELATED} ]]; then
    # convert related to uppercase
    COMMIT_RELATED=$(echo ${COMMIT_RELATED} | tr a-z A-Z)
    # use related as commit reference
    COMMIT_REFERENCE="#${COMMIT_RELATED}"
    # concat related with a text to be human readable
    COMMIT_RELATED="> issue link #${COMMIT_RELATED}"
  # else use the branch name as related
  else
    # concat related with a text to be human readable
    COMMIT_RELATED="> current branch ${COMMIT_BRANCH}"
  fi

  COMMIT_MESSAGE="[${COMMIT_REFERENCE}/${COMMIT_TYPE}] ${COMMIT_MESSAGE}"
  green "  ~> git commit -m '${COMMIT_MESSAGE}'"

  git commit -F- <<EOF
${COMMIT_MESSAGE}
${COMMIT_RELATED}
${COMMIT_CHANGES}
EOF

  # git ls-files --others --exclude-standard --modified
  if [[ "$(git status --short)" ]]; then
    _yellow "# Do you want to commit again? [y/n] $ "
    read -n 1 READ_DO_AGAIN
    if [[ ${READ_DO_AGAIN} = "y" ]]; then
      commit
    fi
    echo ""
  fi
}

# show commit menu file options
function __commitMenu
{
    yellow "# Select the files to be added in the commit"
      printf "  0 [ ] All\n"
    for i in ${!COMMIT_FILES_OPTIONS[@]}; do
        printf "%3d [%s] %s\n" $((i+1)) "${COMMIT_FILES_CHOSEN[i]:- }" "${COMMIT_FILES_OPTIONS[i]}"
    done
    fixes=($(git diff --cached --name-only))
    for i in ${!fixes[@]}; do
        printf "    [x] %s\n" "${fixes[i]}"
    done
}

# perform status git command
function status
{
  __presentation "status"

  if [[ ! -d .git ]]; then
    red "## This folder is not a working tree"
    return
  fi

  STATUS=$(git status --short)
  if [[ ! ${STATUS} ]]; then
    yellow "## No changes"
    return
  fi
  git status --short
}

# perform log git command
function log
{
  __presentation "log"

  if [[ ! -d .git ]]; then
    red "## This folder is not a working tree"
    return
  fi

  if [[ ! "$(git branch -vv)" ]];then
    red "## There are no branches or commits to generate log"
    return
  fi

  git log \
  --pretty=format:"%C(yellow)%h %cd%Creset | %C(green)%ae%Creset | %<(90,trunc)%s " \
  --date=short \
  --graph \
  --grep="${1}"
  #  --invert-grep \
}

# push the changes to remote repo
function push
{
  git config credential.helper store
  git push
}

# push the changes to remote repo
function pull
{
  git config credential.helper store
  git pull
}