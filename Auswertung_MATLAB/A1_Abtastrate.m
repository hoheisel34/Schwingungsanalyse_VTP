%% A1_Abtastrate - Einfluss der Abtastrate
% (a) Versuch 2: Sinus 500 Hz (mit Oberschwingungen) bei 3,2 / 12,8 / 51,2 kHz
% (b) Aliasing: Reduktion der 51,2-kHz-Messung auf 3,2 kHz ohne (downsample)
%     und mit Anti-Aliasing-Filter (resample) im Vergleich zur Messung, bei
%     der das Messsystem selbst filtert
% (c) Zeitsignal bei unterschiedlicher Abtastrate
% (d) Impulsmessung (Versuch 3): Spitzenwert und Impulsbreite bei
%     reduzierter Abtastrate, Frequenzinhalt oberhalb von 1,6 kHz

clear; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), 'lib'));
P = init_pfade();
fprintf('A1: Abtastrate\n');

%% (a) Gemessene Spektren bei drei Abtastraten
namen = {'V2_fs3200', 'V2_fs12800', 'V2_fs51200'};
Mref = lade_messung('V2_fs51200', P);
R0 = spektrum(Mref.aE, Mref.fs, 0.25, 'hanning');
[~, fpk] = peakwert(R0.f, R0.Sx, 500, 5);
b  = abs(R0.f - fpk) <= 1;                          % Grundfrequenz des Erregers als
f0 = sum(R0.f(b).*R0.Sxx(b)) / sum(R0.Sxx(b));      % Leistungsschwerpunkt der Linie
kH = 1:11; fH = kH*f0;                              % Harmonische bis 5,5 kHz
A  = nan(numel(kH), numel(namen));

fig = neue_abb(16, 13);
tl = tiledlayout(fig, numel(namen), 1, 'TileSpacing', 'compact', 'Padding', 'compact');
for m = 1:numel(namen)
    M = lade_messung(namen{m}, P);
    R = spektrum(M.aE, M.fs, 1, 'flattop');         % Flattop: genaue Amplituden
    for k = find(fH < M.fs/2)
        A(k, m) = peakwert(R.f, R.Sx, fH(k), 3);
    end
    nexttile(tl);
    semilogy(R.f, R.Sx, 'Color', P.farbe.blau); xlim([0 6000]); ylim([1e-4 50]);
    xline(M.fs/2, '--', sprintf('f_s/2 = %g Hz', M.fs/2), 'Color', P.farbe.orange, ...
          'LabelVerticalAlignment', 'bottom', 'FontSize', 8);
    title(sprintf('f_s = %g Hz (%s)', M.fs, M.id)); ylabel('S_x in m/s^2');
end
xlabel(tl, 'Frequenz in Hz', 'FontSize', 9);
speichere_abb(fig, 'A1_spektren_fs', P, 'image');

zeilen = {};
for k = kH
    zeilen{end+1} = sprintf('%d & %s & %s & %s & %s \\\\', k, num(fH(k),4), ...
        zelle(A(k,1)), zelle(A(k,2)), zelle(A(k,3))); %#ok<SAGROW>
end
schreibe_tabelle('tab_harmonische', zeilen, P);

%% (b) Aliasing: 51,2 kHz -> 3,2 kHz ohne und mit Anti-Aliasing-Filter
q   = 16; fsq = Mref.fs/q;
x   = Mref.aE - mean(Mref.aE);
xa  = downsample(x, q);                  % nur jeden q-ten Wert behalten: KEIN Filter
xf  = resample(x, 1, q);                 % mit Tiefpass (Kaiser-FIR) vor der Reduktion
M3  = lade_messung('V2_fs3200', P);      % Messsystem filtert selbst (Delta-Sigma-ADC)
Ra  = spektrum(xa,   fsq, 1, 'flattop');
Rf  = spektrum(xf,   fsq, 1, 'flattop');
Rm  = spektrum(M3.aE, M3.fs, 1, 'flattop');
fAlias = abs(fH - round(fH/fsq)*fsq);    % Lage der Harmonischen nach Faltung

