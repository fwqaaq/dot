#!/usr/bin/env bash

type bash &>/dev/null && shtype=bash || shtype=sh

OhMyZSH="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
Root="https://raw.githubusercontent.com/fwqaaq/Nvim/main/"
Custom="$ZSH/custom"
ZshAutoSuggestions="https://github.com/zsh-users/zsh-autosuggestions"
ZshHistorySubStringSearch="https://github.com/zsh-users/zsh-history-substring-search"
ZshSyntaxHighLighting="https://github.com/zsh-users/zsh-syntax-highlighting.git"
Powerlevel10k="https://github.com/romkatv/powerlevel10k.git"

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
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
      ) &
      break
      ;;
    "exit")
      echo -e "\e[34mYou need to install Oh-my-zsh by yourself\e[0m"
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

if installPlugins; then
  echo -e "\e[42mComplete plugin download\e[0m"
fi

curl -o ~/.zshrc "${Root}.zshrc"
curl -o ~/.p10k.zsh "${Root}.p10k.zsh"
