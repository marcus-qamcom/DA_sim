% Sensitivity_to_Noise_floor

clear all
close all
clc



%s=-95; % sensitivity @ 10% PER in Gaussian channel
B=10E6; % Channel bandwidth
k=1.38E-23; % Bolzmanns constant
T0=290; % Kelvin in room temperature
R=6E6; % data rate

Noise_flor_dB=10*log10(k*T0*B)

% http://en.wikipedia.org/wiki/Bit_error_rate
% ...For example, in the case of QPSK modulation and AWGN channel, 
% the BER as function of the Eb/N0 is given by: BER=1/2*erfc(sqrt(Eb/N0)


EbN0_dB=linspace(-16,16,500);
EbN0=10.^(EbN0_dB/10);

BER=0.5*erfc(sqrt(EbN0));
semilogy(EbN0_dB,BER)
axis([-16 16 1E-8 1])
xlabel('Eb/N0 dB')
ylabel('BER')


%% Conversion BER to PER:
% http://en.wikipedia.org/wiki/Bit_error_rate
% The packet error rate (PER) is the number of incorrectly received data packets 
% divided by the total number of received packets. A packet is declared incorrect 
% if at least one bit is erroneous. The expectation value of the PER is denoted 
% packet error probability pp, which for a data packet length of N bits can be 
% expressed as:
PER1000 = 1 - (1 - BER).^(1000*8);
PER100 = 1 - (1 - BER).^(100*8);
figure
semilogy(EbN0_dB,PER100,'r')
hold on
semilogy(EbN0_dB,PER1000,'b')
grid on
legend('100','1000')
axis([0 16 1E-6 1])
xlabel('Eb/N0 dB')
ylabel('PER')
hold off

%% Conversion Eb/N0 to snr
% http://en.wikipedia.org/wiki/Eb/N0
% Eb/N0 is closely related to the carrier-to-noise ratio (CNR or C/N), 
% i.e. the signal-to-noise ratio (SNR) of the received signal, after the 
% receiver filter but before detection:
% C/N=E_b/N_0*fB/B
% where
% fB is the channel data rate (net bitrate), and
% B is the channel bandwidth
% The equivalent expression in logarithmic form (dB):
% CNR_dB = 10*log_10(E_b/N_0) + 10*log_10(fB/B)


SNR_dB=EbN0_dB+10*log10(R/B);
figure
semilogy(SNR_dB,PER100,'r')
grid on
hold on
semilogy(SNR_dB,PER1000,'b')
axis([0 16 1E-6 1])
xlabel('SNR dB')
ylabel('PER')
legend('100','1000')
SNR_dB(sum(PER100>0.1))
SNR_dB(sum(PER1000>0.1))
hold off


%% Estimate PER from BER
clc
ber=0.00015;
Nb=8000;
a_per=0;
for g=1:10000
    a_ber=0;
    for pkt=1:Nb % bits packet
        
        if(rand<ber)
            a_ber=a_ber+1;
        end
    end
    if a_ber>0
        a_per=a_per+1;
    end
end
a_per/10000
%
disp(num2str(1 - (1 - ber).^(Nb)))
disp(num2str(1 - (1 - ber^2).^((Nb-1)*Nb/2)))

%% Eav/N0 vs PER
% Data from:
% An Error model for Intervehicle Communications in Highway Scenarios at
% 5.9GHz
QPSK_snr_at_per0_1=[6.6 7.3 8.0]
packet_size=[39 275 2304]
plot(QPSK_snr_at_per0_1,packet_size,'*-')
QPSK_snr_at_per0_1_est=linspace(6.5,8.5,100);

y0=	-27.59794; % From ORIGIN
A =	4.09328E-7;
t =	0.35618;

packet_size_est=y0+A*exp(QPSK_snr_at_per0_1_est/t);

hold on
plot(QPSK_snr_at_per0_1_est,packet_size_est,'r')
axis([6.5 8.5 -500 2500])
xlabel('Eav/N0 dB')
ylabel('BER')
hold off