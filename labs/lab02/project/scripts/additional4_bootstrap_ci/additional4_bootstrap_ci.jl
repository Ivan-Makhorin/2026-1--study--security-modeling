using DrWatson
@quickactivate "project"
using Distributions, Statistics, Random

λ = 5.0
n_hours = 10000
Random.seed!(123)

sample = rand(Poisson(λ), n_hours)
p_hat = mean(sample .> 10)

#= Бутстреп (ручной) =#
B = 1000
boot_estimates = zeros(B)
for b in 1:B
    boot_sample = rand(sample, n_hours)   #= выборка с возвращением =#
    boot_estimates[b] = mean(boot_sample .> 10)
end

ci_lower = quantile(boot_estimates, 0.025)
ci_upper = quantile(boot_estimates, 0.975)

println("Оценка вероятности P(>10): ", p_hat)
println("95% доверительный интервал (бутстреп): [", ci_lower, ", ", ci_upper, "]")

#= Сохраняем результаты =#
using JLD2
@save datadir("bootstrap_ci.jld2") p_hat ci_lower ci_upper boot_estimates
println("Результаты сохранены в data/bootstrap_ci.jld2")
