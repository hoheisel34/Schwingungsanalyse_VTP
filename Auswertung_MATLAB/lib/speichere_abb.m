function speichere_abb(fig, name, P, typ)
%SPEICHERE_ABB  Speichert eine Abbildung als PDF fuer den LaTeX-Bericht.
%   typ: 'vector' (Standard) oder 'image' (fuer sehr viele Datenpunkte)
if nargin < 4, typ = 'vector'; end
datei = fullfile(P.abb, [name '.pdf']);
exportgraphics(fig, datei, 'ContentType', typ, 'Resolution', 300);
fprintf('  Abbildung gespeichert: %s\n', datei);
end
