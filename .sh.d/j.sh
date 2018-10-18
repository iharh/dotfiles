# wcd-like 
j() {
  local files

  ali=$(cat ~/alias.wcd | 
    while read line; do
      echo "$line"
    done | fzf -i +s -n1 -q "$*" -0 -1)

  if [[ -n $ali ]]; then
    local selected_dir
    selected_dir=$(echo $ali | cut -d' ' -f2-)
    echo selected: $selected_dir
    cd $selected_dir
  fi
}
