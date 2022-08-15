
"""
The Laser module provides information about laser fields.
"""
module Lasers

export Laser, Cos4Laser
export LaserAngFreq, LaserPeriod, LaserF0, LaserA0, LaserAx, LaserAy, LaserFx, LaserFy


"Represents an abstract laser."
abstract type Laser end


begin :Cos4Laser
    "Represents a monochromatic elliptically polarized laser field with Cos4-shape envelope propagating in z direction."
    struct Cos4Laser <: Laser
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
        "Constructs a new monochromatic elliptically polarized laser field."
        Cos4Laser(peakInt, waveLen, cycNum, ellip, cep) = new(peakInt,waveLen,cycNum,ellip,cep);
        #TODO: add support for more flexible constructor function.
    end
    "Gets the angular frequency (ω) of the laser field."
    LaserAngFreq(l::Cos4Laser) = 45.563352525 / l.waveLen
    "Gets the period of the laser field."
    LaserPeriod(l::Cos4Laser) = 2π / LaserAngFreq(l)
    "Gets the peak electric field intensity of the laser field."
    LaserF0(l::Cos4Laser) = sqrt(l.peakInt/(1.0+l.ellip^2)/3.50944521e16)
    "Gets the peak vector potential intensity of the laser field."
    LaserA0(l::Cos4Laser) = LaserF0(l) / LaserAngFreq(l)
    #TODO: add complete property accessors.
    
    "Gets the time-dependent x component of the vector potential under dipole approximation."
    function LaserAx(l::Cos4Laser)
        local A0 = LaserA0(l); local ω = ω(l); local N = l.cycNum; local φ = l.cep;
        return function(t)
            A0 * cos(ω*t/(2N))^4 * (abs(ω*t)<N*π) * cos(ω*t+φ)
        end
    end
    "Gets the time-dependent y component of the vector potential under dipole approximation."
    function LaserAy(l::Cos4Laser)
        local A0 = LaserA0(l); local ω = LaserAngFreq(l); local N = l.cycNum; local φ = l.cep; local ε = l.ellip;
        return function(t)
            A0 * cos(ω*t/(2N))^4 * (abs(ω*t)<N*π) * sin(ω*t+φ) * ε
        end
    end
    "Gets the time-dependent x component of the electric field strength under dipole approximation."
    function LaserFx(l::Cos4Laser)
        local F0 = LaserF0(l); local ω = LaserAngFreq(l); local N = l.cycNum; local φ = l.cep;
        return function(t)
            F0 * cos(ω*t/(2N))^3 * (abs(ω*t)<N*π) * ( cos(ω*t/(2N))*sin(ω*t+φ) + 2/N*sin(ω*t/(2N))*cos(ω*t+φ))
        end
    end
    "Gets the time-dependent y component of the electric field strength under dipole approximation."
    function LaserFy(l::Cos4Laser)
        local F0 = LaserF0(l); local ω = LaserAngFreq(l); local N = l.cycNum; local φ = l.cep; local ε = l.ellip;
        return function(t)
            F0 * cos(ω*t/(2N))^3 * (abs(ω*t)<N*π) * (-cos(ω*t/(2N))*cos(ω*t+φ) + 2/N*sin(ω*t/(2N))*sin(ω*t+φ)) * ε
        end
    end
end

end