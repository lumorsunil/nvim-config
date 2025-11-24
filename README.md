# nvim-config

This is my config for nvim, I usually run it on Ubuntu in WSL.

## Installation

**WARNING**

This is a weird setup that I've hacked together, you can probably figure things out for yourself.
But if you want to do it how I do it, here are some vague instructions:

Clone this repository and/or copy the install.sh file and run it.

The install.sh will clone the repository into ~/.nvim-config/nvim and link ~/.config/nvim to the config.

## Dependencies (not all required)

These are tools that make lsps and other things like telescope work as expected.
The commands for each is catered to my usual distribution of linux.

gcc,make - `sudo apt install build-essential`
[nodejs](https://nodejs.org/en) ([nvm](https://github.com/nvm-sh/nvm) recommended to install latest lts)
[ripgrep](https://github.com/BurntSushi/ripgrep) - `sudo apt install ripgrep` - for telescope live_grep
jq - `sudo apt install jq` - for JSON formatting/querying
[vscode lsps](https://github.com/hrsh7th/vscode-langservers-extracted) - `npm i -g vscode-langservers-extracted` - .json, .js, .html, .css, eslint lsps
[vtsls](https://github.com/yioneko/vtsls) - `npm install -g @vtsls/language-server` - .ts lsp
[marksman](https://github.com/artempyanykh/marksman/releases) - .md lsp
[bash-language-server](https://github.com/bash-lsp/bash-language-server) - `npm i -g bash-language-server` - .sh lsp
[lua-language-server](https://github.com/LuaLS/lua-language-server/releases/tag/3.14.0) - .lua lsp
