# Intentionally empty. Shadows brew's vendor_conf.d/mise-activate.fish (fish sources
# only the first conf.d file of a given name), which activates mise before
# config.fish puts /opt/homebrew/bin on PATH, leaving brew's tools ahead of mise's.
# config.fish activates mise itself, after brew.
