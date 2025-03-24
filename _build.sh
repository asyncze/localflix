#!/bin/bash

# Localflix by @asyncze (Michael Sjöberg)
#
# This script generates an index.html gallery from all .jpg and .png files in the current directory.
# Hovering over an image shows its name with a transparent dark overlay.
#
# Example folder structure:
#   movies/
#   ├── _build.sh
#   ├── _index.html
#   ├── 2001 A Space Odyssey (1968).png
#   ├── 2001 A Space Odyssey (1968)/
#   │   └── ...
#   ├── A.I. Artificial Intelligence (2001).png
#   ├── A.I. Artificial Intelligence (2001)/
#   │   └── ...

shopt -s nullglob

output="_index.html"

cat << 'EOF' > "$output"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Localflix</title>
<style>
  body { 
      background-color: #141414; 
      color: #fff; 
      font-family: Arial, sans-serif; 
      margin: 0; 
      padding: 20px; 
  }
  h1 { 
      text-align: center; 
  }
  .gallery {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
      grid-gap: 20px;
      margin-top: 20px;
  }
  .gallery-item {
      border-radius: 8px;
      position: relative;
      overflow: hidden;
  }
  .gallery-item img {
      width: 100%;
      border-radius: 8px;
      transition: transform 0.3s ease;
      display: block;
  }
  .gallery-item:hover img {
      transform: scale(1.05);
  }
  .overlay {
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: rgba(0, 0, 0, 0.5);
      color: white;
      opacity: 0;
      transition: opacity 0.3s ease;
      display: flex;
      align-items: center;
      justify-content: center;
      border-radius: 8px;
  }
  .gallery-item:hover .overlay {
      opacity: 1;
  }
  .text {
      font-size: 18px;
      font-weight: bold;
      text-align: center;
      padding: 5px;
  }
</style>
</head>
<body>
<h1>Localflix</h1>
<div class="gallery">
EOF

# loop through all .jpg, .png files and add them to page
printf "%s\n" *.jpg *.png | sort -V | while IFS= read -r file; do
    if [ -f "$file" ]; then
        base="${file%.*}"
        video_file=""
        # check if folder with same base name exists
        if [ -d "$base" ]; then
            # loop through list of video extensions
            for ext in mp4 avi mkv; do
                # convert extension to uppercase using tr
                upper_ext=$(echo "$ext" | tr '[:lower:]' '[:upper:]')
                # look for files with extension in both lowercase and uppercase
                video_matches=( "$base"/*."$ext" "$base"/*."$upper_ext" )
                if [ ${#video_matches[@]} -gt 0 ] && [ -f "${video_matches[0]}" ]; then
                    video_file="${video_matches[0]}"
                    break
                fi
            done
        fi
        # URL-encode video file path if found, otherwise use base name
        if [ -n "$video_file" ]; then
            encoded=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "$video_file")
        else
            encoded=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "$base")
        fi
        cat << EOF >> "$output"
    <div class="gallery-item" onclick="location.href='_player.html?video=${encoded}'">
      <img src="$file" alt="$base">
      <div class="overlay">
         <div class="text">$base</div>
      </div>
    </div>
EOF
    fi
done

# end of file HTML tags
cat << 'EOF' >> "$output"
</div>
</body>
</html>
EOF

echo "Localflix created as $output"
