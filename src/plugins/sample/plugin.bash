# This a sample plugin that you can copy paste as a template for your own plugins.
# This sample plugin is ignored by pw and will not be loaded.
# Relevanted places are marked with TOBEIMPLEMENTED.
# This sample resambles the behavior of the default plugin.
# Change the behavior to match your needs.

PW_ENTRY=""
declare -ig PW_FZF=0

_log() { echo "[Sample Plugin] $*"; }

# TOBEIMPLEMENTED
pw::init() { _log "Creating new keychain '${PW_KEYCHAIN}'"; }

# TOBEIMPLEMENTED
pw::open() { _log "Opening keychain '${PW_KEYCHAIN}'"; }

# TOBEIMPLEMENTED
pw::lock() { _log "Locking keychain '${PW_KEYCHAIN}'"; }

# TOBEIMPLEMENTED
pw::unlock() { _log "Unlocking keychain '${PW_KEYCHAIN}'"; }

pw::add() {
  _addOrEdit 0 "$@"
}

pw::edit() {
  pw::select_entry_with_prompt edit "$@"
  _addOrEdit 1 "${PW_ENTRY}"
}

_addOrEdit() {
  local -i edit=$1; shift
  local entry account
  entry="$1" account="${2:-}"
  pw::prompt_password "${entry}"

  if ((edit))
  # TOBEIMPLEMENTED
  then _log "Editing entry '${entry}' with account '${account}' in keychain '${PW_KEYCHAIN}'"
  # TOBEIMPLEMENTED
  else _log "Adding entry '${entry}' with account '${account}' to keychain '${PW_KEYCHAIN}'"
  fi
}

pw::get() {
  local -i print=$1; shift
  if ((print))
  then pw::select_entry_with_prompt print "$@"
  else pw::select_entry_with_prompt copy "$@"
  fi
  local password

  # TOBEIMPLEMENTED
  # shellcheck disable=SC2116
  password="$(echo "sample-password")"

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
    read -rp "Do you really want to remove ${PW_ENTRY} from ${PW_KEYCHAIN}? (y / n): "
    [[ "${REPLY}" == "y" ]] || remove=0
  fi

  # TOBEIMPLEMENTED
  ((!remove)) || _log "Removing entry '${PW_ENTRY}' from keychain '${PW_KEYCHAIN}'"
}

pw::list() {
  # TOBEIMPLEMENTED
  echo -e "sample entry1\nsample entry2\nsample entry3"
}

pw::select_entry_with_prompt() {
  local fzf_prompt="$1"; shift
  if (($#)); then
    PW_ENTRY="$1"
    PW_FZF=0
  else

    # TOBEIMPLEMENTED
    PW_ENTRY="$(pw::list | fzf --prompt="${fzf_prompt}> " --layout=reverse --info=hidden)"

    [[ -n "${PW_ENTRY}" ]] || exit 1
    # shellcheck disable=SC2034
    PW_FZF=1
  fi
}
