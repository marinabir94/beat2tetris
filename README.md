# beat2tetris
Multiplayer Tetris with tangible interface that adapts using the heart rate of the users.

The project consists on a game of Tetris with two modes: competitive and collaborative. It is designed for two players. The pieces are moved using two Wii Remotes (one for each player). They can select the next piece that they desire to have using three colored objects, detected by two color sensors. Each player has ECG electrodes attached, measuring their heart rates. The game rewards the users when their heart rates are similar for a period of time.

The research concept behind this was to study the heart-rate synchronization when collaborating with the same goal (collaboration) versus when competing. The hypothesis was that heart rates synchronize faster when the subjects are collaborating.

This project was developed by Marina Ballester, Claudia Daudén and Héctor López Carral as their final project for the course *Advanced Interface Design* of the Master in Cognitive Systems and Interactive Media (CSIM) at the Universitat Pompeu Fabra (UPF), Barcelona.

## Software
The system used the following software:
* Processing for the Tetris game and integration with the rest of components.
* Arduino for selecting the next piece of the game using two color sensors. Requires [Teensy](https://www.pjrc.com/teensy/tutorial.html). It sends data to Processing using Serial.
* OSCulator for moving the pieces using Wii Remotes. It sends data to Processing using OSC.
* Python for computing the heart rates of the players. It sends data to Processing using OSC.

## Hardware
The system used the following devices:
* Two Wii Remotes for moving the pieces in the game (D-pad for moving and accelerometer for rotating).
* Two color sensors Adafruit TCS34725 attached to a Teensy board 3.2 for selecting the next piece of the game using three color object (one red, one green, one blue).
* One BITalino with two sets of ECG sensors.
