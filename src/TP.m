%% Projet Télécommunications/Traitement du signal
% Étude d'une chaine de transmission sur porteuse pour une transmission
% satellite fixe

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PARAMS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Fe = 24000; % fréquence d'échantillonnage en Hz
fp = 2000; % fréquence porteuse en Hz
Te = 1/Fe; % période d'échantillonnage
Rb = 3000; % débit binaire en bits par seconde
Tb = 1/Rb; % période par bit
N = 1000; % nombre de bits total
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Transmission avec transposition de fréquence
% TOUT A COMMENTER

eps = 1e-1; % précision du TEB de 10%
snrb_dB = 0:1:8;

Q = @(x) 0.5*erfc(x/sqrt(2));
Nsnr = length(snrb_dB);
snrb = 10.^(snrb_dB/10);
TEB_min = zeros(1, Nsnr);
TEB = zeros(1, Nsnr);
figure;
for n=1:4
    M = 2^n;
    for i=1:Nsnr
        TEB_min(i) = 2*((M-1)/(M*n)) * qfunc(sqrt((6*n)/(M^2-1) * snrb(i)));
        N = round(1/(TEB_min(i)*eps^2));
        bits = randi(M, 1, N)*2-M-1;
        TEB(i) = chaine_transmission(n, snrb(i), N);
    end
    semilogy(snrb_dB, TEB_min, 'Color', [1 0 0 0.5]);
    hold on;
    semilogy(snrb_dB, TEB, 'Color', [0 0 1 0.5]);
    text(snrb_dB(end-1), TEB_min(end-1), sprintf('M = %d', 2^n), 'VerticalAlignment', 'top', 'HorizontalAlignment', 'right');
    text(snrb_dB(end-1), TEB(end-1), sprintf('N = %.1e, M = %d', N, 2^n), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');
    grid on;
    hold on;
end
ylabel('TEB');
xlabel('SNR (dB)');
legend('TEB_{min}', 'TEB', 'Location', 'southwest');
