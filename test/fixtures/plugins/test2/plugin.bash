pw::prepare_keychain()   { :; }
pw::plugin_init()        { echo "plugin 2 init ${PW_KEYCHAIN}"; }
pw::plugin_add()         { echo "plugin 2 add $1 $2 $3 ${PW_KEYCHAIN}"; }
pw::plugin_edit()        { echo "plugin 2 edit $1 $2 $3 ${PW_KEYCHAIN}"; }
pw::plugin_get()         { echo "plugin 2 get $1 $2 ${PW_KEYCHAIN}"; }
pw::plugin_rm()          { echo "plugin 2 rm $1 $2 ${PW_KEYCHAIN}"; }
pw::plugin_ls()          {
                            echo "plugin 2 ls ${PW_KEYCHAIN}"
                            declare -p PW_KEYCHAIN_ARGS
                         }
pw::plugin_fzf_preview() { :; }
pw::plugin_open()        { echo "plugin 2 open ${PW_KEYCHAIN}"; }
pw::plugin_lock()        { echo "plugin 2 lock ${PW_KEYCHAIN}"; }
pw::plugin_unlock()      { echo "plugin 2 unlock ${PW_KEYCHAIN}"; }
