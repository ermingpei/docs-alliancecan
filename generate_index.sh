#!/bin/bash

# Base URL for your GitHub Pages site
BASE_URL="https://ermingpei.github.io/docs-alliancecan"

# Output file
OUTPUT_FILE="index.html"

# Start the HTML file
cat <<EOF > "$OUTPUT_FILE"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>docs-alliancecan</title>
  <meta name="description" content="Converted MediaWiki pages into Markdown files for Alliance Canada documentation.">
  <meta name="robots" content="index, follow">
  <style>
    body { font-family: Arial, sans-serif; margin: 2em; }
    h1 { color: #333; }
    ul { list-style-type: none; padding: 0; }
    li { margin: 0.5em 0; }
    a { text-decoration: none; color: #0366d6; }
    a:hover { text-decoration: underline; }
  </style>
</head>
<body>
  <h1>docs-alliancecan</h1>
  <p>Converted MediaWiki pages into Markdown files for Alliance Canada documentation.</p>
  <h2>Available Documents</h2>
  <ul>
EOF

# Function to URL-encode file paths
url_encode() {
  local input="$1"
  # Use Python for URL encoding
  python3 -c "import urllib.parse; print(urllib.parse.quote('''$input'''))"
}

# Find all files and append them as list items in index.html
find . -type f | while read -r filepath; do
  # Remove the leading './' from the filepath
  relative_path="${filepath#./}"
  # URL-encode the relative path
  url_path=$(url_encode "$relative_path")
  echo "    <li><a href=\"$BASE_URL/$url_path\">$relative_path</a></li>" >> "$OUTPUT_FILE"
done

# Close the HTML tags
cat <<EOF >> "$OUTPUT_FILE"
  </ul>
</body>
</html>
EOF

echo "index.html has been generated successfully."
