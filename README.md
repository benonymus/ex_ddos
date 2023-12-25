# ExDdos

Ddos capabale utility for experimenting and learning purposes.
For max performance this would not be ran in iex, rather in compiled form.
There is room to tweak the connection pool opts depending on the number of desired bots.

I thought it is an interesting idea to have a separate control panel if you will, that is what Cachex is for. This way the bots can keep running and be changed on the fly rather than stoppped, reconfigured, and restarted or sending messages to all the bots with commands.

For an alternative versio check the mint_version branch.

## How to run

- `iex -S mix`
- `alias ExDdos.Utils`
- `Utils.start_num_of_bots count here`
- `Utils.set_target "url here"`
- alternatively you can use a proxy list called "proxies.csv" with `Utils.start_bots_with_proxy` that starts as many bots as the list has entries
- `Utils.start_attack` will make the bots send requests
- `Utils.stop_attack` will pause the attack, that can be restarted
