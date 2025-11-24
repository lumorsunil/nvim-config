# Todo

## Largish

- [ ] learn undotree
- [ ] when in lushify mode, be able to add/edit the higlight rule for the node under the cursor, perhaps just jump to the place in the lush code where it's defined or create a new entry for it if it's not defined
- [ ] plugin that enables to change plugin settings on the fly (for compatible plugins)

## Low-Prio

- [ ] short context switch: extend to recently used marks and other relevant locations
- [ ] daily todos: improve open daily function to look for existing buffers that are shown with the target daily file and switch to that buffer instead of opening a new one
- [ ] daily todos: replace current way of finding sections and tasks with treesitter logic
- [ ] fix issue with "go to url" functionality that does not seem to work on some urls (maybe port numbers issue?) # the issue seems to be that it can't match hostnames with no dots (http://localhost doesn't match while http://localhost.com does)

## Done

- [x] git integration
  - [x] git commit (using git commit)
  - [x] git blame (:EnableBlameLine)
  - [x] git signs
  - [x] conflict solver (:DiffviewOpen)
  - [x] file/line history (:DiffviewFileHistory)
- [x] jump to help section under cursor
- [x] color switch depending on context
- [x] integrate lushify to define new color schemes easily
- [x] easily open the current colorscheme, if it's defined in colors_src plugin
- [x] more context about current opened file (abbreviated foldername ?)
- [x] fix bug in SCS where long buffer names are not fully visible # still not fully visible but abbreviated
- [x] add command to daily-todos that "saves"/("publishes") the changes to remote (git add . && git push)
- [x] short context window quick tab with shift-tab (open a float window populated with recent marks, buffers etc, stack order, same functionality as alt-tabbing like back and forth with windows)
- [x] fix bug where prettier error is overwriting the current file being formatted
- [x] fix bug where prettier does not use the config of the project
- [x] npm scripts plugin: implement plugin that reads package.json and allows you to spawn terminals that run the scripts
  - [x] read script list and have different ways to access the list (ie: :PmsScripts, :PmsRun <script>)
  - [x] run a script which starts a terminal (unless terminal already exists for that script)
  - [x] command to restart script, (maybe keep a list of running scripts that can be selected from)
- [x] implement with keymap CTRL + up/down to mean move lines up/down, can also work in visual mode with range
- [x] [RESOLVED BY DISABLING TREE]: bug: coloring of different windows gets messed up with nvim tree when selecting which window to put a file
