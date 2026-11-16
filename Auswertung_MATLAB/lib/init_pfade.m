function P = init_pfade()
%INIT_PFADE  Legt alle Pfade der Auswertung fest und setzt Grafik-Standards.
%   P = init_pfade() liefert eine Struktur mit den Feldern
%     P.daten  - Ordner mit den Messdateien (*_binaer.bin, *_meta.mat)
%     P.abb    - Zielordner fuer Abbildungen (PDF) des LaTeX-Berichts
%     P.tab    - Zielordner fuer automatisch erzeugte LaTeX-Tabellen
%     P.farbe  - einheitliche Linienfarben (blau, orange, gruen, grau)

if isempty(ver('signal'))
    error('Die Auswertung benoetigt die Signal Processing Toolbox.');
end

hier   = fileparts(mfilename('fullpath'));        % .../Auswertung_MATLAB/lib
wurzel = fileparts(fileparts(hier));              % .../VTP_Schwingungsanalyse

P.daten = fullfile(wurzel, 'VMTP_Schwingungsanalyse_Platz1_1611', '02_Daten');
P.abb   = fullfile(wurzel, 'Bericht_LaTeX', 'abbildungen');
P.tab   = fullfile(wurzel, 'Bericht_LaTeX', 'tabellen');
if ~exist(P.abb, 'dir'), mkdir(P.abb); end
if ~exist(P.tab, 'dir'), mkdir(P.tab); end

P.farbe.blau   = [0 0.32 0.62];
P.farbe.orange = [0.85 0.33 0];
P.farbe.gruen  = [0.2 0.6 0.2];
P.farbe.grau   = [0.45 0.45 0.45];
P.farben3      = [P.farbe.blau; P.farbe.orange; P.farbe.gruen];

% einheitliches Erscheinungsbild aller Diagramme
set(groot, 'defaultAxesFontSize', 9, ...
           'defaultTextFontSize', 9, ...
           'defaultAxesXGrid', 'on', 'defaultAxesYGrid', 'on', ...
           'defaultLineLineWidth', 0.9, ...
           'defaultAxesBox', 'on', ...
           'defaultLegendFontSize', 8);
end
