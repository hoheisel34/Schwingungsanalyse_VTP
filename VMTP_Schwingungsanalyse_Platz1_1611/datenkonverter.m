% datei = '.\02_Daten\2026Nov02_T162110_binaer_Rechteck_025Hz_3200Abtastrate.bin'
datei = '.\02_Daten\2026Nov16_T154757_binaer.bin'

fileID = fopen(datei, 'r');
daten = (fread(fileID,[4 inf],'double'))';
fclose(fileID);

time1 = daten(:,1);
data1 = daten(:, 2:end);