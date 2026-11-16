%% A5_Sensorposition - Einfluss der Sensorposition auf der Struktur
% Kanal 1: Beschleunigungssensor auf dem Balken
% Kanal 2: Beschleunigungssensor an der Krafteinleitung (Erregerposition)
% Kanal 3: Kraftsensor an der Krafteinleitung
% (a) Vergleich der Spektren beider Positionen bei periodischer Anregung
% (b) Uebertragungsfunktion H1 = G12/G11 (Einleitung -> Balken) mit
%     Kohaerenz aus den unregelmaessigen Anregungen
% (c) Kraftkanal

clear; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), 'lib'));
P = init_pfade();
fprintf('A5: Sensorposition\n');
blau = [0 0.32 0.62]; orange = [0.85 0.33 0]; grau = [0.45 0.45 0.45];

%% (a) Spektren an beiden Positionen bei periodischer Anregung
Ma = lade_messung('100Hz-1HZ-Flattop.bin', P);
Mb = lade_messung('4HZ-Rechteck.bin', P);
fig = neue_abb(16, 11);
tl  = tiledlayout(fig, 2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
zeilen = {};
punkte = [];                                   % [f, |H|] aus den Sinusmessungen
messungen = {Ma, 100:100:1500, 'Anregung 100 Hz (100Hz-1HZ-Flattop)'; ...
             Mb, [500 1000 1500], 'Anregung 500 Hz (4HZ-Rechteck)'};
for m = 1:2
    M = messungen{m,1};
    R1 = spektrum(M.x(:,1), M.fs, 1, 'flattop');   % Flattop: genaue Amplituden
    R2 = spektrum(M.x(:,2), M.fs, 1, 'flattop');
    nexttile(tl);
    semilogy(R2.f, R2.Sx, 'Color', orange); hold on;
    semilogy(R1.f, R1.Sx, 'Color', blau);
    xlim([0 1600]); ylim([1e-3 100]); ylabel('S_x in m/s^2');
    title(messungen{m,3});
    if m == 1, legend('Kanal 2: Einleitung', 'Kanal 1: Balken', 'Location', 'northeast'); end
    if m == 2, xlabel('Frequenz in Hz'); end
    for f0 = messungen{m,2}
        a1 = peakwert(R1.f, R1.Sx, f0, 2); a2 = peakwert(R2.f, R2.Sx, f0, 2);
        if a2 < 0.2, continue; end                 % nur deutliche Linien
        zeilen{end+1} = sprintf('%s & %s & %s & %s & %s & %s \\\\', ...
            strrep(messungen{m,3}(1:find(messungen{m,3}=='(')-2), 'Anregung ', ''), ...
            num(f0,4), num(a2,3), num(a1,3), num(a1/a2,3), num(20*log10(a1/a2),3)); %#ok<SAGROW>
        punkte(end+1,:) = [f0, a1/a2]; %#ok<SAGROW>
    end
end
speichere_abb(fig, 'A5_spektren_positionen', P);
schreibe_tabelle('tab_positionen', zeilen, P);

%% (b) Uebertragungsfunktion aus den unregelmaessigen Anregungen
Mz = lade_messung('Unregelmaessig-Zeit.bin', P);
Mf = lade_messung('Unregelmaessig-Frequenz.bin', P);
xe = [Mz.x(:,2); Mf.x(:,2)];               % Eingang:  Einleitung
xa = [Mz.x(:,1); Mf.x(:,1)];               % Ausgang:  Balken
U  = uebertragung(xe, xa, Mz.fs, 2, 'hanning');
R1 = spektrum(Mz.x(:,1), Mz.fs, 2, 'hanning');
R2 = spektrum(Mz.x(:,2), Mz.fs, 2, 'hanning');

fig = neue_abb(16, 15);
tl  = tiledlayout(fig, 3, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
nexttile(tl);
semilogy(R2.f, R2.Gxx, 'Color', orange); hold on;
semilogy(R1.f, R1.Gxx, 'Color', blau);
xlim([0 800]); ylabel('G_{xx} in (m/s^2)^2/Hz');
legend('Kanal 2: Einleitung', 'Kanal 1: Balken', 'Location', 'northeast');
title('Leistungsdichte an beiden Positionen (Unregelmaessig-Zeit, \Delta f = 2 Hz, Hanning)');
nexttile(tl);
semilogy(U.f, abs(U.H1), 'Color', grau); hold on;
semilogy(punkte(:,1), punkte(:,2), 'o', 'Color', orange, 'MarkerFaceColor', orange, 'MarkerSize', 5);
xlim([0 800]); ylim([1e-2 10]);
ylabel('|H_1| = |G_{21}/G_{22}|');
legend('aus unregelmaessiger Anregung', 'aus Sinusmessungen (Tabelle)', 'Location', 'northeast');
title('Uebertragungsfunktion Einleitung \rightarrow Balken');
nexttile(tl);
plot(U.f, U.koh, 'Color', grau);
xlim([0 800]); ylim([0 1.05]); ylabel('Kohaerenz \gamma^2'); xlabel('Frequenz in Hz');
speichere_abb(fig, 'A5_uebertragung', P);

% Resonanzstellen des Balkens aus |H1| (lokale Maxima mit guter Kohaerenz)
H = abs(U.H1); f = U.f;
istMax = H == movmax(H, 11);                  % Maximum innerhalb +/- 10 Hz
kand = find(istMax & f > 5 & f < 700 & H > 0.5);
zeilen = {};
for i = kand(:)'
    zeilen{end+1} = sprintf('%s & %s & %s \\\\', num(f(i),4), num(H(i),3), num(U.koh(i),3)); %#ok<SAGROW>
end
schreibe_tabelle('tab_resonanzen', zeilen, P);

%% (c) Kraftkanal
R3 = spektrum(Ma.x(:,3), Ma.fs, 1, 'flattop');
fid = fopen(fullfile(P.tab, 'wert_kraft.tex'), 'w');
fprintf(fid, '\\newcommand{\\KraftMittel}{%s}\n', num(mean(Ma.x(:,3))*1000, 3));
fprintf(fid, '\\newcommand{\\KraftEff}{%s}\n', num(rms(Ma.x(:,3)-mean(Ma.x(:,3)))*1000, 2));
fprintf(fid, '\\newcommand{\\KraftHundert}{%s}\n', num(peakwert(R3.f, R3.Sx, 100, 2)*1000, 2));
fclose(fid);
