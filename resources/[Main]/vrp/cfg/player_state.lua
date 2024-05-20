local cfg = {}

cfg.spawn_enabled = true 
cfg.spawn_position = {99.72, -1712.55, 30.11}
cfg.spawn_radius = 0.8

cfg.default_customization = {
	model = "mp_m_freemode_01" 
}

-- init default ped parts
for i=0,19 do
	cfg.default_customization[i] = {0,0}
end

cfg.clear_phone_directory_on_death = false
cfg.lose_aptitudes_on_death = true
cfg.lose_inventory_on_death = true


return cfg
