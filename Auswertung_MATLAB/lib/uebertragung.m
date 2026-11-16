function U = uebertragung(xe, xa, fs, df, fenstertyp, ueberlappung)
%UEBERTRAGUNG  Schaetzung der Uebertragungsfunktion H1(f) = Gea/Gee und der
%              Kohaerenz gamma^2 = |Gea|^2/(Gee*Gaa) mit gemittelten
%              Kreuz- und Autospektren.
%   xe  Eingang (Referenz), xa Ausgang (Antwort)

if nargin < 6, ueberlappung = 2/3; end
N = ceil(fs/df); w = fenster(fenstertyp, N); O = ceil(ueberlappung*N);
[E, f] = stft(xe(:)-mean(xe), w, O, fs);
A      = stft(xa(:)-mean(xa), w, O, fs);
Gee = mean(abs(E).^2, 2);
Gaa = mean(abs(A).^2, 2);
Gea = mean(conj(E).*A, 2);
U.f   = f;
U.H1  = Gea ./ Gee;
U.koh = abs(Gea).^2 ./ (Gee.*Gaa);
U.nBloecke = size(E,2);
end
