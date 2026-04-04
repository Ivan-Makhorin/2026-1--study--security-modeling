# # Проверка гипотезы о пуассоновости на реальных данных
# 
# Скрипт ожидает файл data/real_attacks.csv с колонкой timestamp (в секундах).
# Если файл не найден – задание пропускается.
# 

using DrWatson
@quickactivate "project"
using CSV, DataFrames, HypothesisTests, Plots, StatsPlots, Distributions

data_file = datadir("real_attacks.csv")
if !isfile(data_file)
    println("Файл $data_file не найден. Задание 6 пропущено.")
else
    df = CSV.read(data_file, DataFrame)
    #= Предполагаем, что есть колонка :timestamp =#
    times = df.timestamp
    intervals = diff(times) ./ 3600.0   #= переводим в часы =#
    λ_est = 1 / mean(intervals)

    #= QQ-plot =#
    p1 = qqplot(Exponential(1/λ_est), intervals, qqline=:identity,
                title="QQ-plot интервалов (λ_est=$λ_est)")
    savefig(p1, plotsdir("real_data_qqplot.png"))

    #= Критерий Колмогорова-Смирнова =#
    ks_test = ExactOneSampleKSTest(intervals, Exponential(1/λ_est))
    println("p-value критерия Колмогорова-Смирнова: ", pvalue(ks_test))

    #= Гистограмма интервалов =#
    p2 = histogram(intervals, bins=30, normalize=:pdf, label="Эмпирическая плотность")
    x_range = range(0, maximum(intervals), length=100)
    plot!(p2, x_range, pdf.(Exponential(1/λ_est), x_range), lw=2, label="Экспоненциальная")
    savefig(p2, plotsdir("real_data_hist.png"))

    println("Графики сохранены в plots/real_data_qqplot.png и plots/real_data_hist.png")
end