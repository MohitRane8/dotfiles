#!/usr/bin/env bash
set -euo pipefail

command -v fc-cache >/dev/null || {
  echo "fc-cache missing. Run: sudo apt install -y fontconfig"
  exit 1
}

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

font_dir="$HOME/.local/share/fonts"
google_dir="$font_dir/GoogleFonts"
google_base="https://raw.githubusercontent.com/google/fonts/main"

curl -fL https://github.com/madmalik/mononoki/releases/latest/download/mononoki.zip \
  -o "$tmp/mononoki.zip"
curl -fL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Mononoki.zip \
  -o "$tmp/Mononoki.zip"
curl -fL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip \
  -o "$tmp/JetBrainsMono.zip"

google_fonts=(
  "ofl/asap/Asap"{,-Italic}"[wdth,wght].ttf"
  "ofl/fragmentmono/FragmentMono-"{Regular,Italic}".ttf"
  "ofl/inter/Inter"{,-Italic}"[opsz,wght].ttf"
  "ofl/splinesansmono/SplineSansMono"{,-Italic}"[wght].ttf"
  "ofl/martianmono/MartianMono[wdth,wght].ttf"
  "ofl/redditsans/RedditSans"{,-Italic}"[wght].ttf"
  "ofl/redditmono/RedditMono[wght].ttf"
  "ofl/iosevkacharonmono/IosevkaCharonMono-"{Light,LightItalic,Regular,Italic,Medium,MediumItalic,Bold,BoldItalic}".ttf"
)

for font in "${google_fonts[@]}"; do
  curl --globoff -fL "$google_base/$font" -o "$tmp/$(basename "$font")"
done

mkdir -p "$font_dir/mononoki" "$font_dir/Mononoki" \
  "$font_dir/JetBrainsMonoNerd" "$google_dir"
unzip -oq "$tmp/mononoki.zip" -d "$font_dir/mononoki"
unzip -oq "$tmp/Mononoki.zip" -d "$font_dir/Mononoki"
unzip -oq "$tmp/JetBrainsMono.zip" -d "$font_dir/JetBrainsMonoNerd"
install -m 0644 "$tmp"/*.ttf "$google_dir/"

fc-cache -f
echo "Fonts installed into: $font_dir"
