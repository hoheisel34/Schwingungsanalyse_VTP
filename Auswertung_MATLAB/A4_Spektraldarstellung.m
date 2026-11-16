%% A4_Spektraldarstellung - Betragsspektrum Sx, Autoleistungsspektrum Sxx
%  und spektrale Leistungsdichte Gxx im Vergleich
% (a) periodisches Signal (100 Hz + Harmonische) bei verschiedenen df
% (b) breitbandiges Signal (unregelmaessige Anregung) bei verschiedenen df
% (c) Einfluss der Fensterfunktion auf Sx und Gxx
% (d) Energiebilanz (Parseval): Effektivwert aus Zeitsignal und Spektren

clear; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), 'lib'));
P = init_pfade();
fprintf('A4: Spektraldarstellung\n');
dfListe = [0.25 1 4];
farben  = [0 0.32 0.62; 0.85 0.33 0; 0.2 0.6 0.2];
typen   = {'rechteck', 'hanning', 'flattop'};
namen   = {'Rechteck', 'Hanning', 'Flattop'};

Ms = lade_messung('100Hz-1HZ-Flattop.bin', P);     % periodisch
Mb = lade_messung('Unregelmaessig-Zeit.bin', P);   % breitbandig
rauschband = [1350 1550];                          % Bereich ohne Harmonische

%% (a) + (b) Sx, Sxx, Gxx fuer beide Signalarten und drei Aufloesungen
fig = neue_abb(16, 17);
tl  = tiledlayout(fig, 3, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
groessen = {'Sx', 'Sxx', 'Gxx'};
ylab = {'S_x in m/s^2', 'S_{xx} in (m/s^2)^2', 'G_{xx} in (m/s^2)^2/Hz'};
zeilen = {};
for g = 1:3
    for s = 1:2
        ax = nexttile(tl, 2*(g-1)+s); hold(ax, 'on'); set(ax, 'YScale', 'log');
        if s == 1, M = Ms; else, M = Mb; end
        for k = numel(dfListe):-1:1            % feinste Aufloesung zuletzt (oben)
            R = spektrum(M.x(:,2), M.fs, dfListe(k), 'hanning');
            h(k) = plot(ax, R.f, R.(groessen{g}), 'Color', farben(k,:)); %#ok<SAGROW>
        end
        if g == 1 && s == 1, hLeg = h; end
        if s == 1
            xlim(ax, [0 1600]);
            if g == 1, title(ax, 'Periodisch (100 Hz + Harmonische)'); end
        else
            xlim(ax, [0 400]);
            if g == 1, title(ax, 'Breitbandig (Unregelmaessig-Zeit)'); end
        end
        ylabel(ax, ylab{g});
        if g == 3, xlabel(ax, 'Frequenz in Hz'); end
    end
end
lg = legend(hLeg, arrayfun(@(d) sprintf('\\Delta f = %g Hz', d), dfListe, 'UniformOutput', false), ...
    'Orientation', 'horizontal'); lg.Layout.Tile = 'north';
speichere_abb(fig, 'A4_sx_sxx_gxx', P);

% Kennwerte: Linie 100 Hz und Rauschboden (Median 1350...1550 Hz)
for k = 1:numel(dfListe)
    R = spektrum(Ms.x(:,2), Ms.fs, dfListe(k), 'hanning');
    b = R.f >= rauschband(1) & R.f <= rauschband(2);
    zeilen{end+1} = sprintf('%s & %s & %s & %s & %s & %s & %s \\\\', num(dfListe(k),3), ...
        num(peakwert(R.f, R.Sx, 100, 3),4), num(peakwert(R.f, R.Sxx, 100, 3),4), ...
        num(peakwert(R.f, R.Gxx, 100, 3),4), num(median(R.Sx(b)),3), ...
        num(median(R.Sxx(b)),3), num(median(R.Gxx(b)),3)); %#ok<SAGROW>
end
schreibe_tabelle('tab_spektren_df', zeilen, P);

%% (c) Fenstereinfluss auf Sx und Gxx (df = 1 Hz)
fig = neue_abb(16, 11);
tl  = tiledlayout(fig, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
zeilen = {};
for s = 1:2
    if s == 1, M = Ms; else, M = Mb; end
    axS = nexttile(tl, s);     hold(axS, 'on'); set(axS, 'YScale', 'log');
    axG = nexttile(tl, s + 2); hold(axG, 'on'); set(axG, 'YScale', 'log');
    for k = 1:3
        R = spektrum(M.x(:,2), M.fs, 1, typen{k});
        plot(axS, R.f, R.Sx, 'Color', farben(k,:));
        plot(axG, R.f, R.Gxx, 'Color', farben(k,:));
        if s == 1
            zeilen{end+1} = sprintf('%s & %s & %s & %s', namen{k}, num(R.Beff,3), ...
                num(peakwert(R.f, R.Sx, 100, 3),4), num(peakwert(R.f, R.Gxx, 100, 3),4)); %#ok<SAGROW>
        else
            b = R.f >= 10 & R.f <= 50;          % breitbandiger Bereich
            zeilen{k} = [zeilen{k} sprintf(' & %s & %s \\\\', num(mean(R.Sx(b)),3), num(mean(R.Gxx(b)),3))];
        end
    end
    if s == 1
        xlim(axS, [60 140]); xlim(axG, [60 140]);
        title(axS, 'Periodisch: Ausschnitt um 100 Hz');
    else
        xlim(axS, [0 100]); xlim(axG, [0 100]);
        title(axS, 'Breitbandig: 0 ... 100 Hz');
    end
    ylabel(axS, 'S_x in m/s^2'); ylabel(axG, 'G_{xx} in (m/s^2)^2/Hz');
    xlabel(axG, 'Frequenz in Hz');
end
legend(nexttile(tl, 1), namen, 'Location', 'northeast');
speichere_abb(fig, 'A4_fenster_sx_gxx', P);
schreibe_tabelle('tab_spektren_fenster', zeilen, P);

%% (d) Parseval: Effektivwert aus Zeitsignal und aus Spektren
% x_eff^2 = sum(Gxx)*df      (gilt unabhaengig von Fenster und df)
% sum(Sxx/2) ueberschaetzt die Leistung um den Faktor Beff/df
% (bei Sx und Sxx wird jede Linie als Sinus interpretiert, die Leistung
%  "verschmiert" aber durch das Fenster auf Beff/df Linien)
zeilen = {};
sig = {Ms, 'periodisch'; Mb, 'breitbandig'};
for s = 1:2
    M = sig{s,1}; x = M.x(:,2);
    xeff = rms(x - mean(x));
    for k = 1:3
        R = spektrum(x, M.fs, 1, typen{k});
        effG  = sqrt(sum(R.Gxx(2:end))*R.df);
        effSx = sqrt(sum(R.Sxx(2:end)/2));
        zeilen{end+1} = sprintf('%s & %s & %s & %s & %s \\\\', sig{s,2}, namen{k}, ...
            num(xeff,4), num(effG,4), num(effSx,4)); %#ok<SAGROW>
    end
end
schreibe_tabelle('tab_parseval', zeilen, P);
