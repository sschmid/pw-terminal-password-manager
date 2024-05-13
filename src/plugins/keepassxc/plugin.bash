: "${PW_KEEPASSXC:="/Applications/KeePassXC.app/Contents/MacOS/keepassxc-cli"}"

_set_password() {
  if [[ ! -v PW_KEEPASSXC_PASSWORD ]]; then
    read -rsp "Enter password for ${PW_KEYCHAIN}: " PW_KEEPASSXC_PASSWORD </dev/tty
    echo
  fi
}

_keepassxc-cli() {
  "${PW_KEEPASSXC}" "$@"
}

_keepassxc-cli_with_db_password() {
  _set_password
  _keepassxc-cli "$@" <<< "${PW_KEEPASSXC_PASSWORD}"
}

_keepassxc-cli_with_db_password_and_entry_password() {
  _set_password
  local password="$1"; shift
  _keepassxc-cli "$@" << EOF
${PW_KEEPASSXC_PASSWORD}
${password}
EOF
}

PW_NAME=""
declare -ig PW_FZF=0

pw::init() { _keepassxc-cli db-create -p "${PW_KEYCHAIN}"; }
pw::open() { open -a "KeePassXC" "${PW_KEYCHAIN}"; }
pw::lock() { echo "not available for keepassxc-cli"; }
pw::unlock() { _keepassxc-cli open "${PW_KEYCHAIN}"; }

pw::add() {
  _addOrEdit 0 "$@"
}

pw::edit() {
  pw::select_entry_with_prompt edit "$@"
  _addOrEdit 1 "${PW_NAME}"
}

_addOrEdit() {
  local -i edit=$1; shift
  PW_NAME="$1" account="${2:-}"
  local password retype
  read -rsp "Enter password for ${PW_NAME}: " password; echo
  if [[ -n "${password}" ]]; then
    read -rsp "Retype password for ${PW_NAME}: " retype; echo
    if [[ "${retype}" != "${password}" ]]; then
      echo "Error: the entered passwords do not match."
      exit 1
    fi
  else
    password="$(pw::gen 1)"
  fi

  if ((edit))
  then _keepassxc-cli_with_db_password_and_entry_password "${password}" edit -qp "${PW_KEYCHAIN}" "${PW_NAME}"
  else _keepassxc-cli_with_db_password_and_entry_password "${password}" add -qp "${PW_KEYCHAIN}" -u "${account}" "${PW_NAME}"
  fi
}

pw::get() {
  local -i print=$1; shift
  if ((print))
  then pw::select_entry_with_prompt print "$@"
  else pw::select_entry_with_prompt copy "$@"
  fi
  local password
  password="$(_keepassxc-cli_with_db_password show -qsa Password "${PW_KEYCHAIN}" "${PW_NAME}")"
  if ((print)); then
    echo "${password}"
  else
    local p
    p="pw-$(id -u)"
    pkill -f "^$p" 2> /dev/null && sleep 0.5
    echo -n "${password}" | pbcopy
    (
      ( exec -a "${p}" sleep "${PW_CLIP_TIME}" )
      [[ "$(pbpaste)" == "${password}" ]] && echo -n | pbcopy
    ) > /dev/null 2>&1 & disown
  fi
}

pw::rm() {
  local -i remove=1
  pw::select_entry_with_prompt remove "$@"
  if ((PW_FZF)); then
    read -rp "Do you really want to remove ${PW_NAME} from ${PW_KEYCHAIN}? (y / n): "
    [[ "${REPLY}" == "y" ]] || remove=0
  fi
  ((!remove)) || _keepassxc-cli_with_db_password rm -q "${PW_KEYCHAIN}" "${PW_NAME}"
}

pw::list() {
  local list
  list="$(_keepassxc-cli_with_db_password ls -qfR "${PW_KEYCHAIN}" | grep -v '/$')"
  [[ "${list}" == "[empty]" ]] || echo "${list}"
}

pw::select_entry_with_prompt() {
  _set_password
  local fzf_prompt="$1"; shift
  if (($#)); then
    PW_NAME="$1"
    PW_FZF=0
  else
    PW_NAME="$(pw::list | fzf --prompt="${fzf_prompt}> " --layout=reverse --info=hidden \
              --preview="\"${PW_KEEPASSXC}\" show -q \"${PW_KEYCHAIN}\" {} <<< \"${PW_KEEPASSXC_PASSWORD}\"")"
    [[ -n "${PW_NAME}" ]] || exit 1
    # shellcheck disable=SC2034
    PW_FZF=1
  fi
}