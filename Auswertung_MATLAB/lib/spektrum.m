function R = spektrum(x, fs, df, fenstertyp, ueberlappung)
%SPEKTRUM  Gemitteltes Spektrum nach Versuchsunterlage (Folie "Praktische
%          Umsetzung in MATLAB"): Betragsspektrum Sx, Autoleistungsspektrum
%          Sxx und spektrale Leistungsdichte Gxx, berechnet mit spectrogram.
%
%   R = spektrum(x, fs, df, fenstertyp, ueberlappung)
%     x            Zeitsignal (Gleichanteil wird entfernt)
%     fs           Abtastrate in Hz
%     df           gewuenschte Frequenzaufloesung in Hz  (N = round(fs/df))
%     fenstertyp   'rechteck' | 'hanning' | 'flattop'
%     ueberlappung Anteil 0...1 (Standard 2/3)
%
%   Felder von R:
%     f, t              Frequenz- und Zeitachse (Blockmitten)
%     SxB, SxxB, GxxB   Spektrogramme (je Block eine Spalte)
%     Sx, Sxx, Gxx      linear gemittelte Spektren
%     N, T, df, FM, PM, Beff, O, nBloecke, w

if nargin < 5, ueberlappung = 2/3; end
x  = x(:) - mean(x);
N  = round(fs/df);                % Blocklaenge in Samples
w  = fenster(fenstertyp, N);
O  = min(ceil(ueberlappung * N), N-1);
if numel(x) < N
    error(['Signal (%d Werte, %.2f s) kürzer als Blocklänge N = %d (%.2f s): ' ...
           'Frequenzauflösung %g Hz zu fein für diese Messdauer.'], ...
           numel(x), numel(x)/fs, N, N/fs, df);
end

FM   = mean(w);                   % Fenstermittelwert
PM   = mean(w.^2);                % Leistungsmittelwert
Beff = enbw(w, fs);               % effektive Bandbreite in Hz = PM/(T*FM^2)

% s: Kurzzeit-FFT, GxxB: einseitige Leistungsdichte (Toolbox-Skalierung)
[s, f, t, GxxB] = spectrogram(x, w, O, N, fs, 'psd');

% Betragsspektrum: Amplitude eines Sinus wird korrekt wiedergegeben
SxB = 2*abs(s)/(N*FM);
SxB(1,:) = SxB(1,:)/2;            % Gleichanteil nicht verdoppeln
if mod(N,2) == 0, SxB(end,:) = SxB(end,:)/2; end   % Nyquist-Linie ebenso
SxxB = SxB.^2;                    % Autoleistungsspektrum (Amplitude^2)

R.f = f; R.t = t; R.s = s;
R.SxB = SxB; R.SxxB = SxxB; R.GxxB = GxxB;
R.Sx  = mean(SxB, 2);
R.Sxx = mean(SxxB, 2);
R.Gxx = mean(GxxB, 2);
R.N = N; R.T = N/fs; R.df = fs/N; R.FM = FM; R.PM = PM; R.Beff = Beff;
R.O = O; R.nBloecke = size(s,2); R.fenster = fenstertyp; R.w = w;
end
