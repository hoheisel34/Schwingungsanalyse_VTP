%% A0_Zeitsignale - Messuebersicht, Gueltigkeitspruefung und Zeitsignale
% Listet alle Messungen mit Kennwerten und Gueltigkeit (siehe
% lib/messkatalog.m), dokumentiert die ungueltigen Messungen und stellt die
% Zeitsignale der Anregungsarten dar (Sinus, Impuls, verrauschtes Signal).

clear; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), 'lib'));
P = init_pfade();
fprintf('A0: Messübersicht und Zeitsignale\n');

%% Uebersichtstabelle aller Messungen und Liste der ungueltigen Messungen
K = messkatalog(P);
zeilen = {}; zeilenU = {};
for i = 1:height(K)
    M = lade_messung(K.id{i}, P, true);
    x = M.x - mean(M.x);                          % Effektivwerte ohne Gleichanteil
    if M.gueltig, status = 'ja'; else, status = '\textbf{nein}'; end
    zeilen{end+1} = sprintf('\\texttt{%s} & %d & %s & %s & %s & %s & %s & %s & %s \\\\', ...
        M.id, K.versuch(i), M.beschreibung, num(M.fs,5), num(M.T,3), ...
        num(rms(x(:,M.iF)),3), num(rms(x(:,M.iE)),3), num(rms(x(:,M.iB)),3), status); %#ok<SAGROW>
    if ~M.gueltig
        zeilenU{end+1} = sprintf('\\texttt{%s} & %s & %s \\\\', M.id, M.beschreibung, M.grund); %#ok<SAGROW>
        fprintf('  UNGÜLTIG  %s (%s): %s\n', M.id, M.kurz, M.grund);
    end
end
schreibe_tabelle('tab_messungen', zeilen, P);
schreibe_tabelle('tab_ungueltig', zeilenU, P);

%% Abbildung: Sinusanregung 500 Hz (Versuch 1)
M = lade_messung('V1_df1_R', P);
fig = neue_abb(16, 10);
tl = tiledlayout(fig, 3, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
kanaele = [M.iF M.iE M.iB];
for c = 1:3
    k = kanaele(c);
    nexttile(tl);
    plot(M.t, M.x(:,k), 'Color', P.farbe.blau);
    ylabel(sprintf('%s in %s', M.kanal{k}, M.einheit{k}));
    if c == 1, title('Gesamte Messdauer'); end
    if c == 3, xlabel('Zeit in s'); end
    nexttile(tl);
    b = M.t >= 1 & M.t <= 1.01;
    plot(M.t(b)*1000, M.x(b,k), '.-', 'Color', P.farbe.orange, 'MarkerSize', 7);
    if c == 1, title('Ausschnitt 10 ms (Punkte = Abtastwerte)'); end
    if c == 3, xlabel('Zeit in ms'); end
end
speichere_abb(fig, 'A0_zeit_500Hz', P);

%% Abbildung: Impulsanregung an beiden Positionen (Versuch 3)
namen = {'V3_Einleitung', 'V3_Mitte'};
fig = neue_abb(16, 10);
tl = tiledlayout(fig, 3, 2, 'TileSpacing', 'compact', 'Padding', 'compact', 'TileIndexing', 'columnmajor');
for m = 1:2
    M = lade_messung(namen{m}, P);
    [~, i0] = max(abs(M.F - mean(M.F)));          % Zeitpunkt des Kraftimpulses
    b = abs(M.t - M.t(i0) - 0.0125) <= 0.0175;    % -5 ... +30 ms
    for k = [M.iF M.iE M.iB]
        nexttile(tl);
        plot((M.t(b) - M.t(i0))*1000, M.x(b,k) - mean(M.x(:,k)), 'Color', P.farbe.blau);
        if m == 1, ylabel(sprintf('%s in %s', M.kanal{k}, M.einheit{k})); end
        if k == M.iF, title(sprintf('%s (%s)', M.beschreibung, M.id)); end
        if k == M.iB, xlabel('Zeit relativ zum Kraftmaximum in ms'); end
    end
end
speichere_abb(fig, 'A0_zeit_impuls', P);

%% Abbildung: verrauschtes Signal (Versuch 4)
M = lade_messung('V4_Rauschen', P);
fig = neue_abb(16, 10);
tl = tiledlayout(fig, 3, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
for k = [M.iF M.iE M.iB]
    nexttile(tl);
    plot(M.t, M.x(:,k) - mean(M.x(:,k)), 'Color', P.farbe.blau);
    ylabel(sprintf('%s in %s', M.kanal{k}, M.einheit{k}));
end
title(tl, sprintf('%s (%s), f_s = %g Hz', M.beschreibung, M.id, M.fs), 'FontSize', 9);
xlabel(tl, 'Zeit in s', 'FontSize', 9);
speichere_abb(fig, 'A0_zeit_rauschen', P, 'image');
