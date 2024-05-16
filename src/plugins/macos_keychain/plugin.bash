PW_NAME=""
PW_ACCOUNT=""
declare -ig PW_FZF=0

pw::init() { security create-keychain -P "${PW_KEYCHAIN}"; }
pw::open() { open -a "Keychain Access" ~/Library/Keychains/"${PW_KEYCHAIN}"; }
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
  local name account
  name="$1" account="${2:-}"
  pw::prompt_password "${name}"

  if ((edit))
  then security add-generic-password -U -a "${account}" -s "${name}" -w "${PW_PASSWORD}" "${PW_KEYCHAIN}"
  else security add-generic-password -a "${account}" -s "${name}" -w "${PW_PASSWORD}" "${PW_KEYCHAIN}"
  fi
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
    pw::clip_and_forget "${password}"
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
    printf "%-40s\t%s\n" "${name}" "${account}"
  done | sort
}

pw::select_entry_with_prompt() {
  local fzf_prompt="$1"; shift
  if (($#)); then
    PW_NAME="$1"
    PW_ACCOUNT="${2:-}"
    PW_FZF=0
  else
    local name account
    while IFS=$'\t' read -r name account; do
      PW_NAME="$(echo "${name}" | xargs)"
      PW_ACCOUNT="$(echo "${account}" | xargs)"
    done < <(pw::list | fzf --prompt="${fzf_prompt}> " --layout=reverse --info=hidden)
    [[ -n "${PW_NAME}" && -n "${PW_ACCOUNT}" ]] || exit 1
    # shellcheck disable=SC2034
    PW_FZF=1
  fi
}
