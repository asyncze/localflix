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

# Loop through all .jpg and .png files and add them to the gallery
# for file in *.jpg *.png; do
printf "%s\n" *.jpg *.png | sort -V | while IFS= read -r file; do
    if [ -f "$file" ]; then
        cat << EOF >> "$output"
    <div class="gallery-item">
      <img src="$file" alt="$file">
      <div class="overlay">
         <div class="text">${file%.*}</div>
      </div>
    </div>
EOF
    fi
done

# Close the HTML tags.
cat << 'EOF' >> "$output"
</div>
</body>
</html>
EOF

echo "Localflix created as $output"
