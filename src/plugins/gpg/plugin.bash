if ! command -v gpg > /dev/null; then
  cat << EOF >&2
command not found: gpg
Please make sure that GnuPG is installed and gpg is in your PATH.
EOF
  exit 1
fi

_gpg() {
  if [[ -v PW_GPG_PASSWORD ]]
  then gpg --quiet --batch --pinentry-mode loopback --passphrase "${PW_GPG_PASSWORD}" "$@"
  else gpg --quiet "$@"
  fi
}

_mk_owner_dir() {
  # shellcheck disable=SC2174
  mkdir -m 700 -p "$1"
}

pw::prepare_keychain() {
  : # this plugin does not require any preparation
}

pw::plugin_init() {
  if [[ -d "${PW_KEYCHAIN}" ]]; then
    echo "${PW_KEYCHAIN} already exists." >&2
    exit 1
  fi

  _mk_owner_dir "${PW_KEYCHAIN}"
}

pw::plugin_add() {
  _mk_owner_dir "${PW_KEYCHAIN}"
  mkdir -p "${PW_KEYCHAIN}/$(dirname "$1")"
  if [[ "${1##*.}" == "asc" ]]
  then _gpg --output "${PW_KEYCHAIN}/$1" --encrypt --armor --default-recipient-self <<< "$3"
  else _gpg --output "${PW_KEYCHAIN}/$1" --encrypt --default-recipient-self <<< "$3"
  fi
}

pw::plugin_edit() {
  _gpg --yes --output "${PW_KEYCHAIN}/$1" --encrypt --default-recipient-self <<< "$3"
}

pw::plugin_get() {
  _gpg --decrypt "${PW_KEYCHAIN}/$1"
}

pw::plugin_rm() {
  rm "${PW_KEYCHAIN}/$1"
}

pw::plugin_ls() {
  local format="${1:-default}" list
  pushd "${PW_KEYCHAIN}" > /dev/null || exit 1
    list="$(find . -type f ! -name .DS_Store | LC_ALL=C sort)"
  popd > /dev/null || exit 1

  case "${format}" in
    fzf) echo "${list}" | awk '{print $0 "\t\t" $0}' ;;
    *) echo "${list}" ;;
  esac
}

pw::plugin_fzf_preview() {
  : # this plugin does not implement fzf preview
}

pw::plugin_open() {
  open "${PW_KEYCHAIN}"
}

pw::plugin_lock() {
  killall gpg-agent 2> /dev/null || true
}

pw::plugin_unlock() {
  if [[ -p /dev/stdin ]]; then
    IFS= read -r PW_GPG_PASSWORD
  fi
  echo \
    | _gpg --encrypt --default-recipient-self \
    | _gpg --decrypt > /dev/null
}
