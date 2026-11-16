function w = fenster(typ, N)
%FENSTER  Fenster der Versuchsunterlage aus der Signal Processing
%   Toolbox: 'rechteck' -> rectwin, 'hanning' -> hann, 'flattop' -> flattopwin
%   (jeweils symmetrisch, Spaltenvektor der Laenge N).
switch lower(typ)
    case {'rechteck', 'rect', 'keins'}, w = rectwin(N);
    case {'hanning', 'hann'},           w = hann(N);
    case 'flattop',                     w = flattopwin(N);
    otherwise, error('Unbekannte Fensterfunktion: %s', typ);
end
end
