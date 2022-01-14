source common.sh

clearStore

cp ./simple.nix ./simple.builder.sh ./config.nix $TEST_HOME
cd $TEST_HOME
mkdir -p foo/subdir
echo '{ outputs = _: {}; }' > foo/flake.nix
cat <<EOF > flake.nix
{
    inputs.foo.url = "$PWD/foo";
    outputs = a: {
       defaultPackage.$system = import ./simple.nix;
       packages.$system.test = import ./simple.nix;
    };
}
EOF
mkdir subdir
pushd subdir

for i in "" . .# .#test ../subdir ../subdir#test "$PWD"; do
    nix build $i || fail "flake should be found by searching up directories"
done

for i in "path:$PWD"; do
    ! nix build $i || fail "flake should not search up directories when using 'path:'"
done

popd

nix build --override-input foo . || fail "flake should search up directories when not an installable"

sed "s,$PWD/foo,$PWD/foo/subdir,g" -i flake.nix
! nix build || fail "flake should not search upwards when part of inputs"
