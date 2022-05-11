tmp=$(mktemp -d)

git clone https://github.com/ScoopInstaller/Main $tmp/main -b master --depth 1

cp $tmp/main/bucket/{v2ray,xray}.json bucket/

sed -E -i 's/github\.com\/(.+)\/releases\/download/download.fastgit.org\/\1\/releases\/download/' bucket/{v2ray,xray}.json

# https://stackoverflow.com/a/25149786
if [[ $(git status --porcelain --untracked-files=no) ]]; then
  git add bucket/{v2ray,xray}.json
  git config user.name "github-actions[bot]"
  git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
  git commit -m "Sync external manifest"
  git push
fi

rm -rf $tmp
