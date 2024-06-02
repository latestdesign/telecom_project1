%% Projet Télécommunications/Traitement du signal
% Étude d'une chaine de transmission sur porteuse pour une transmission
% satellite fixe

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PARAMS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Fe = 6000; % fréquence d'échantillonnage en Hz
fp = 2000; % fréquence porteuse en Hz
Te = 1/Fe; % période d'échantillonnage
Rb = 3000; % débit binaire en bits par seconde
Tb = 1/Rb; % période par bit
N = 1000; % nombre de bits total
beta = 0.35; % paramètre de roll-off du filtre en racine de cosinus surélevé
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 2 - Transmission avec transposition de fréquence (pbEquivalent = false)
%% 3 - Chaîne passe-bas équivalente (pbEquivalent = true)
n = 2;
SNRB = 4;
pbEquivalent = true;
ASK = false;
[~, s, s_transp, symboles, s_sample, nb_symb, Ns] = chaine_transmission(n, SNRB, N, Fe, fp, Rb, pbEquivalent, ASK, beta);

%% 1) Signaux générés en quadrature de phase
figure;
plot(0:Te:(nb_symb*Ns-1)*Te, real(s));
hold on;
plot(0:Te:(nb_symb*Ns-1)*Te, imag(s));
title('Signal généré en quadrature de phase');
xlabel('Temps (s)');
ylabel('Amplitude');
legend('a_k', 'b_k');
grid on;

%% 2-2) Signal transmis sur fréquence porteuse
temps = 0:Te:(nb_symb*Ns-1)*Te;
figure;
plot(temps, real(s_transp));
xlabel('Temps (s)');
ylabel('Signal');
hold on;

%% 2-3)/3-2) DSP du signal transmis sur fréquence porteuse
[DSP, F] = pwelch(s_transp, [], [], [], Fe, "centered");
figure;
plot(F, 10*log10(DSP));
xlabel('Fréquence (Hz)');
ylabel('DSP (dB/Hz)');
title('DSP du signal transmis sur fréquence porteuse');
grid on;

% 2-4)/3-3) Explications

%% 3-4) Constellations en sortie du mapping et de l'échantilloneur
% étude des variations en fonction du SNRB
% symboles (mapping) et s_sample (echantilloneur)
figure;
set(gcf, 'Position', [100, 100, 1000, 500]);
sgtitle(sprintf('Constellation des symboles, SNRB = %d', SNRB));
subplot(1, 2, 1);
plot(real(symboles), imag(symboles), 'o');
title('Sortie du mapping');
xlabel('Re');
ylabel('Im');
axis equal;
axis tight;
grid on;
subplot(1, 2, 2);
plot(real(s_sample), imag(s_sample), 'o');
title('Sortie de l''échantilloneur');
xlabel('Re');
ylabel('Im');
axis equal;
axis tight;
grid on;

%% 5) et 6) TEB en fonction du SNRB, comparaison à la théorie
eps = 1e-1; % précision du TEB de 10%
snrb_dB = 0:0.1:6;
n_range = 1:2;
func_chaine = @(n, SNRB, N) chaine_transmission(n, SNRB, N, Fe, fp, Rb, pbEquivalent, ASK, beta);
TEB_comp(eps, snrb_dB, func_chaine, n_range);

%% 4 - Comparaison des modulateurs DVB-S et 4-ASK
n = 2;
SNRB = 4;
pbEquivalent = true;
ASK = true;
[~, s, s_transp, symboles, s_sample, nb_symb, Ns] = chaine_transmission(n, SNRB, N, Fe, fp, Rb, pbEquivalent, ASK, beta);

%% 4-1-1) Constellations en sortie du mapping et de l'échantilloneur
% étude des variations en fonction du SNRB
% symboles (mapping) et s_sample (echantilloneur)
figure;
set(gcf, 'Position', [100, 100, 800, 200]);
sgtitle(sprintf('Constellation des symboles, SNRB = %d', SNRB));
subplot(1, 2, 1);
plot(real(symboles), imag(symboles), 'o');
title('Sortie du mapping');
xlabel('Re');
ylabel('Im');
axis equal;
axis tight;
grid on;
subplot(1, 2, 2);
plot(real(s_sample), imag(s_sample), 'o');
title('Sortie de l''échantilloneur');
xlabel('Re');
ylabel('Im');
axis equal;
axis tight;
grid on;

%% 4-1-2)/4-1-3) TEB en fonction du SNRB, comparaison à la théorie
eps = 1e-1; % précision du TEB de 10%
snrb_dB = 0:0.1:6;
n_range = 1:3;
func_chaine = @(n, SNRB, N) chaine_transmission(n, SNRB, N, Fe, fp, Rb, pbEquivalent, ASK, beta);
[TEB, TEB_min] = TEB_comp(eps, snrb_dB, func_chaine, n_range);

%% 4-2 Comparaison des modulateurs DVB-S et 4-ASK
% Les tracés et comparaisons sont traitées dans le rapport.

%% 5 - Comparaison des modulateurs DVB-S et DVB-S2

% Grâce à la fonction chaine_transmission, on peut modéliser n'importe quel
% type de modulation et mapping, avec un choix de n, ASK/PSK, SNRB, etc.

% Nous nous servons de ce paramétrage pour comparer les modulations de DVB-S
% et DVB-S2 dans le rapport final.

n = 3;
SNRB = 4;
pbEquivalent = true;
ASK = false;
beta = 0.2;
[~, ~, s_transp] = chaine_transmission(n, SNRB, N, Fe, fp, Rb, pbEquivalent, ASK, beta);
[DSP, F] = pwelch(s_transp, [], [], [], Fe, "centered");

n = 2;
SNRB = 4;
pbEquivalent = true;
ASK = false;
beta = 0.35;
[~, ~, s_transp] = chaine_transmission(n, SNRB, N, Fe, fp, Rb, pbEquivalent, ASK, beta);
[DSP2, F2] = pwelch(s_transp, [], [], [], Fe, "centered");

figure;
plot(F, 10*log10(DSP), 'DisplayName', 'DVB-S2');
hold on;
plot(F2, 10*log10(DSP2), 'DisplayName', 'DVB-S');
legend;
xlabel('Fréquence (Hz)');
ylabel('DSP (dB/Hz)');
title('DSP du signal transmis sur fréquence porteuse');
grid on;