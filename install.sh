#!/usr/bin/env bash

OhMyZSH="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
Root="https://raw.githubusercontent.com/fwqaaq/dot/main/"
ZshAutoSuggestions="https://github.com/zsh-users/zsh-autosuggestions"
ZshHistorySubStringSearch="https://github.com/zsh-users/zsh-history-substring-search"
ZshSyntaxHighLighting="https://github.com/zsh-users/zsh-syntax-highlighting.git"
Powerlevel10k="https://github.com/romkatv/powerlevel10k.git"
Nvm="https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh"
Repo="https://github.com/fwqaaq/dot.git"
NvimPath='https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz'
DownLoadNvimPath='/opt/nvim-linux64.tar.gz'

choses=("install" "exit")

green() {
        echo -e "\e[32m $1 \e[0m"
}

yellow() {
        echo -e "\e[33m $1 \e[0m"
}

red() {
        echo -e "\e[34m $1 \e[0m"
}

installPlugins() {
        if [ -n "$ZSH" ]; then
                Custom="$ZSH/custom"
        else
                red "Not found ZSH!!!"
                exit 1
        fi

        local pluginsPath_sug="${Custom}/plugins/zsh-autosuggestions"
        local pluginsPath_sea="${Custom}/plugins/zsh-history-substring-search"
        local PluginsPath_hig="${Custom}/plugins/zsh-syntax-highlighting"
        local ThemePath_pow="${Custom}/themes/powerlevel10k"
        if [ ! -d "$pluginsPath_sug" ]; then
                green "Installing $ZshAutoSuggestions ...."
                git clone --depth=1 "$ZshAutoSuggestions" "$pluginsPath_sug"
        fi
        if [ ! -d "$pluginsPath_sea" ]; then
                green "Installing $ZshHistorySubStringSearch ...."
                git clone --depth=1 "$ZshHistorySubStringSearch" "$pluginsPath_sea"
        fi
        if [ ! -d "$PluginsPath_hig" ]; then
                green "Installing $ZshSyntaxHighLighting ...."
                git clone --depth=1 "$ZshSyntaxHighLighting" "$PluginsPath_hig"
        fi
        if [ ! -d "$ThemePath_pow" ]; then
                green "Installing $Powerlevel10k ...."
                git clone --depth=1 "$Powerlevel10k" "$ThemePath_pow"
        fi
}

installNvm() {
        if command -v node >/dev/null 2>&1; then
                green "Hi, you already have node, we will jump! You can chose by youself.."
        fi
        select chose in "${choses[@]}"; do
                case $chose in
                "install")
                        green "start automatic intall for you"
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
                        yellow "You need to install by yourself."
                        exit 1
                        ;;
                *)
                        red "Invalid entry"
                        ;;
                esac
        done
}

installTmux() {
        if ! command -v tmux >/dev/null 2>&1; then
                green "Hi, you don't yet have tmux, we will exit!..."
                exit 1
        fi

        green "Let's start to install .tmux.conf and its plugins."
        curl -o ~/.tmux.conf "${Root}.tmux.conf"
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
        yellow "Done. But you must open tmux, and use 'Ctrl-a' + 'Shift-i' to install others plugins."
}

installNvim() {
        if ! command -v nvim >/dev/null 2>&1; then
                set -e
                sudo curl -L -o $DownLoadNvimPath $NvimPath
                sudo tar -xvf $DownLoadNvimPath -C /opt/
                sudo ln -s /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim
                sudo rm -rf $DownLoadNvimPath
                set +e
        fi

        if [ ! -d "$HOME/.config/" ]; then
                mkdir -p "$HOME/.config/"
        fi

        if [ -d "$HOME/.config/nvim" ]; then
                mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak"
        fi
}

if ! command -v git >/dev/null 2>&1; then
        red "Please install git at first."
        exit 1
fi

if [[ -n "$SHELL" && "${SHELL##*/}" != "zsh" ]]; then
        if command -v zsh >/dev/null 2>&1; then
                if chsh -s "$(which zsh)"; then
                        yellow "Zsh is now the default shell. Please log out and log back in to apply the changes."
                else
                        yellow "You need to install chsh command at first. Or You can set zsh by manually."
                        exit 1
                fi
        else
                red "Zsh is not installed. You must intall zsh at first."
                exit 1
        fi
fi

green "Do you want to install .zshrc and p10k config? And, it's necessary. Please intput (y/n)"
read answer

if [ "$answer" = "y" ]; then
        curl -o ~/.zshrc "${Root}.zshrc"
        curl -o ~/.p10k.zsh "${Root}.p10k.zsh"
        # Generate $ZSH
        source ~/.zshrc
        green -e "\e[42;30mComplete plugin download\e[0m"
elif [ "$answer" = "n" ] && [ ! -f "$HOME/.zshrc" ]; then
        red "exit...."
        exit 1
fi

if [ ! -n "$ZSH" ] || [ ! -f "$ZSH/oh-my-zsh.sh" ]; then
        green "              You need to install oh-my-zsh, you can chose 1 or 2"
        green "              1, it can automatic intall for you"
        green "              2, then by youself by manually, shell will be exitem"

        green "start automatic intall for you"
        (
                sh -c "$(curl -fsSL $OhMyZSH)"
        ) &
        wait $!
fi

# Download plugins
# source ~/.zshrc
installPlugins

# Install nvm for node
green "Do you want to install nvm to manage node config? Please intput (y/n)"
read answer

if [ "$answer" = "y" ]; then
        if installNvm; then
                echo -e "\e[42;30mComplete nvm and pnpm download\e[0m"
                yellow "Please exec \e[41msource ~/.zshrc\e[0m"
        else
                red "Excution failed! Please view the question!"
        fi
else
        green "Continue....."
fi

# Install tmux
green "Do you want to install tmux config? Please intput (y/n)"
read answer

if [ "$answer" = "y" ]; then
        green "Start...."
        if installTmux; then
                green "Complete tmux download."
        else
                red "Excution failed! Please view the question!"
        fi
else
        green "Countine...."
fi

red "Please source .zshrc, or log out and login in again."

# Install Nvim
green "Do you want to install nvim config? Please intput (y/n)"
read answer
if [ "$answer" = "y" ]; then
        if installNvim; then
                git clone --depth=1 "$Repo" "$HOME/.config/dot"
                mv "$HOME/.config/dot/.config/nvim/" "$HOME/.config/nvim/"
                rm -rf "$HOME/.config/dot"
                green "Complete nvim download."
        else
                red "Excution failed! Please view the question!"
        fi
else
        green "Continue....."
fi
