%% A3_Frequenzaufloesung - Einfluss der Frequenzaufloesung (Linienabstand)
% (a) Sinusfoermige Anregung (100 Hz): Linienbreite, Amplitude, Mittelungen
% (b) Trennung eng benachbarter Resonanzen (Balken, unregelmaessige Anregung)
% (c) Zeit-Frequenz-Unschaerfe im Spektrogramm (Anregung mit wechselnder Frequenz)

clear; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), 'lib'));
P = init_pfade();
fprintf('A3: Frequenzaufloesung\n');
dfListe = [0.25 1 4];
farben  = [0 0.32 0.62; 0.85 0.33 0; 0.2 0.6 0.2; 0.5 0.5 0.5];

%% (a) 100-Hz-Messung, Hanning
M = lade_messung('100Hz-1HZ-Flattop.bin', P);
fig = neue_abb(16, 6.5);
tl  = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
ax1 = nexttile(tl); hold(ax1, 'on'); set(ax1, 'YScale', 'log');
ax2 = nexttile(tl); hold(ax2, 'on');
zeilen = {}; leg = {};
for k = 1:numel(dfListe)
    R = spektrum(M.x(:,2), M.fs, dfListe(k), 'hanning');
    plot(ax1, R.f, R.Sx, 'Color', farben(k,:));
    plot(ax2, R.f, R.Sx, '.-', 'Color', farben(k,:), 'MarkerSize', 9);
    leg{end+1} = sprintf('\\Delta f = %g Hz', dfListe(k)); %#ok<SAGROW>
    A100 = peakwert(R.f, R.Sx, 100, 3);
    zeilen{end+1} = sprintf('%s & %d & %s & %d & %s & %s \\\\', num(R.df,3), R.N, ...
        num(R.T,3), R.nBloecke, num(R.Beff,3), num(A100,4)); %#ok<SAGROW>
end
xlim(ax1, [0 1600]); ylim(ax1, [1e-3 100]); xlabel(ax1, 'Frequenz in Hz'); ylabel(ax1, 'S_x in m/s^2');
title(ax1, 'Kanal 2, Hanning, Gesamtspektrum');
xlim(ax2, [85 115]); xlabel(ax2, 'Frequenz in Hz'); ylabel(ax2, 'S_x in m/s^2');
title(ax2, 'Ausschnitt um 100 Hz'); legend(ax2, leg, 'Location', 'northeast');
speichere_abb(fig, 'A3_aufloesung_sinus', P);
schreibe_tabelle('tab_aufloesung', zeilen, P);

%% (b) Benachbarte Resonanzen: Balkensensor bei unregelmaessiger Anregung
M = lade_messung('Unregelmaessig-Zeit.bin', P);
dfB = [0.25 1 4 16];
fig = neue_abb(16, 7);
ax = axes(fig); hold(ax, 'on'); set(ax, 'YScale', 'log');
leg = {};
for k = 1:numel(dfB)
    R = spektrum(M.x(:,1), M.fs, dfB(k), 'hanning');
    plot(ax, R.f, R.Gxx, 'Color', farben(k,:), 'LineWidth', 1.0 + 0.3*(k==4));
    leg{end+1} = sprintf('\\Delta f = %g Hz (T = %g s, %d Mittelungen)', R.df, R.T, R.nBloecke); %#ok<SAGROW>
end
xlim(ax, [0 250]); xlabel(ax, 'Frequenz in Hz'); ylabel(ax, 'G_{xx} in (m/s^2)^2/Hz');
title(ax, 'Kanal 1 (Balken), Messung Unregelmaessig-Zeit, Hanning, 2/3 Ueberlappung');
legend(ax, leg, 'Location', 'northeast');
speichere_abb(fig, 'A3_aufloesung_resonanzen', P);

%% (c) Spektrogramm bei veraenderlicher Anregungsfrequenz
M = lade_messung('Unregelmaessig-Frequenz.bin', P);
dfS = [0.5 4 16];
fig = neue_abb(16, 6.5);
tl  = tiledlayout(fig, 1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
for k = 1:numel(dfS)
    R = spektrum(M.x(:,2), M.fs, dfS(k), 'hanning', 0.9);
    nexttile(tl);
    imagesc(R.t, R.f, 10*log10(R.GxxB + 1e-12)); axis xy;
    ylim([0 80]); clim([-40 20]); colormap(turbo);
    title(sprintf('\\Delta f = %g Hz, T = %g s', R.df, R.T));
    xlabel('Zeit in s');
    if k == 1, ylabel('Frequenz in Hz'); end
end
cb = colorbar; cb.Layout.Tile = 'east'; cb.Label.String = 'G_{xx} in dB re 1 (m/s^2)^2/Hz';
speichere_abb(fig, 'A3_spektrogramm', P, 'image');
