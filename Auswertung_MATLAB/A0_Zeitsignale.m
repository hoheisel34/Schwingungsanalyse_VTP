%% A0_Zeitsignale - Uebersicht ueber alle Messungen
% Liest alle Binaerdateien, erstellt eine Uebersichtstabelle und stellt die
% Zeitsignale der verschiedenen Anregungsarten dar.

clear; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), 'lib'));
P = init_pfade();
fprintf('A0: Zeitsignale\n');

%% Uebersichtstabelle aller Messungen
dateien = {'0,25HZ-Rechteck.bin', '1HZ-Rechteck.bin', '1HZ-Hanning.bin', ...
           '4HZ-Rechteck.bin', '100Hz-1HZ-Rechteck.bin', '100Hz-1HZ-Hanning.bin', ...
           '100Hz-1HZ-Flattop.bin', 'Unregelmaessig-Zeit.bin', ...
           'Unregelmaessig-Frequenz.bin', '0,1Hz-Rechteck-Zeit.bin'};
zeilen = {};
for i = 1:numel(dateien)
    M = lade_messung(dateien{i}, P);
    x = M.x - mean(M.x);                         % Effektivwerte ohne Gleichanteil
    R = spektrum(M.x(:,2), M.fs, 1, 'hanning');  % dominante Frequenz Kanal 2
    [~, k] = max(R.Sx(2:end)); fdom = R.f(k+1);
    zeilen{end+1} = sprintf('\\texttt{%s} & %s & %s & %s & %s & %s & %s & %s \\\\', ...
        strrep(M.name, '_', '\_'), num(M.fs, 5), num(M.T, 3), num(M.n, 7), ...
        num(rms(x(:,1)), 3), num(rms(x(:,2)), 3), num(rms(x(:,3))*1000, 2), num(fdom, 4));
end
schreibe_tabelle('tab_messungen', zeilen, P);

%% Abbildung: Sinusanregung 500 Hz (Datei 1HZ-Rechteck)
M = lade_messung('1HZ-Rechteck.bin', P);
fig = neue_abb(16, 10);
tl = tiledlayout(fig, 3, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
for c = 1:3
    nexttile(tl);
    plot(M.t, M.x(:,c), 'Color', [0 0.32 0.62]);
    ylabel(sprintf('%s in %s', M.kanal{c}, M.einheit{c}));
    if c == 1, title('Gesamte Messdauer'); end
    if c == 3, xlabel('Zeit in s'); end
    nexttile(tl);
    b = M.t >= 1 & M.t <= 1.02;
    plot(M.t(b)*1000, M.x(b,c), '.-', 'Color', [0.80 0.33 0], 'MarkerSize', 7);
    if c == 1, title('Ausschnitt 20 ms (Punkte = Abtastwerte)'); end
    if c == 3, xlabel('Zeit in ms'); end
end
speichere_abb(fig, 'A0_zeit_500Hz', P);

%% Abbildung: Anregung 100 Hz (Datei 100Hz-1HZ-Rechteck)
M = lade_messung('100Hz-1HZ-Rechteck.bin', P);
fig = neue_abb(16, 6);
b = M.t >= 1 & M.t <= 1.04;
tl = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
for c = 1:2
    nexttile(tl);
    plot(M.t(b)*1000, M.x(b,c), '.-', 'MarkerSize', 6);
    xlabel('Zeit in ms'); ylabel(sprintf('%s in %s', M.kanal{c}, M.einheit{c}));
    title(sprintf('Kanal %d: %s', c, M.kanal{c}));
end
speichere_abb(fig, 'A0_zeit_100Hz', P);

%% Abbildung: unregelmaessige Anregungen und Langzeitmessung
namen = {'Unregelmaessig-Zeit.bin', 'Unregelmaessig-Frequenz.bin', '0,1Hz-Rechteck-Zeit.bin'};
titel = {'Unregelmaessig-Zeit', 'Unregelmaessig-Frequenz', '0,1Hz-Rechteck-Zeit (f_s = 51,2 kHz)'};
fig = neue_abb(16, 12);
tl = tiledlayout(fig, 3, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
for i = 1:3
    M = lade_messung(namen{i}, P);
    nexttile(tl);
    plot(M.t, M.x(:,2), 'Color', [0.80 0.33 0]); hold on;
    plot(M.t, M.x(:,1), 'Color', [0 0.32 0.62]);
    ylabel('a in m/s^2'); title(titel{i});
    if i == 1, legend('Kanal 2: Einleitung', 'Kanal 1: Balken', 'Location', 'northeast'); end
end
xlabel(tl, 'Zeit in s', 'FontSize', 9);
speichere_abb(fig, 'A0_zeit_unregelmaessig', P, 'image');
