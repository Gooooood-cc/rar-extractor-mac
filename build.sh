#!/bin/zsh
set -euo pipefail

root_dir=${0:A:h}
app_path="$root_dir/dist/解压 RAR.app"

rm -rf "$app_path"
mkdir -p "$app_path/Contents/MacOS" "$app_path/Contents/Resources" "$root_dir/build/clang-cache"

cp "$root_dir/src/Info.plist" "$app_path/Contents/Info.plist"
printf 'APPL????' > "$app_path/Contents/PkgInfo"

env CLANG_MODULE_CACHE_PATH="$root_dir/build/clang-cache" \
  clang -fobjc-arc -framework Cocoa "$root_dir/src/RarExtractor.m" -o "$app_path/Contents/MacOS/RarExtractor"

chmod +x "$app_path/Contents/MacOS/RarExtractor"
codesign --force --deep --sign - "$app_path"

ditto -c -k --keepParent "$app_path" "$root_dir/dist/解压 RAR-macOS.zip"

