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

# generate index page

index="_index.html"

cat << 'EOF' > "$index"
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

# loop through all dirs in folder
for dir in */; do
    if [ -d "$dir" ]; then
        base="${dir%/}"
        
        # find poster image inside folder (first match)
        poster=$(find "$dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" \) | sort -V | head -n 1)
        # skip if no image file in folder
        [ -z "$poster" ] && continue

        # find video file inside folder
        video_file=""
        for ext in mp4 avi mkv; do
            # convert extension to uppercase for alternate matching
            upper_ext=$(echo "$ext" | tr '[:lower:]' '[:upper:]')
            video_matches=( "$dir"/*."$ext" "$dir"/*."$upper_ext" )
            if [ ${#video_matches[@]} -gt 0 ] && [ -f "${video_matches[0]}" ]; then
                video_file="${video_matches[0]}"
                break
            fi
        done
        # skip if no video file in folder
        [ -z "$video_file" ] && continue

        # URL-encode video file path using Python 3
        encoded=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "$video_file")

        # append to index page
        cat << EOF >> "$index"
    <div class="gallery-item" onclick="location.href='_player.html?video=${encoded}'">
      <img src="$poster" alt="$base">
      <div class="overlay">
         <div class="text">$base</div>
      </div>
    </div>
EOF
    fi
done

# end of file HTML tags
cat << 'EOF' >> "$index"
</div>
</body>
</html>
EOF

echo "Localflix : $index created"

# generate player page

player="_player.html"

cat << 'EOF' > "$player"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Localflix</title>
    <style>
        body { background-color: #141414; color: #fff; font-family: Arial, sans-serif; padding: 20px; text-align: center; }
        video { max-width: 90%; margin-top: 20px; border: 5px solid #fff; border-radius: 8px; }
        a { color: #fff; text-decoration: none; }
    </style>
</head>
<body>
    <h1 id="video-title">Loading...</h1>
    
    <video id="video-player" controls>
        <source id="video-source" src="" type="video/mp4">
        Your browser does not support the video tag.
    </video>
    
    <div style="margin-top: 20px;">
        <a href="_index.html">Go back</a>
    </div>
    
    <script>
        // helper function to get query parameters
        function getQueryParam(param) {
            const urlParams = new URLSearchParams(window.location.search);
            return urlParams.get(param);
        }

        // get video name from URL
        const videoName = getQueryParam('video');
        if (videoName) {
            const decodedName = decodeURIComponent(videoName);
            let folderName = decodedName;
            if (decodedName.indexOf('/') !== -1) {
                folderName = decodedName.split('/')[0];
            }

            // set folder name as title
            document.getElementById('video-title').textContent = folderName;
            // set video source
            document.getElementById('video-source').src = decodedName;
            // load the video
            document.getElementById('video-player').load();
        
        } else {
            document.getElementById('video-title').textContent = "No video specified";
        }
    </script>
</body>
</html>
EOF

echo "Localflix : $player created"
