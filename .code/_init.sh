#!/bin/sh

CODE_DIR=$(cd $(dirname $0) && pwd)
VSCODE_SETTING_DIR=~/Library/Application\ Support/Code/User

rm "$VSCODE_SETTING_DIR/settings.json"
ln -s "$CODE_DIR/settings.json" "${VSCODE_SETTING_DIR}/settings.json"

rm "$VSCODE_SETTING_DIR/keybindings.json"
ln -s "$CODE_DIR/keybindings.json" "${VSCODE_SETTING_DIR}/keybindings.json"
