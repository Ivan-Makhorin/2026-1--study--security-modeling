using DrWatson
@quickactivate "project"
using Distributions, DataFrames, CSV, Plots

include(srcdir("simulation.jl"))

λ_values = [2.0, 8.0, 12.0]
T = 24.0
num_hours = 10000

results = []

for λ in λ_values
    hourly = rand(Poisson(λ), num_hours)
    emp_prob = mean(hourly .> 10)
    theor_prob = 1 - cdf(Poisson(λ), 10)
    push!(results, (λ=λ, emp=emp_prob, theor=theor_prob))
end

df = DataFrame(results)
CSV.write(datadir("lambda_comparison.csv"), df)
println("Таблица сохранена в data/lambda_comparison.csv")
println(df)

#= График =#
p = plot(df.λ, [df.theor df.emp],
         label=["Теоретическая" "Эмпирическая"],
         marker=:circle, xlabel="λ", ylabel="P(>10)",
         title="Сравнение интенсивностей")
savefig(p, plotsdir("lambda_comparison.png"))
println("График сохранён в plots/lambda_comparison.png")
