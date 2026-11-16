function [wert, fpk] = peakwert(f, S, f0, breite)
%PEAKWERT  Maximum des Spektrums S im Bereich f0 +/- breite.
if nargin < 4, breite = 5; end
b = abs(f - f0) <= breite;
[wert, i] = max(S(b));
fb = f(b); fpk = fb(i);
end
