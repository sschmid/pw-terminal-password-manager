: "${PW_KEEPASSXC:="/Applications/KeePassXC.app/Contents/MacOS/keepassxc-cli"}"

_get_password() {
  if [[ ! -v PW_KEEPASSXC_PASSWORD ]]; then
    read -rsp "Enter password for ${PW_KEYCHAIN}: " PW_KEEPASSXC_PASSWORD </dev/tty
    echo
  fi
}

PW_NAME=""
declare -ig PW_FZF=0

pw::init() { "${PW_KEEPASSXC}" db-create -p "${PW_KEYCHAIN}"; }
pw::open() { open -a "KeePassXC" "${PW_KEYCHAIN}"; }
pw::lock() { echo "not available for keepassxc-cli"; }
pw::unlock() {
  _get_password
  "${PW_KEEPASSXC}" open -q "${PW_KEYCHAIN}" <<< "${PW_KEEPASSXC_PASSWORD}"
}

pw::add() {
  _get_password
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
  echo -ne "${PW_KEEPASSXC_PASSWORD}\n${password}\n" | "${PW_KEEPASSXC}" add -qp "${PW_KEYCHAIN}" -u "${account}" "${PW_NAME}"
}

pw::edit() {
  _get_password
  PW_NAME="$1"
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
  echo -ne "${PW_KEEPASSXC_PASSWORD}\n${password}\n" | "${PW_KEEPASSXC}" edit -qp "${PW_KEYCHAIN}" "${PW_NAME}"
}

pw::get() {
  _get_password
  local -i print=$1; shift
  if ((print))
  then pw::select_entry_with_prompt print "$@"
  else pw::select_entry_with_prompt copy "$@"
  fi
  local password
  password="$("${PW_KEEPASSXC}" show -qsa Password "${PW_KEYCHAIN}" "${PW_NAME}" <<< "${PW_KEEPASSXC_PASSWORD}")"
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
  _get_password
  local -i remove=1
  pw::select_entry_with_prompt remove "$@"
  if ((PW_FZF)); then
    read -rp "Do you really want to remove ${PW_NAME} from ${PW_KEYCHAIN}? (y / n): "
    [[ "${REPLY}" == "y" ]] || remove=0
  fi
  ((!remove)) || "${PW_KEEPASSXC}" rm -q "${PW_KEYCHAIN}" "${PW_NAME}" <<< "${PW_KEEPASSXC_PASSWORD}"
}

pw::list() {
  _get_password
  local list
  list="$("${PW_KEEPASSXC}" ls -qfR "${PW_KEYCHAIN}" <<< "${PW_KEEPASSXC_PASSWORD}" | grep -v '/$')"
  [[ "${list}" == "[empty]" ]] || echo "${list}"
}

pw::select_entry_with_prompt() {
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
