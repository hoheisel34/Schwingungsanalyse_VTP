function fig = neue_abb(breite_cm, hoehe_cm)
%NEUE_ABB  Erzeugt eine unsichtbare Abbildung in Berichtsgroesse
%          (helles Design, unabhaengig vom MATLAB-Desktop-Theme).
if nargin < 1, breite_cm = 16; end
if nargin < 2, hoehe_cm = 8; end
fig = figure('Visible', 'off', 'Units', 'centimeters', 'Color', 'w', ...
             'Position', [2 2 breite_cm hoehe_cm]);
try
    fig.Theme = 'light';          % ab MATLAB R2025a
catch
end
end
