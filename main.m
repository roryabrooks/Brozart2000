% https://www.yumpu.com/en/document/read/43474027/physical-modeling-of-plucked-string-instruments-with-application-to-#google_vignette

%% RATE CONFIGURATION

f_s = 11025; % sampling frequency
T_s = 1/f_s; % sampling period
bps = 1.68; % tempo in beats per second
N_n = floor(f_s/bps); % note interval

%% PROCESSING NOTE SEQUENCE VECTOR

C4_scale = [
            [261.81/4,293.66/4,329.63/4,349.23/4,392/4,440/4,493.88/4,261.81/2,293.66/2,329.63/2,349.23/2,392/2,440/2,493.88/2,261.81,293.66,329.63,349.23,392,440,493.88,523.25,2*293.66,2*329.63,2*349.23,2*392,2*440,2*493.88,2*523.25]; 
            [261.81/2,293.66/2,329.63/2,349.23/2,392/2,440/2,493.88/2,261.81,293.66,329.63,349.23,392,440,493.88,523.25,2*293.66,2*329.63,2*349.23,2*392,2*440,2*493.88,2*523.25,261.81/4,293.66/4,329.63/4,349.23/4,392/4,440/4,493.88/4]
           ];
zelda_freq = [349.23,440,493.88,0,349.23,440,493.88,0,349.23,440,493.88,659.25];
% F A B 0 F A B 0 F A B E

%USE THIS LINE TO DEFINE INPUT SEQ
input_seq = C4_scale;

%getting input sequence length for counter to count up to
seq_length = ceil(log2(length(input_seq)+1));
input_seq = [input_seq, zeros([2 power(2, seq_length) - length(input_seq)])];

%define length of time per note
playback_speed = 0.5;

period_sequence = normalised_period(f_s,input_seq);

D2_period = normalised_period(f_s,73.42)

note = 30;
freq_F_sharp_1 = midi_to_freq(note);

zelda_period = normalised_period(f_s,zelda_freq);

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
    L = size(freqs,1);
    N = size(freqs,2);
    M = 2^ceil(log2(N));
    v = zeros(L,M, 'uint32');
    for i=1:N
        for j=1:L
            if (freqs(j,i) == 0)
                v(j,i) = 0;
            else
                v(j,i) = round(f_s/freqs(j,i));
            end
        end
    end
end

% convert MIDI note number into continuous frequency
function f = midi_to_freq(note)
    a = 440;
    f = (a / 32) * (2 ^ ((note - 9) / 12.0));
end
