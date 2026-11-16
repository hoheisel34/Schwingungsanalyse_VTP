function schreibe_tabelle(name, zeilen, P)
%SCHREIBE_TABELLE  Schreibt Tabellenzeilen (cellstr) als LaTeX-Datei, die im
%   Bericht per \input{tabellen/<name>} eingebunden wird.
datei = fullfile(P.tab, [name '.tex']);
fid = fopen(datei, 'w', 'n', 'UTF-8');
fprintf(fid, '%% Tabelle "%s" - automatisch erzeugt von Auswertung_MATLAB, nicht von Hand bearbeiten\n', name);
fprintf(fid, '%s\n', zeilen{:});
fclose(fid);
fprintf('  Tabelle gespeichert: %s\n', datei);
end
