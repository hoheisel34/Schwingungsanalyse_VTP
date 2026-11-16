%% A1_Abtastrate - Einfluss der Abtastrate
% (a) Aliasing: Reduktion der Abtastrate einer 500-Hz-Messung durch
%     Weglassen von Abtastwerten (ohne bzw. mit Anti-Aliasing-Filter)
% (b) Impulsmessung: Hammerschlag bei 51,2 kHz und reduzierten Abtastraten
% (c) Frequenzinhalt der 51,2-kHz-Messung oberhalb von 1,6 kHz

clear; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), 'lib'));
P = init_pfade();
fprintf('A1: Abtastrate\n');
blau = [0 0.32 0.62]; orange = [0.85 0.33 0]; gruen = [0.2 0.6 0.2];

%% (a) Aliasing an der 500-Hz-Sinusmessung
M = lade_messung('1HZ-Rechteck.bin', P);
b = M.t < 3.5;                     % nur stationaerer Teil (Anregung endet bei 3,6 s)
x = M.x(b,2);  fs0 = M.fs;

faktoren = [1 2 4];
fig = neue_abb(16, 14);
tl = tiledlayout(fig, numel(faktoren)+1, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
zeilen = {};
for k = 1:numel(faktoren)
    q   = faktoren(k); fsq = fs0/q;
    xq  = x(1:q:end);              % Abtastrate reduzieren, KEIN Filter
    R   = spektrum(xq, fsq, 1, 'hanning');
    nexttile(tl);
    semilogy(R.f, R.Sx, 'Color', blau); xlim([0 1600]); ylim([1e-3 50]);
    xline(fsq/2, '--', sprintf('f_s/2 = %g Hz', fsq/2), 'Color', orange, ...
          'LabelVerticalAlignment', 'bottom', 'FontSize', 8);
    title(sprintf('f_s = %g Hz, ohne Anti-Aliasing-Filter', fsq));
    ylabel('S_x in m/s^2');
    [A1, f1] = peakwert(R.f, R.Sx, 0, 2000);                 % groesste Linie
    S2 = R.Sx; S2(abs(R.f - f1) < 10) = 0; [A2, f2] = peakwert(R.f, S2, 0, 2000);
    zeilen{end+1} = sprintf('%s & %s & %s & %s & %s & %s \\\\', num(fsq,5), num(fsq/2,4), ...
        num(f1,4), num(A1,3), num(f2,4), num(A2,3)); %#ok<SAGROW>
end
% mit Anti-Aliasing-Filter (FIR-Tiefpass bei 0,8*fs_neu/2) vor der Reduktion
q = 4; fsq = fs0/q;
h  = tiefpass_fir(0.8*fsq/2, fs0, 400);
xq = filtern(h, x); xq = xq(1:q:end);
xq = xq(101:end-100);              % Filterrand entfernen
R  = spektrum(xq, fsq, 1, 'hanning');
nexttile(tl);
semilogy(R.f, R.Sx, 'Color', gruen); xlim([0 1600]); ylim([1e-3 50]);
xline(fsq/2, '--', sprintf('f_s/2 = %g Hz', fsq/2), 'Color', orange, ...
      'LabelVerticalAlignment', 'bottom', 'FontSize', 8);
title(sprintf('f_s = %g Hz, mit Anti-Aliasing-Filter (f_g = %g Hz)', fsq, 0.8*fsq/2));
ylabel('S_x in m/s^2'); xlabel('Frequenz in Hz');
speichere_abb(fig, 'A1_aliasing', P);
[A1, f1] = peakwert(R.f, R.Sx, 0, 2000);
zeilen{end+1} = sprintf('%s (AA-Filter) & %s & %s & %s & -- & -- \\\\', num(fsq,5), num(fsq/2,4), num(f1,4), num(A1,3));
schreibe_tabelle('tab_aliasing', zeilen, P);

% Zeitsignal-Ausschnitt: 500 Hz bei 3200 Hz und bei 800 Hz Abtastrate
fig = neue_abb(16, 6);
tt = M.t(b); bz = find(tt >= 1 & tt <= 1.02);
plot(tt(bz)*1000, x(bz), '.-', 'Color', blau, 'MarkerSize', 8); hold on;
i4 = bz(mod(bz-1, 4) == 0);
plot(tt(i4)*1000, x(i4), 'o-', 'Color', orange, 'LineWidth', 1.3);
xlabel('Zeit in ms'); ylabel('Einleitung in m/s^2');
legend('f_s = 3200 Hz (6,4 Werte je Periode)', 'f_s = 800 Hz (jeder 4. Wert)', ...
       'Location', 'southoutside', 'Orientation', 'horizontal');
speichere_abb(fig, 'A1_aliasing_zeit', P);

%% (b) Impulsmessung bei unterschiedlichen Abtastraten
M   = lade_messung('0,1Hz-Rechteck-Zeit.bin', P);
fs0 = M.fs;
x   = M.x(:,2);
% die drei Hammerschlaege finden (je Schlag das Betragsmaximum)
[~, ord] = sort(abs(x), 'descend');
schlaege = ord(1);
for k = 2:numel(ord)
    if all(abs(ord(k) - schlaege) > fs0), schlaege(end+1) = ord(k); end %#ok<SAGROW>
    if numel(schlaege) == 3, break; end
end
schlaege = sort(schlaege);
i0 = schlaege(abs(x(schlaege)) == max(abs(x(schlaege))));

fsListe = [51200 25600 12800 6400 3200];
fig = neue_abb(16, 7.5);
farben = lines(numel(fsListe));
zeilen = {}; leg = {};
for k = 1:numel(fsListe)
    q   = fs0/fsListe(k);
    idx = 1:q:M.n;                                  % festes Raster ab Messbeginn
    ti  = M.t(idx); xi = x(idx);
    bz  = abs(ti - M.t(i0)) <= 1e-3;
    stairs(1000*(ti(bz)-M.t(i0)), xi(bz), 'Color', farben(k,:), 'LineWidth', 1.1); hold on;
    leg{end+1} = sprintf('f_s = %g Hz', fsListe(k)); %#ok<SAGROW>
    % Kennwerte: Spitzenwert, Impulsbreite (Dauer |x| >= 50 % des Spitzenwerts)
    xl = xi(bz);
    [pk, ip] = max(abs(xl));
    ueber = abs(xl) >= 0.5*pk;
    i1 = ip; while i1 > 1 && ueber(i1-1), i1 = i1-1; end
    i2 = ip; while i2 < numel(xl) && ueber(i2+1), i2 = i2+1; end
    nw = i2 - i1 + 1;
    zeilen{end+1} = sprintf('%s & %s & %s & %d & %s \\\\', num(fsListe(k),5), ...
        num(1e6/fsListe(k),3), num(pk,3), nw, num(nw/fsListe(k)*1000,3)); %#ok<SAGROW>
end
xlim([-0.6 0.8]);
xlabel('Zeit relativ zum Maximum in ms'); ylabel('Einleitung in m/s^2');
legend(leg, 'Location', 'eastoutside');
speichere_abb(fig, 'A1_impuls', P);
schreibe_tabelle('tab_impuls', zeilen, P);

% Streuung des Spitzenwerts in Abhaengigkeit der Lage des Abtastrasters
% (alle q moeglichen Startpunkte, alle drei Hammerschlaege)
zeilen = {};
for k = 1:numel(fsListe)
    q = fs0/fsListe(k); fehler = [];
    for s = schlaege(:)'
        bereich = s-200:s+200; ref = max(abs(x(bereich)));
        for ph = 0:q-1
            ii = bereich(mod(bereich - 1 - ph, q) == 0);
            fehler(end+1) = 1 - max(abs(x(ii)))/ref; %#ok<SAGROW>
        end
    end
    zeilen{end+1} = sprintf('%s & %s & %s \\\\', num(fsListe(k),5), ...
        num(100*mean(fehler),2), num(100*max(fehler),2)); %#ok<SAGROW>
end
schreibe_tabelle('tab_impuls_streuung', zeilen, P);

%% (c) Frequenzinhalt der 51,2-kHz-Messung und Folgen fuer fs = 3200 Hz
R0 = spektrum(x, fs0, 4, 'hanning');
fig = neue_abb(16, 11);
tl = tiledlayout(fig, 2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
nexttile(tl);
loglog(R0.f, R0.Gxx, 'Color', blau);
xline(1600, '--', 'f_s/2 bei f_s = 3200 Hz', 'Color', orange, 'FontSize', 8);
xlim([4 25600]); ylabel('G_{xx} in (m/s^2)^2/Hz');
title('Kanal 2 (Einleitung), f_s = 51,2 kHz, \Delta f = 4 Hz, Hanning, 2/3 Ueberlappung');

q = 16; fsq = fs0/q;
xa = x(1:q:end);                                 % ohne Filter
h  = tiefpass_fir(0.8*fsq/2, fs0, 1600);
xf = filtern(h, x); xf = xf(1:q:end);            % mit Filter
Ra = spektrum(xa, fsq, 4, 'hanning');
Rf = spektrum(xf, fsq, 4, 'hanning');
nexttile(tl);
semilogy(Ra.f, Ra.Gxx, 'Color', orange); hold on;
semilogy(R0.f, R0.Gxx, 'Color', blau);
semilogy(Rf.f, Rf.Gxx, 'Color', gruen);
xlim([0 1600]); ylim([1e-9 1e-2]); xlabel('Frequenz in Hz'); ylabel('G_{xx} in (m/s^2)^2/Hz');
legend('f_s = 3,2 kHz ohne AA-Filter', 'f_s = 51,2 kHz (Referenz)', ...
       'f_s = 3,2 kHz mit AA-Filter', 'Location', 'southwest');
speichere_abb(fig, 'A1_spektrum_51k', P);

% Leistungsanteil oberhalb von 1600 Hz (Parseval ueber Gxx)
anteil = sum(R0.Gxx(R0.f > 1600)) / sum(R0.Gxx(R0.f > 0));
% Erhoehung der Leistung im Band 0..1600 Hz durch Aliasing
band = Ra.f > 0 & Ra.f < 1280;
erh  = sum(Ra.Gxx(band)) / sum(Rf.Gxx(band));
fid = fopen(fullfile(P.tab, 'wert_abtastrate.tex'), 'w');
fprintf(fid, '\\newcommand{\\AnteilUeber}{%s}\n', num(100*anteil, 2));
fprintf(fid, '\\newcommand{\\AliasFaktor}{%s}\n', num(erh, 2));
fclose(fid);
fprintf('  Leistungsanteil > 1600 Hz: %.1f %%, Leistungserhoehung durch Aliasing: Faktor %.1f\n', 100*anteil, erh);
