#!/usr/bin/env bash
# D1 : echoue si des fichiers generes ont change (ou apparu) apres regeneration en CI.
#
# Usage : check-generated-drift.sh [--optional] "<libelle>" <chemin> [<chemin>...]
#   Les chemins sont relatifs a la racine du depot ; le script s'y place lui-meme.
#   Detecte les fichiers modifies, supprimes ET non suivis (git diff --exit-code ne voit pas ces derniers).
#   --optional : si AUCUN des chemins n'existe ni n'est suivi par git, avertit et sort en succes
#                (contrat OpenAPI avant B6, client genere avant W3/M4).
set -euo pipefail

optional=0
if [[ "${1:-}" == "--optional" ]]; then
  optional=1
  shift
fi

if [[ $# -lt 2 ]]; then
  echo "Usage : $0 [--optional] \"<libelle>\" <chemin> [<chemin>...]" >&2
  exit 2
fi

label="$1"
shift

cd "$(git rev-parse --show-toplevel)"

present=0
for path in "$@"; do
  if [[ -e "$path" || -n "$(git ls-files -- "$path")" ]]; then
    present=1
  fi
done

if [[ "$present" -eq 0 ]]; then
  if [[ "$optional" -eq 1 ]]; then
    echo "##vso[task.logissue type=warning]${label} : controle ignore (aucun de ces chemins n'existe encore) : $*"
    echo "${label} : controle ignore, chemins absents : $*"
    exit 0
  fi
  echo "##vso[task.logissue type=error]${label} : chemins introuvables : $*"
  exit 1
fi

changes="$(git status --porcelain --untracked-files=all -- "$@")"
if [[ -n "$changes" ]]; then
  echo "##vso[task.logissue type=error]${label} : fichiers generes differents de ceux versionnes."
  echo "${label} : le depot n'est pas a jour apres regeneration. Regenerer en local et commiter :"
  echo "$changes"
  echo
  git --no-pager diff --stat -- "$@" || true
  exit 1
fi

echo "${label} : aucun ecart."
