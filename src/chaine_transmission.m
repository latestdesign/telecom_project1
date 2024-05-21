function [TEB] = chaine_transmission(n, SNRB, N, visual)
    % - n: nombre de bits par symbole
    % - SNRB: rapport signal sur bruit par bit
    % - N: nombre de bits total transmis
    % - visual: true pour afficher les graphiques

    % paramètres fixés par l'énoncé
    Fe = 24000; % fréquence d'échantillonnage en Hz
    fp = 2000; % fréquence porteuse en Hz
    Te = 1/Fe; % période d'échantillonnage
    Rb = 3000; % débit binaire en bits par seconde

    reste = mod(N, n);
    if reste ~= 0
        N = N + n - reste;
    end

    Rs = Rb/n; % débit symbole
    Ts = 1/Rs; % période symbole
    Ns = round(Ts/Te); % nombre d'échantillons par symbole
    nb_symb = N/n; % nombre de symboles total

    % SIGNAL ENTREE
    bits = randi(2, 1, N)-1; % le signal d'entrée
    M = 2^n; % paramètre Q pour la modulation PSK

    % MAPPING
    bits_regroupes = reshape(bits, n, []);
    entiers = bi2de(bits_regroupes.', 'left-msb');
    symboles = pskmod(entiers, M).'; % éventuellement mettre en Gray
    x = kron(symboles, [1 zeros(1, Ns-1)]);

    % FILTRE EMISSION
    beta = 0.35;
    L = 8;
    h = rcosdesign(beta, L, Ns);
    s = filter(h, 1, x);

    % TRANSPOSITION FREQUENTIELLE
    t = 0:Te:(nb_symb*Ns-1)*Te;
    freq_transp = exp(1j*2*pi*fp*t);
    s_transp = real(freq_transp.*s);

    % BRUITAGE
    Ps = mean(abs(s_transp.^2));
    sigma = sqrt(Ps*Ns/(2*n*SNRB));
    bruit = sigma*randn(1, nb_symb*Ns);
    s_bruite = s_transp+bruit;

    % FILTRE RECEPTION
    s_detransp = exp(-1j*2*pi*fp*t).*s_bruite;
    hr = h;
    s_demod = filter(hr, 1, s_detransp);

    % DETECTION OPTIMALE
    [~, n0] = max(abs(conv(h, hr)));
    s_sample = s_demod(n0:Ns:end);

    % DEMAPPING
    s_demappe = pskdemod(s_sample, M);
    s_demappe = de2bi(s_demappe, 'left-msb').';
    s_demappe = s_demappe(:).';

    % TEB
    retard = floor(n0/Ns)*n;
    TEB = sum(bits(1:end-retard) ~= s_demappe)/(N-retard);

    % Affichage graphique
    if visual
        % signaux générés en quadrature de phase
        figure;
        plot(0:Te:(nb_symb*Ns-1)*Te, real(s));
        hold on;
        plot(0:Te:(nb_symb*Ns-1)*Te, imag(s));
        title('Signal généré en quadrature de phase');
        xlabel('Temps (s)');
        ylabel('Amplitude');
        legend('a_k', 'b_k');
        grid on;

        % Signal transmis sur f porteuse
        temps = 0:Te:(nb_symb*Ns-1)*Te;
        figure;
        plot(temps, s_transp);
        xlabel('temps (s)');
        ylabel('Signal');
        hold on;

        % DSP du signal transmis sur frequence porteuse
        [DSP, F] = pwelch(s_transp, [], [], [], Fe);
        figure;
        plot(F, 10*log10(DSP));
        xlabel('Fréquence (Hz)');
        ylabel('DSP (dB/Hz)');
        title('DSP du signal transmis sur fréquence porteuse');
        grid on;

        
    end
end
