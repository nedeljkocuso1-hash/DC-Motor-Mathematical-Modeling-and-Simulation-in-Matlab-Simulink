clear all

%--------------------------------------------------------------------------------------------------------------------------------
% Parametri simulacije
%--------------------------------------------------------------------------------------------------------------------------------
Tsim = 10e-6;                                                               % Fiksni korak simulacije: 10 [us]
Tstart = 0;                                                                 % Vremenska instanca pocetka simulacije: 0 [s]
Tstop = 10;                                                                 % Vremenska instanca zavrsetka simulacije: 10 [s]

%--------------------------------------------------------------------------------------------------------------------------------
% ZIM 160 L - 2
%--------------------------------------------------------------------------------------------------------------------------------
%--------------------------------------------------------------------------------------------------------------------------------
% Parametri strujnog kola indukta - rotora
%--------------------------------------------------------------------------------------------------------------------------------
Ra = 2.5;                                                                   % Otpora indukta u [Ohm]
La = 30.3e-3;                                                               % Induktivnost indukta u [H]
Ta = La/Ra;                                                                 % Vremenska konstanta elektromagnetnog podsistema rotora u [s]

%--------------------------------------------------------------------------------------------------------------------------------
% Parametri strujnog kola induktora - statora
%--------------------------------------------------------------------------------------------------------------------------------
Rp = 145.9;                                                                 % Otpor induktora u [Ohm]
Lp = 20.0;                                                                  % Induktivnost induktora u [H]
Tp = Lp/Rp;                                                                 % Vremenska konstanta elektromagnetnog podsistema statora u [s]

%--------------------------------------------------------------------------------------------------------------------------------
% Parametri mehanickog podsistema - koordinate brzina obrtanja rotora i pozicije
%--------------------------------------------------------------------------------------------------------------------------------
kw = 0;                                                                     % Koeficijent sile mehanickog trenja u [Nms]           % default vrednost      0.01;
J = 0.11;                                                                   % Momenat inercije u [kgm2]

%--------------------------------------------------------------------------------------------------------------------------------
% Konstrukcioni parametri MJS
%--------------------------------------------------------------------------------------------------------------------------------
p = 4;                                                                      % Broj pari polova
Na = 100;                                                                   % Ukupan broj provodnika namotaja indukta

% Vrsta namotavanja armature
PETLJASTI = 1;
VALOVITI = 2;

NAMOTAJ = PETLJASTI;

% Broj pari paralelnih - 2*a
if NAMOTAJ == PETLJASTI
    a = p;                                                                  % Slucaj petljastog namotaja                                                               
else
    a = p/2;                                                                % Slucaj valovitog namotaja
end

c = (Na/2)*p/(pi()*a);                                                      % Konstrukciona konstanta masine

%--------------------------------------------------------------------------------------------------------------------------------
% Natpisna plocica MJS
%--------------------------------------------------------------------------------------------------------------------------------
Uan = 400;                                                                  % Nazivna vrednost napona indukta u [V]
Ian = 23.0;                                                                 % Nazivna vrednost struje indukta u [A]
nn = 2113;                                                                  % Nazivna vrednost brzine obrtanja rotora u [o/min]
Upn = 200;                                                                  % Nazivna vrednost napona pobude u [V]

%--------------------------------------------------------------------------------------------------------------------------------
% Proracuni u specijalnim rezimima rada - nominalni režim
%--------------------------------------------------------------------------------------------------------------------------------
wn = 2*pi()/60*nn;                                                          % Nazivna vrednost ugaone brzine obrtanja rotora u [rad/s]
En = Uan - Ra*Ian;                                                          % Vrednost indukovane EMS u nazivnom rezimu rada u [V]
flux_nom = En/wn;                                                           % Vrednost fluksnog obuhvata namotaja rotora u [Nm/A] - konstanta momenta u baznom opsegu

