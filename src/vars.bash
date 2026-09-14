#!/usr/bin/env bash
# shellcheck disable=2034

declare -gr PW_HOME="${PW_HOME:-.}"
declare -gr PW_CONFIG_HOME="${XDG_CONFIG_HOME:-"${HOME}/.config"}/pw"
declare -gr PW_CONFIG_FILE="${PW_CONFIG_HOME}/pw.conf"

# shellcheck disable=2174
mkdir -m 700 -p "${PW_CONFIG_HOME}"

PATH="${PW_HOME}/src:${PATH}"
