
"Represents a monochromatic elliptically polarized laser field with Cos4-shape envelope propagating in z direction."
struct Cos4Laser <: MonochromaticLaser
    "Peak intensity of the laser field (in W/cm^2)."
    peakInt;
    "Wavelength of the laser field (in NANOMETER)."
    waveLen;
    "Cycle number of the laser field."
    cycNum;
    "Ellpticity of the laser field."
    ellip;
    "Carrier-Envelope-Phase (CEP) of the laser field."
    cep;
    """
    Constructs a new monochromatic elliptically polarized laser field.
    # Parameters
    - `peakInt`     : Peak intensity of the laser field (in W/cm²).
    - `WaveLen`     : Wavelength of the laser field (in nm).
    - `cycNum`      : Number of cycles of the laser field.
    - `Ellpticity`  : Ellpticity of the laser field [0≤e≤1, 0 indicates linear polarization (in x direction) and 1 indicates circular polarization].
    - `cep`         : Carrier-Envelope-Phase of the laser field (optional, default 0).
    """
    function Cos4Laser(peakInt, waveLen, cycNum, ellip, cep=0.)
        @assert peakInt>0   "[Cos4Laser] Peak intensity must be positive."
        @assert waveLen>0   "[Cos4Laser] Wavelength must be positive."
        @assert cycNum>0    "[Cos4Laser] Cycle number must be positive."
        @assert 0≤ellip≤1   "[Cos4Laser] Ellpticity must be in [0,1]."
        new(peakInt,waveLen,cycNum,ellip,cep)
    end
    function Cos4Laser(;peakInt, waveLen, cycNum, ellip, cep=0.)
        @assert peakInt>0   "[Cos4Laser] Peak intensity must be positive."
        @assert waveLen>0   "[Cos4Laser] Wavelength must be positive."
        @assert cycNum>0    "[Cos4Laser] Cycle number must be positive."
        @assert 0≤ellip≤1   "[Cos4Laser] Ellpticity must be in [0,1]."
        new(peakInt,waveLen,cycNum,ellip,cep)
    end
    """
    Constructs a new monochromatic elliptically polarized laser field.
    # Parameters
    - `peakInt`     : Peak intensity of the laser field (in W/cm²).
    - `WaveLen`     : Wave length of the laser field (in nm). Must specify either `waveLen` or `angFreq`.
    - `angFreq`     : Angular frequency of the laser field (in a.u.). Must specify either `waveLen` or `angFreq`.
    - `cycNum`      : Number of cycles of the laser field. Must specify either `cycNum` or `duration`.
    - `duration`    : Duration of the laser field (in a.u.). Must specify either `cycNum` or `duration`.
    - `Ellpticity`  : Ellpticity of the laser field [0≤e≤1, 0 indicates linear polarization (in x direction) and 1 indicates circular polarization].
    - `cep`         : Carrier-Envelope-Phase of the laser field (optional, default 0).
    """
    function Cos4Laser(;peakInt,
                        waveLen=-1, angFreq=-1,     # must specify either waveLen or angFreq.
                        cycNum=-1,  duration=-1,    # must specify either cycNum or duration.
                        ellip,
                        cep=0.)
        @assert peakInt>0   "[Cos4Laser] Peak intensity must be positive."
        @assert waveLen>0 || angFreq>0  "[Cos4Laser] Must specify either waveLen or angFreq."
        @assert cycNum>0 || duration>0  "[Cos4Laser] Must specify either cycNum or duration."
        @assert 0≤ellip≤1   "[Cos4Laser] Ellpticity must be in [0,1]."
        if waveLen>0 && angFreq>0
            @warn "[Cos4Laser] Both waveLen & angFreq are specified, will use waveLen."
        end
        if cycNum>0 && duration>0
            @warn "[Cos4Laser] Both cycNum & duration are specified, will use cycNum."
        end
        if waveLen==-1
            waveLen = 45.563352525 / angFreq
        end
        if cycNum==-1
            cycNum = duration / (2π/angFreq)
        end
        new(peakInt,waveLen,cycNum,ellip,cep)
    end
end
"Gets the peak intensity of the laser field (in W/cm²)."
PeakInt(l::Cos4Laser) = l.peakInt
"Gets the wave length of the laser field (in nm)."
WaveLen(l::Cos4Laser) = l.waveLen
"Gets the cycle number of the laser field."
CycNum(l::Cos4Laser) = l.cycNum
"Gets the ellpticity of the laser field."
Ellpticity(l::Cos4Laser) = l.ellip
"Gets the angular frequency (ω) of the laser field (in a.u.)."
AngFreq(l::Cos4Laser) = 45.563352525 / l.waveLen
"Gets the period of the laser field (in a.u.)."
Period(l::Cos4Laser) = 2π / AngFreq(l)
"Gets the peak electric field intensity of the laser field (in a.u.)."
LaserF0(l::Cos4Laser) = sqrt(l.peakInt/(1.0+l.ellip^2)/3.50944521e16)
"Gets the peak vector potential intensity of the laser field (in a.u.)."
LaserA0(l::Cos4Laser) = LaserF0(l) / AngFreq(l)

"Gets the time-dependent x component of the vector potential under dipole approximation."
function LaserAx(l::Cos4Laser)
    local A0 = LaserA0(l); local ω = AngFreq(l); local N = l.cycNum; local φ = l.cep;
    return function(t)
        A0 * cos(ω*t/(2N))^4 * (abs(ω*real(t))<N*π) * cos(ω*t+φ)
    end
end
"Gets the time-dependent y component of the vector potential under dipole approximation."
function LaserAy(l::Cos4Laser)
    local A0 = LaserA0(l); local ω = AngFreq(l); local N = l.cycNum; local φ = l.cep; local ε = l.ellip;
    return function(t)
        A0 * cos(ω*t/(2N))^4 * (abs(ω*real(t))<N*π) * sin(ω*t+φ) * ε
    end
end
"Gets the time-dependent x component of the electric field strength under dipole approximation."
function LaserFx(l::Cos4Laser)
    local F0 = LaserF0(l); local ω = AngFreq(l); local N = l.cycNum; local φ = l.cep;
    return function(t)
        F0 * cos(ω*t/(2N))^3 * (abs(ω*real(t))<N*π) * ( cos(ω*t/(2N))*sin(ω*t+φ) + 2/N*sin(ω*t/(2N))*cos(ω*t+φ))
    end
end
"Gets the time-dependent y component of the electric field strength under dipole approximation."
function LaserFy(l::Cos4Laser)
    local F0 = LaserF0(l); local ω = AngFreq(l); local N = l.cycNum; local φ = l.cep; local ε = l.ellip;
    return function(t)
        F0 * cos(ω*t/(2N))^3 * (abs(ω*real(t))<N*π) * (-cos(ω*t/(2N))*cos(ω*t+φ) + 2/N*sin(ω*t/(2N))*sin(ω*t+φ)) * ε
    end
end

"Prints the information about the laser."
Base.show(io::IO, l::Cos4Laser) = print(io,"[MonochromaticLaser] Envelope cos⁴, Wavelength=$(l.waveLen) nm, $(l.cycNum) cycle(s), e=$(l.ellip)"
                                           * (l.ellip==0 ? " [Linearly (x ax.) polarized]" : "") * (l.ellip==1 ? " [Circularly polarized]" : "") * (l.cep==0 ? "" : ", CEP=$(l.cep)"))