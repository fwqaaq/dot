#!/usr/bin/env bash

type bash &>/dev/null && shtype=bash || shtype=sh

OhMyZSH="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
Root="https://raw.githubusercontent.com/fwqaaq/Nvim/main/"
Custom="$ZSH/custom"
ZshAutoSuggestions="https://github.com/zsh-users/zsh-autosuggestions"
ZshHistorySubStringSearch="https://github.com/zsh-users/zsh-history-substring-search"
ZshSyntaxHighLighting="https://github.com/zsh-users/zsh-syntax-highlighting.git"
Powerlevel10k="https://github.com/romkatv/powerlevel10k.git"
Nvm="https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh"

choses=("install" "exit")

installPlugins() {
  local pluginsPath_sug="${Custom}/plugins/zsh-autosuggestions"
  local pluginsPath_sea="${Custom}/plugins/zsh-history-substring-search"
  local PluginsPath_hig="${Custom}/plugins/zsh-syntax-highlighting"
  local ThemePath_pow="${Custom}/themes/powerlevel10k"
  if [ ! -d $pluginsPath_sug ]; then
    echo -e "\e[32mInstalling $ZshAutoSuggestions ....\e[0m"
    git clone --depth=1 $ZshAutoSuggestions $pluginsPath_sug
  fi
  if [ ! -d $pluginsPath_sea ]; then
    echo -e "\e[32mInstalling $ZshHistorySubStringSearch ....\e[0m"
    git clone --depth=1 $ZshHistorySubStringSearch $pluginsPath_sea
  fi
  if [ ! -d $PluginsPath_hig ]; then
    echo -e "\e[32mInstalling $ZshSyntaxHighLighting ....\e[0m"
    git clone --depth=1 $ZshSyntaxHighLighting $PluginsPath_hig
  fi
  if [ ! -d $ThemePath_pow ]; then
    echo -e "\e[32mInstalling $Powerlevel10k ....\e[0m"
    git clone --depth=1 $Powerlevel10k $ThemePath_pow
  fi
}

installNvm() {
  if command -v node >/dev/null 2>&1; then
    echo "\e[32mHi, you already have node, we will jump! You can chose by youself...\e[0m"
  fi
  select chose in "${choses[@]}"; do
    case $chose in
    "install")
      echo -e "\e[32mstart automatic intall for you\e[0m"
      (curl -o- $Nvm | bash) &
      wait $!
      source ~/.zshrc
      set -e
      nvm install --lts
      npm install pnpm -g
      node -v && pnpm -v
      set +e
      break
      ;;
    "exit")
      echo -e "\e[34mYou need to install by yourself\e[0m"
      exit 1
      ;;
    *)
      echo -e "\e[31mInvalid entry\e[0m"
      ;;
    esac
  done
}

installTmux() {
  if ! command -v tmux >/dev/null 2>&1; then
    echo -e "\e[32mHi, you don't yet have tmux, we will exit!...\e[0m"
    exit 1
  fi

  echo -e "\e[31m Let's start to install .tmux.conf and its plugins.\e[0m"
  curl -o ~/.tmux.conf "${Root}.tmux.conf"
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  echo -e "\e[31mDone. But you must open tmux, and use 'Ctrl-a' + 'Shift-i' to install others plugins.\e[0m"
}

if ! command -v git >/dev/null 2>&1; then
  echo -e "\e[31mPlease install git at first.\e[0m"
  exit 1
fi

if [[ -n "$SHELL" && "${SHELL##*/}" != "zsh" ]]; then
  if command -v zsh >/dev/null 2>&1; then
    if chsh -s "$(which zsh)"; then
      echo -e "\e[31mZsh is now the default shell. Please log out and log back in to apply the changes.\e[0m"
    else
      echo -e "\e[31m You need to install chsh command at first. Or You can set zsh by manually.\e[0m"
      exit 1
    fi
  else
    echo -e "\e[31mZsh is not installed. You must intall zsh at first.\e[0m"
    exit 1
  fi
fi

if [ ! -n "$ZSH" ] || [ ! -f "$ZSH/oh-my-zsh.sh" ]; then
  echo -e "\e[32m              You need to install oh-my-zsh, you can chose 1 or 2\e[0m"
  echo -e "\e[32m              1, it can automatic intall for you\e[0m"
  echo -e "\e[32m              2, then by youself by manually, shell will be exited\e[0m"
  select chose in "${choses[@]}"; do
    case $chose in
    "install")
      echo -e "\e[32mstart automatic intall for you\e[0m"
      (
        sh -c "$(curl -fsSL $OhMyZSH)"
      ) &
      break
      ;;
    "exit")
      echo -e "\e[34mYou need to install by yourself\e[0m"
      exit 1
      ;;
    *)
      echo -e "\e[31mInvalid entry\e[0m"
      break
      ;;
    esac
  done
fi

wait

read -p "Do you want to install nvm to zsh and p10k config? Please intput (y/n)" answer
if [ "$answer" = "y" ]; then
  if installPlugins; then
    curl -o ~/.zshrc "${Root}.zshrc"
    curl -o ~/.p10k.zsh "${Root}.p10k.zsh"
    echo -e "\e[42;30mComplete plugin download\e[0m"
  else
    echo "\e[31mExcution failed! Please view the question!\e[0m"
  fi
else
  echo -e "Continue...."
fi

# Install nvm for node

read -p "Do you want to install nvm to manage node config? Please intput (y/n)" answer

if [ "$answer" = "y" ]; then
  if installNvm; then
    echo -e "\e[42;30mComplete nvm and pnpm download\e[0m"
    echo -e "Please exec \e[42msource ~/.zshrc\e[0m"
  else
    echo "\e[31mExcution failed! Please view the question!\e[0m"
  fi
else
  echo -e "Continue....."
fi

# Install tmux

read -p "Do you want to install tmux config? Please intput (y/n)" answer

if [ "$answer" = "y" ]; then
  echo -e "\e[32mStart....\e[0m"
  if installTmux; then
    echo -e "\e[32mComplete tmux download.\e[0m"
  else
    echo "\e[31mExcution failed! Please view the question!\e[0m"
  fi
else
  echo -e "Countine...."
fi
