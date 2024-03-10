% https://www.yumpu.com/en/document/read/43474027/physical-modeling-of-plucked-string-instruments-with-application-to-#google_vignette

%% RATE CONFIGURATION

f_s = 11025; % sampling frequency
T_s = 1/f_s; % sampling period
bps = 1.68; % tempo in beats per second
N_n = floor(f_s/bps); % note interval

%% PROCESSING NOTE SEQUENCE VECTOR

C4_scale = [261.81,293.66,329.63,349.23,392,440,493.88,523.25];
zelda_freq = [349.23,440,493.88,0,349.23,440,493.88,0,349.23,440,493.88,659.25];
% F A B 0 F A B 0 F A B E
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
    N = size(freqs,2);
    M = 2^ceil(log2(N));
    v = zeros(1,M, 'uint32');
    for i=1:N
        if (freqs(i) == 0)
            v(i) = 0;
        else
            v(i) = round(f_s/freqs(i));
        end
    end
end

% convert MIDI note number into continuous frequency
function f = midi_to_freq(note)
    a = 440;
    f = (a / 32) * (2 ^ ((note - 9) / 12.0));
end
