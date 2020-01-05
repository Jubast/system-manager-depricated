
# clean everything and rebuild
dub clean
dub clean-caches
rm dub.selections.json
dub build --force --build=release --force --config=release

# create config dir and copy configs
path="$HOME/.local/share/jubast/system-manager/"
mkdir -p $path

\cp -f *.xml $path
\cp -f monitors.json $path

# create bin dir and copy program
ppath="$HOME/.local/bin/"
mkdir -p $ppath

\cp -f system_manager $ppath