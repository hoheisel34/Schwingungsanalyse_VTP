%% A3_Frequenzaufloesung - Einfluss der Frequenzaufloesung (Linienabstand)
% (a) Sinus 500 Hz (Versuch 1, Messungen mit 0,25 / 1 / 4 Hz): Linienbreite,
%     Amplitude, Anzahl Mittelungen
% (b) Trennung von Resonanzen: Uebertragungsfunktion aus dem Impulsversuch
%     (Versuch 3) bei unterschiedlicher Blocklaenge
% (c) Zeit-Frequenz-Unschaerfe im Spektrogramm (Versuch 4)

clear; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), 'lib'));
P = init_pfade();
fprintf('A3: Frequenzauflösung\n');
farben = [P.farben3; P.farbe.grau];

%% (a) Sinus 500 Hz, Hanning, jeweils die Messung zur eingestellten Aufloesung
messungen = {'V1_df0p25_3', 0.25; 'V1_df1_H', 1; 'V1_df4_H', 4};
fig = neue_abb(16, 6.5);
tl  = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
ax1 = nexttile(tl); hold(ax1, 'on'); set(ax1, 'YScale', 'log');
ax2 = nexttile(tl); hold(ax2, 'on');
zeilen = {}; leg = {};
for k = 1:size(messungen, 1)
    M = lade_messung(messungen{k,1}, P);
    R = spektrum(M.aE, M.fs, messungen{k,2}, 'hanning');
    plot(ax1, R.f, R.Sx, 'Color', farben(k,:));
    plot(ax2, R.f, R.Sx, '.-', 'Color', farben(k,:), 'MarkerSize', 9);
    leg{end+1} = sprintf('\\Delta f = %g Hz', R.df); %#ok<SAGROW>
    zeilen{end+1} = sprintf('%s & \\texttt{%s} & %s & %d & %s & %d & %s & %s \\\\', ...
        num(R.df,3), M.id, num(M.T,2), R.N, num(R.T,3), R.nBloecke, num(R.Beff,3), ...
        num(peakwert(R.f, R.Sx, 500, 3),4)); %#ok<SAGROW>
end
xlim(ax1, [0 1600]); ylim(ax1, [1e-4 50]); xlabel(ax1, 'Frequenz in Hz'); ylabel(ax1, 'S_x in m/s^2');
title(ax1, 'Einleitung, Hanning, Gesamtspektrum');
xlim(ax2, [485 515]); xlabel(ax2, 'Frequenz in Hz'); ylabel(ax2, 'S_x in m/s^2');
title(ax2, 'Ausschnitt um 500 Hz'); legend(ax2, leg, 'Location', 'northeast');
speichere_abb(fig, 'A3_aufloesung_sinus', P);
schreibe_tabelle('tab_aufloesung', zeilen, P);

%% (b) Resonanzen: |H| = |a_Balken / F| aus einem Block ab dem Kraftimpuls
M  = lade_messung('V3_Mitte', P);
[~, i0] = max(abs(M.F - mean(M.F)));
i0 = i0 - round(0.005*M.fs);                 % Block beginnt 5 ms vor dem Impuls
% Lange Bloecke loesen feiner auf, enthalten nach dem Abklingen (ca. 50 ms)
% aber fast nur noch Rauschen -> Zielkonflikt Aufloesung / Stoerabstand.
dfB = [0.25 1 4 16];
fig = neue_abb(16, 11);
tl  = tiledlayout(fig, 2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
ax1 = nexttile(tl); hold(ax1, 'on'); set(ax1, 'YScale', 'log');
ax2 = nexttile(tl); hold(ax2, 'on'); set(ax2, 'YScale', 'log');
leg = {};
for k = 1:numel(dfB)
    N  = round(M.fs/dfB(k));
    ib = i0 + (0:N-1);
    [H, f] = tfestimate(M.F(ib) - mean(M.F), M.aB(ib) - mean(M.aB), rectwin(N), 0, N, M.fs);
    b = f <= 2000;
    plot(ax1, f(b), abs(H(b)), 'Color', farben(k,:), 'LineWidth', 1.0 + 0.3*(k==4));
    plot(ax2, f(b), abs(H(b)), '.-', 'Color', farben(k,:), 'MarkerSize', 6, 'LineWidth', 1.0 + 0.3*(k==4));
    leg{end+1} = sprintf('\\Delta f = %g Hz (T = %g s)', dfB(k), N/M.fs); %#ok<SAGROW>
end
xlim(ax1, [0 2000]); ylabel(ax1, '|a_{Balken} / F| in (m/s^2)/N');
title(ax1, sprintf('%s (%s), Rechteckfenster, ein Block ab 5 ms vor dem Impuls', M.beschreibung, M.id));
xlim(ax2, [450 650]); ylabel(ax2, '|a_{Balken} / F| in (m/s^2)/N');
xlabel(ax2, 'Frequenz in Hz'); title(ax2, 'Ausschnitt 450 ... 650 Hz');
legend(ax1, leg, 'Location', 'northeast');
speichere_abb(fig, 'A3_aufloesung_resonanzen', P, 'image');

%% (c) Spektrogramm des verrauschten Signals bei drei Aufloesungen
M = lade_messung('V4_Rauschen', P);
dfS = [0.5 4 32];
fig = neue_abb(16, 6.5);
tl  = tiledlayout(fig, 1, numel(dfS), 'TileSpacing', 'compact', 'Padding', 'compact');
R = cell(size(dfS)); Lmax = -Inf;
for k = 1:numel(dfS)
    R{k} = spektrum(M.aE, M.fs, dfS(k), 'hanning', 0.9);
    Lmax = max(Lmax, 10*log10(max(R{k}.GxxB(R{k}.f < 3000, :), [], 'all')));
end
for k = 1:numel(dfS)
    nexttile(tl);
    imagesc(R{k}.t, R{k}.f, 10*log10(R{k}.GxxB + 1e-12)); axis xy;
    ylim([0 3000]); clim(Lmax + [-50 0]); colormap(turbo);
    title(sprintf('\\Delta f = %g Hz, T = %g s', R{k}.df, R{k}.T));
    xlabel('Zeit in s');
    if k == 1, ylabel('Frequenz in Hz'); end
end
cb = colorbar; cb.Layout.Tile = 'east'; cb.Label.String = 'G_{xx} in dB re 1 (m/s^2)^2/Hz';
speichere_abb(fig, 'A3_spektrogramm', P, 'image');
