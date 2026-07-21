function fish_user_key_bindings
    fish_default_key_bindings -M insert
    fish_vi_key_bindings --no-erase insert
    set --no-event -g fish_key_bindings fish_vi_key_bindings
end
