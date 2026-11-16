function M = lade_messung(name, P, erlaubeUngueltig)
%LADE_MESSUNG  Liest eine Messung der Mess-App (Binaerdatei + Metadaten).
%   M = lade_messung('V1_df1_H', P)            Kurzname aus messkatalog
%   M = lade_messung('T155809', P)             oder Zeitstempel
%   M = lade_messung(name, P, true)            auch ungueltige Messungen laden
%
%   Aufbau der Binaerdatei: 4 double-Werte je Abtastzeitpunkt
%   [Zeit, Kanal 1, Kanal 2, Kanal 3]; die Werte sind von der App bereits
%   mit dem Kalibrierwert in physikalische Einheiten umgerechnet. Die
%   Kanalbelegung wird aus meta.Setup gelesen (nicht fest angenommen).
%
%   Rueckgabe:
%     M.t, M.x            Zeitvektor in s, Messwerte [n x 3]
%     M.F, M.aE, M.aB     Kraft (N), Beschleunigung Einleitung und Balken (m/s^2)
%     M.fs, M.n, M.T      Abtastrate, Anzahl Werte, Messdauer
%     M.kanal, M.einheit  Kanalnamen und Einheiten laut Setup
%     M.id, M.kurz, M.beschreibung, M.gueltig, M.grund

if nargin < 3, erlaubeUngueltig = false; end
K = messkatalog(P);
i = find(strcmp(K.kurz, name) | strcmp(K.id, name), 1);
if isempty(i), error('Messung "%s" nicht im Messkatalog.', name); end
if ~K.gueltig(i) && ~erlaubeUngueltig
    error('Messung %s (%s) ist ungültig: %s', K.kurz{i}, K.id{i}, K.grund{i});
end

fid = fopen(fullfile(P.daten, K.datei{i}), 'r');
daten = fread(fid, [4 inf], 'double')';
fclose(fid);
meta = load(fullfile(P.daten, strrep(K.datei{i}, '_binaer.bin', '_meta.mat'))).meta;

M.id = K.id{i}; M.kurz = K.kurz{i}; M.beschreibung = K.beschreibung{i};
M.gueltig = K.gueltig(i); M.grund = K.grund{i};
M.t  = daten(:,1);
M.x  = daten(:,2:end);
M.fs = K.fs(i); M.n = K.n(i); M.T = K.T(i);
M.kanal   = {meta.Setup.Name};
M.einheit = {meta.Setup.Unit};

% Kanalzuordnung ueber das Setup (Name "Krafteinleitung" enthaelt auch
% "einleitung", daher Kraft ueber die Einheit N erkennen)
M.iF = find(strcmp(M.einheit, 'N'), 1);
M.iE = find(strcmpi(M.kanal, 'Einleitung'), 1);
M.iB = find(contains(M.kanal, 'Balken', 'IgnoreCase', true), 1);
M.F  = M.x(:, M.iF);
M.aE = M.x(:, M.iE);
M.aB = M.x(:, M.iB);
end
