using DrWatson
@quickactivate "project"
using Distributions, Statistics, JLD2

include(srcdir("simulation.jl"))

params = Dict(
    :λ => 5.0,                 #= интенсивность (атак/час) =#
    :T => 24.0,                #= период моделирования (часов) =#
    :num_hours_for_est => 10000 #= объём выборки для оценки вероятности =#
)

function run_simulation(p)
    λ = p[:λ]
    T = p[:T]
    num_hours_for_est = p[:num_hours_for_est]
    res = simulate_attacks(λ, T)

    #= Генерируем большую выборку почасовых чисел атак для устойчивой оценки =#
    hourly_sample = rand(Poisson(λ), num_hours_for_est)
    emp_prob = count(hourly_sample .> 10) / num_hours_for_est
    theor_prob = 1 - cdf(Poisson(λ), 10)

    return Dict(
        :hourly_counts => res.hourly_counts,
        :intervals => res.intervals,
        :attack_times => res.attack_times,
        :emp_prob => emp_prob,
        :theor_prob => theor_prob
    )
end

filename = datadir("attack_sim", savename(params, "jld2"))
mkpath(datadir("attack_sim"))

if isfile(filename)
    @load filename data
    println("Загружены существующие данные из $filename")
else
    println("Запуск симуляции...")
    data = run_simulation(params)
    @save filename data
    println("Результаты сохранены в $filename")
end

println("Эмпирическая вероятность P(>10) = ", data[:emp_prob])
println("Теоретическая вероятность = ", data[:theor_prob])
