function M = lade_messung(datei, P)
%LADE_MESSUNG  Liest eine Binaerdatei der Messapp (vgl. datenkonverter.m).
%   M = lade_messung('1HZ-Rechteck.bin', P)
%
%   Aufbau der Datei: 4 double-Werte je Abtastzeitpunkt
%   [Zeit, Kanal 1, Kanal 2, Kanal 3]. Die Messwerte sind von der App
%   bereits mit dem Kalibrierwert in physikalische Einheiten umgerechnet.
%
%   Rueckgabe:
%     M.name   Dateiname (ohne Endung)
%     M.t      Zeitvektor in s
%     M.x      Messwerte [n x 3]
%     M.fs     Abtastrate in Hz
%     M.kanal  Kanalbezeichnungen,  M.einheit  Einheiten

fid = fopen(fullfile(P.daten, datei), 'r');
if fid < 0, error('Datei %s nicht gefunden.', datei); end
daten = fread(fid, [4 inf], 'double')';
fclose(fid);

[~, M.name] = fileparts(datei);
M.t  = daten(:,1);
M.x  = daten(:,2:end);
M.fs = round(1/median(diff(M.t)));
M.kanal   = {'Balken', 'Einleitung', 'Kraft'};
M.einheit = {'m/s^2', 'm/s^2', 'N'};
M.n  = size(M.x,1);
M.T  = M.n / M.fs;
end
