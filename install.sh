#!/usr/bin/env bash

OHMYZSH="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
ROOT="https://raw.githubusercontent.com/fwqaaq/dot/main/"
ZSHAUTOSUGGESTIONS="https://github.com/zsh-users/zsh-autosuggestions"
ZSHHISTORYSUBSTRINGSEARCH="https://github.com/zsh-users/zsh-history-substring-search"
ZSHSYNTAXHIGHLIGHTING="https://github.com/zsh-users/zsh-syntax-highlighting.git"
POWERLEVEL10K="https://github.com/romkatv/powerlevel10k.git"
NVM="https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh"
REPO="https://github.com/fwqaaq/dot.git"
NVIMPATH="https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz"
DOWNLOADNVIMPATH="/opt/nvim-linux64.tar.gz"

green() {
    # \e 的兼容性差
    echo -e "\033[32m $1 \033[0m"
}

yellow() {
    echo -e "\033[33m $1 \033[0m"
}

red() {
    echo -e "\033[31m $1 \033[0m"
}

export -f green yellow red

start() {
    text="
                         ____ _____  _    ____ _____      
                  __/\__/ ___|_   _|/ \  |  _ \_   _|_/\__
                  \    /\___ \ | | / _ \ | |_) || | \    /
                  /_  _\ ___) || |/ ___ \|  _ < | | /_  _\\
                    \/  |____/ |_/_/   \_\_| \_\|_|   \/  
        "
    echo -e "\033[32m $text \033[0m"
}

install_plugins() {
    if [[ -n "$ZSH" ]]; then
        custom="$ZSH/custom"
    else
        red "Not found ZSH!!!"
        exit 1
    fi

    local plugins_path_sug="${custom}/plugins/zsh-autosuggestions"
    local plugins_path_sea="${custom}/plugins/zsh-history-substring-search"
    local plugins_path_hig="${custom}/plugins/zsh-syntax-highlighting"
    local theme_path_pow="${custom}/themes/powerlevel10k"
    if [[ ! -d "$plugins_path_sug" ]]; then
        green "[INFO] Installing $ZSHAUTOSUGGESTIONS ...."
        git clone --depth=1 "$ZSHAUTOSUGGESTIONS" "$plugins_path_sug"
    fi
    if [[ ! -d "$plugins_path_sea" ]]; then
        green "[INFO] Installing $ZSHHISTORYSUBSTRINGSEARCH ...."
        git clone --depth=1 "$ZSHHISTORYSUBSTRINGSEARCH" "$plugins_path_sea"
    fi
    if [[ ! -d "$plugins_path_hig" ]]; then
        green "[INFO] Installing $ZSHSYNTAXHIGHLIGHTING ...."
        git clone --depth=1 "$ZSHSYNTAXHIGHLIGHTING" "$plugins_path_hig"
    fi
    if [[ ! -d "$theme_path_pow" ]]; then
        green "[INFO] Installing $POWERLEVEL10K ...."
        git clone --depth=1 "$POWERLEVEL10K" "$theme_path_pow"
    fi
}

install_nvm() {
    if command -v node >/dev/null 2>&1; then
        yellow "[WARNING] Hi, you already have node, we will jump! You can chose by youself.."
    fi

    green "[INFO] Beginning automatic installation for you."
    (curl -o- $NVM | bash) &
    wait $!
    set -e
    nvm install --lts
    npm install pnpm -g
    node -v && pnpm -v
    set +e
}

install_tmux() {
    if ! command -v tmux >/dev/null 2>&1; then
        red "[WRONG] Hi, you don't yet have tmux, we will exit!..."
        exit 1
    fi

    green "[INFO] Let's start to install .tmux.conf and its plugins."
    curl -o ~/.tmux.conf "${ROOT}.tmux.conf"
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    yellow "[WARNING] Done. But you must open tmux, and use 'Ctrl-a' + 'Shift-i' to install others plugins."
}