Ipn = Upn/Rp;                                                               % Vrednost struje pobude u nazivnom režimu rada u [A]
flux_p_nom = Lp*Ipn;                                                        % Vrednost fluksnog obuhvata namotaja pobude u nazivnom rezimu rada u [Wb] 

c1 = flux_nom/flux_p_nom;                                                   % Koeficijent srazmere fluksnih obuhvata namotaja
Ns = c/c1;                                                                  % Broj navojaka namotaja pobude

flux_pol_nom = flux_p_nom/Ns;                                               % Vrednost fluksa po polu u [Wb]

me_nom = flux_nom*Ian;                                                      % Vrednost elektromagnetskog momenta u nazivnom rezimu rada u [Nm]
mm_nom = me_nom - kw*wn;                                                    % Vrednost momenta opterecenja u nazivnom rezimu rada u [Nm]

%--------------------------------------------------------------------------------------------------------------------------------
% Vremenske konstante mehanickog podsistema brzine obrtanja i pozicije rotora
%--------------------------------------------------------------------------------------------------------------------------------
K = flux_nom^2/Ra;                                                          % Nazivni koeficijent virtuelnog trenja - modeluje pad brzine obrtanja usled momenta opterećenja
tau_m = J/K;                                                                % Mehanicka vremenska konstanta integracije pri nazivnoj pobudi
Tth = 1;                                                                    % Ugaona vremenska konstanta

%--------------------------------------------------------------------------------------------------------------------------------
% Proracuni u specijalnim rezimima rada - prazan hod
%--------------------------------------------------------------------------------------------------------------------------------
won = Uan/flux_nom/(1+kw/K);                                                % Vrednost nazivne ugaone brzine obrtanja rotora u režimu praznog hoda u [rad/s]
meo_nom = kw*won;                                                           % Vrednost nazivnog elektromagnetskog momenta u režimu praznog hoda u [Nm]
Iao_nom = meo_nom/flux_nom;                                                 % Vrednost nazivne struje indukta u režimu praznog hoda u [A]

%--------------------------------------------------------------------------------------------------------------------------------
% Proracuni u specijalnim rezimima rada - kratak spoj
%--------------------------------------------------------------------------------------------------------------------------------
Ia_ks_nom = Uan/Ra;                                                         % Vrednost nazivne polazne struje indukta u [A]
me_ks_nom = flux_nom*Ia_ks_nom;                                             % Vrednost nazivnog polaznog elektromagnetskog momenta u [Nm]

%--------------------------------------------------------------------------------------------------------------------------------
% Pocetni uslovi - akumulacije energija podsistema MJS
%--------------------------------------------------------------------------------------------------------------------------------
Ia0 = 0;                                                                    % Pocetna vrednost magnetske energije u prigušnici namotaja rotora
Ip0 = 0;                                                                    % Pocetna vrednost magnetske energije u prigušnici namotaja statora
w0 = 0;                                                                     % Pocetna vrednost kineticke energije zamajnih masa rotora
theta0 = 0;                                                                 % Pocetna vrednost ugaone koordinate rotora

%--------------------------------------------------------------------------------------------------------------------------------
% Parametri blokova za eksitacija sistema - pobuda, armatura, vratilo
%--------------------------------------------------------------------------------------------------------------------------------
t_ramp = 2;                                                                 % Vremenska instanca zadavanja rampa funkcije napona
Tzalet = 3;                                                                 % Vreme trajanja rampe napona u [s]
ramp_ofset = 0;                                                             % Vrednost rampa funkcije u trenutka zadavanja reference napona

k_ramp = Uan/Tzalet;                                                        % Nagib rampe napona u [V/s]

% Magnetni ulaz - kolo pobude
Up = Upn;                                                                   % Refenca pobudnog napona u [V]
t_pob = 0.1;                                                                % Vremenska instanca zadavanja odskocnog signala pobude

flux_p = Up/Rp*c1*Lp;                                                       % Vrednost fluksnog obuhvata namotaja pobude u [Wb] 
Ip = Up/Rp;                                                                 % Vrednost struje pobude u [A]

