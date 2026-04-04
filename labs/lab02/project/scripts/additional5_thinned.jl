# # Прореженный пуассоновский поток
# 
# Все атаки генерируются с интенсивностью λ = 5 атак/час.
# Каждая атака успешна с вероятностью p = 0.3.
# Успешные атаки образуют прореженный поток с интенсивностью λ·p.
# 

using DrWatson
@quickactivate "project"
using Plots, Statistics

include(srcdir("simulation_ext.jl"))

λ = 5.0
T = 24.0
p = 0.3

res = simulate_thinned_poisson(λ, T, p)

all_count = length(res.all_times)
success_count = length(res.success_times)
emp_success_rate = success_count / all_count
theor_success_rate = p

println("Всего атак: $all_count")
println("Успешных атак: $success_count")
println("Эмпирическая доля успеха: $emp_success_rate")
println("Теоретическая: $theor_success_rate")

#= Визуализация =#
p1 = plot(res.all_times, 1:all_count, label="Все атаки", xlabel="Время (ч)", ylabel="Накопленное число")
plot!(p1, res.success_times, 1:success_count, label="Успешные", linetype=:steppre)
title!(p1, "Прореженный пуассоновский поток (p=$p)")

if success_count > 1
    success_intervals = diff(res.success_times)
    p2 = histogram(success_intervals, bins=30, normalize=:pdf,
                   label="Эмпирические интервалы", xlabel="Интервал (ч)")
    x_range = range(0, maximum(success_intervals), length=100)
    plot!(p2, x_range, pdf.(Exponential(1/(λ*p)), x_range), lw=2, label="Экспоненциальная (λ*p)")
    title!(p2, "Интервалы между успешными атаками")
    plot(p1, p2, layout=(2,1), size=(800,600))
else
    plot(p1)
end
savefig(plotsdir("thinned_poisson.png"))
println("График сохранён в plots/thinned_poisson.png")