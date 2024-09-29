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

_gpg_encrypt() {
  local -a options=()
  [[ -v PW_KEYCHAIN_ARGS["key"] ]] && options+=("--default-key" "${PW_KEYCHAIN_ARGS["key"]}")
  _gpg --encrypt "${options[@]}" --default-recipient-self "$@"
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
  mkdir -p "${PW_KEYCHAIN}/$(dirname "${PW_NAME}")"

  local content="${PW_PASSWORD}
${PW_ACCOUNT}
${PW_URL}
${PW_NOTES}"

  if [[ "${PW_NAME##*.}" == "asc" ]]
  then _gpg_encrypt --output "${PW_KEYCHAIN}/${PW_NAME}" --armor <<< "${content}"
  else _gpg_encrypt --output "${PW_KEYCHAIN}/${PW_NAME}" <<< "${content}"
  fi
}

pw::plugin_edit() {
  local content
  content="${PW_PASSWORD}
$(_gpg --decrypt "${PW_KEYCHAIN}/${PW_NAME}" | sed -n 2,\$p)"
  _gpg_encrypt --output "${PW_KEYCHAIN}/${PW_NAME}" --yes <<< "${content}"
}

pw::plugin_get() {
  _gpg --decrypt "${PW_KEYCHAIN}/${PW_NAME}" | sed -n 1p
}

pw::plugin_rm() {
  rm "${PW_KEYCHAIN}/${PW_NAME}"
}

pw::plugin_ls() {
  local format="${1:-default}" list
  pushd "${PW_KEYCHAIN}" > /dev/null || exit 1
    list="$(find . -type f ! -name .DS_Store | LC_ALL=C sort)"
  popd > /dev/null || exit 1

  case "${format}" in
    fzf) echo "${list}" | awk '{print $0 "\t\t\t" $0}' ;;
    *) echo "${list}" ;;
  esac
}

pw::plugin_fzf_preview() {
  if echo | _gpg_encrypt | _gpg --decrypt &> /dev/null; then
    local gpg_cmd awk_cmd
    gpg_cmd="gpg --quiet --decrypt \"${PW_KEYCHAIN}/\"{4}"

    # KCOV_EXCL_START
    awk_cmd=$(cat <<'EOF'
awk '
  NR==2 { account=$0 }
  NR==3 { url=$0 }
  NR>=4 { notes=$0 }
  END { printf "Account: %s\nURL: %s\nNotes: %s", account, url, notes }'
EOF
    )
    # KCOV_EXCL_STOP
    echo "${gpg_cmd} | ${awk_cmd}"
  fi
}

pw::plugin_open() {
  open "${PW_KEYCHAIN}"
}

pw::plugin_lock() {
  killall gpg-agent 2> /dev/null || true
}

pw::plugin_unlock() {
  [[ -p /dev/stdin ]] && IFS= read -r PW_GPG_PASSWORD
  echo | _gpg_encrypt | _gpg --decrypt > /dev/null
}
