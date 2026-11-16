function run_alle()
%RUN_ALLE  Fuehrt die komplette Auswertung des Versuchs Schwingungsanalyse aus.
% Erzeugt alle Abbildungen (Bericht_LaTeX/abbildungen) und Tabellen
% (Bericht_LaTeX/tabellen), die im LaTeX-Bericht eingebunden werden.
%
% Daten:  VMTP_Schwingungsanalyse_Platz1_1611/02_Daten (Messung 16.11.2026)
%         Zuordnung und Gueltigkeitspruefung der Messungen: lib/messkatalog.m
% Benoetigt: MATLAB R2025b mit Signal Processing Toolbox
%         (rectwin/hann/flattopwin, enbw, spectrogram, tfestimate, mscohere,
%          resample, findpeaks)

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
