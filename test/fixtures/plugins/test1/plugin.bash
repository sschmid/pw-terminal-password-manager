pw::prepare_keychain()   { :; }
pw::plugin_init()        {
                           echo "plugin 1 init ${PW_KEYCHAIN}"
                           declare -p PW_KEYCHAIN_ARGS
                         }
pw::plugin_add()         { echo "plugin 1 add ${PW_NAME} ${PW_ACCOUNT} ${PW_URL} ${PW_PASSWORD} ${PW_KEYCHAIN}"; }
pw::plugin_edit()        { echo "plugin 1 edit ${PW_NAME} ${PW_ACCOUNT} ${PW_URL} ${PW_PASSWORD} ${PW_KEYCHAIN}"; }
pw::plugin_get()         { echo "plugin 1 get ${PW_NAME} ${PW_ACCOUNT} ${PW_URL} ${PW_KEYCHAIN}"; }
pw::plugin_show()        { echo "plugin 1 show ${PW_NAME} ${PW_ACCOUNT} ${PW_URL} ${PW_KEYCHAIN}"; }
pw::plugin_rm()          { echo "plugin 1 rm ${PW_NAME} ${PW_ACCOUNT} ${PW_URL} ${PW_KEYCHAIN}"; }
pw::plugin_ls()          {
                            echo "plugin 1 ls ${PW_KEYCHAIN}"
                            declare -p PW_KEYCHAIN_ARGS
                         }
pw::plugin_fzf_preview() { :; }
pw::plugin_open()        { echo "plugin 1 open ${PW_KEYCHAIN}"; }
pw::plugin_lock()        { echo "plugin 1 lock ${PW_KEYCHAIN}"; }
pw::plugin_unlock()      { echo "plugin 1 unlock ${PW_KEYCHAIN}"; }
