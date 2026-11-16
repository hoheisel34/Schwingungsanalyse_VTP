function K = messkatalog(P)
%MESSKATALOG  Verzeichnis aller Messungen mit Kurzname und Gueltigkeitspruefung.
%   K = messkatalog(P) liefert eine Tabelle mit einer Zeile je Messdatei:
%     id, kurz, versuch, df_soll, beschreibung, fs, T, n, gueltig, grund
%
%   Die Zuordnung Zeitstempel -> Kurzname/Beschreibung stammt aus dem
%   Messprotokoll (Felder VB01/VB02 der *_meta.mat). Die Gueltigkeit wird
%   automatisch geprueft; eine Messung ist UNGUELTIG, wenn
%     1. keine Versuchsbeschreibung eingetragen ist (Testmessung),
%     2. die Messdauer kuerzer ist als ein Block T = 1/df der im Protokoll
%        geforderten Frequenzaufloesung (es entsteht kein einziges Spektrum),
%     3. sie im Protokoll durch eine spaetere Wiederholung "... V2 (korrekt)"
%        desselben Versuchs ersetzt wurde,
%     4. ein Kanal uebersteuert ist (Maximalwert ueber mehrere Abtastwerte
%        konstant abgeschnitten).
%   Ungueltige Messungen werden von lade_messung nur auf ausdruecklichen
%   Wunsch geladen und in A0 in einer eigenen Tabelle aufgefuehrt.

persistent cache cacheOrdner
if ~isempty(cache) && strcmp(cacheOrdner, P.daten)
    K = cache; return
end

%  Zeitstempel   Kurzname        Versuch  df_soll  Beschreibung
liste = {
  'T154757', 'Test',            0, NaN,  'Sinus 500 Hz (ohne Protokolleintrag)'
  'T155632', 'V1_df0p25_1',     1, 0.25, 'Sinus 500 Hz, Auflösung 0,25 Hz'
  'T155705', 'V1_df0p25_2',     1, 0.25, 'Sinus 500 Hz, Auflösung 0,25 Hz'
  'T155711', 'V1_df0p25_3',     1, 0.25, 'Sinus 500 Hz, Auflösung 0,25 Hz'
  'T155721', 'V1_df0p25_4',     1, 0.25, 'Sinus 500 Hz, Auflösung 0,25 Hz'
  'T155748', 'V1_df1_R',        1, 1,    'Sinus 500 Hz, Auflösung 1 Hz, Rechteck'
  'T155809', 'V1_df1_H',        1, 1,    'Sinus 500 Hz, Auflösung 1 Hz, Hanning'
  'T155821', 'V1_df1_F',        1, 1,    'Sinus 500 Hz, Auflösung 1 Hz, Flattop'
  'T155840', 'V1_df4_R',        1, 4,    'Sinus 500 Hz, Auflösung 4 Hz, Rechteck'
  'T155850', 'V1_df4_H',        1, 4,    'Sinus 500 Hz, Auflösung 4 Hz, Hanning'
  'T155901', 'V1_df4_F',        1, 4,    'Sinus 500 Hz, Auflösung 4 Hz, Flattop'
  'T160431', 'V2_fs3200',       2, 1,    'Sinus 500 Hz, Abtastrate 3200 Hz'
  'T160445', 'V2_fs12800',      2, 1,    'Sinus 500 Hz, Abtastrate 12800 Hz'
  'T160501', 'V2_fs51200',      2, 1,    'Sinus 500 Hz, Abtastrate 51200 Hz'
  'T161058', 'V3_Einl_alt',     3, 0.25, 'Impuls, Balken-Einleitung (1. Versuch)'
  'T161127', 'V3_Mitte_alt',    3, 0.25, 'Impuls, Balken-Mitte (1. Versuch)'
  'T161233', 'V3_Einleitung',   3, 0.25, 'Impuls, Balken-Einleitung'
  'T161303', 'V3_Mitte',        3, 0.25, 'Impuls, Balken-Mitte'
  'T162024', 'V4_Rauschen',     4, 1,    'Verrauschtes Signal (Stoßfolge)'
};

