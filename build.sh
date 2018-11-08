#!/usr/bin/env bash
BI="$PWD/scripts/installs.sh"

echo '#!/usr/bin/env bash'>"$BI"

for file in $PWD/installs/*
do
  if test -f "$file"; then
    cat <"$file" | sed -E 's|#!/usr/bin/env bash||'>>"$BI"
  fi
done

chmod +x "$BI"

INIT_DESKTOP="$PWD/scripts/initialize-desktop.sh"

echo '#!/usr/bin/env bash'>"$INIT_DESKTOP"
cat <"./profile.sh"                | sed -E 's|#!/usr/bin/env bash||'>>"$INIT_DESKTOP"
cat <"./scripts/installs.sh"       | sed -E 's|#!/usr/bin/env bash||'>>"$INIT_DESKTOP"
cat <"./src/personalise.sh"        | sed -E 's|#!/usr/bin/env bash||'>>"$INIT_DESKTOP"
cat <"./src/develop-env.sh"        | sed -E 's|#!/usr/bin/env bash||'>>"$INIT_DESKTOP"
cat <"./src/initialize-desktop.sh" | sed -E 's|#!/usr/bin/env bash||'>>"$INIT_DESKTOP"


INIT_SERVER="$PWD/scripts/initialize-server.sh"

echo '#!/usr/bin/env bash'>"$INIT_SERVER"
cat <"./profile.sh"               | sed -E 's|#!/usr/bin/env bash||'>>"$INIT_SERVER"
cat <"./scripts/installs.sh"      | sed -E 's|#!/usr/bin/env bash||'>>"$INIT_SERVER"
cat <"./src/initialize-server.sh" | sed -E 's|#!/usr/bin/env bash||'>>"$INIT_SERVER"
