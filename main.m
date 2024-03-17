% https://www.yumpu.com/en/document/read/43474027/physical-modeling-of-plucked-string-instruments-with-application-to-#google_vignette

%% RATE CONFIGURATION

f_s = 11025; % sampling frequency
T_s = 1/f_s; % sampling period
bps = (120*4)/60; % tempo in beats per second
N_n = floor(f_s/bps); % note interval - samples per beat

%% Load in midi converted array
input = midiMsg_to_input(msgArray);

%% PROCESSING NOTE SEQUENCE VECTOR

C4_chromatic = [261.63,277.18,293.66,311.12,329.63,349.23,369.99,392,415.30,440,466.16,493.88];

C4_scale = [
            [261.81/4,293.66/4,329.63/4,349.23/4,392/4,440/4,493.88/4,261.81/2,293.66/2,329.63/2,349.23/2,392/2,440/2,493.88/2,261.81,293.66,329.63,349.23,392,440,493.88,523.25,2*293.66,2*329.63,2*349.23,2*392,2*440,2*493.88,2*523.25];
            [261.81/2,293.66/2,329.63/2,349.23/2,392/2,440/2,493.88/2,261.81,293.66,329.63,349.23,392,440,493.88,523.25,2*293.66,2*329.63,2*349.23,2*392,2*440,2*493.88,2*523.25,261.81/4,293.66/4,329.63/4,349.23/4,392/4,440/4,493.88/4];
           ];

C4_scale_1 = [
            [48,50,51,53,55,57,59,60,62,64,65,67,69,71,72,74,76,77,79,81,83,84];
            [ 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 4, 4, 4, 4, 4, 4, 4];
           ];

C4_scale_2 = [
            [60,62,64,65,67,69,71,72,74,76,77,79,81,83,84,50,51,53,55,57,59,60];
            [ 2, 2, 2, 2, 2, 2, 2, 2, 4, 4, 4, 4, 4, 4, 4, 1, 1, 1, 1, 1, 1, 1];
           ];

C4_hold_1 = [
            [61,    -1,  -1,  60,  62,  61,  -1,  -1];
            [0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25];
            ];
C4_hold_2 = [
            [59,    58,  -1, 57,  59,  60,  -1];
            [0.25,0.25,0.25,0.5,0.25,0.25,0.25];
            ];
zelda_freq = [349.23,440,493.88,0,349.23,440,493.88,0,349.23,440,493.88,659.25];
% F A B 0 F A B 0 F A B E

%USE THIS LINE TO DEFINE INPUT SEQ

input_seq = C4_scale;

input_seq_1 = input(1:2,:);
input_seq_2 = input(3:4,:);
% input_seq_1 = C4_hold_1;
% input_seq_2 = C4_hold_2;

input_seq_1 = [C4_hold_1,input_seq_1];
input_seq_2 = [C4_hold_2,input_seq_2];

% if(length(input_seq_1)>length(input_seq_2))
%     input_seq_2 = [input_seq_2, repmat([-1;0],length(input_seq_1)-length(input_seq_2))];
% end
% if(length(input_seq_2)>length(input_seq_1))
%     input_seq_1 = [input_seq_1, repmat([-1;0],length(input_seq_2)-length(input_seq_1))];
% end

seq_length = length(input_seq_1)+1; %1 and 2 should be same length

input_seq_1 = [midi_to_freq(input_seq_1, C4_chromatic)
               timestamp_to_length(input_seq_1(2,:))];
input_seq_2 = [midi_to_freq(input_seq_2, C4_chromatic)
               timestamp_to_length(input_seq_2(2,:))];

period_sequence = normalised_period(f_s,input_seq);

period_sequence_1 = [normalised_period(f_s,input_seq_1(1,:))
                     input_seq_1(2,:)];
period_sequence_2 = [normalised_period(f_s,input_seq_2(1,:));
                     input_seq_2(2,:)];

%define length of time per note
playback_speed = 0.5;

%% GENERATE GAUSSIAN NOISE WAVETABLE

excitation = randn(1,256) * 0.8;
%in_table = fi([[0],excitation], 1,32,30);
in_table = single([[0],excitation]);
%in_table = double([[0],excitation]);

%% TUNING COUPLED STRING MODEL

% generate coefficients for fractional delay interpolator
function h = lagrange( N, delay )

    n = 0:N;
    h = ones(1,N+1);
    for k = 0:N
        index = find(n ~= k);
        h(index) = h(index) *  (delay-k)./ (n(index)-k);
    end
end

% find period of a note in samples
function v = normalised_period(f_s,freqs)
    L = length(freqs);
    v = zeros(1,L, 'uint32');
   
    for j=1:L
        if (freqs(j) == 0)
            v(j) = 0;
        else
            v(j) = round(f_s/freqs(j));
        end
    end

end

% convert MIDI note number into continuous frequency
function freq_array = midi_to_freq(input_vector, C4_chromatic)
    freqs = [];
    for i = 1:length(input_vector)
        if (input_vector(1, i) ~= -1)                                      %if midi in is -1, that means it's a rest
            midi_note = input_vector(1, i);
            note_pos = mod(midi_note,12) + 1;
            octave = floor(midi_note/12) - 1;
            freqs = [freqs, C4_chromatic(note_pos)*pow2(octave - 4)];
        else
            freqs = [freqs, 0];
        end
    end
    freq_array = freqs;
end

