#!/bin/sh

cat - >index.html <<EOF
<!doctype html>
  <html>
    <body>
EOF

for file in `find dist django_bookmarks.egg-info -type f`; do
    printf '      <a href="%s">%s</a>\n' $file $file >> index.html
done

cat - >>index.html <<EOF
  </body>
</html>
EOF
