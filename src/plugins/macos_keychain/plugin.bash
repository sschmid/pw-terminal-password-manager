PW_ENTRY=""
PW_ACCOUNT=""
declare -ig PW_FZF=0

pw::init() {
  if [[ -p /dev/stdin ]]; then
    IFS= read -r password
    security create-keychain -p "${password}" "${PW_KEYCHAIN}"
  else
    security create-keychain -P "${PW_KEYCHAIN}"
  fi
}

pw::open() {
  if [[ -f "${PW_KEYCHAIN}" ]]; then
    open -a "Keychain Access" "${PW_KEYCHAIN}"
  elif [[ -f "${HOME}/Library/Keychains/${PW_KEYCHAIN}" ]]; then
    open -a "Keychain Access" "${HOME}/Library/Keychains/${PW_KEYCHAIN}"
  fi
}

pw::lock() { security lock-keychain "${PW_KEYCHAIN}"; }
pw::unlock() {
  if [[ -p /dev/stdin ]]; then
    IFS= read -r password
    security unlock-keychain -p "${password}" "${PW_KEYCHAIN}"
  else
    security unlock-keychain "${PW_KEYCHAIN}"
  fi
}

pw::add() {
  _addOrEdit 0 "$@"
}

pw::edit() {
  pw::select_entry_with_prompt edit "$@"
  _addOrEdit 1 "${PW_ENTRY}" "${PW_ACCOUNT}"
}

_addOrEdit() {
  local -i edit=$1; shift
  local entry="$1" account="${2:-}"
  pw::prompt_password "${entry}"
  ((edit)) || unset edit
  security add-generic-password ${edit:+-U} -s "${entry}" -a "${account}" -w "${PW_PASSWORD}" "${PW_KEYCHAIN}"
}

pw::get() {
  local -i print=$1; shift
  if ((print))
  then pw::select_entry_with_prompt print "$@"
  else pw::select_entry_with_prompt copy "$@"
  fi
  local password
  password="$(security find-generic-password ${PW_ENTRY:+-s "${PW_ENTRY}"} ${PW_ACCOUNT:+-a "${PW_ACCOUNT}"} -w "${PW_KEYCHAIN}")"
  if ((print))
  then echo "${password}"
  else pw::clip_and_forget "${password}"
  fi
}

pw::rm() {
  local -i remove=1
  pw::select_entry_with_prompt remove "$@"
  if ((PW_FZF)); then
    read -rp "Do you really want to remove ${PW_ENTRY:+"'${PW_ENTRY}' "}${PW_ACCOUNT:+"'${PW_ACCOUNT}' "}from ${PW_KEYCHAIN}? (y / N): "
    [[ "${REPLY}" == "y" ]] || remove=0
  fi
  ((!remove)) || security delete-generic-password ${PW_ENTRY:+-s "${PW_ENTRY}"} ${PW_ACCOUNT:+-a "${PW_ACCOUNT}"} "${PW_KEYCHAIN}" > /dev/null
}

pw::list() {
  security dump-keychain "${PW_KEYCHAIN}" | awk '
    BEGIN { FS="<blob>="; OFS="\t" }
    /"acct"/ {
      account = ($2 == "<NULL>") ? "" : substr($2, 2, length($2) - 2)
    }
    /"svce"/ {
      name = ($2 == "<NULL>") ? "" : substr($2, 2, length($2) - 2)
      printf "%-40s\t%s\n", name, account
    }' | LC_ALL=C sort
}

pw::select_entry_with_prompt() {
  local fzf_prompt="$1"; shift
  if (($#)); then
    PW_ENTRY="$1" PW_ACCOUNT="${2:-}" PW_FZF=0
  else
    local entry account
    while IFS=$'\t' read -r entry account; do
      PW_ENTRY="$(echo "${entry}" | xargs)"
      PW_ACCOUNT="$(echo "${account}" | xargs)"
    done < <(pw::list | fzf --prompt="${fzf_prompt}> " --layout=reverse --info=hidden)
    [[ -n "${PW_ENTRY}" || -n "${PW_ACCOUNT}" ]] || exit 1
    # shellcheck disable=SC2034
    PW_FZF=1
  fi
}
