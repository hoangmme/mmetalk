require 'json'
bots = AgentBot.all.as_json
puts JSON.pretty_generate(bots)
