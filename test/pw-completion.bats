setup() {
  load 'test-helper.bash'
}

assert_comp() {
  _comp "$@"
  if(($#)); then
    assert_equal "${actual[*]}" "${expected[*]}"
  else
    refute_output
  fi
}

# shellcheck disable=SC2207,SC2068,SC2206
_comp() {
  export COMP_LINE="$1"
  export COMP_POINT="${#COMP_LINE}"
  # shellcheck disable=SC1090,SC1091
  source "${PROJECT_ROOT}/src/pw"
  run pw::main
  actual=("${output}")
  actual=($(for i in ${actual[@]}; do echo "$i"; done | sort))
  if [[ -v 2 ]]; then
    expected=($2)
    expected=($(for i in ${expected[@]}; do echo "$i"; done | sort))
  fi
}

@test "completes pw with options and commands" {
  local expected=(-p -a -k init open lock unlock add edit rm ls update help)
  assert_comp "pw " "${expected[*]}"
}

@test "completes pw with multiple options and removes already used ones" {
  local expected=(-a -k init open lock unlock add edit rm ls update help)
  assert_comp "pw -p " "${expected[*]}"

  local expected=(-k init open lock unlock add edit rm ls update help)
  assert_comp "pw -p -a " "${expected[*]}"

  local expected=(init open lock unlock add edit rm ls update help)
  assert_comp "pw -p -a -k " "${expected[*]}"
}
