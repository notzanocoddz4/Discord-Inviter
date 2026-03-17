# Discord Inviter

A lightweight module that allows you to (optionally) prompt users with a Discord server invite.

## Features

- Prompt user in-game to join your Discord server
- Optional in-game invite prompt UI

## Limitations

- User must be logged into the Discord app
- Discord app always requires a final confirmation

## Usage

### Direct Join

```lua
Inviter:Join("discord.gg/vynixius")
```

Opens the Discord invite directly. User still needs to confirm in the Discord app.

### With Invitation Prompt

```lua
Inviter:Prompt({
    name = "Cool Server",
    invite = "discord.gg/vynixius"
})
```

Shows an in-game prompt first. If the user clicks join, it opens the Discord invite.