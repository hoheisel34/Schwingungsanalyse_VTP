function y = filtern(h, x)
%FILTERN  Nullphasige Filterung mit symmetrischem FIR-Filter h.
y = conv(x(:), h(:), 'same');
end
