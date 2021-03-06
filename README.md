IrisValve
=========

IrisValve is intended to be a turn-based game of close combat in a science-fiction future. The game is played either on the web or through a dedicated client. This code is the online game engine, to be run through Google App Engine (or something similar).

The game itself is turn based, and therefore relatively free of the restrictions that would normally be imposed where communication channels need to be maintained at all times. The expectation is that the views provided by IrisValve represent a web interface to the game as well as a REST based interface to interact with the game.

The state of any given game will be represented in the model structure supported by IrisValve - a table structure within Google, etc. A completely in-memory game using a memcache service to maintain state is also potential.

The game is based loosely on the 1979 board game [Snapshot](http://traveller.wikia.com/wiki/Snapshot "Snapshot") and [Azhanti High Lightning](http://traveller.wikia.com/wiki/Azhanti_High_Lightning "Azhanti High Lightning") by [GDW](http://traveller.wikia.com/wiki/Game_Designers_Workshop "Game Designer's Workshop"). 

The player represents an individual on a starship (or other close environment) in a science fiction setting. The player has action points to spend moving or fighting, the available players taking turns in the combat based on total number of action points available to them. High "AP" players get offered turns first, but can "defer" those turns until later.

The question remains outstanding of what to do for players who cease to interact with the game - so potentially a timeout needs to be available before which the character needs to interact or loose that turn. What drives that "tick of the clock" is TBD, as is the game logic which may move NPC's through the game environment.

The REST interface needs to also be designed, as well as the game rules fully defined.