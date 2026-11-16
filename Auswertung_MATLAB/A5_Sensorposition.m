%% A5_Sensorposition - Einfluss der Sensorposition auf der Struktur
% Kanalbelegung laut Setup (meta.Setup): Kraftsensor an der Krafteinleitung,
% Beschleunigungssensor an der Einleitung und in Balkenmitte.
% (a) Amplituden an beiden Positionen bei Sinusanregung (Versuch 2, 51,2 kHz:
%     Grundschwingung und Harmonische bis 5,5 kHz)
% (b) Uebertragungsfunktionen und Kohaerenz aus dem verrauschten Signal
%     (Versuch 4) mit tfestimate/mscohere, Resonanzstellen mit findpeaks
% (c) Impulsversuch (Versuch 3): Inertanz a/F an beiden Positionen
% (d) Kennwerte des Kraftkanals

clear; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), 'lib'));
P = init_pfade();
fprintf('A5: Sensorposition\n');
c = P.farbe;

%% (a) Sinusanregung: Einleitung vs. Balkenmitte
M  = lade_messung('V2_fs51200', P);
RE = spektrum(M.aE, M.fs, 1, 'flattop');           % Flattop: genaue Amplituden
RB = spektrum(M.aB, M.fs, 1, 'flattop');
[~, f0] = peakwert(RE.f, RE.Sx, 500, 5);
fig = neue_abb(16, 7);
semilogy(RE.f, RE.Sx, 'Color', c.orange); hold on;
semilogy(RB.f, RB.Sx, 'Color', c.blau);
xlim([0 6000]); ylim([1e-4 50]); xlabel('Frequenz in Hz'); ylabel('S_x in m/s^2');
legend('Einleitung', 'Balkenmitte', 'Location', 'northeast');
title(sprintf('%s (%s), Flattop, \\Delta f = 1 Hz', M.beschreibung, M.id));
speichere_abb(fig, 'A5_spektren_positionen', P);

zeilen = {}; punkte = [];                          % [f, |aB/aE|] der Sinuslinien
for k = 1:11
    aE = peakwert(RE.f, RE.Sx, k*f0, 3); aB = peakwert(RB.f, RB.Sx, k*f0, 3);
    if aE < 0.05, continue; end                    % nur deutliche Linien
    zeilen{end+1} = sprintf('%d & %s & %s & %s & %s & %s \\\\', k, num(k*f0,4), ...
        num(aE,3), num(aB,3), num(aB/aE,3), num(20*log10(aB/aE),3)); %#ok<SAGROW>
    punkte(end+1,:) = [k*f0, aB/aE]; %#ok<SAGROW>
end
schreibe_tabelle('tab_positionen', zeilen, P);

%% (b) Uebertragungsfunktionen aus dem verrauschten Signal
M  = lade_messung('V4_Rauschen', P);
df = 2; N = round(M.fs/df); w = hann(N); O = round(2/3*N);
F  = detrend(M.F); aE = detrend(M.aE); aB = detrend(M.aB);
[HEF, f] = tfestimate(F,  aE, w, O, N, M.fs);      % Inertanz Einleitung
 HBF     = tfestimate(F,  aB, w, O, N, M.fs);      % Inertanz Balkenmitte
 HBE     = tfestimate(aE, aB, w, O, N, M.fs);      % Einleitung -> Balkenmitte
gEF = mscohere(F,  aE, w, O, N, M.fs);
gBF = mscohere(F,  aB, w, O, N, M.fs);
gBE = mscohere(aE, aB, w, O, N, M.fs);
fmax = 5000; b = f <= fmax;

