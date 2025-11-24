#!/bin/bash

base_dir="$HOME/.nvim_config"
nvim_base_dir="$base_dir/nvim"
nvim_config_dir="$nvim_base_dir/src/nvim"

# check nvim_config
# echo "nvim_config nvim config at: $nvim_base_dir"
if [ -d "$nvim_base_dir" ]; then
    echo "skipping clone: $nvim_base_dir exists"
else
    git clone https://github.com/nvim_config/nvim_config-nvim-config "$nvim_base_dir"
fi

# check nvim config link
nvim_config=$(nvim --headless --cmd ":echo stdpath('config')" --cmd ":q" 2>&1)
# echo "nvim config at: $nvim_config"
if [ -d "$nvim_config" ]; then
    if [ -h "$nvim_config" ]; then
        nvim_config_target=$(readlink -f "$nvim_config")
        if [ "$nvim_config_target" = "$nvim_config_dir" ]; then
            echo "skipping creating symlink: nvim config points to $nvim_config_dir"
        else
            echo "error: nvim config does not point to $nvim_config_dir, instead it points to $nvim_config_target" 1>&2
            exit 1
        fi
    else
        echo "error: nvim config is not a symbolic link ($nvim_config)" 1>&2
        exit 1
    fi
else
    echo "creating symlink in $nvim_config to $nvim_config_dir"
    mkdir -p "$(dirname "$nvim_config")"
    ln -s -r "$nvim_config_dir" "$nvim_config"
fi

# check required commands
required_commands=("gcc" "make")

for command in "${required_commands[@]}"; do
    if ! command -v "$command" &> /dev/null
    then
        echo "install missing required command \"$command\""
    fi
done

echo "nvim_config-nvim-config installation complete"
echo "after installing any missing required commands listed above, run \"nvim\" and then run the vim command \":Lazy install\""
