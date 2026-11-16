%% A4_Spektraldarstellung - Betragsspektrum Sx, Autoleistungsspektrum Sxx
%  und spektrale Leistungsdichte Gxx im Vergleich
% (a) periodisches Signal (Sinus 500 Hz, Versuch 1) bei verschiedenen df
% (b) breitbandiges Signal (verrauschtes Signal, Versuch 4) bei verschiedenen df
% (c) Einfluss der Fensterfunktion auf Sx und Gxx
% (d) Energiebilanz (Parseval): Effektivwert aus Zeitsignal und Spektren

clear; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), 'lib'));
P = init_pfade();
fprintf('A4: Spektraldarstellung\n');
dfListe = [0.25 1 4];
typen   = {'rechteck', 'hanning', 'flattop'};
namen   = {'Rechteck', 'Hanning', 'Flattop'};

Ms = lade_messung('V1_df1_R', P);       % periodisch, fs = 3200 Hz, T = 4,5 s
Mb = lade_messung('V4_Rauschen', P);    % breitbandig, fs = 51200 Hz, T = 31 s
rauschband = [1100 1400];               % Bereich ohne Harmonische (periodisch)
fGrenzeB   = 5000;                      % Darstellungsbereich breitbandig

%% (a) + (b) Sx, Sxx, Gxx fuer beide Signalarten und drei Aufloesungen
fig = neue_abb(16, 17);
tl  = tiledlayout(fig, 3, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
groessen = {'Sx', 'Sxx', 'Gxx'};
ylab = {'S_x in m/s^2', 'S_{xx} in (m/s^2)^2', 'G_{xx} in (m/s^2)^2/Hz'};
R = cell(2, numel(dfListe));
for k = 1:numel(dfListe)
    R{1,k} = spektrum(Ms.aE, Ms.fs, dfListe(k), 'hanning');
    R{2,k} = spektrum(Mb.aE, Mb.fs, dfListe(k), 'hanning');
end
h = gobjects(1, numel(dfListe));
for g = 1:3
    for s = 1:2
        ax = nexttile(tl, 2*(g-1)+s); hold(ax, 'on'); set(ax, 'YScale', 'log');
        for k = numel(dfListe):-1:1            % feinste Aufloesung zuletzt (oben)
            h(k) = plot(ax, R{s,k}.f, R{s,k}.(groessen{g}), 'Color', P.farben3(k,:));
        end
        if s == 1
            xlim(ax, [0 1600]);
            if g == 1, title(ax, 'Periodisch (Sinus 500 Hz)'); end
        else
            xlim(ax, [0 fGrenzeB]);
            if g == 1, title(ax, 'Breitbandig (verrauschtes Signal)'); end
        end
        ylabel(ax, ylab{g});
        if g == 3, xlabel(ax, 'Frequenz in Hz'); end
    end
end
lg = legend(h, arrayfun(@(d) sprintf('\\Delta f = %g Hz', d), dfListe, 'UniformOutput', false), ...
    'Orientation', 'horizontal'); lg.Layout.Tile = 'north';
speichere_abb(fig, 'A4_sx_sxx_gxx', P, 'image');

% Kennwerte: Linie 500 Hz und Rauschboden (Median im Rauschband)
zeilen = {};
for k = 1:numel(dfListe)
    r = R{1,k};
    b = r.f >= rauschband(1) & r.f <= rauschband(2);
    zeilen{end+1} = sprintf('%s & %s & %s & %s & %s & %s & %s \\\\', num(dfListe(k),3), ...
        num(peakwert(r.f, r.Sx, 500, 3),4), num(peakwert(r.f, r.Sxx, 500, 3),4), ...
        num(peakwert(r.f, r.Gxx, 500, 3),4), num(median(r.Sx(b)),3), ...
        num(median(r.Sxx(b)),3), num(median(r.Gxx(b)),3)); %#ok<SAGROW>
end
schreibe_tabelle('tab_spektren_df', zeilen, P);

%% (c) Fenstereinfluss auf Sx und Gxx (df = 1 Hz)
fig = neue_abb(16, 11);
tl  = tiledlayout(fig, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
zeilen = cell(1, 3);
for s = 1:2
    if s == 1, M = Ms; else, M = Mb; end
    axS = nexttile(tl, s);     hold(axS, 'on'); set(axS, 'YScale', 'log');
    axG = nexttile(tl, s + 2); hold(axG, 'on'); set(axG, 'YScale', 'log');
    for k = 1:3
        r = spektrum(M.aE, M.fs, 1, typen{k});
        plot(axS, r.f, r.Sx, 'Color', P.farben3(k,:));
        plot(axG, r.f, r.Gxx, 'Color', P.farben3(k,:));
        if s == 1
            zeilen{k} = sprintf('%s & %s & %s & %s', namen{k}, num(r.Beff,3), ...
                num(peakwert(r.f, r.Sx, 500, 3),4), num(peakwert(r.f, r.Gxx, 500, 3),4));
        else
            b = r.f >= 200 & r.f <= 1000;       % breitbandiger Bereich
            zeilen{k} = [zeilen{k} sprintf(' & %s & %s \\\\', num(mean(r.Sx(b)),3), num(mean(r.Gxx(b)),3))];
        end
    end
    if s == 1
        xlim(axS, [460 540]); xlim(axG, [460 540]);
        title(axS, 'Periodisch: Ausschnitt um 500 Hz');
    else
        xlim(axS, [0 2000]); xlim(axG, [0 2000]);
        title(axS, 'Breitbandig: 0 ... 2000 Hz');
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
    M = sig{s,1}; x = M.aE;
    xeff = rms(x - mean(x));
    for k = 1:3
        r = spektrum(x, M.fs, 1, typen{k});
        effG  = sqrt(sum(r.Gxx(2:end))*r.df);
        effSx = sqrt(sum(r.Sxx(2:end)/2));
        zeilen{end+1} = sprintf('%s & %s & %s & %s & %s \\\\', sig{s,2}, namen{k}, ...
            num(xeff,4), num(effG,4), num(effSx,4)); %#ok<SAGROW>
    end
end
schreibe_tabelle('tab_parseval', zeilen, P);
