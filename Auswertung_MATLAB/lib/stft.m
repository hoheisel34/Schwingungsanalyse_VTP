function [s, f, t] = stft(x, w, O, fs)
%STFT  Kurzzeit-Fouriertransformation, identisch zu
%      [s,f,t] = spectrogram(x, w, O, numel(w), fs)   (einseitig, reelles x)
%   x  Signal (Vektor), w Fensterfunktion (Laenge N), O Ueberlappung in Samples

x = x(:); w = w(:); N = numel(w);
L = numel(x);
if L < N
    error('Signal (%d Werte) kuerzer als Blocklaenge N = %d. Frequenzaufloesung zu fein fuer diese Messdauer.', L, N);
end
hop = N - O;
K   = floor((L - O) / hop);                 % Anzahl Bloecke
idx = (1:N)' + (0:K-1)*hop;                  % Indexmatrix [N x K]
X   = fft(x(idx) .* w, N);                   % FFT spaltenweise
nf  = floor(N/2) + 1;                        % einseitiges Spektrum
s   = X(1:nf, :);
f   = (0:nf-1)' * fs / N;
t   = ((0:K-1)*hop + N/2) / fs;              % Blockmitte
end
