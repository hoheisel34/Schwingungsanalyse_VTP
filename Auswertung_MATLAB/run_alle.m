function run_alle()
%RUN_ALLE  Fuehrt die komplette Auswertung des Versuchs Schwingungsanalyse aus.
% Erzeugt alle Abbildungen (Bericht_LaTeX/abbildungen) und Tabellen
% (Bericht_LaTeX/tabellen), die im LaTeX-Bericht eingebunden werden.
%
% Benoetigt: MATLAB (getestet mit R2025b). Die Signal Processing Toolbox
% wird NICHT benoetigt - Fensterfunktionen und STFT sind in lib/
% nachgebildet und liefern identische Ergebnisse wie hann, flattopwin und
% spectrogram.

skripte = {'A0_Zeitsignale', 'A1_Abtastrate', 'A2_Fensterfunktion', ...
           'A3_Frequenzaufloesung', 'A4_Spektraldarstellung', 'A5_Sensorposition'};
ordner = fileparts(mfilename('fullpath'));
for i = 1:numel(skripte)
    fuehre_aus(fullfile(ordner, [skripte{i} '.m']));
end
fprintf('\nAuswertung abgeschlossen.\n');
end

function fuehre_aus(datei)
% eigener Workspace je Skript, damit "clear" im Skript die Schleife nicht stoert
run(datei);
end
