#!/bin/zsh
set -e
cd "${0:A:h}"
chair_gh="$(command -v gh || true)"
if [[ -z "$chair_gh" && -x "$HOME/.local/bin/gh" ]]; then
  chair_gh="$HOME/.local/bin/gh"
fi
if [[ -z "$chair_gh" ]]; then
  print "Install GitHub CLI from https://cli.github.com/ and run this again."
  read "?Press Return to close. "
  exit 1
fi
if ! "$chair_gh" auth status >/dev/null 2>&1; then
  "$chair_gh" auth login --hostname github.com --git-protocol https --web
fi
if [[ ! -d .git ]]; then
  git init -b main
  git add .
  git -c user.name='Aarush Singh Minhas' -c user.email='249406974+aarushsinghm-netizen@users.noreply.github.com' commit -m 'Build chair game with credited assets'
fi
if git remote get-url origin >/dev/null 2>&1; then
  git push -u origin main
else
  "$chair_gh" repo create chairman-of-the-bounce --public --source=. --remote=origin --push
fi
"$chair_gh" repo view --web
print "Published. Asset credits and license files are included."
read "?Press Return to close. "
