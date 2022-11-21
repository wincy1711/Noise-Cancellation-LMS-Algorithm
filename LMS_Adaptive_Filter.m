clear

% set parameters
T  = 60;        %output duration
L  = 2000;      %Filter Length
mu = 0.005;     %Step size

% data preparation
[DataIn2, Fs2] = audioread('Bohemian1_noise1.wav');           %Reference Input
[N2,P2] = size(DataIn2);
[DataIn3, Fs3] = audioread('Bohemian1_noise_source1.wav');    %Primary Input
[N3,P3] = size(DataIn3);

noiseN=DataIn2(1:(Fs2*T));          %noiseN = Reference Input
noiseF=DataIn3(1:(Fs3*T));          %noiseF = Primary Input


% Correlation
if 1
    refP=noiseN((3.5e5):(4e5));     %Select reference point
    r=xcorr(noiseF,refP);
    figure(1)
    plot(abs(r),'bo-')
    title('Correlation Signal')
    grid on
    D = (find(abs(r) == max(abs(r))))-length(noiseF)-3.5e5;      % actual delay samples

end

% Calibrate Input
xN=noiseN(1:end-D);
xF=noiseF((D+1):end);


M=length(xF);
t=1:M;          % samples
tt=(t-1)/Fs2;   % times


% Noise Cancellation (LMS)
y=zeros(M,1);       %System Ouput (LMS Error)
e=zeros(M,1);       %LMS Error
sr=zeros(L,1);      %window size
h=zeros(L,1);       %Adaptive filter

for n=1:M
   sr=[xN(n);sr(1:L-1)];        %windowed noise near
   y(n)=(h')*sr;                %LMS error
   e(n)=xF(n)-y(n);             %LMS estimator
   h=h+(mu*sr*e(n));            %updated parameter
end

% plot
figure(2)
if 1
    plot(tt,xF,'b-',tt,xN,'m-',tt,y,'r-',tt,e,'g-')
    xlabel('Seconds') 
    ylabel('Amplitude') 
    title('LMS Estimation Signal (seconds)')
    legend({'Noise Far','Noise Short', 'LMS Estimation', 'LMS Error'},'Location','southwest')
else
    plot(t,xF,'b-',t,y,'r-',t,e,'g-')       
    xlabel('Samples') 
    ylabel('Amplitude') 
    title('LMS Estimation Signal (samples)')
    legend({'Noise Far','Noise Short', 'LMS Estimation', 'LMS Error'},'Location','southwest')
end
grid on

% obeserve correlation of LMS estimator and noise far(Primary Input)
%xlim([30.16 30.18])
%ylim([-0.1 0.1])

% Save LMS output in audio file with 44.1 kHz sampling rate
%audiowrite('LMS_Bohemian_1_2000_0.007.wav', y, 44100);
% Save LMS estimator in audio file with 44.1 kHz sampling rate
%audiowrite('LMS_Bohemian_1_2000_0.007_error.wav', e, 44100);


