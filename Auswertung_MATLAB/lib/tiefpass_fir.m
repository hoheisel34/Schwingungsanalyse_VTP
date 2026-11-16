function h = tiefpass_fir(fg, fs, ordnung)
%TIEFPASS_FIR  Linearphasiger FIR-Tiefpass (gefenstertes sinc, Hanning)
%              als Anti-Aliasing-Filter, ohne Toolbox.
%   fg Grenzfrequenz in Hz, fs Abtastrate in Hz, ordnung (gerade Zahl)
n  = (-ordnung/2:ordnung/2)';
wc = 2*fg/fs;                                  % normierte Grenzfrequenz
h  = wc * sinc_(wc*n) .* (0.5 + 0.5*cos(2*pi*n/(ordnung+2)));
h  = h / sum(h);                               % Verstaerkung 1 bei f = 0
end

function y = sinc_(x)
y = ones(size(x)); k = x ~= 0;
y(k) = sin(pi*x(k)) ./ (pi*x(k));
end
