%% A2_Fensterfunktion - Einfluss der Fensterfunktion
% (a) Eigenschaften der Fenster Rechteck, Hanning, Flattop
%     (Zeitverlauf, Spektrum, Fenstermittelwert, Leistungsmittelwert, Beff)
% (b) Anwendung auf die 100-Hz-Messung: Fall A - Signalfrequenz liegt genau
%     auf einer Spektrallinie, Fall B - Signalfrequenz genau zwischen zwei
%     Linien (ungeradzahlige Periodenanzahl im Block -> Leckeffekt)

clear; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), 'lib'));
P = init_pfade();
fprintf('A2: Fensterfunktion\n');
typen  = {'rechteck', 'hanning', 'flattop'};
namen  = {'Rechteck', 'Hanning', 'Flattop'};
farben = [0 0.32 0.62; 0.85 0.33 0; 0.2 0.6 0.2];

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
    ENBW = PM/FM^2;                        % effektive Bandbreite in Linien (Beff*T)
    W  = abs(fft(w, zp*N)); W = W/W(1);
    bins = (0:zp*N-1)/zp; bins(bins > N/2) = bins(bins > N/2) - N;
    [bins, o] = sort(bins); WdB = 20*log10(W(o) + 1e-12);
    plot(ax1, (0:N-1)/N, w, 'Color', farben(k,:), 'LineWidth', 1.2);
    plot(ax2, bins, WdB, 'Color', farben(k,:), 'LineWidth', 1.0);
    % maximaler Amplitudenfehler (Signal genau zwischen zwei Linien)
    scallop = 20*log10(W(1 + zp/2));
    % hoechste Nebenkeule: erstes lokales Maximum ausserhalb der Hauptkeule
    Wp = W(1:zp*20); d = diff(Wp); im = find(d(1:end-1) < 0 & d(2:end) >= 0, 1);
    sl = 20*log10(max(Wp(im+1:end)));
    zeilen{end+1} = sprintf('%s & %s & %s & %s & %s & %s \\\\', namen{k}, num(FM,4), ...
        num(PM,4), num(ENBW,4), num(scallop,3), num(sl,3)); %#ok<SAGROW>
end
xlabel(ax1, 'normierte Zeit t/T'); ylabel(ax1, 'w(t)'); title(ax1, 'Fensterfunktionen');
xlabel(ax2, 'Frequenzabstand in Linien (\Delta f)'); ylabel(ax2, '|W(f)| in dB');
title(ax2, 'Spektrum der Fensterfunktionen'); xlim(ax2, [-10 10]); ylim(ax2, [-120 5]);
legend(ax1, namen, 'Location', 'south');
speichere_abb(fig, 'A2_fenster_eigenschaften', P);
schreibe_tabelle('tab_fenster', zeilen, P);

%% (b) Anwendung auf die Messung mit 100 Hz Grundfrequenz
M  = lade_messung('100Hz-1HZ-Flattop.bin', P);
x  = M.x(:,2); fs = M.fs;
faelle = struct('N', {3200, 1072}, ...
    'text', {'Fall A: N = 3200, \Delta f = 1 Hz (100 Hz auf Linie)', ...
             'Fall B: N = 1072, \Delta f = 2,985 Hz (100 Hz zw. Linien)'});
fig = neue_abb(16, 13);
tl  = tiledlayout(fig, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
erg = zeros(3, 2, 2);                       % Fenster x Fall x [100 Hz, 300 Hz]
for c = 1:2
    df = fs/faelle(c).N;
    axl = nexttile(tl, 2*c-1); hold(axl, 'on'); set(axl, 'YScale', 'log');
    axr = nexttile(tl, 2*c);   hold(axr, 'on');
    for k = 1:3
        R = spektrum(x, fs, df, typen{k});
        plot(axl, R.f, R.Sx, 'Color', farben(k,:));
        plot(axr, R.f, R.Sx, '.-', 'Color', farben(k,:), 'MarkerSize', 10);
        erg(k, c, 1) = peakwert(R.f, R.Sx, 100, 5);
        erg(k, c, 2) = peakwert(R.f, R.Sx, 300, 5);
    end
    xlim(axl, [0 800]); ylim(axl, [1e-3 100]);
    ylabel(axl, 'S_x in m/s^2'); title(axl, faelle(c).text, 'FontSize', 8.5);
    xlim(axr, [100-6*df 100+6*df]); ylim(axr, [0 45]);
    ylabel(axr, 'S_x in m/s^2'); title(axr, 'Ausschnitt um 100 Hz (Punkte = Linien)', 'FontSize', 8.5);
    if c == 2, xlabel(axl, 'Frequenz in Hz'); xlabel(axr, 'Frequenz in Hz'); end
end
legend(nexttile(tl, 2), namen, 'Location', 'northeast');
speichere_abb(fig, 'A2_fenster_messung', P);

% Tabelle: Amplituden der Linien 100 Hz und 300 Hz, Bezug: Rechteck Fall A
ref = squeeze(erg(1, 1, :));
zeilen = {};
for k = 1:3
    zeilen{end+1} = sprintf('%s & %s & %s & %s & %s & %s & %s \\\\', namen{k}, ...
        num(erg(k,1,1),4), num(erg(k,2,1),4), num(100*(erg(k,2,1)/ref(1)-1),2), ...
        num(erg(k,1,2),4), num(erg(k,2,2),4), num(100*(erg(k,2,2)/ref(2)-1),2)); %#ok<SAGROW>
end
schreibe_tabelle('tab_fenster_messung', zeilen, P);

%% (c) Wirkung der Fensterung im Zeitbereich (ein Block, Fall B)
Nb = 1072; xb = x(1:Nb) - mean(x(1:Nb)); tb = (0:Nb-1)/fs;
fig = neue_abb(16, 6);
tl  = tiledlayout(fig, 1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
for k = 1:3
    nexttile(tl);
    w = fenster(typen{k}, Nb);
    plot(tb*1000, xb.*w/mean(w), 'Color', farben(k,:)); hold on;
    plot(tb*1000, max(abs(xb))*w/mean(w), 'k--', 'LineWidth', 0.8);
    title(namen{k}); xlabel('Zeit in ms'); xlim([0 tb(end)*1000]);
    if k == 1, ylabel('x(t) w(t) / FM in m/s^2'); end
end
speichere_abb(fig, 'A2_fenster_zeit', P);
