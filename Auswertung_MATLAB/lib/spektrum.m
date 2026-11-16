function R = spektrum(x, fs, df, fenstertyp, ueberlappung)
%SPEKTRUM  Gemitteltes Spektrum nach Versuchsunterlage (Folie "Praktische
%          Umsetzung in MATLAB"): Betragsspektrum Sx, Autoleistungsspektrum
%          Sxx und spektrale Leistungsdichte Gxx.
%
%   R = spektrum(x, fs, df, fenstertyp, ueberlappung)
%     x            Zeitsignal (Gleichanteil wird entfernt)
%     fs           Abtastrate in Hz
%     df           gewuenschte Frequenzaufloesung in Hz  (N = ceil(fs/df))
%     fenstertyp   'rechteck' | 'hanning' | 'flattop'
%     ueberlappung Anteil 0...1 (Standard 2/3)
%
%   Felder von R:
%     f, t              Frequenz- und Zeitachse
%     SxB, SxxB, GxxB   Spektrogramme (je Block eine Spalte)
%     Sx, Sxx, Gxx      linear gemittelte Spektren
%     N, T, df, FM, PM, Beff, O, nBloecke

if nargin < 5, ueberlappung = 2/3; end
x  = x(:) - mean(x);
N  = ceil(fs/df - 1e-6);          % Linienzahl / Blocklaenge in Samples
w  = fenster(fenstertyp, N);
O  = ceil(ueberlappung * N);
if O >= N, O = N-1; end
FM = sum(w)/N;                    % Fenstermittelwert
PM = sum(w.^2)/N;                 % Leistungsmittelwert
T  = N/fs;                        % Blocklaenge in s
Beff = PM/(T*FM^2);               % effektive Bandbreite in Hz

[s, f, t] = stft(x, w, O, fs);

% Betragsspektrum (Amplitude eines Sinus wird korrekt wiedergegeben)
SxB = 2*abs(s/N)/FM;
SxB(1,:) = SxB(1,:)/2;            % Gleichanteil nicht verdoppeln
SxxB = SxB.^2;                    % Autoleistungsspektrum
GxxB = SxxB/2/Beff;               % PSD:  Gxx = (Sx/sqrt2)^2 / Beff
GxxB(1,:) = SxxB(1,:)/Beff;       % (identisch zu spectrogram(...,'psd'))

R.f = f; R.t = t; R.s = s;
R.SxB = SxB; R.SxxB = SxxB; R.GxxB = GxxB;
R.Sx  = mean(SxB, 2);
R.Sxx = mean(SxxB, 2);
R.Gxx = mean(GxxB, 2);
R.N = N; R.T = T; R.df = fs/N; R.FM = FM; R.PM = PM; R.Beff = Beff;
R.O = O; R.nBloecke = size(s,2); R.fenster = fenstertyp; R.w = w;
end
