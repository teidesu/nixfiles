set -eauo pipefail
export PATH="$PATH:$HOME/.local/bin"
list=$(aerospace list-windows --monitor all --app-bundle-id com.raphaelamorim.rio)

if ! [ -z "$list" ]; then
    window_id=$(echo "$list" | awk '{print $1}') 
    aerospace move-node-to-workspace --window-id "$window_id" "$(aerospace list-workspaces --focused)"
    aerospace focus --window-id "$window_id"
else
    open -a /Applications/Rio.app
fi