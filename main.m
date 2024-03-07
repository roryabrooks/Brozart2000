f_s = 16000;
T_s = 1/f_s;
bps = 1.68;
N_n = floor(f_s/bps);

C4_scale = [261.81,293.66,329.63,349.23,392,440,493.88,523.25];
zelda = [349.23,440,493.88,0,349.23,440,493.88,0,349.23,440,493.88,659.25];
% F A B 0 F A B 0 F A B E
period_sequence = normalised_period(f_s,zelda);

D2_period = normalised_period(f_s,73.42)

note = 30;
freq_F_sharp_1 = midi_to_freq(note);

function h = lagrange( N, delay )

    n = 0:N;
    h = ones(1,N+1);
    for k = 0:N
        index = find(n ~= k);
        h(index) = h(index) *  (delay-k)./ (n(index)-k);
    end
end

function v = normalised_period(f_s,freqs)
    N = size(freqs,2);
    M = 2^ceil(log2(N));
    v = zeros(1,M);
    for i=1:N
        if (freqs(i) == 0)
            v(i) = 0;
        else
            v(i) = round(f_s/freqs(i));
        end
    end
end

function f = midi_to_freq(note)
    a = 440;
    f = (a / 32) * (2 ^ ((note - 9) / 12.0));
end
