pw::prepare_keychain()   { :; }
pw::plugin_init()        { echo "plugin 2 init ${PW_KEYCHAIN}"; }
pw::plugin_add()         { echo "plugin 2 add ${PW_NAME} ${PW_ACCOUNT} ${PW_URL} ${PW_PASSWORD} ${PW_KEYCHAIN}"; }
pw::plugin_edit()        { echo "plugin 2 edit ${PW_NAME} ${PW_ACCOUNT} ${PW_URL} ${PW_PASSWORD} ${PW_KEYCHAIN}"; }
pw::plugin_get()         { echo "plugin 2 get ${PW_NAME} ${PW_ACCOUNT} ${PW_URL} ${PW_KEYCHAIN}"; }
pw::plugin_show()        { echo "plugin 2 show ${PW_NAME} ${PW_ACCOUNT} ${PW_URL} ${PW_KEYCHAIN}"; }
pw::plugin_rm()          { echo "plugin 2 rm ${PW_NAME} ${PW_ACCOUNT} ${PW_URL} ${PW_KEYCHAIN}"; }
pw::plugin_ls()          {
                            echo -e "name 1\taccount 1\turl 1\tname 1\taccount 1\turl 1"
                            echo -e "name 2\taccount 2\turl 2\tname 2\taccount 2\turl 2"
                            echo -e "name 3\taccount 3\turl 3\tname 3\taccount 3\turl 3"
                         }
pw::plugin_fzf_preview() { :; }
pw::plugin_open()        { echo "plugin 2 open ${PW_KEYCHAIN}"; }
pw::plugin_lock()        { echo "plugin 2 lock ${PW_KEYCHAIN}"; }
pw::plugin_unlock()      { echo "plugin 2 unlock ${PW_KEYCHAIN}"; }
