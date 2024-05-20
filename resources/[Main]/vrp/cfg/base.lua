local cfg = {}

cfg.save_interval = 15 -- seconds
cfg.whitelist = false -- enable/disable whitelist

cfg.lang = "da"
cfg.debug = false

cfg.webhooks = {
    ['all'] = '',
    ['admin'] = '',
    ['whitelist'] = '',
    ['user-group'] = '',
    ['seize'] = '',
    ['kick'] = '',
    ['ban'] = '',
    ['unban'] = '',
    ['money'] = '',
    ['item-spawn'] = '',
}

return cfg