fig = neue_abb(16, 13);
tl = tiledlayout(fig, 3, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
spek = {Ra, Rf, Rm};
titel = {sprintf('51,2 kHz \\rightarrow %g Hz ohne Anti-Aliasing-Filter (downsample)', fsq), ...
         sprintf('51,2 kHz \\rightarrow %g Hz mit Anti-Aliasing-Filter (resample)', fsq), ...
         sprintf('direkt mit f_s = %g Hz gemessen (%s)', M3.fs, M3.id)};
farben = {P.farbe.orange, P.farbe.gruen, P.farbe.blau};
for s = 1:3
    nexttile(tl);
    semilogy(spek{s}.f, spek{s}.Sx, 'Color', farben{s}); hold on;
    xline(fAlias(fH > fsq/2), ':', 'Color', P.farbe.grau);
    xlim([0 fsq/2]); ylim([1e-4 50]); ylabel('S_x in m/s^2'); title(titel{s});
end
xlabel(tl, 'Frequenz in Hz (gepunktet: Lage gefalteter Harmonischer)', 'FontSize', 9);
speichere_abb(fig, 'A1_aliasing', P);

zeilen = {};
for k = find(fH > fsq/2)
    zeilen{end+1} = sprintf('%d & %s & %s & %s & %s & %s & %s \\\\', k, num(fH(k),4), ...
        num(fAlias(k),4), num(A(k,3),2), num(peakwert(Ra.f, Ra.Sx, fAlias(k), 3),2), ...
        num(peakwert(Rf.f, Rf.Sx, fAlias(k), 3),2), num(peakwert(Rm.f, Rm.Sx, fAlias(k), 3),2)); %#ok<SAGROW>
end
schreibe_tabelle('tab_aliasing', zeilen, P);

%% (c) Zeitsignal: 51,2 kHz, jeder 16. Wert (3,2 kHz) und jeder 64. Wert (800 Hz)
fig = neue_abb(16, 6);
b = Mref.t >= 1 & Mref.t <= 1.02; ib = find(b);
plot(Mref.t(b)*1000, x(b), '-', 'Color', P.farbe.grau); hold on;
i16 = ib(mod(ib-1, 16) == 0); i64 = ib(mod(ib-1, 64) == 0);
plot(Mref.t(i16)*1000, x(i16), 'o-', 'Color', P.farbe.blau, 'MarkerSize', 4);
plot(Mref.t(i64)*1000, x(i64), 's-', 'Color', P.farbe.orange, 'LineWidth', 1.3);
xlabel('Zeit in ms'); ylabel('Einleitung in m/s^2');
legend(sprintf('f_s = 51200 Hz (%.0f Werte je Periode)', Mref.fs/f0), ...
       sprintf('f_s = 3200 Hz (%.1f Werte je Periode)', 3200/f0), ...
       sprintf('f_s = 800 Hz (Alias bei %.0f Hz)', abs(f0 - 800)), ...
       'Location', 'southoutside', 'Orientation', 'horizontal');
speichere_abb(fig, 'A1_aliasing_zeit', P);

%% (d) Impulsmessung bei unterschiedlichen Abtastraten (Kraftimpuls)
% Am Kraftsignal, da die Beschleunigungen hochfrequent (ca. 13 kHz) nachschwingen
% und dort keine sinnvolle Impulsbreite definiert ist.
fsListe = [51200 25600 12800 6400 3200];
impulse = {'V3_Einleitung', 'V3_Mitte'};
M  = lade_messung(impulse{1}, P);
xi = M.F - mean(M.F);
[~, i0] = max(abs(xi));

fig = neue_abb(16, 7.5);
farben = lines(numel(fsListe));
zeilen = {}; leg = {};
for k = 1:numel(fsListe)
    q   = M.fs/fsListe(k);
    idx = 1:q:M.n;                                  % festes Raster ab Messbeginn
    tq  = M.t(idx); xq = xi(idx);
    bz  = abs(tq - M.t(i0)) <= 1e-3;
    stairs(1000*(tq(bz)-M.t(i0)), xq(bz), 'Color', farben(k,:), 'LineWidth', 1.1); hold on;
    leg{end+1} = sprintf('f_s = %g Hz', fsListe(k)); %#ok<SAGROW>
    % Kennwerte: Spitzenwert, Impulsbreite (Dauer |x| >= 50 % des Spitzenwerts)
    xl = xq(bz);
    [pk, ip] = max(abs(xl));
    ueber = abs(xl) >= 0.5*pk;
    i1 = ip; while i1 > 1 && ueber(i1-1), i1 = i1-1; end
    i2 = ip; while i2 < numel(xl) && ueber(i2+1), i2 = i2+1; end
    nw = i2 - i1 + 1;
    zeilen{end+1} = sprintf('%s & %s & %s & %d & %s \\\\', num(fsListe(k),5), ...
        num(1e6/fsListe(k),3), num(pk,3), nw, num(nw/fsListe(k)*1000,3)); %#ok<SAGROW>
end
xlim([-0.6 0.8]);
xlabel('Zeit relativ zum Maximum in ms'); ylabel('Kraft in N');
title(sprintf('Kraftimpuls, %s (%s)', M.beschreibung, M.id));
legend(leg, 'Location', 'eastoutside');
speichere_abb(fig, 'A1_impuls', P);
schreibe_tabelle('tab_impuls', zeilen, P);

% Spitzenwertfehler in Abhaengigkeit der Lage des Abtastrasters
% (alle q moeglichen Startpunkte, beide Impulsmessungen, alle drei Kanaele)
signale = {};
for m = 1:numel(impulse)
    Mi = lade_messung(impulse{m}, P);
    signale = [signale, {Mi.F, Mi.aE, Mi.aB}]; %#ok<AGROW>
end
zeilen = {};
for k = 1:numel(fsListe)
    q = 51200/fsListe(k); fehler = [];
    for sig = signale
        s = sig{1} - mean(sig{1});
        [~, ip] = max(abs(s)); bereich = ip-200:ip+200; ref = max(abs(s(bereich)));
        for ph = 0:q-1
            ii = bereich(mod(bereich - 1 - ph, q) == 0);
            fehler(end+1) = 1 - max(abs(s(ii)))/ref; %#ok<SAGROW>
        end
    end
    zeilen{end+1} = sprintf('%s & %s & %s \\\\', num(fsListe(k),5), ...
        num(100*mean(fehler),2), num(100*max(fehler),2)); %#ok<SAGROW>
end
schreibe_tabelle('tab_impuls_streuung', zeilen, P);

% Frequenzinhalt des Impulses (0,5 s ab 10 ms vor dem Maximum, ein Block)
seg = xi(i0 - round(0.01*M.fs) + (0:round(0.5*M.fs)-1));
R0  = spektrum(seg, M.fs, 2, 'rechteck');
Ra  = spektrum(downsample(seg, 16), M.fs/16, 2, 'rechteck');
Rf  = spektrum(resample(seg, 1, 16), M.fs/16, 2, 'rechteck');
fig = neue_abb(16, 11);
tl = tiledlayout(fig, 2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
nexttile(tl);
loglog(R0.f, R0.Gxx, 'Color', P.farbe.blau);
xline(1600, '--', 'f_s/2 bei f_s = 3200 Hz', 'Color', P.farbe.orange, 'FontSize', 8);
xlim([2 25600]); ylabel('G_{xx} in N^2/Hz');
title(sprintf('Kraftimpuls, f_s = 51,2 kHz, \\Delta f = 2 Hz, Rechteck (%s)', M.id));
nexttile(tl);
semilogy(Ra.f, Ra.Gxx, 'Color', P.farbe.orange); hold on;
semilogy(R0.f, R0.Gxx, 'Color', P.farbe.blau);
semilogy(Rf.f, Rf.Gxx, 'Color', P.farbe.gruen);
xlim([0 1600]); xlabel('Frequenz in Hz'); ylabel('G_{xx} in N^2/Hz');
legend('f_s = 3,2 kHz ohne AA-Filter', 'f_s = 51,2 kHz (Referenz)', ...
       'f_s = 3,2 kHz mit AA-Filter', 'Location', 'southwest');
speichere_abb(fig, 'A1_spektrum_51k', P);

% Leistungsanteil oberhalb von 1600 Hz (Parseval ueber Gxx) und
% Leistungserhoehung im Band 0...1280 Hz durch Aliasing
anteil = sum(R0.Gxx(R0.f > 1600)) / sum(R0.Gxx(R0.f > 0));
band   = Ra.f > 0 & Ra.f < 1280;
erh    = sum(Ra.Gxx(band)) / sum(Rf.Gxx(band));
fid = fopen(fullfile(P.tab, 'wert_abtastrate.tex'), 'w');
fprintf(fid, '\\newcommand{\\GrundFrequenz}{%s}\n', num(f0, 4));
fprintf(fid, '\\newcommand{\\AnteilUeber}{%s}\n', num(100*anteil, 2));
fprintf(fid, '\\newcommand{\\AliasFaktor}{%s}\n', num(erh, 2));
fclose(fid);
fprintf('  Grundfrequenz %.2f Hz, Leistungsanteil > 1600 Hz: %.1f %%, Aliasing-Faktor %.2f\n', ...
        f0, 100*anteil, erh);

%% Hilfsfunktion
function s = zelle(a)
if isnan(a), s = '--'; else, s = num(a, 3); end
end
