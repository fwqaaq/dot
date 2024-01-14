#!/usr/bin/env bash
CHROME="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"

if grep -q "Debian" /etc/os-release; then
        pkg="apt"
fi

function install_application() {
        if ! type google-chrome >/dev/null 2>&1; then
                green "Install google chrome in this device (y/n)"
                read answer

                if [[ "$answer" == "y" || "$answer" == "yes" ]]; then
                        wget $CHROME
                        sudo $pkg install ./google-chrome-stable_current_amd64.deb
                        rm ./google-chrome-stable_current_amd64.deb
                fi
        fi

        green "Install telegram-desktop in this device (y/n)"
        read answer
        if [[ "$answer" == "y" || "$answer" == "yes" ]]; then
                sudo $pkg install telegram-desktop/stable -y
        fi
        return 0
}

function install_tools() {
        # check clang, llvm, make, cmake
        tools=("tmux" "cmake" "clang" "clangd")

        for tool in ${tools[@]}; do
                if ! type $tool >/dev/null 2>&1; then
                        green "Install $tool in this device (y/n)"
                        read answer
                        if [[ "$answer" == "y" || "$answer" == "yes" ]]; then
                                case $tool in
                                "tmux")
                                        sudo $pkg install tmux/stable -y
                                        ;;
                                "cmake")
                                        sudo $pkg install cmake/stable -y
                                        ;;
                                "clang")
                                        sudo $pkg install clang-16/stable -y
                                        sudo ln /usr/bin/clang-16 /usr/bin/clang
                                        ;;
                                "clangd")
                                        sudo $pkg install clangd-16/stable -y
                                        sudo ln /usr/bin/clangd-16 /usr/bin/clangd
                                        ;;
                                esac
                        fi
                fi
        done

        return 0
}

function others() {
        green "Install FiraCode Fonts and in this device (y/n)"
        read answer
        if [[ "$answer" == "y" || "$answer" == "yes" ]]; then
                wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/FiraCode.tar.xz
                sudo tar -xvf FiraCode.tar.xz -C /usr/local/share/fonts/
                fc-cache -fv
                rm FiraCode.tar.xz
        fi

        return 0
}

function languages() {
        green "Install Rust, Go, Deno in this device"

        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        curl -fsSL https://deno.land/install.sh | sh
        sudo $pkg install golang/stable -y
        echo 'export DENO_INSTALL="/home/fwqaq/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"' >>$HOME/.zshrc
        yellow "Done. Please source \"$HOME/.cargo/env\"."
        return 0
}

if ! install_application; then
        red "[WRONG] applicaiton install failed."
        exit 1
fi

if ! install_tools; then
        red "[WRONG] tools install failed."
        exit 1
fi

if ! others; then
        red "[WRONG] font files install failed."
        exit 1
fi

green "Install programming languages in this device (y/n)"
read answer
if [[ "$answer" == "y" || "$answer" == "yes" ]]; then
        if ! languages; then
                red "[WRONG] languages install failed."
                exit 1
        fi
fi
