#!/bin/bash

# Localflix by @asyncze (Michael Sjöberg)
#
# This script generates an index.html gallery from all .jpg and .png files in the current directory.
# Hovering over an image shows its name with a transparent dark overlay.

shopt -s nullglob

# generate index page

index="_index.html"

cat << 'EOF' > "$index"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">

<title>LOCALFLIX</title>

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
        color: #E50914;
        font-weight: bold;
    }
    .logo {
        display: block;
        margin: 40px auto;
        max-width: 100%;
        border-bottom-left-radius: 20px;
        border-bottom-right-radius: 20px;
    }
    .gallery {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
        grid-gap: 20px;
        margin-top: 20px;
    }
    .gallery-item {
        border-radius: 24px;
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
        border-radius: 24px;
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
    .player-container {
        grid-column: 1 / -1;

        border-radius: 8px;
        overflow: hidden;
    }
    .player-container video {
        width: 100%;
        display: block;
    }
    .close-button {
        position: absolute;
        top: 10px;
        right: 10px;
        background-color: rgba(0, 0, 0, 0.5);
        color: #fff;
        border: none;
        font-size: 20px;
        cursor: pointer;
        padding: 5px 10px;
        border-radius: 4px;
        z-index: 9999 !important;
    }
</style>
</head>
<body>

<img src="data:image/png;base64,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" alt="Localflix Logo" class="logo">

<div class="gallery">
EOF

# loop through all dirs in folder (image inside dir)

# Example folder structure:
#   movies/
#   ├── _build.sh
#   ├── _index.html
#   ├── 2001 A Space Odyssey (1968)/
#   │   ├── 2001 A Space Odyssey (1968).png
#   │   └── ...
#   ├── A.I. Artificial Intelligence (2001)/
#   │   ├── A.I. Artificial Intelligence (2001).png
#   │   └── ...
# for dir in */; do
#     if [ -d "$dir" ]; then
#         base="${dir%/}"
        
#         # find poster image inside folder (first match)
#         poster=$(find "$dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | sort -V | head -n 1)
#         # skip if no image file in folder
#         [ -z "$poster" ] && continue

#         # find video file inside folder
#         video_file=""
#         for ext in mp4 avi mkv; do
#             # convert extension to uppercase for alternate matching
#             upper_ext=$(echo "$ext" | tr '[:lower:]' '[:upper:]')
#             video_matches=( "$dir"/*."$ext" "$dir"/*."$upper_ext" )
#             if [ ${#video_matches[@]} -gt 0 ] && [ -f "${video_matches[0]}" ]; then
#                 video_file="${video_matches[0]}"
#                 break
#             fi
#         done
#         # skip if no video file in folder
#         [ -z "$video_file" ] && continue

#         # URL-encode video file path using Python 3
#         encoded=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "$video_file")

#         # append to index page
#         cat << EOF >> "$index"
#     <div class="gallery-item" onclick="playVideo('${encoded}', this)">
#         <img src="$poster" alt="$base">
#         <div class="overlay">
#             <div class="text">$base</div>
#         </div>
#     </div>
# EOF
#     fi
# done

# loop through all dirs in folder (image outside dir)

# Example folder structure:
#   movies/
#   ├── _localflix.sh
#   ├── _index.html
#   ├── 2001 A Space Odyssey (1968).png
#   ├── 2001 A Space Odyssey (1968)/
#   │   └── ...
#   ├── A.I. Artificial Intelligence (2001).png
#   ├── A.I. Artificial Intelligence (2001)/
#   │   └── ...
for dir in */; do
    if [ -d "$dir" ]; then
        base="${dir%/}"
        
        # look for image in root folder with the same name as directory
        poster=""
        for ext in jpg png jpeg; do
            candidate="${base}.${ext}"
            if [ -f "$candidate" ]; then
                poster="$candidate"
                break
            fi
        done
        # skip if no matching image is found
        [ -z "$poster" ] && continue

        # find video file inside directory
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

        # URL-encode the video file path using Python 3
        encoded=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "$video_file")

        # append to index page
        cat << EOF >> "$index"
    <div class="gallery-item" onclick="playVideo('${encoded}', this)">
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

<script>
    // function to dynamically insert video player below clicked item
    function playVideo(encodedVideo, clickedElem) {
        var videoPath = decodeURIComponent(encodedVideo);

        // remove any existing player container
        var oldContainer = document.getElementById('video-player-container');
        if (oldContainer) {
            oldContainer.parentNode.removeChild(oldContainer);
        }

        // create new container div that will span full grid row
        var container = document.createElement('div');
        container.id = 'video-player-container';
        container.className = 'player-container';
        container.style.position = 'relative'; // so the close button can be positioned absolutely

        // create close button
        var closeButton = document.createElement('button');
        closeButton.textContent = '×';
        closeButton.className = 'close-button';
        
        // remove container on click
        closeButton.onclick = function() {
          container.remove();
        };
        container.appendChild(closeButton);

        // create video element
        var video = document.createElement('video');
        video.controls = true;
        video.preload = 'metadata';

        // create source element
        var source = document.createElement('source');
        source.src = videoPath;
        source.type = 'video/mp4';
        video.appendChild(source);

        // todo : this is not working

        // derive subtitle file path from video source
        // var subtitlePath = videoPath.replace(/\.[^/.]+$/, ".srt");
        // var track = document.createElement('track');
        // track.kind = 'subtitles';
        // track.label = 'English';
        // track.srclang = 'en';
        // track.src = subtitlePath;
        // track.default = true;
        // video.appendChild(track);

        // append video element to container
        container.appendChild(video);
        
        // insert container after clicked item
        clickedElem.insertAdjacentElement('afterend', container);

        // smooth scroll into view
        container.scrollIntoView({ behavior: 'smooth' });
        video.play().catch(function(error) {
            console.log("Autoplay failed:", error);
        });
    }
</script>

</body>
</html>
EOF

echo "Localflix : $index created"
