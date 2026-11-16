function s = num(x, nk)
%NUM  Zahl als siunitx-Ausdruck \num{...}, gerundet auf nk signifikante
%     Stellen (ohne Exponentialdarstellung).
if nargin < 2, nk = 3; end
if x == 0
    v = 0;
else
    v = round(x, nk, 'significant');
end
s = ['\num{' num2str(v, 12) '}'];
end
