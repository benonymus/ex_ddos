# ExDdos

Ddos capabale utility for experimenting and learning purposes.
For max performance this would not be ran in iex, rather in compiled form.

I made this version using Mint directly in each genserver. I also made a version with Req and Finch but all these (unsurprisingly) hit the same limitation.

emfile error or [label: {:erl_prim_loader, :file_error}, report: ~c"File operation error: emfile. Target: sys.beam. Function: get_file. Process: code_server."]
Meaning the system (local device) cannot make that many connections as I want.
HttPosion and Hackney was more successful/forgiving here I was able to run more bots on that version.
I also removed the Cachex command center here, no need for it here.


## How to run

- `iex -S mix`
- `alias ExDdos.Utils`
- `Utils.start_num_of_bots count here`
- `Utils.set_target "url here"`
- alternatively you can use a proxy list called "proxies.csv" with `Utils.start_bots_with_proxy` that starts as many bots as the list has entries
- `Utils.start_attack` will make the bots send requests
- `Utils.stop_attack` will pause the attack, that can be restarted
