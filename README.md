
## How to play:

1. In midi.m load the midi file via the line: 

readme = fopen('bach_invention_13_bwv_784.mid');

(By default this loads in BWV 784)

2. Then run the main.m file to convert this into an input sequence for the simulink model.

3. Then load the simulink model to the board. The model is titled "board_algorithm_2note_length.slx"

The board should begin playing the loaded midi file. 
