using SemiclassicalSFI
using Test

@testset verbose=true "SemiclassicalSFI" begin
    include("PySCFMolecularCalculator_test.jl")
    include("TrajectorySimulation_test.jl")
end
