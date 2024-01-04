# MATLAB Space Invaders Game

## Overview
This MATLAB project is an object-oriented implementation of a Space Invaders-style game. The game features a player-controlled spaceship,
alien fleets, a scoring system, and barriers for defense. The game's objective is to shoot down alien ships while avoiding their attacks.

## Features
- **Player Control**: Move the spaceship and shoot at alien fleets.
- **Alien Fleets**: Enemy groups that move in a pattern and occasionally shoot back.
- **Scoring System**: Gain points for shooting down aliens and alien ships.
- **Barriers**: Provide cover for the player but can be destroyed.
- **Game Over Handling**: Display "GAME OVER" message with the final score.
- **Restrictive Shooting**: Limit the player to shoot once every 0.75 seconds.

## Installation
1. Clone or download the repository to your local machine.
2. Open MATLAB and navigate to the project's directory.
3. Run the `runthegame.m` script to start the game.

## Usage
- **Starting the Game**: Execute the `runthegame.m` script.
- **Player Movement**: Use keyboard arrow keys to move the spaceship left or right.
- **Shooting**: Press the spacebar to shoot; shooting is limited to every 0.75 seconds.
- **Restarting the Game**: Press the 's' key after the game is over to start a new game.

## Game Components
- **Game**: The main class that handles game logic and rendering.
- **Player**: Represents the player's spaceship.
- **Alien**: Represents an individual alien in the fleet.
- **AlienFleet**: Handles the group of alien ships.
- **Scoreboard**: Manages and displays the player's score.
- **Barrier**: Provides cover for the player, can be damaged and destroyed.

## Key Files
- `Game.m`: Main game class that orchestrates the gameplay.
- `Player.m`, `Alien.m`, `AlienFleet.m`, `Scoreboard.m`, `Barrier.m`: Classes representing different game entities.
- `runthegame.m`: Script to initialize and run the game.

## Contributing
Contributions to this project are welcome. Please fork the repository and submit a pull request with your changes.

## Credits
First credit goes to the team behind Matlab course at ČVUT FEL, thank you for your guidce and lecutres. 
Secondly, i want to thank DALLE, for their software and the ability to create graphics for the game. 

## License
This project is open source and available under the [MIT License](LICENSE).
