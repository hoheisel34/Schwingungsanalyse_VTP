function P = init_pfade()
%INIT_PFADE  Legt alle Pfade der Auswertung fest und setzt Grafik-Standards.
%   P = init_pfade() liefert eine Struktur mit den Feldern
%     P.daten  - Ordner mit den Binaerdateien (*.bin) der Messung
%     P.abb    - Zielordner fuer Abbildungen (PDF) des LaTeX-Berichts
%     P.tab    - Zielordner fuer automatisch erzeugte LaTeX-Tabellen

hier   = fileparts(mfilename('fullpath'));        % .../Auswertung_MATLAB/lib
wurzel = fileparts(fileparts(hier));              % .../VTP_Schwingungsanalyse

P.daten = fullfile(wurzel, 'VTP_MTP_Schwingungsanalyse_Platz2', '02_Daten');
P.abb   = fullfile(wurzel, 'Bericht_LaTeX', 'abbildungen');
P.tab   = fullfile(wurzel, 'Bericht_LaTeX', 'tabellen');
if ~exist(P.abb, 'dir'), mkdir(P.abb); end
if ~exist(P.tab, 'dir'), mkdir(P.tab); end

% einheitliches Erscheinungsbild aller Diagramme
set(groot, 'defaultAxesFontSize', 9, ...
           'defaultTextFontSize', 9, ...
           'defaultAxesXGrid', 'on', 'defaultAxesYGrid', 'on', ...
           'defaultLineLineWidth', 0.9, ...
           'defaultAxesBox', 'on', ...
           'defaultLegendFontSize', 8);
end
