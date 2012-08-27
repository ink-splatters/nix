source common.sh

clearStore

# Create the binary cache.
cacheDir=$TEST_ROOT/binary-cache
rm -rf $cacheDir

outPath=$(nix-build dependencies.nix --no-out-link)

nix-push --dest $cacheDir $outPath


# By default, a binary cache doesn't support "nix-env -qas", but does
# support installation.
clearStore
rm -f $NIX_STATE_DIR/binary-cache*

nix-env --option binary-caches "file://$cacheDir" -f dependencies.nix -qas \* | grep -- "---"

nix-store --option binary-caches "file://$cacheDir" -r $outPath


# But with the right configuration, "nix-env -qas" should also work.
clearStore
rm -f $NIX_STATE_DIR/binary-cache*
echo "WantMassQuery: 1" >> $cacheDir/nix-cache-info

nix-env --option binary-caches "file://$cacheDir" -f dependencies.nix -qas \* | grep -- "--S"

nix-store --option binary-caches "file://$cacheDir" -r $outPath

nix-store --check-validity $outPath
nix-store -qR $outPath | grep input-2

