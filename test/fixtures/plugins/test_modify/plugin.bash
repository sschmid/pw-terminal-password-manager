pw::prepare_keychain()   { :; }
pw::plugin_init()        { echo "plugin modify init ${PW_KEYCHAIN}"; }
pw::plugin_add()         { echo "plugin modify add ${PW_NAME} ${PW_ACCOUNT} ${PW_PASSWORD} ${PW_KEYCHAIN}"; }
pw::plugin_edit()        { echo "plugin modify edit ${PW_NAME} ${PW_ACCOUNT} ${PW_PASSWORD} ${PW_KEYCHAIN}"; }
pw::plugin_get()         { echo "plugin modify get ${PW_NAME} ${PW_ACCOUNT} ${PW_KEYCHAIN}"; }
pw::plugin_rm()          { echo "plugin modify rm ${PW_NAME} ${PW_ACCOUNT} ${PW_KEYCHAIN}"; }
pw::plugin_ls()          { echo "plugin modify ls ${PW_KEYCHAIN}"; }
pw::plugin_fzf_preview() { :; }
pw::plugin_open()        { echo "plugin modify open ${PW_KEYCHAIN}"; }
pw::plugin_lock()        { echo "plugin modify lock ${PW_KEYCHAIN}"; }
pw::plugin_unlock()      { echo "plugin modify unlock ${PW_KEYCHAIN}"; }