fig = neue_abb(16, 17);
tl  = tiledlayout(fig, 3, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
nexttile(tl);
semilogy(f(b), abs(HEF(b)), 'Color', c.orange); hold on;
semilogy(f(b), abs(HBF(b)), 'Color', c.blau);
ylabel('|a / F| in (m/s^2)/N');
legend('Einleitung / Kraft', 'Balkenmitte / Kraft', 'Location', 'southeast');
title(sprintf('%s (%s), H_1-Schätzer, \\Delta f = %g Hz, Hanning, 2/3 Überlappung', ...
      M.beschreibung, M.id, df));
nexttile(tl);
semilogy(f(b), abs(HBE(b)), 'Color', c.grau); hold on;
semilogy(punkte(:,1), punkte(:,2), 'o', 'Color', c.orange, 'MarkerFaceColor', c.orange, 'MarkerSize', 5);
ylabel('|a_{Balken} / a_{Einleitung}|');
legend('aus verrauschtem Signal', 'aus Sinusmessung (Tabelle)', 'Location', 'southeast');
nexttile(tl);
plot(f(b), gEF(b), 'Color', c.orange); hold on;
plot(f(b), gBF(b), 'Color', c.blau);
plot(f(b), gBE(b), 'Color', c.grau);
ylim([0 1.05]); ylabel('Kohärenz \gamma^2'); xlabel('Frequenz in Hz');
legend('Einleitung / Kraft', 'Balkenmitte / Kraft', 'Balkenmitte / Einleitung', 'Location', 'southwest');
xlim(findobj(tl, 'Type', 'axes'), [0 fmax]);
speichere_abb(fig, 'A5_uebertragung', P);

% Resonanzstellen: Maxima von |a_Balken/F| mit guter Kohaerenz
bb = f > 20 & f < fmax;
[pk, lo] = findpeaks(abs(HBF(bb)), f(bb), 'MinPeakProminence', 0.3*median(abs(HBF(bb))), ...
                     'MinPeakDistance', 50, 'SortStr', 'descend', 'NPeaks', 12);
[lo, o] = sort(lo); pk = pk(o);
zeilen = {};
for i = 1:numel(lo)
    k = find(f == lo(i), 1);
    if gBF(k) < 0.8, continue; end
    zeilen{end+1} = sprintf('%s & %s & %s & %s \\\\', num(lo(i),4), num(pk(i),3), ...
        num(abs(HEF(k)),3), num(gBF(k),3)); %#ok<SAGROW>
end
schreibe_tabelle('tab_resonanzen', zeilen, P);

%% (c) Impulsversuch: Inertanz an beiden Positionen, ein Block ab dem Impuls
% Blocklaenge 0,25 s (df = 4 Hz) statt der im Protokoll eingestellten 4 s
% (df = 0,25 Hz): die Antwort ist nach ca. 50 ms abgeklungen, ein laengerer
% Block enthaelt nur zusaetzliches Rauschen (vgl. A3, Abbildung Resonanzen).
namen = {'V3_Einleitung', 'V3_Mitte'};
fig = neue_abb(16, 11);
tl  = tiledlayout(fig, 2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
for m = 1:2
    M = lade_messung(namen{m}, P);
    [~, i0] = max(abs(M.F - mean(M.F)));
    Ni = round(M.fs/4);
    ib = i0 - round(0.005*M.fs) + (0:Ni-1);
    [HE, fi] = tfestimate(M.F(ib) - mean(M.F), M.aE(ib) - mean(M.aE), rectwin(Ni), 0, Ni, M.fs);
     HB      = tfestimate(M.F(ib) - mean(M.F), M.aB(ib) - mean(M.aB), rectwin(Ni), 0, Ni, M.fs);
    nexttile(tl);
    bi = fi <= fmax;
    semilogy(fi(bi), abs(HE(bi)), 'Color', c.orange); hold on;
    semilogy(fi(bi), abs(HB(bi)), 'Color', c.blau);
    xlim([0 fmax]); ylabel('|a / F| in (m/s^2)/N');
    title(sprintf('%s (%s), Rechteckfenster, \\Delta f = %g Hz', M.beschreibung, M.id, M.fs/Ni));
    if m == 1, legend('Einleitung / Kraft', 'Balkenmitte / Kraft', 'Location', 'southeast'); end
end
xlabel(tl, 'Frequenz in Hz', 'FontSize', 9);
speichere_abb(fig, 'A5_impuls', P, 'image');

%% (d) Kraftkanal bei Sinusanregung
M  = lade_messung('V1_df1_F', P);
RF = spektrum(M.F, M.fs, 1, 'flattop');
fid = fopen(fullfile(P.tab, 'wert_kraft.tex'), 'w');
fprintf(fid, '\\newcommand{\\KraftMittel}{%s}\n', num(mean(M.F), 2));
fprintf(fid, '\\newcommand{\\KraftEff}{%s}\n', num(rms(M.F - mean(M.F)), 3));
fprintf(fid, '\\newcommand{\\KraftAmplitude}{%s}\n', num(peakwert(RF.f, RF.Sx, 500, 3), 3));
fclose(fid);
