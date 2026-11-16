function w = fenster(typ, N)
%FENSTER  Fensterfunktionen Rechteck, Hanning und Flattop (Spaltenvektor).
%   Die Definitionen entsprechen exakt den MATLAB-Funktionen
%   rectwin(N), hann(N) und flattopwin(N) der Signal Processing Toolbox
%   (symmetrische Form), sodass keine Toolbox benoetigt wird.

n = (0:N-1)';
switch lower(typ)
    case {'rechteck', 'rect', 'keins'}
        w = ones(N,1);
    case {'hanning', 'hann'}
        w = 0.5 * (1 - cos(2*pi*n/(N-1)));
    case 'flattop'
        a = [0.21557895 0.41663158 0.277263158 0.083578947 0.006947368];
        x = 2*pi*n/(N-1);
        w = a(1) - a(2)*cos(x) + a(3)*cos(2*x) - a(4)*cos(3*x) + a(5)*cos(4*x);
    otherwise
        error('Unbekannte Fensterfunktion: %s', typ);
end
end