install_nvim() {
    # check x86
    if [[ "$(uname -m)" != "x86_64" ]]; then
        red "[WRONG] Nvim only support x86_64."
        exit 1
    fi

    if ! command -v nvim >/dev/null 2>&1; then
        set -e
        sudo curl -L -o $DOWNLOADNVIMPATH $NVIMPATH
        sudo tar -xvf $DOWNLOADNVIMPATH -C /opt/
        sudo ln -s /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim
        sudo rm -rf $DOWNLOADNVIMPATH
        set +e
    fi

    if [[ ! -d "$HOME/.config/" ]]; then
        mkdir -p "$HOME/.config/"
    fi

    if [[ -d "$HOME/.config/nvim" ]]; then
        mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak"
    fi
}

# flag!
start

if [[ "$(uname)" == "Linux" ]]; then
    green "Init for Linux OS (y/n)"
    read answer
    if [[ "$answer" == "y" || "$answer" == "yes" ]]; then
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/fwqaaq/dot/main/debian.sh)"
    fi
fi

if ! command -v git >/dev/null 2>&1; then
    red "[WRONG] Please install git at first."
    exit 1
fi

if [[ -n "$SHELL" && "${SHELL##*/}" != "zsh" ]]; then
    if command -v zsh >/dev/null 2>&1; then
        if chsh -s "$(which zsh)"; then
            yellow "[WARNING] Zsh is now the default shell. Please log out and log back in to apply the changes."
        else
            yellow "[WARNING] You need to install chsh command at first. Or You can set zsh by manually."
            exit 1
        fi
    else
        red "[WRONG] Zsh is not installed. You must intall zsh at first."
        exit 1
    fi
fi

if [[ ! -n "$ZSH" || ! -f "$ZSH/oh-my-zsh.sh" ]]; then
    green "[INFO] You need to install oh-my-zsh; It can be installed automatically for you now."

    (
        sh -c "$(curl -fsSL $OHMYZSH)"
    ) &
    wait $!
    export ZSH="$HOME/.oh-my-zsh"
fi

echo -e "\033[32m 1 Install .zshrc and p10k config.\033[0m \033[31mAnd, it's necessary.\033[0m \033[32mPlease intput (y/n)\033[0m"
read answer

if [[ "$answer" = "y" || "$answer" = "yes" ]]; then
    curl -o ~/.zshrc "${ROOT}.zshrc"
    curl -o ~/.p10k.zsh "${ROOT}.p10k.zsh"
    # Generate $ZSH
    green "[INFO] Complete plugin download"
elif [[ "$answer" = "n" && ! -f "$HOME/.zshrc" ]]; then
    red "You don't have .zshrc file, please generate it!!!"
    exit 1
fi

# Download plugins
install_plugins

# Install nvm for node
green "2 Install nvm to manage node config. Please intput (y/n)"
read answer

if [[ "$answer" = "y" || "$answer" = "yes" ]]; then
    if install_nvm; then
        echo -e "\033[42;30m Complete nvm and pnpm download.\033[0m"
        yellow "[WARNING] Please exec source ~/.zshrc"
    else
        red "[WRONG] Excution failed! Please view the question!"
    fi
fi

# Install tmux
green "3 Install tmux config. Please intput (y/n)"
read answer

if [[ "$answer" = "y" || "$answer" = "yes" ]]; then
    green "Start...."
    if install_tmux; then
        green "[INFO] Complete tmux download."
    else
        red "[WRONG] Excution failed! Please view the question!"
    fi
fi

# Install Nvim
green "4 Install nvim config? Please intput (y/n)"
read answer
if [[ "$answer" = "y" || "$answer" = "yes" ]]; then
    if install_nvim; then
        git clone --depth=1 "$REPO" "$HOME/.config/dot"
        mv "$HOME/.config/dot/.config/nvim/" "$HOME/.config/nvim/"
        rm -rf "$HOME/.config/dot"
        green "[INFO] Complete nvim download."
    else
        red "[WRONG] Excution failed! Please view the question!"
    fi
fi

yellow "[WARNING] Please exec source ~/.zshrc or reboot your computer."
