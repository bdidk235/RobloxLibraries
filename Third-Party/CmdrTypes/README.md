# Cmdr Types
Get [Cmdr](https://github.com/evaera/Cmdr) and the external types, then use them like this:
## Cmdr (Server):
```lua
local CmdrTypes = require(path.to.CmdrTypes)
local Cmdr = require(path.to.Cmdr) :: CmdrTypes.Cmdr
```
## Cmdr (Client):
```lua
local CmdrTypes = require(path.to.CmdrTypes)
local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient")) :: CmdrTypes.CmdrClient
```
