using StippleKeplerGL
using Aqua
using Test

##

#=
ambiguities is tested separately since it defaults to recursive=true
but there are packages that have ambiguities that will cause the test
to fail
=#
Aqua.test_ambiguities(StippleKeplerGL; recursive=false) 
Aqua.test_all(StippleKeplerGL; ambiguities=false)

tests = [
        "StippleKeplerGL.jl"
    ]

for test in tests
    @testset "$test" begin
        include(test)
    end
end