dateien = dir(fullfile(P.daten, '*_binaer.bin'));
nD = numel(dateien);
id = cell(nD,1); kurz = id; beschreibung = id; grund = id; vb02 = id;
versuch = zeros(nD,1); df_soll = nan(nD,1); fs = versuch; T = versuch; n = versuch;

for i = 1:nD
    stamm  = erase(dateien(i).name, '_binaer.bin');
    id{i}  = char(regexp(stamm, 'T\d{6}$', 'match', 'once'));
    meta   = load(fullfile(P.daten, [stamm '_meta.mat'])).meta;
    vb02{i} = strtrim(meta.VB02);

    k = find(strcmp(liste(:,1), id{i}));
    if isempty(k)        % neue, noch nicht eingetragene Messung
        kurz{i} = id{i}; beschreibung{i} = strtrim([meta.VB01 ' ' meta.VB02]);
        versuch(i) = str2double(regexp(meta.VB01, '(?<=Versuch Nr\. )\d+', 'match', 'once'));
        warning('Messung %s ist nicht im Messkatalog eingetragen.', id{i});
    else
        [kurz{i}, versuch(i), df_soll(i), beschreibung{i}] = liste{k, 2:5};
    end

    daten = lese_bin(fullfile(P.daten, dateien(i).name));
    n(i)  = size(daten, 1);
    fs(i) = round(1/median(diff(daten(:,1))));
    T(i)  = n(i)/fs(i);
    gruende = {};

    % 1. Testmessung ohne Protokolleintrag
    if isempty(strtrim(meta.VB01)) && isempty(vb02{i})
        gruende{end+1} = 'Testmessung ohne Versuchsbeschreibung'; %#ok<AGROW>
    end
    % 2. Messdauer kuerzer als ein Block der geforderten Aufloesung
    if T(i) < 1/df_soll(i) - 1e-9
        gruende{end+1} = sprintf(['Messdauer %s s kürzer als Blocklänge %s s ' ...
            '(Auflösung %s Hz): kein vollständiger Block'], komma(T(i)), ...
            komma(1/df_soll(i)), komma(df_soll(i))); %#ok<AGROW>
    end
    % 4. Uebersteuerung: Extremwert ueber >= 3 aufeinanderfolgende Werte konstant
    for c = 2:size(daten,2)
        x = daten(:,c);
        for ext = [max(x) min(x)]
            if max(laengster_lauf(x == ext)) >= 3
                gruende{end+1} = sprintf('Kanal %d übersteuert', c-1); %#ok<AGROW>
                break
            end
        end
    end
    grund{i} = strjoin(gruende, '; ');
end

% 3. durch spaetere Wiederholung "<Bezeichnung> V2 (korrekt)" ersetzt
for j = 1:nD
    if ~contains(vb02{j}, 'korrekt', 'IgnoreCase', true), continue; end
    basis = strtrim(regexprep(vb02{j}, '\s*V\d+\s*\(korrekt\)', '', 'ignorecase'));
    alt = find(versuch == versuch(j) & strcmpi(vb02, basis) & (1:nD)' ~= j);
    for i = alt(:)'
        txt = sprintf('fehlerhaft, durch Wiederholung %s ersetzt', id{j});
        grund{i} = strjoin([grund(i), {txt}], '; ');
        grund{i} = regexprep(grund{i}, '^; ', '');
    end
end
gueltig = cellfun(@isempty, grund);

K = table(id, kurz, versuch, df_soll, beschreibung, fs, T, n, gueltig, grund, ...
          'RowNames', kurz);
K.datei = {dateien.name}';
cache = K; cacheOrdner = P.daten;
end

% -------------------------------------------------------------------------
function daten = lese_bin(datei)
fid = fopen(datei, 'r');
if fid < 0, error('Datei %s nicht lesbar.', datei); end
daten = fread(fid, [4 inf], 'double')';
fclose(fid);
end

function L = laengster_lauf(b)
% Laenge der zusammenhaengenden true-Folgen eines logischen Vektors
d = diff([0; b(:); 0]);
L = find(d == -1) - find(d == 1);
if isempty(L), L = 0; end
end

function s = komma(x)
s = strrep(num2str(x), '.', ',');
end
