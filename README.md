# Dotfiles
I make use of those dotfiles inside a alpine container using [distrobox](https://distrobox.it/). A similar setup can be made running the following script:

```bash
#!/bin/bash

CONTAINER_NAME="workspace"
CONTAINER_HOME="$HOME/.distrobox/$CONTAINER_NAME"

command -v distrobox >/dev/null 2>&1 || { 
	echo >&2 "Command 'distrobox' not found."
	exit 1 
}

if [[ ! -z $(distrobox-list --no-color | grep $CONTAINER_NAME) ]]; then
	echo "Container with name '$CONTAINER_NAME' already exists."
	exit 1
fi

distrobox create --pull \
    --name $CONTAINER_NAME \
    --home $CONTAINER_HOME \
    --image alpine:latest

function run() {
	cmd="distrobox-enter $CONTAINER_NAME -e "
	[[ $1 == "sudo" ]] && cmd+="sudo sh -c \"$2\"" || cmd+="sh -c \"$1\""
	echo $cmd | sh || {
		distrobox rm -f $CONTAINER_NAME
		rm -rf $CONTAINER_HOME
		exit 1
	}
}

run sudo "echo https://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories"
run sudo "apk update && apk upgrade"
run sudo "apk add \
    stow make gcc musl musl-dev openssl-dev openssl-libs-static \
    yazi yazi-cli file 7zip jq poppler imagemagick wl-clipboard \
    git lazygit zsh zoxide fzf bat eza fd ripgrep \
    neovim lua-language-server luarocks5.1 \
    kitty kitty-kitten mesa-egl \
    rustup pipx npm yarn"

run "chsh -s /bin/zsh"

run "mkdir -p $CONTAINER_HOME/.local/bin $CONTAINER_HOME/.local/share"
run "ln -s /usr/bin/luarocks-5.1 $CONTAINER_HOME/.local/bin/luarocks"
run "ln -s $HOME/.local/share/fonts $CONTAINER_HOME/.local/share/fonts"

run "rustup-init -y"
run "$CONTAINER_HOME/.cargo/bin/rustup toolchain install nightly"
run "$CONTAINER_HOME/.cargo/bin/cargo install \
    cargo-update tree-sitter-cli stylua selene"

run "distrobox-export \
    --app kitty \
    --extra-flags \"-d $CONTAINER_HOME\" \
    --enter-flags \"-a \"--env SHELL=zsh\"\""

run "git clone https://github.com/marjrohn/.dotfiles.git $CONTAINER_HOME/.dotfiles"
run "cd $CONTAINER_HOME/.dotfiles && stow ."

distrobox stop --yes $CONTAINER_NAME
```

To update everything you can run the following commands inside the container.

```bash
sudo apk update && sudo apk upgrade
rustup update
cargo install-update -a
pipx upgrade-all
yarn global upgrade
npm update --global
nvim --headless "+Lazy! Sync" +qa
```