% Elektricni prolaz - namotaj rotora
Ua = Uan;                                                                   % Referenca napona rotora u [V]
t_a = t_ramp;                                                               % Vremenska instanca zadavanja odskocnog signala armature

% Mehanicki prolaz - vratilo
mm = mm_nom;                                                                % Referenca momenta opterecenja u [Nm]
t_opt = 7;                                                                  % Vremenska instanca zadavanja opterecenja na vratilu

Ia = mm/flux_p;                                                             % Vrednost struje opterecenja prilikom strujnog napajanja u [A]

deltaw_percent = 10;                                                        % Procentualni pad brzine obrtanja tokom trajanja opterecenja kod strujnog napajanja u [%]
deltat_opt = deltaw_percent/100*Tzalet;                                     

%--------------------------------------------------------------------------------------------------------------------------------
% Proracun polova i karakteristicnih parametara sistema
%--------------------------------------------------------------------------------------------------------------------------------
tau_m1 = J*Ra/flux_nom^2*(Upn/Up)^2;                                        % Mehanicka vremenska konstanta integracije u rezimu rada pogona u [s]

if kw == 0
    % Slucaj: kw = 0
    sys1 = tf([1/(tau_m1*Ta)],[1 1/Ta 1/(tau_m1*Ta)]);                        
    
    psi1 = sqrt(tau_m1/4/Ta);                                               % Faktor relativnog prigusenja u [r.j.]
    wn1 = 1/sqrt(tau_m1*Ta);                                                % Neprigusena ucestanost oscilovanja u [rad/s]
    pole(sys1)                                                              % Polovi MJS
else
    % Slucaj: kw
    Tm_prim = J/kw;                                                         % Ekvivalentna mehanicka vremenska konstanta

    sys2 = tf([1/(Tm_prim*Ta)*(1+K/kw)],[1 (1/Ta+1/Tm_prim) 1/(Tm_prim*Ta)*(1+K/kw)]);        

    wn2 = sqrt(1/(Tm_prim*Ta)*(1+K/kw));                                    % Neprigusena ucestanost oscilovanja u [rad/s]
    psi2 = (1/Ta+1/Tm_prim)/(2*wn2);                                        % Faktor relativnog prigusenja u [r.j.]
    
    pole(sys2)                                                              % Polovi MJS
end

%--------------------------------------------------------------------------------------------------------------------------------
% Proracun struje i ubrzanja rotora u kvazistacionarnom režimu tokom trajanja zaleta putem soft starta - slu�?aj kw = 0
%--------------------------------------------------------------------------------------------------------------------------------
Iao_zalet = Ua/Ra*tau_m1/Tzalet;                                            % Struja zaleta u neopterecenom stanju u [A]
Ia_zalet = Iao_zalet + mm/flux_p;                                           % Struja zaleta u opterecenom stanju u [A]

alphao_zalet = Ua/flux_p/Tzalet;                                            % Ubrzanje tokom trajanja zaleta u [rad/s2]     
k_rampI = Ian/Tzalet;                                                       % Nagib rampe struje u [A/s]        

%--------------------------------------------------------------------------------------------------------------------------------
% Normalizacija
%--------------------------------------------------------------------------------------------------------------------------------


% Sistemi normalizacije
SISTEM_I = 1;                                                               % Nominalni režim rada
SISTEM_II = 2;                                                              % Ogledi PH i KS
SISTEM_III = 3;                                                             % Maksimalne vrednosti prilagodjenje uC

NORMALIZACIJA = SISTEM_II;

if NORMALIZACIJA == SISTEM_I
    
    
elseif NORMALIZACIJA == SISTEM_II
    % osnovne
    Ua_b = Uan;
    flux_b = flux_nom;
    Ra_b = Ra;
    Lp_b = Lp;
    Up_b = Upn;

    % izvedene
    Ia_b = Ua_b/Ra_b;
    w_b = Ua_b/flux_b;
    me_b = flux_b*Ia_b;
    k_b = me_b/w_b;   
    
    flux_p_b = flux_b/c1;
    Ip_b = flux_p_b/Lp_b;
    Rp_b = Up_b/Ip_b;  
    
    theta_b = w_b;
    
    flux_b1 = flux_b;

    
   
