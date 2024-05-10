pw::init() { security create-keychain -P "${PW_KEYCHAIN}"; }
pw::open() { open -a "Keychain Access" ~/Library/Keychains/"${PW_KEYCHAIN}-db"; }
pw::lock() { security lock-keychain "${PW_KEYCHAIN}"; }
pw::unlock() { security unlock-keychain "${PW_KEYCHAIN}"; }

pw::add() {
  _addOrEdit 0 "$@"
}

pw::edit() {
  pw::select_entry_with_prompt edit "$@"
  _addOrEdit 1 "${PW_NAME}" "${PW_ACCOUNT}"
}

_addOrEdit() {
  local -i edit=$1; shift
  ((edit)) || unset edit
  PW_NAME="$1" PW_ACCOUNT="${2:-}"
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
  security add-generic-password ${edit:+-U} -a "${PW_ACCOUNT}" -s "${PW_NAME}" -w "${password}" "${PW_KEYCHAIN}"
}

pw::get() {
  local -i print=$1; shift
  if ((print))
  then pw::select_entry_with_prompt print "$@"
  else pw::select_entry_with_prompt copy "$@"
  fi
  local password
  password="$(security find-generic-password ${PW_ACCOUNT:+-a "${PW_ACCOUNT}"} -s "${PW_NAME}" -w "${PW_KEYCHAIN}")"
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
    read -rp "Do you really want to remove ${PW_NAME:+"'${PW_NAME}' "}${PW_ACCOUNT:+"'${PW_ACCOUNT}' "}from ${PW_KEYCHAIN}? (y / n): "
    [[ "${REPLY}" == "y" ]] || remove=0
  fi
  ((!remove)) || security delete-generic-password -a "${PW_ACCOUNT}" -s "${PW_NAME}" "${PW_KEYCHAIN}" > /dev/null
}

pw::list() {
  local dump
  local -a names accounts name account
  dump="$(security dump-keychain "${PW_KEYCHAIN}")"
  mapfile -t names < <(echo "${dump}" | grep "svce" | awk -F= '{print $2}' | tr -d \")
  mapfile -t accounts < <(echo "${dump}" | grep "acct" | awk -F= '{print $2}' | tr -d \")
  for ((i = 0; i < ${#names[@]}; i++)); do
    name="${names[i]}"
    account="${accounts[i]}"
    [[ "${name}" == "<NULL>" ]] && name=""
    [[ "${account}" == "<NULL>" ]] && account=""
    printf "%-32s\t%s\n" "${name}" "${account}"
  done | sort
}
