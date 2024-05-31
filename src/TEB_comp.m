function [TEB, TEB_min] = TEB_comp(eps, snrb_dB, func_chaine)
    % Compare le TEB théorique et le TEB simulé
    % - N: nombre de bits total transmis
    % - eps: précision du TEB
    % - snrb_dB: Signal to Noise Ratio en dB

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
            TEB(i) = func_chaine(n, snrb(i), N);
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
end