else
    % Sistem III   
    SHIFT = 0;
    
    flux_b1 = (2^SHIFT)*flux_b;

    
end

% Parametri normalizovanog modela
Tm = J/k_b;
kw_norm = kw/k_b;
Tthn = theta_b/w_b;

Ra_norm = Ra/Ra_b;
Tan = La/Ra_b;

if flux_b1 == flux_b
    ke = 1;
    km = ke;
else
    ke = 2^SHIFT;
    km = ke;
end

Rp_norm = Rp/Rp_b;
Tpn = Lp/Rp_b;

kflux = (c1*Lp)/(flux_b1/Ip_b);

% Eksitacija

Ua_norm = Ua/Ua_b;
Up_norm = Up/Up_b;

k_ramp_norm = k_ramp/Ua_b;

mm_norm = mm/me_b;

R_norm = Ra/Uan*Ian;

%--------------------------------------------------------------------------------------------------------------------------------
% Parametri za snimanje trajektorije pogona
%--------------------------------------------------------------------------------------------------------------------------------
Trec = 1e-3;                                                                % Perioda odabiranja snimaca trajektorije u [s]
% VSI
ymin1 = -1.5*wn;                                                              % Donji limit ordinatne ose 
ymax1 = 1.5*wn;                                                               % Gornji limit ordinatne ose 
xmin1 = -me_ks_nom;                                                              % Donji limit apscisne ose 
xmax1 = me_ks_nom;                                                               % Gornji limit apscisne ose 

% VSI
ymin2 = ymin1;                                                              % Donji limit ordinatne ose 
ymax2 = ymax1;                                                               % Gornji limit ordinatne ose 
xmin2 = xmin1;                                                              % Donji limit apscisne ose 
xmax2 = xmax1;                                                               % Gornji limit apscisne ose 

% VSI Normalizovano
ymin3 = ymin1/w_b;                                                              % Donji limit ordinatne ose 
ymax3 = ymax1/w_b;                                                               % Gornji limit ordinatne ose 
xmin3 = xmin1/me_b;                                                              % Donji limit apscisne ose 
xmax3 = xmax1/me_b;                                                               % Gornji limit apscisne ose 

DIZALICA = 0;
VOZILO = 1;
VENTILATOR = 2;

OPTERECENJE = VENTILATOR;


if OPTERECENJE == VOZILO
    kw = me_nom/wn;
    
    %Tzalet = 1.5*5*J/kw;
    t_opt = 2*5*J/kw+2;
    
    Tstop = 15;
    
    Tzalet = Tstop;
    deltat_opt = Tstop;
    
    Iao_zalet = Ian;
    Ia = 0;
    
    mm = flux_nom*Ian/10;
    
    DEADZONE_START = 0;
    DEADZONE_STOP = 0;
    
    
elseif OPTERECENJE == VENTILATOR
    mm = flux_nom*Ian/10;

     kw = (me_nom-mm)/wn^2;
   
    
    %Tzalet = 1.5*5*J/kw;
    t_opt = t_a;
    
    Tstop = 15;
    
    Tzalet = Tstop;
    deltat_opt = Tstop;
    
    Iao_zalet = Ian;
    Ia = 0;
    
    DEADZONE_START = -inf;
    DEADZONE_STOP = 0;

elseif OPTERECENJE == DIZALICA

    DEADZONE_START = 0;
    DEADZONE_STOP = 0;
    
    %STAVITI NORMALIZACIJU ZA KW JER NIJE VISE LINEARNA ZAVISNOST
    
end

n = 40;

Tn = Ta;
wgr = n*1/Ta;
Kp = n*Ra;

Ki = Kp/Tn;



