using DrWatson
@quickactivate "project"
using Distributions, Statistics, Plots, StatsPlots, JLD2, Random, CSV, DataFrames

include(srcdir("simulation.jl"))

base_params = Dict(
    :T => 24.0,
    :num_hours_for_est => 10000
)

λ_values = [2.0, 5.0, 8.0, 12.0, 15.0]
Random.seed!(42)

parametric_plots_dir = plotsdir("parameter_sweep")
mkpath(parametric_plots_dir)

summary = Dict{Float64, Dict}()

println("Запуск параметрического исследования...")

for λ in λ_values
    #= Формируем полный набор параметров =#
    params = merge(base_params, Dict(:λ => λ))
    #= Генерируем имя файла на основе параметров =#
    filename = datadir("attack_sim", savename(params, "jld2"))

    if isfile(filename)
        @load filename data
        println("Загружены данные для λ=$λ")
    else
        println("Симуляция для λ=$λ...")
        res = simulate_attacks(λ, params[:T])
        hourly_sample = rand(Poisson(λ), params[:num_hours_for_est])
        emp_prob = count(hourly_sample .> 10) / params[:num_hours_for_est]
        theor_prob = 1 - cdf(Poisson(λ), 10)
        data = Dict(
            :hourly_counts => res.hourly_counts,
            :intervals => res.intervals,
            :attack_times => res.attack_times,
            :emp_prob => emp_prob,
            :theor_prob => theor_prob
        )
        @save filename data
    end

    #= Детальные графики для текущего λ =#
    p1 = histogram(data[:hourly_counts],
                   bins = 0:maximum(data[:hourly_counts]),
                   normalize = :probability,
                   label = "Эмпирическая частота")
    x_vals = 0:maximum(data[:hourly_counts])
    plot!(p1, x_vals, pdf.(Poisson(λ), x_vals),
          line = :stem, marker = :circle,
          label = "Poisson($λ)", lw=2)
    title!(p1, "Число атак за час, λ=$λ")

    p2 = plot(data[:attack_times], 1:length(data[:attack_times]),
              label = "Реализация",
              xlabel = "Время (ч)", ylabel = "Накопленное число атак")
    plot!(p2, 0:0.1:params[:T], λ*(0:0.1:params[:T]),
          label = "Среднее λ·t", ls = :dash)
    title!(p2, "Накопленное число атак (λ=$λ)")

    p3 = histogram(data[:intervals], bins = 30, normalize = :pdf,
                   label = "Эмпирическая плотность")
    x_dens = range(0, maximum(data[:intervals]), length=100)
    plot!(p3, x_dens, pdf.(Exponential(1/λ), x_dens),
          label = "Экспоненциальная плотность", lw=2)
    title!(p3, "Интервалы между атаками (λ=$λ)")

    p4 = qqplot(Exponential(1/λ), data[:intervals], qqline = :identity,
                xlabel = "Теоретические квантили",
                ylabel = "Эмпирические квантили",
                title = "QQ-plot интервалов (λ=$λ)")

    combined = plot(p1, p2, p3, p4, layout = (2,2), size = (1000, 800))
    plot_filename = joinpath(parametric_plots_dir, "attack_sim_λ=$(λ).png")
    savefig(combined, plot_filename)
    println("Детальные графики для λ=$λ сохранены в $plot_filename")

    summary[λ] = Dict(:emp_prob => data[:emp_prob],
                      :theor_prob => data[:theor_prob])
end

summary_filename = datadir("parameter_sweep", "summary_λ_values.jld2")
mkpath(datadir("parameter_sweep"))
@save summary_filename λ_values summary
println("Сводные данные сохранены в $summary_filename")

λs = λ_values
theor_probs = [summary[λ][:theor_prob] for λ in λs]
emp_probs   = [summary[λ][:emp_prob] for λ in λs]

p = plot(λs, [theor_probs emp_probs],
         label = ["Теоретическая P(>10)" "Эмпирическая P(>10)"],
         marker = :circle,
         xlabel = "Интенсивность λ (атак/час)",
         ylabel = "Вероятность P(>10)",
         title = "Зависимость вероятности от интенсивности атак")
global_plot_path = plotsdir("parameter_sweep.png")
savefig(p, global_plot_path)
println("Общий график зависимости сохранён в $global_plot_path")

df = DataFrame(λ = λs, theoretical = theor_probs, empirical = emp_probs)
CSV.write(datadir("parameter_sweep", "summary.csv"), df)
println("Таблица сохранена в ", datadir("parameter_sweep", "summary.csv"))
