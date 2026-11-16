%% A2_Fensterfunktion - Einfluss der Fensterfunktion
% (a) Eigenschaften der Fenster Rechteck, Hanning, Flattop
%     (Zeitverlauf, Spektrum, Fenstermittelwert, Leistungsmittelwert, Beff)
% (b) Anwendung auf die 500-Hz-Messung (Versuch 1): Fall A - Signalfrequenz
%     liegt genau auf einer Spektrallinie, Fall B - Signalfrequenz genau
%     zwischen zwei Linien (Leckeffekt)
% (c) Wirkung der Fensterung im Zeitbereich

clear; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), 'lib'));
P = init_pfade();
fprintf('A2: Fensterfunktion\n');
typen = {'rechteck', 'hanning', 'flattop'};
namen = {'Rechteck', 'Hanning', 'Flattop'};

%% (a) Fenstereigenschaften
N   = 3200;                                % entspricht fs = 3200 Hz, df = 1 Hz
zp  = 64;                                  % Zero-Padding-Faktor fuer glatten Verlauf
fig = neue_abb(16, 6.5);
tl  = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
ax1 = nexttile(tl); hold(ax1, 'on');
ax2 = nexttile(tl); hold(ax2, 'on');
zeilen = {};
for k = 1:3
    w  = fenster(typen{k}, N);
    FM = mean(w); PM = mean(w.^2);
    ENBW = enbw(w);                        % effektive Bandbreite in Linien (Beff*T)
    [W, fw] = freqz(w/sum(w), 1, zp*N, 'whole');
    bins = fw/(2*pi)*N; bins(bins > N/2) = bins(bins > N/2) - N;
    [bins, o] = sort(bins); W = abs(W(o));
    plot(ax1, (0:N-1)/N, w, 'Color', P.farben3(k,:), 'LineWidth', 1.2);
    plot(ax2, bins, 20*log10(W + 1e-12), 'Color', P.farben3(k,:));
    % maximaler Amplitudenfehler (Signal genau zwischen zwei Linien)
    scallop = 20*log10(interp1(bins, W, 0.5));
    % hoechste Nebenkeule: groesstes lokales Maximum ausserhalb der Hauptkeule
    b  = bins > 0 & bins < 20;
    [pk, lo] = findpeaks(W(b), bins(b));
    pk = pk(lo > 0.6);                     % Hauptkeule ausschliessen
    sl = 20*log10(max([pk; eps]));
    zeilen{end+1} = sprintf('%s & %s & %s & %s & %s & %s \\\\', namen{k}, num(FM,4), ...
        num(PM,4), num(ENBW,4), num(scallop,3), num(sl,3)); %#ok<SAGROW>
end
xlabel(ax1, 'normierte Zeit t/T'); ylabel(ax1, 'w(t)'); title(ax1, 'Fensterfunktionen');
xlabel(ax2, 'Frequenzabstand in Linien (\Delta f)'); ylabel(ax2, '|W(f)| in dB');
title(ax2, 'Spektrum der Fensterfunktionen'); xlim(ax2, [-10 10]); ylim(ax2, [-120 5]);
legend(ax1, namen, 'Location', 'south');
speichere_abb(fig, 'A2_fenster_eigenschaften', P);
schreibe_tabelle('tab_fenster', zeilen, P);

%% (b) Anwendung auf die Messung mit 500 Hz
M  = lade_messung('V1_df1_R', P);
x  = M.aE; fs = M.fs;
f1 = 500; f3 = 1500;                        % Grundschwingung und 3. Harmonische
% Fall B: N so, dass 500 Hz genau zwischen zwei Linien liegt (500/df = 167,5)
NB = round(fs*167.5/f1);
faelle = struct('N', {fs, NB}, ...
    'text', {sprintf('Fall A: N = %d, \\Delta f = %g Hz (500 Hz auf Linie)', fs, 1), ...
             sprintf('Fall B: N = %d, \\Delta f = %.3f Hz (500 Hz zw. Linien)', NB, fs/NB)});
fig = neue_abb(16, 13);
tl  = tiledlayout(fig, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
erg = zeros(3, 2, 2);                       % Fenster x Fall x [500 Hz, 1500 Hz]
for c = 1:2
    df = fs/faelle(c).N;
    axl = nexttile(tl, 2*c-1); hold(axl, 'on'); set(axl, 'YScale', 'log');
    axr = nexttile(tl, 2*c);   hold(axr, 'on');
    for k = 1:3
        R = spektrum(x, fs, df, typen{k});
        plot(axl, R.f, R.Sx, 'Color', P.farben3(k,:));
        plot(axr, R.f, R.Sx, '.-', 'Color', P.farben3(k,:), 'MarkerSize', 10);
        erg(k, c, 1) = peakwert(R.f, R.Sx, f1, 5);
        erg(k, c, 2) = peakwert(R.f, R.Sx, f3, 5);
    end
    xlim(axl, [0 1600]); ylim(axl, [1e-4 50]);
    ylabel(axl, 'S_x in m/s^2'); title(axl, faelle(c).text, 'FontSize', 8.5);
    xlim(axr, f1 + [-6 6]*df); ylim(axr, [0 1.2*max(erg(:,1,1))]);
    ylabel(axr, 'S_x in m/s^2'); title(axr, 'Ausschnitt um 500 Hz (Punkte = Linien)', 'FontSize', 8.5);
    if c == 2, xlabel(axl, 'Frequenz in Hz'); xlabel(axr, 'Frequenz in Hz'); end
end
legend(nexttile(tl, 2), namen, 'Location', 'northeast');
speichere_abb(fig, 'A2_fenster_messung', P);

% Tabelle: Amplituden der Linien 500 Hz und 1500 Hz, Bezug: Flattop Fall A
ref = squeeze(erg(3, 1, :));
zeilen = {};
for k = 1:3
    zeilen{end+1} = sprintf('%s & %s & %s & %s & %s & %s & %s \\\\', namen{k}, ...
        num(erg(k,1,1),4), num(erg(k,2,1),4), num(100*(erg(k,2,1)/ref(1)-1),2), ...
        num(erg(k,1,2),4), num(erg(k,2,2),4), num(100*(erg(k,2,2)/ref(2)-1),2)); %#ok<SAGROW>
end
schreibe_tabelle('tab_fenster_messung', zeilen, P);

%% (c) Wirkung der Fensterung im Zeitbereich (ein Block, Fall B)
xb = x(1:NB) - mean(x(1:NB)); tb = (0:NB-1)/fs;
fig = neue_abb(16, 6);
tl  = tiledlayout(fig, 1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
for k = 1:3
    nexttile(tl);
    w = fenster(typen{k}, NB);
    plot(tb*1000, xb.*w/mean(w), 'Color', P.farben3(k,:)); hold on;
    plot(tb*1000, max(abs(xb))*w/mean(w), 'k--', 'LineWidth', 0.8);
    title(namen{k}); xlabel('Zeit in ms'); xlim([0 tb(end)*1000]);
    if k == 1, ylabel('x(t) w(t) / FM in m/s^2'); end
end
speichere_abb(fig, 'A2_fenster_zeit', P);
