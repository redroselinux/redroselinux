# This script is totally AI generated.
# I am using it to fix issues with shared libraries, so issues are found soon.

(
export LC_ALL=C; R=rootfs/filesystem; shopt -s nullglob
unset st mf cnt pid seen elf files      # drop anything inherited from earlier runs
declare -A st mf cnt pid seen; elf=(); m=0 ok=0 sk=0 fl=0 j=0
files=($R/usr/*bin/*)

for f in "${files[@]}"; do
  magic=
  [ -f "$f" ] && [ ! -L "$f" ] && IFS= read -r -n4 magic 2>/dev/null <"$f"
  if [[ $magic == $'\x7fELF' ]]; then elf+=("$f"); st["$f"]=e; else st["$f"]=s; fi
done

tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
if [ ${#elf[@]} -gt 0 ]; then
  while IFS=$'\t' read -r f l; do
    mf["$f"]+="$l "; cnt[$l]=$(( ${cnt[$l]:-0} + 1 )); m=$((m+1))
  done < <(
    { find -H $R/lib $R/lib64 $R/usr/lib $R/usr/lib64 \( -type f -o -type l \) -printf 'L %f\n' 2>/dev/null
      readelf -d "${elf[@]}" 2>/dev/null; } |
    F0=${elf[0]} awk '
      BEGIN { f = ENVIRON["F0"] }
      /^L /                { have[substr($0,3)] = 1; next }
      /^File: /            { f = substr($0,7); next }
      /Shared library: \[/ { s=$0; sub(/.*Shared library: \[/,"",s); sub(/\].*/,"",s)
                             if (!(s in have)) print f "\t" s }')
fi

for l in "${!cnt[@]}"; do
  n=${l#lib}; car search "${n%%.so*}" </dev/null >"$tmp/$l" 2>&1 & pid[$l]=$!
  ((++j % 16)) || wait
done

for f in "${files[@]}"; do
  if [ "${st[$f]}" = s ]; then
    printf '%s... \033[33mskip\033[0m\n' "$f"; sk=$((sk+1))
  elif [ -z "${mf[$f]}" ]; then
    printf '%s... \033[32mok\033[0m\n' "$f"; ok=$((ok+1))
  else
    printf '%s... \033[1;31mfail\033[0m\n' "$f"; fl=$((fl+1))
    for l in ${mf[$f]}; do
      printf '    \033[1;31m:: missing %s\033[0m\n' "$l"
      if [ -z "${seen[$l]}" ]; then
        seen[$l]=1; wait "${pid[$l]}" 2>/dev/null
        while IFS= read -r x; do printf '        %s\n' "$x"; done <"$tmp/$l"
      fi
    done
  fi
done

row(){ printf '| %-20s | %6d |\n' "$1" "$2"; }
printf '\n+----------------------+--------+\n| %-20s | %6s |\n+----------------------+--------+\n' STAT COUNT
row total ${#files[@]}; row ok $ok; row skipped $sk; row failed $fl; row "missing libs" $m; row "unique missing libs" ${#cnt[@]}
printf '+----------------------+--------+\n'
if [ ${#cnt[@]} -gt 0 ]; then
  printf '\n+------------------------------------------+----------+\n| %-40s | %8s |\n+------------------------------------------+----------+\n' "MISSING LIB" BINARIES
  for l in "${!cnt[@]}"; do printf '%d\t%s\n' "${cnt[$l]}" "$l"; done | sort -t$'\t' -k1,1nr -k2,2 |
    while IFS=$'\t' read -r c l; do printf '| %-40s | %8d |\n' "$l" "$c"; done
  printf '+------------------------------------------+----------+\n'
fi
)