function length_array = timestamp_to_length(input_vector)
    lengths = [];
    for i = 1:length(input_vector)
        lengths = [lengths, input_vector(i) * 24];
    end
    length_array = lengths;
end


%% Convert midi Array into midi notes and note lengths

function output = midiMsg_to_input(midiArray)                                                 
    noteInputs1 = zeros(2,0);
    noteInputs2 = zeros(2,0);
    playedNotes1 = [];
    playedNotes2 = [];
    processedNotes = [];

    channelFree = [true,true];                                                                                %markout which channels are free
    lastNoteRest1 = false;
    lastNoteRest2 = false;

    for j = 1:length(midiArray)
        if (midiArray(j).Type == 'NoteOn' || midiArray(j).Type == 'NoteOff')                                  %check is valid msg type  
            if (midiArray(j).Channel ~= 1)
                midiArray(j).Channel = 1;
            end
        end
    end 

    for j = 1:length(midiArray)
        if (midiArray(j).Type == 'NoteOn')                                  %check is valid msg type                                                                  
            if (midiArray(j).Velocity > 0)
                currentNoteOn = midiArray(j).Note;
                currentNoteBegin = midiArray(j).Timestamp;

                if (~isempty(playedNotes1))
                    if((currentNoteBegin >= (playedNotes1(end).Timestamp + noteInputs1(2,end))) && lastNoteRest1 == false)            %if this note's start = after ch1 prev note's end (timestamp+duration)
                        channelFree(1) = true;                                                           %channel 1 is free     
                        if(currentNoteBegin > (playedNotes1(end).Timestamp + noteInputs1(2,end)))            %if empty space, put in a -1 note (rest)
                            if((currentNoteBegin - (playedNotes1(end).Timestamp + noteInputs1(2,end))) > 0.0001)
                                noteInputs1 = [noteInputs1, [-1;(currentNoteBegin - (playedNotes1(end).Timestamp + noteInputs1(2,end)))]];
                            end
                            lastNoteRest1 = true;                                             
                        end
                    end
                elseif(isempty(playedNotes1) && currentNoteBegin > 0)                                                                %case that this is first note in channel, and it doesn't happen at time = 0
                        noteInputs1 = [noteInputs1, [-1;currentNoteBegin]];
                end

                if (~isempty(playedNotes2))
                    if(currentNoteBegin >= (playedNotes2(end).Timestamp + noteInputs2(2,end)))            %if this note's start = after ch2 prev note's end (timestamp+duration)
                        channelFree(2) = true;                                                           %channel 2 is free
                        if((currentNoteBegin > (playedNotes2(end).Timestamp + noteInputs2(2,end))) && lastNoteRest2 == false && channelFree(1) == false)  %if empty space, and this channel is played on (!channelFree1) put in a -1 note (rest)
                            if((currentNoteBegin - (playedNotes2(end).Timestamp + noteInputs2(2,end))) >= 0.0001)                                            %try to discount tiny computer error
                                noteInputs2 = [noteInputs2, [-1;(currentNoteBegin - (playedNotes2(end).Timestamp + noteInputs2(2,end)))]];
                            end
                            lastNoteRest2 = true;                                                      
                        end
                    end
                elseif(isempty(playedNotes2) && currentNoteBegin > 0)                                                                %case that this is first note in channel, and it doesn't happen at time = 0
                        noteInputs2 = [noteInputs2, [-1;currentNoteBegin]];
                end
                
                for i = j:length(midiArray)
                    if ((midiArray(i).Type == 'NoteOn' || midiArray(i).Type == 'NoteOff') && (midiArray(i).Note == currentNoteOn) && (midiArray(i).Velocity == 0) && (midiArray(i).Timestamp > currentNoteBegin))
                        noteEndIndex = i; 
                        break
                    elseif((midiArray(i).Type == 'NoteOff') && (midiArray(i).Note == currentNoteOn) && (midiArray(i).Timestamp > currentNoteBegin))
                        noteEndIndex = i;
                        break;
                    end
                end

                currentNoteEnd = midiArray(noteEndIndex).Timestamp;

                noteLength = currentNoteEnd - currentNoteBegin;

                if (channelFree(1))
                    noteInputs1 = [noteInputs1,[currentNoteOn;noteLength]];
          
                    playedNotes1 = [playedNotes1, midiArray(j)];                                    %record this as played on channel 1
                    channelFree(1) = false;
                    lastNoteRest1 = false;
                elseif (channelFree(2))
                    noteInputs2 = [noteInputs2,[currentNoteOn;noteLength]];
               
                    playedNotes2 = [playedNotes2, midiArray(j)];                                    %record this as played on channel 2
                    channelFree(2) = false;
                    lastNoteRest2 = false;
                end

                processedNotes = [processedNotes, midiArray(j)];                                    %record this note has been processed
            end
        end
    end
    
    if (size(noteInputs2,2) ~= 1)
        lengthdif = length(noteInputs1) - length(noteInputs2);
    else
        lengthdif = length(noteInputs1) - 1;
    end
    
    if(lengthdif > 0)                                                                               %case that noteInputs1 longer than noteInputs2
        noteInputs2 = [noteInputs2,repmat([-1;0],1,(lengthdif))];
    elseif(lengthdif < 0)                                                                           %case that noteInputs2 longer than noteInputs1
        noteInputs1 = [noteInputs1,repmat([-1;0],1,(-1*lengthdif))];
    end

    length(noteInputs1)
    length(noteInputs2)

    output = [noteInputs1;noteInputs2];
end



