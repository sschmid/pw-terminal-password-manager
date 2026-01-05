_setup() {
	load 'test-helper'
	_common_setup
	export PW_KEYCHAIN="${BATS_TEST_TMPDIR}/pw gpg test/"
}

_delete_keychain() {
	rm -rf "${PW_KEYCHAIN}"
}

# sec   ed25519/691ED007F1E410B0 2024-09-12 [C]
#       8F1F7B428DC46AD4AD2E5123691ED007F1E410B0
# uid                 [ unknown] pw_test_1 <pw_test_1@example.com>
# ssb   cv25519/8593E03F5A33D9AC 2024-09-12 [E]

# sec   ed25519/5956BBFD659D6C4C 2024-09-12 [C]
#       2F07F8722CE9FEF50DF247D25956BBFD659D6C4C
# uid                 [ unknown] pw_test_2 <pw_test_2@example.com>
# ssb   cv25519/634419040D678764 2024-09-12 [E]

# password:                     pw_test_password
