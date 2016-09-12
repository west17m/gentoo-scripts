#!/bin/bash

# this script will create a startup file which will add appropriate
# paths to PATH on startup

A=$(echo "$(dirname "$0")" | sed 's:/core::')
for d in $(find "$A" -not -iwholename "*/.git*" -not -iwholename "$A" -type d)
do
  # check if in path
  [[ ":$PATH:" != *":$d:"* ]] && PATH="$d:${PATH}"
done

START="/etc/profile.d/01-gentoo-scripts.sh"
echo -e '#!/bin/bash\n# do not edit, managed by add-path.sh from gentoo-scripts' > "$START"
echo -e "A=\"$A\"" >> "$START"
echo -e 'for d in $(find "$A" -not -iwholename "*/.git*" -not -iwholename "$A" -type d)' >> "$START"
echo -e 'do\n  # check if in path\n  [[ ":$PATH:" != *":$d:"* ]] && PATH="$d:${PATH}"\ndone\n' >> "$START"
chmod 755 "$START"

mkdir -p "$A/local"

echo "now"
echo "source $START"

exit 0
