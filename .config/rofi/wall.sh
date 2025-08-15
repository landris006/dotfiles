#!/bin/bash

wallpaper_dir="${HOME}/Pictures/Wallpapers"
cache_dir="${HOME}/.cache/wallpaper-preview"
rofi_command="rofi -p $wallpaper_dir -dmenu -theme ${HOME}/.config/rofi/wallpaper.rasi -theme-str"

# Create cache dir if not exists
if [ ! -d "${cache_dir}" ] ; then
  mkdir -p "${cache_dir}"
fi

# Scale down images and save to cache dir
for image_path in "$wallpaper_dir"/*.{jpg,jpeg,png,webp}; do
	if [ -f "$image_path" ]; then
		image_name=$(basename "$image_path")
			if [ ! -f "${cache_dir}/${image_name}" ] ; then
        ffmpeg -i "$image_path" -vf scale=-1:500 -q:v 1 "${cache_dir}/${image_name}"
			fi
    fi
done

# Select a picture with rofi
file_list=$(find "${wallpaper_dir}" -maxdepth 1  -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -exec basename {} \;)
wall_selection=$(
  printf "%s\n" "${file_list}" \
  | sort \
  | {
    while read -r A;
    do \
      echo -en "$A\x00icon\x1f""${cache_dir}"/"$A\n"
    done
    echo "random"
  } \
  | $rofi_command
)

# Set the wallpaper
[[ -n "$wall_selection" ]] || exit 1

if [[ "$wall_selection" == "random" ]]; then
  wall_selection=$(
    printf "%s\n" "${file_list}" \
    | sort -R \
    | head -n 1
  )
fi

wallpaper_path="${wallpaper_dir}/${wall_selection}"
swww img \
  "${wallpaper_path}" \
  --transition-fps 165 \
  --transition-type grow \
  --transition-pos 0.8,0.9 && \
  echo "${wallpaper_path}" > "${HOME}/.cache/current-wallpaper"

exit 0
