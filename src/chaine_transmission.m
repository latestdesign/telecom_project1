function [TEB, s, s_transp, symboles, s_sample, nb_symb, Ns] = chaine_transmission(n, SNRB, N, Fe, fp, Rb, pbEquivalent, ASK, beta)
    % - n: nombre de bits par symbole
    % - SNRB: rapport signal sur bruit par bit
    % - N: nombre de bits total transmis
    % - visual: true pour afficher les graphiques

    reste = mod(N, n);
    if reste ~= 0
        N = N + n - reste;
    end

    Te = 1/Fe; % période d'échantillonnage
    Rs = Rb/n; % débit symbole
    Ts = 1/Rs; % période symbole
    Ns = round(Ts/Te); % nombre d'échantillons par symbole
    nb_symb = N/n; % nombre de symboles total

    % SIGNAL ENTREE
    bits = randi(2, 1, N)-1; % le signal d'entrée
    M = 2^n; % paramètre Q pour la modulation PSK

    % MAPPING
    bits_regroupes = reshape(bits, n, []);
    entiers = bi2de(bits_regroupes.', 'left-msb'); % éventuellement mettre en Gray
    if ASK
        symboles = pammod(entiers, M).'; % mapping entier vers M-ASK
    else
        symboles = pskmod(entiers, M).'; % mapping entier vers M-PSK
    end
    x = kron(symboles, [1 zeros(1, Ns-1)]);

    % FILTRE EMISSION
    L = 8;
    h = rcosdesign(beta, L, Ns);
    s = filter(h, 1, x);

    % TRANSPOSITION FREQUENTIELLE
    if pbEquivalent
        s_transp = s;
    else
        t = 0:Te:(nb_symb*Ns-1)*Te;
        freq_transp = exp(1j*2*pi*fp*t);
        s_transp = real(freq_transp.*s);
    end

    % BRUITAGE
    Ps = mean(abs(s_transp.^2));
    sigma = sqrt(Ps*Ns/(2*n*SNRB));
    if pbEquivalent
        bruit = sigma*randn(1, nb_symb*Ns) + 1j*sigma*randn(1, nb_symb*Ns);
        s_bruite = s+bruit;
    else
        bruit = sigma*randn(1, nb_symb*Ns);
        s_bruite = s_transp+bruit;
    end

    % FILTRE RECEPTION
    if pbEquivalent
        s_detransp = s_bruite;
    else
        s_detransp = exp(-1j*2*pi*fp*t).*s_bruite;
    end
    hr = h;
    s_demod = filter(hr, 1, s_detransp);

    % DETECTION OPTIMALE
    [~, n0] = max(abs(conv(h, hr)));
    s_sample = s_demod(n0:Ns:end);

    % DEMAPPING
    if ASK
        s_demappe = pamdemod(s_sample, M);
    else
        s_demappe = pskdemod(s_sample, M);
    end
    s_demappe = de2bi(s_demappe, 'left-msb').';
    s_demappe = s_demappe(:).';

    % TEB
    retard = floor(n0/Ns)*n;
    TEB = sum(bits(1:end-retard) ~= s_demappe)/(N-retard);
end
